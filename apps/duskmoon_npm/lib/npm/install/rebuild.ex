defmodule NPM.Install.Rebuild do
  @moduledoc """
  Detects packages needing native rebuilds.

  Identifies packages with install scripts, binding.gyp files,
  or other indicators that they contain native addons.
  """

  @native_indicators ["binding.gyp", "CMakeLists.txt", "Makefile"]

  @doc """
  Scans node_modules for packages with native addons.
  """
  @spec scan(String.t()) :: [map()]
  def scan(node_modules_dir \\ "node_modules") do
    case File.ls(node_modules_dir) do
      {:ok, entries} ->
        entries
        |> Enum.reject(&String.starts_with?(&1, "."))
        |> Enum.flat_map(&scan_entry(node_modules_dir, &1))
        |> Enum.sort_by(& &1.name)

      _ ->
        []
    end
  end

  @doc """
  Checks if a specific package has native components.
  """
  @spec native?(String.t(), String.t()) :: boolean()
  def native?(package_dir, name \\ "") do
    has_native_files?(package_dir) or has_install_script?(package_dir, name)
  end

  @doc """
  Returns the list of packages that need rebuild after Node.js upgrade.
  """
  @spec needs_rebuild(String.t()) :: [String.t()]
  def needs_rebuild(node_modules_dir \\ "node_modules") do
    scan(node_modules_dir)
    |> Enum.map(& &1.name)
  end

  @doc """
  Formats scan results for display.
  """
  @spec format_results([map()]) :: String.t()
  def format_results([]), do: "No native addons found."

  def format_results(packages) do
    header = "Native addons (#{length(packages)}):\n"
    body = Enum.map_join(packages, "\n", &"  #{&1.name} — #{&1.reason}")
    header <> body
  end

  defp scan_entry(nm_dir, entry) do
    if String.starts_with?(entry, "@") do
      scan_scoped(nm_dir, entry)
    else
      check_native(nm_dir, entry, entry)
    end
  end

  defp scan_scoped(nm_dir, scope) do
    scope_dir = Path.join(nm_dir, scope)

    case File.ls(scope_dir) do
      {:ok, subs} -> Enum.flat_map(subs, &check_native(scope_dir, &1, "#{scope}/#{&1}"))
      _ -> []
    end
  end

  defp check_native(parent, entry, full_name) do
    pkg_dir = Path.join(parent, entry)

    cond do
      has_native_files?(pkg_dir) ->
        [%{name: full_name, reason: "has native build files"}]

      has_install_script?(pkg_dir, full_name) ->
        [%{name: full_name, reason: "has install script"}]

      true ->
        []
    end
  end

  defp has_native_files?(pkg_dir) do
    Enum.any?(@native_indicators, &File.exists?(Path.join(pkg_dir, &1)))
  end

  defp has_install_script?(pkg_dir, _name) do
    pkg_json = Path.join(pkg_dir, "package.json")

    case File.read(pkg_json) do
      {:ok, content} ->
        data = NPM.JSON.decode!(content)
        scripts = data["scripts"] || %{}
        Map.has_key?(scripts, "install") or Map.has_key?(scripts, "postinstall")

      _ ->
        false
    end
  rescue
    _ -> false
  end
end
