defmodule NPM.Dependency.UsageCheck do
  @moduledoc """
  Detects unused and missing dependencies in a project.

  Scans source files for `require()` and `import` statements,
  then compares against declared dependencies.
  """

  @type check_result :: %{
          unused: [String.t()],
          missing: [String.t()]
        }

  @doc """
  Analyzes a project for unused and missing dependencies.
  """
  @spec check(String.t()) :: {:ok, check_result()} | {:error, term()}
  def check(project_dir) do
    pkg_path = Path.join(project_dir, "package.json")

    case NPM.JSON.read_file(pkg_path) do
      {:ok, data} when is_map(data) ->
        declared = extract_declared(data)
        used = scan_imports(project_dir)

        {:ok,
         %{
           unused: find_unused(declared, used),
           missing: find_missing(declared, used)
         }}

      {:ok, _} ->
        {:error, :invalid_package_json}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Extracts package names from require/import statements in source code.
  """
  @spec extract_imports(String.t()) :: [String.t()]
  def extract_imports(source) do
    require_pattern = ~r/require\s*\(\s*['"]([^'"\.][^'"]*)['"]\s*\)/
    import_pattern = ~r/(?:import|export)\s+.*?from\s+['"]([^'"\.][^'"]*)['"]/
    dynamic_pattern = ~r/import\s*\(\s*['"]([^'"\.][^'"]*)['"]\s*\)/

    [require_pattern, import_pattern, dynamic_pattern]
    |> Enum.flat_map(&Regex.scan(&1, source))
    |> Enum.map(&List.last/1)
    |> Enum.map(&normalize_package_name/1)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Normalizes a module specifier to a package name.

  Handles scoped packages and deep imports.
  """
  @spec normalize_package_name(String.t()) :: String.t()
  def normalize_package_name("@" <> rest) do
    case String.split(rest, "/", parts: 3) do
      [scope, name | _] -> "@#{scope}/#{name}"
      [scope] -> "@#{scope}"
    end
  end

  def normalize_package_name(name) do
    name |> String.split("/", parts: 2) |> hd()
  end

  @doc """
  Scans JS/TS source files in a directory for imports.
  """
  @spec scan_imports(String.t()) :: MapSet.t()
  def scan_imports(project_dir) do
    source_dirs = ["src", "lib", "app", "pages", "components"]

    source_dirs
    |> Enum.flat_map(fn dir ->
      full = Path.join(project_dir, dir)
      if File.dir?(full), do: scan_directory(full), else: []
    end)
    |> Enum.into(MapSet.new())
  end

  defp extract_declared(data) do
    deps = data["dependencies"] || %{}
    dev_deps = data["devDependencies"] || %{}
    Map.keys(deps) ++ Map.keys(dev_deps)
  end

  defp find_unused(declared, used) do
    declared
    |> Enum.reject(&MapSet.member?(used, &1))
    |> Enum.sort()
  end

  defp find_missing(declared, used) do
    declared_set = MapSet.new(declared)

    used
    |> MapSet.to_list()
    |> Enum.reject(&(MapSet.member?(declared_set, &1) or builtin?(&1)))
    |> Enum.sort()
  end

  @node_builtins ~w(fs path http https os url util crypto stream events buffer net child_process cluster dgram dns readline tls vm zlib assert)

  defp builtin?(name), do: name in @node_builtins or String.starts_with?(name, "node:")

  defp scan_directory(dir) do
    case File.ls(dir) do
      {:ok, entries} -> Enum.flat_map(entries, &scan_entry(dir, &1))
      _ -> []
    end
  end

  @js_extensions ~w(.js .jsx .ts .tsx .mjs .cjs)

  defp scan_entry(dir, entry) do
    path = Path.join(dir, entry)

    cond do
      File.dir?(path) -> scan_directory(path)
      Path.extname(entry) in @js_extensions -> scan_file(path)
      true -> []
    end
  end

  defp scan_file(path) do
    case File.read(path) do
      {:ok, content} -> extract_imports(content)
      _ -> []
    end
  end
end
