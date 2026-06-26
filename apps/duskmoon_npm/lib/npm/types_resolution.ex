defmodule NPM.TypesResolution do
  @moduledoc """
  Resolves DefinitelyTyped @types/ packages for TypeScript consumers.

  Maps package names to their corresponding @types/ package names
  and checks if type definitions are needed or already provided.
  """

  @doc """
  Returns the @types/ package name for a given package.
  """
  @spec types_package(String.t()) :: String.t()
  def types_package(name) do
    case name do
      "@" <> scoped ->
        [scope, pkg] = String.split(scoped, "/", parts: 2)
        "@types/#{scope}__#{pkg}"

      _ ->
        "@types/#{name}"
    end
  end

  @doc """
  Checks if a package bundles its own types (has a `types` or `typings` field).
  """
  @spec has_bundled_types?(map()) :: boolean()
  def has_bundled_types?(pkg_data) do
    Map.has_key?(pkg_data, "types") or
      Map.has_key?(pkg_data, "typings") or
      has_types_export?(pkg_data)
  end

  @doc """
  Finds packages that need @types/ definitions.

  Returns packages that don't bundle types and whose @types/ package
  is not in the lockfile.
  """
  @spec missing_types(map(), map(), String.t()) :: [String.t()]
  def missing_types(pkg_data, lockfile, node_modules_dir \\ "node_modules") do
    deps = Map.keys(pkg_data["dependencies"] || %{})

    Enum.filter(deps, fn name ->
      not has_types_in_package?(node_modules_dir, name) and
        not Map.has_key?(lockfile, types_package(name))
    end)
    |> Enum.sort()
  end

  @doc """
  Lists all @types/ packages in the lockfile.
  """
  @spec installed_types(map()) :: [String.t()]
  def installed_types(lockfile) do
    lockfile
    |> Map.keys()
    |> Enum.filter(&String.starts_with?(&1, "@types/"))
    |> Enum.sort()
  end

  @doc """
  Maps installed @types/ packages back to the packages they provide types for.
  """
  @spec types_map(map()) :: %{String.t() => String.t()}
  def types_map(lockfile) do
    installed_types(lockfile)
    |> Map.new(fn types_pkg ->
      original = types_to_original(types_pkg)
      {original, types_pkg}
    end)
  end

  defp has_types_export?(%{"exports" => exports}) when is_map(exports) do
    Enum.any?(exports, fn
      {_key, value} when is_map(value) -> Map.has_key?(value, "types")
      _ -> false
    end)
  end

  defp has_types_export?(_), do: false

  defp has_types_in_package?(nm_dir, name) do
    pkg_json = Path.join([nm_dir, name, "package.json"])

    case File.read(pkg_json) do
      {:ok, content} -> has_bundled_types?(NPM.JSON.decode!(content))
      _ -> false
    end
  rescue
    _ -> false
  end

  defp types_to_original("@types/" <> rest) do
    if String.contains?(rest, "__") do
      [scope, pkg] = String.split(rest, "__", parts: 2)
      "@#{scope}/#{pkg}"
    else
      rest
    end
  end
end
