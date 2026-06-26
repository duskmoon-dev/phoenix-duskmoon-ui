defmodule NPM.Resolution.Exports do
  @moduledoc """
  Parse and resolve the `exports` field from `package.json`.

  Modern npm packages use the `exports` field (a.k.a. "export map") to
  define entry points and restrict access to internal modules.

  Supports:
  - String shorthand: `"exports": "./index.js"`
  - Subpath exports: `"exports": { ".": "./index.js", "./utils": "./lib/utils.js" }`
  - Conditional exports: `"exports": { "import": "./esm.js", "require": "./cjs.js" }`
  - Nested conditions: `"exports": { ".": { "import": "./esm.js", "default": "./cjs.js" } }`
  """

  @type export_map :: String.t() | [export_map()] | %{String.t() => export_map()} | nil

  @doc """
  Parse the exports field from a package.json map.

  Returns a normalized map of subpath → target mappings, or nil if no exports field.
  """
  @spec parse(map()) :: %{String.t() => String.t() | map()} | nil
  def parse(%{"exports" => exports}) when is_binary(exports) do
    %{"." => exports}
  end

  def parse(%{"exports" => exports}) when is_map(exports) do
    if subpath_exports?(exports) do
      exports
    else
      %{"." => exports}
    end
  end

  def parse(_), do: nil

  @doc """
  Resolve an import path against an export map.

  Given a subpath (e.g. `"."`, `"./utils"`) and a list of conditions
  (e.g. `["import", "default"]`), returns the resolved file path.
  """
  @spec resolve(map(), String.t(), [String.t()]) :: {:ok, String.t()} | :error
  def resolve(export_map, subpath, conditions \\ ["default"]) do
    export_map
    |> candidates(subpath, conditions)
    |> Enum.find_value(:error, &{:ok, &1})
  end

  @doc """
  List all exported subpaths from an export map.
  """
  @spec subpaths(map()) :: [String.t()]
  def subpaths(export_map) when is_map(export_map) do
    Map.keys(export_map) |> Enum.sort()
  end

  def subpaths(_), do: []

  @doc """
  Detect whether a package uses ESM (`type: "module"`) or CJS.
  """
  @spec module_type(map()) :: :esm | :cjs
  def module_type(%{"type" => "module"}), do: :esm
  def module_type(_), do: :cjs

  @doc """
  Checks if a subpath is exported by the export map.
  """
  @spec exported?(String.t(), map() | nil) :: boolean()
  def exported?(_subpath, nil), do: false

  def exported?(subpath, export_map) when is_map(export_map) do
    Map.has_key?(export_map, subpath) or has_wildcard_match?(subpath, export_map)
  end

  def exported?(_, _), do: false

  @doc """
  Extracts all conditions used in the export map.
  """
  @spec conditions(map() | nil) :: [String.t()]
  def conditions(nil), do: []

  def conditions(export_map) when is_map(export_map) do
    export_map
    |> Map.values()
    |> Enum.flat_map(&extract_conditions/1)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Validates that all export paths resolve to existing files.
  """
  @spec validate(map() | nil, String.t()) :: {:ok, [String.t()]} | {:error, [String.t()]}
  def validate(nil, _base_dir), do: {:ok, []}

  def validate(export_map, base_dir) when is_map(export_map) do
    paths = collect_paths(export_map)
    missing = Enum.reject(paths, &File.exists?(Path.join(base_dir, &1)))

    if missing == [],
      do: {:ok, paths},
      else: {:error, Enum.map(missing, &"#{&1} not found")}
  end

  defp subpath_exports?(map) do
    Map.keys(map) |> Enum.any?(&String.starts_with?(&1, "."))
  end

  defp candidates(export_map, subpath, conditions) when is_map(export_map) do
    exact = Map.get(export_map, subpath) |> target_candidates(conditions)

    wildcard =
      export_map
      |> Enum.flat_map(fn {pattern, target} ->
        case wildcard_replacement(pattern, subpath) do
          nil -> []
          replacement -> replace_wildcards(target_candidates(target, conditions), replacement)
        end
      end)

    exact ++ wildcard
  end

  defp candidates(_, _, _), do: []

  defp target_candidates(nil, _conditions), do: []
  defp target_candidates(path, _conditions) when is_binary(path), do: [path]

  defp target_candidates(list, conditions) when is_list(list),
    do: Enum.flat_map(list, &target_candidates(&1, conditions))

  defp target_candidates(target, conditions) when is_map(target) do
    conditions
    |> Enum.flat_map(fn condition ->
      Map.get(target, condition) |> target_candidates(conditions)
    end)
  end

  defp replace_wildcards(paths, replacement) do
    Enum.map(paths, &String.replace(&1, "*", replacement))
  end

  defp wildcard_replacement(pattern, subpath) do
    case String.split(pattern, "*", parts: 2) do
      [prefix, suffix] ->
        if String.starts_with?(subpath, prefix) and String.ends_with?(subpath, suffix) do
          subpath
          |> String.trim_leading(prefix)
          |> trim_suffix(suffix)
        end

      _ ->
        nil
    end
  end

  defp trim_suffix(value, ""), do: value
  defp trim_suffix(value, suffix), do: String.trim_trailing(value, suffix)

  defp has_wildcard_match?(subpath, export_map) do
    Enum.any?(export_map, fn {pattern, _} -> wildcard_matches?(subpath, pattern) end)
  end

  defp wildcard_matches?(subpath, pattern), do: wildcard_replacement(pattern, subpath) != nil

  defp extract_conditions(entry) when is_map(entry),
    do: Map.keys(entry) ++ Enum.flat_map(Map.values(entry), &extract_conditions/1)

  defp extract_conditions(entry) when is_list(entry),
    do: Enum.flat_map(entry, &extract_conditions/1)

  defp extract_conditions(_), do: ["default"]

  defp collect_paths(export_map) do
    export_map
    |> Map.values()
    |> Enum.flat_map(&collect_target_paths/1)
    |> Enum.uniq()
  end

  defp collect_target_paths(value) when is_binary(value), do: [value]

  defp collect_target_paths(value) when is_list(value),
    do: Enum.flat_map(value, &collect_target_paths/1)

  defp collect_target_paths(value) when is_map(value),
    do: value |> Map.values() |> Enum.flat_map(&collect_target_paths/1)

  defp collect_target_paths(_), do: []
end
