defmodule Mix.Tasks.Npm.Licenses do
  @shortdoc "Show licenses for installed packages"

  @moduledoc """
  List the license of each installed package.

      mix npm.licenses
      mix npm.licenses --summary

  Reads the `license` field from each package's `package.json`.

  ## Options

    * `--summary` — show a count of each license type
  """

  use Mix.Task

  @impl true
  def run(args) do
    Application.ensure_all_started(:req)
    {opts, _, _} = OptionParser.parse(args, strict: [summary: :boolean])

    licenses = collect_licenses("node_modules")

    if opts[:summary] do
      print_summary(licenses)
    else
      print_all(licenses)
    end
  end

  @doc false
  def collect_licenses(node_modules_dir) do
    node_modules_dir
    |> list_packages()
    |> Enum.map(fn name ->
      pkg_json = Path.join([node_modules_dir, name, "package.json"])
      license = read_license(pkg_json)
      {name, license}
    end)
    |> Enum.sort_by(&elem(&1, 0))
  end

  defp print_all(licenses) do
    Enum.each(licenses, fn {name, license} ->
      Mix.shell().info("#{name}: #{license || "UNKNOWN"}")
    end)
  end

  defp print_summary(licenses) do
    licenses
    |> Enum.map(fn {_, license} -> license || "UNKNOWN" end)
    |> Enum.frequencies()
    |> Enum.sort_by(fn {_, count} -> -count end)
    |> Enum.each(fn {license, count} ->
      Mix.shell().info("#{license}: #{count}")
    end)
  end

  defp read_license(path) do
    case File.read(path) do
      {:ok, content} ->
        data = NPM.JSON.decode!(content)
        Map.get(data, "license")

      {:error, _} ->
        nil
    end
  end

  defp list_packages(dir) do
    case File.ls(dir) do
      {:ok, entries} ->
        entries
        |> Enum.reject(&String.starts_with?(&1, "."))
        |> Enum.flat_map(&expand_entry(dir, &1))

      {:error, _} ->
        []
    end
  end

  defp expand_entry(dir, "@" <> _ = scope) do
    case File.ls(Path.join(dir, scope)) do
      {:ok, pkgs} -> Enum.map(pkgs, &"#{scope}/#{&1}")
      {:error, _} -> []
    end
  end

  defp expand_entry(_dir, entry), do: [entry]
end
