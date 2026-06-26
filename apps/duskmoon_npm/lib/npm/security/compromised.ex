defmodule NPM.Security.Compromised do
  @moduledoc """
  Checks lockfiles against known malicious or compromised npm package reports.

  Local reports use the OSV schema used by the OpenSSF malicious-packages
  repository and OSV.dev `MAL-*` advisories. This keeps the default check
  offline and reproducible while allowing callers to supply an updated database
  path through configuration.
  """

  alias NPM.Config
  alias NPM.JSON
  alias NPM.Security.Compromised.OSV

  @type source :: :local | :osv
  @type finding :: %{
          package: String.t(),
          version: String.t(),
          source: source(),
          advisory: map()
        }

  @doc "Check a lockfile map against configured compromised-package sources."
  @spec check(NPM.Lockfile.t(), keyword()) :: [finding()]
  def check(lockfile, opts \\ []) when is_map(lockfile) do
    sources = Keyword.get(opts, :sources, Config.compromised_sources())

    sources
    |> Enum.flat_map(&check_source(lockfile, &1, opts))
    |> sort_findings()
  end

  @doc "Check one package version against configured compromised-package sources."
  @spec check_package(String.t(), String.t(), keyword()) :: [finding()]
  def check_package(name, version, opts \\ []) do
    check(%{name => %{version: version}}, opts)
  end

  @doc "Check a lockfile against OSV.dev and return query errors to the caller."
  @spec check_osv(NPM.Lockfile.t(), keyword()) :: {:ok, [finding()]} | {:error, term()}
  def check_osv(lockfile, opts \\ []) when is_map(lockfile) do
    packages = Enum.map(lockfile, fn {package, entry} -> {package, entry_version(entry)} end)

    case OSV.query_packages(packages, opts) do
      {:ok, advisories_by_package} ->
        findings =
          Enum.flat_map(lockfile, fn {package, entry} ->
            match_advisories(
              %{package => entry},
              Map.get(advisories_by_package, package, []),
              :osv
            )
          end)

        {:ok, sort_findings(findings)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc "Return the shared global cache path for OSV-format compromised-package reports."
  @spec cache_path :: String.t()
  def cache_path, do: Config.compromised_db_path()

  @doc "Read OSV advisory reports from a local JSON database."
  @spec read_database(String.t()) :: {:ok, [map()]} | {:error, term()}
  def read_database(path \\ cache_path()) do
    case JSON.read_file(path) do
      {:ok, data} -> normalize_database(data)
      {:error, :enoent} -> read_bundled_database(path)
      error -> error
    end
  end

  @doc "Write OSV advisory reports to a local JSON database."
  @spec write_database(String.t(), [map()]) :: :ok | {:error, term()}
  def write_database(path, advisories) do
    File.mkdir_p!(Path.dirname(path))
    File.write(path, JSON.encode_pretty(sort_advisories(advisories)))
  end

  @doc "Merge new OSV advisories into an existing local database."
  @spec merge_database(String.t(), [map()]) :: {:ok, [map()]} | {:error, term()}
  def merge_database(path, advisories) do
    with {:ok, existing} <- read_database(path),
         merged = merge_advisories(existing, advisories),
         :ok <- write_database(path, merged) do
      {:ok, merged}
    end
  end

  @doc "Merge advisory lists by OSV id and return stable sorted advisories."
  @spec merge_advisories([map()], [map()]) :: [map()]
  def merge_advisories(existing, new) do
    existing
    |> Kernel.++(new)
    |> Enum.uniq_by(&advisory_key/1)
    |> sort_advisories()
  end

  @doc "Return whether an OSV advisory affects an npm package version."
  @spec affects?(map(), String.t(), String.t()) :: boolean()
  def affects?(advisory, package, version) do
    advisory
    |> Map.get("affected", [])
    |> Enum.any?(&affected_entry?(&1, package, version))
  end

  @doc "Formats compromised-package findings for CLI output."
  @spec format_findings([finding()]) :: [String.t()]
  def format_findings(findings) do
    Enum.map(findings, fn finding ->
      id = finding.advisory["id"] || "unknown"
      summary = finding.advisory["summary"] || "known malicious package"
      "#{finding.package}@#{finding.version} matches #{id}: #{summary}"
    end)
  end

  @doc "Convert a finding to a JSON-encodable map."
  @spec finding_to_json(finding()) :: map()
  def finding_to_json(finding) do
    %{
      "package" => finding.package,
      "version" => finding.version,
      "source" => Atom.to_string(finding.source),
      "advisory" => finding.advisory
    }
  end

  defp check_source(lockfile, :local, opts) do
    path = Keyword.get(opts, :db_path, Config.compromised_db_path())

    case read_database(path) do
      {:ok, advisories} -> match_advisories(lockfile, advisories, :local)
      {:error, :enoent} -> []
      {:error, _reason} -> []
    end
  end

  defp check_source(lockfile, :osv, opts) do
    case Keyword.get(opts, :online?, false) and check_osv(lockfile, opts) do
      {:ok, findings} -> findings
      _ -> []
    end
  end

  defp check_source(_lockfile, _source, _opts), do: []

  defp read_bundled_database(path) do
    bundled_path = Config.bundled_compromised_db_path()

    if path == bundled_path do
      {:error, :enoent}
    else
      read_database(bundled_path)
    end
  end

  defp normalize_database(%{"advisories" => advisories}) when is_list(advisories),
    do: {:ok, advisories}

  defp normalize_database(%{"vulns" => advisories}) when is_list(advisories),
    do: {:ok, advisories}

  defp normalize_database(advisories) when is_list(advisories), do: {:ok, advisories}
  defp normalize_database(_), do: {:error, :invalid_compromised_database}

  defp sort_findings(findings) do
    findings
    |> Enum.uniq_by(fn finding ->
      {finding.source, finding.advisory["id"], finding.package, finding.version}
    end)
    |> Enum.sort_by(fn finding ->
      {finding.package, finding.version, finding.advisory["id"] || ""}
    end)
  end

  defp sort_advisories(advisories) do
    Enum.sort_by(advisories, fn advisory -> advisory["id"] || "" end)
  end

  defp advisory_key(%{"id" => id}) when is_binary(id), do: {:id, id}
  defp advisory_key(advisory), do: {:content, :erlang.phash2(advisory)}

  defp match_advisories(lockfile, advisories, source) do
    for {package, entry} <- lockfile,
        advisory <- advisories,
        version = entry_version(entry),
        affects?(advisory, package, version) do
      %{package: package, version: version, source: source, advisory: advisory}
    end
  end

  defp affected_entry?(
         %{"package" => %{"ecosystem" => ecosystem, "name" => name}} = affected,
         package,
         version
       ) do
    npm_ecosystem?(ecosystem) and name == package and version_affected?(affected, version)
  end

  defp affected_entry?(_affected, _package, _version), do: false

  defp npm_ecosystem?(ecosystem) when is_binary(ecosystem),
    do: String.downcase(ecosystem) == "npm"

  defp npm_ecosystem?(_), do: false

  defp version_affected?(affected, version) do
    explicit_match? = version in Map.get(affected, "versions", [])
    range_match? = affected |> Map.get("ranges", []) |> Enum.any?(&range_affected?(&1, version))

    explicit_match? or range_match? or no_version_constraints?(affected)
  end

  defp no_version_constraints?(affected) do
    Map.get(affected, "versions", []) == [] and Map.get(affected, "ranges", []) == []
  end

  defp range_affected?(%{"type" => type, "events" => events}, version)
       when is_binary(type) and is_list(events) do
    String.upcase(type) == "ECOSYSTEM" and events_match?(events, version)
  end

  defp range_affected?(_range, _version), do: false

  defp events_match?(events, version) do
    events
    |> Enum.chunk_while(nil, &range_event/2, &range_after/1)
    |> Enum.any?(&version_in_range?(version, &1))
  end

  defp range_event(%{"introduced" => introduced}, nil), do: {:cont, %{introduced: introduced}}
  defp range_event(%{"introduced" => introduced}, _range), do: {:cont, %{introduced: introduced}}

  defp range_event(%{"fixed" => fixed}, range),
    do: {:cont, Map.put(range || %{}, :fixed, fixed), nil}

  defp range_event(_event, range), do: {:cont, range}

  defp range_after(nil), do: {:cont, []}
  defp range_after(range), do: {:cont, range, nil}

  defp version_in_range?(version, %{introduced: introduced, fixed: fixed}) do
    NPMSemver.matches?(version, ">=#{normalize_version(introduced)} <#{fixed}")
  rescue
    _ -> false
  end

  defp version_in_range?(version, %{introduced: introduced}) do
    NPMSemver.matches?(version, ">=#{normalize_version(introduced)}")
  rescue
    _ -> false
  end

  defp version_in_range?(version, %{fixed: fixed}) do
    NPMSemver.matches?(version, "<#{fixed}")
  rescue
    _ -> false
  end

  defp version_in_range?(_version, _range), do: false

  defp entry_version(%{version: version}), do: version
  defp entry_version(%{"version" => version}), do: version

  defp normalize_version("0"), do: "0.0.0"
  defp normalize_version(version), do: version
end
