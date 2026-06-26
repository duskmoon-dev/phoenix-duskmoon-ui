defmodule Mix.Tasks.Npm.Audit do
  @shortdoc "Check for security vulnerabilities"

  @moduledoc """
  Check installed packages for known security vulnerabilities.

      mix npm.audit
      mix npm.audit --compromised
      mix npm.audit --osv
      mix npm.audit --osv --write-cache
      mix npm.audit --osv --write priv/security/compromised_packages.json
      mix npm.audit --compromised
      mix npm.audit --compromised --db priv/security/compromised_packages.json
      mix npm.audit --compromised --format json

  With no flags, queries the npm registry audit endpoint for vulnerability
  advisories affecting packages in `npm.lock`.

  `--compromised` checks `npm.lock` offline against a local OSV-format malicious
  package database. `--osv` queries OSV.dev for malicious package advisories and
  can optionally write matching advisories to a local database for future offline
  checks.
  """

  use Mix.Task

  alias NPM.Config
  alias NPM.Security.Compromised
  alias NPM.Security.TaskReporter

  @switches [
    compromised: :boolean,
    osv: :boolean,
    db: :string,
    lockfile: :string,
    format: :string,
    policy: :string,
    write: :string,
    write_cache: :boolean
  ]

  @impl true
  def run(args) do
    Application.ensure_all_started(:req)

    {opts, argv, invalid} = OptionParser.parse(args, strict: @switches)

    case {argv, invalid, TaskReporter.parse_format(opts[:format]),
          TaskReporter.parse_policy(opts[:policy])} do
      {[], [], {:ok, format}, {:ok, policy}} -> run_audit(opts, format, policy)
      _ -> Mix.shell().error(usage())
    end
  end

  defp run_audit(opts, format, policy) do
    lockfile_path = opts[:lockfile] || NPM.Lockfile.default_path()

    case NPM.Lockfile.read(lockfile_path) do
      {:ok, lockfile} when lockfile == %{} ->
        Mix.shell().info("No #{lockfile_path} found, run `mix npm.install` first.")

      {:ok, lockfile} ->
        audit_with_options(lockfile, opts, format, policy)

      {:error, reason} ->
        Mix.raise("Failed to read #{lockfile_path}: #{inspect(reason)}")
    end
  end

  defp audit_with_options(lockfile, opts, format, policy) do
    cond do
      opts[:osv] -> audit_osv(lockfile, opts, format, policy)
      opts[:compromised] -> audit_compromised(lockfile, opts, format, policy)
      true -> audit_registry(lockfile)
    end
  end

  defp audit_osv(lockfile, opts, format, policy) do
    case Compromised.check_osv(lockfile) do
      {:ok, findings} ->
        advisories = findings |> Enum.map(& &1.advisory) |> Enum.uniq_by(& &1["id"])

        TaskReporter.report(
          findings,
          format,
          "No malicious OSV advisories found for npm.lock packages.",
          "Found #{length(findings)} malicious OSV advisory matches:"
        )

        maybe_write(write_path(opts), advisories)
        TaskReporter.enforce(findings, policy)

      {:error, reason} ->
        Mix.raise("OSV query failed: #{inspect(reason)}")
    end
  end

  defp audit_compromised(lockfile, opts, format, policy) do
    findings =
      Compromised.check(lockfile,
        sources: [:local],
        db_path: opts[:db] || Config.compromised_db_path()
      )

    TaskReporter.report(
      findings,
      format,
      "No compromised packages found in npm.lock.",
      "Found #{length(findings)} compromised package matches:"
    )

    TaskReporter.enforce(findings, policy)
  end

  defp write_path(opts) do
    cond do
      opts[:write_cache] -> Compromised.cache_path()
      opts[:write] -> opts[:write]
      true -> nil
    end
  end

  defp maybe_write(nil, _advisories), do: :ok

  defp maybe_write(path, advisories) do
    case Compromised.merge_database(path, advisories) do
      {:ok, merged} ->
        Mix.shell().info(
          "Merged #{length(advisories)} OSV advisories into #{path} (#{length(merged)} total)"
        )

      {:error, reason} ->
        Mix.raise("Failed to write OSV advisories to #{path}: #{inspect(reason)}")
    end
  end

  defp audit_registry(lockfile) do
    payload = build_audit_payload(lockfile)
    url = "#{NPM.Registry.registry_url()}/-/npm/v1/security/audits"

    case Req.post(url, json: payload) do
      {:ok, %{status: 200, body: body}} ->
        print_audit_results(body)

      {:ok, %{status: status}} ->
        Mix.shell().info("Audit API returned status #{status}. Checking packages manually...")
        check_deprecated(lockfile)

      {:error, reason} ->
        Mix.shell().error("Audit failed: #{inspect(reason)}")
        check_deprecated(lockfile)
    end
  end

  defp build_audit_payload(lockfile) do
    requires =
      for {name, entry} <- lockfile, into: %{} do
        {name, entry.version}
      end

    dependencies =
      for {name, entry} <- lockfile, into: %{} do
        {name, %{"version" => entry.version}}
      end

    %{
      "name" => "npm-audit",
      "version" => "0.0.0",
      "requires" => requires,
      "dependencies" => dependencies
    }
  end

  defp print_audit_results(%{"advisories" => advisories}) when map_size(advisories) == 0 do
    Mix.shell().info("No known vulnerabilities found.")
  end

  defp print_audit_results(%{"advisories" => advisories}) do
    count = map_size(advisories)
    Mix.shell().info("Found #{count} advisor#{if count == 1, do: "y", else: "ies"}:")

    Enum.each(advisories, fn {_id, advisory} ->
      severity = Map.get(advisory, "severity", "unknown")
      title = Map.get(advisory, "title", "Unknown")
      module_name = Map.get(advisory, "module_name", "?")
      Mix.shell().info("  [#{severity}] #{module_name}: #{title}")
    end)
  end

  defp print_audit_results(_body) do
    Mix.shell().info("No vulnerability data available.")
  end

  defp check_deprecated(lockfile) do
    lockfile
    |> Task.async_stream(
      fn {name, _entry} -> {name, NPM.Registry.get_packument(name)} end,
      max_concurrency: 8,
      timeout: 30_000
    )
    |> Enum.each(fn
      {:ok, {name, {:ok, packument}}} ->
        version = lockfile[name].version
        info = Map.get(packument.versions, version, %{})

        case Map.get(info, :deprecated) do
          msg when is_binary(msg) and msg != "" ->
            Mix.shell().info("  [deprecated] #{name}@#{version}: #{msg}")

          _ ->
            :ok
        end

      _ ->
        :ok
    end)
  end

  defp usage do
    "Usage: mix npm.audit [--compromised | --osv] [--lockfile path] [--db path] [--format text|json] [--policy error|warn|off] [--write path] [--write-cache]"
  end
end
