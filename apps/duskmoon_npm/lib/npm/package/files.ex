defmodule NPM.Package.Files do
  @moduledoc """
  Analyzes which files would be included when publishing a package.

  Uses the `files` field from package.json, default inclusions,
  and .npmignore rules.
  """

  @always_included ~w(package.json README.md README LICENSE LICENCE COPYING CHANGELOG)
  @default_excluded ~w(.git .svn .hg node_modules .npm .DS_Store)

  @doc """
  Returns the files whitelist from package.json.
  """
  @spec whitelist(map()) :: [String.t()] | nil
  def whitelist(%{"files" => files}) when is_list(files), do: files
  def whitelist(_), do: nil

  @doc """
  Checks if a file is always included regardless of `files` field.
  """
  @spec always_included?(String.t()) :: boolean()
  def always_included?(filename) do
    basename = Path.basename(filename)
    upcased = String.upcase(basename)

    Enum.any?(@always_included, fn pattern ->
      upcased == String.upcase(pattern) or
        String.starts_with?(upcased, String.upcase(pattern) <> ".")
    end)
  end

  @doc """
  Checks if a file is always excluded.
  """
  @spec always_excluded?(String.t()) :: boolean()
  def always_excluded?(filename) do
    basename = Path.basename(filename)
    Enum.any?(@default_excluded, &(basename == &1))
  end

  @doc """
  Returns the main entry point.
  """
  @spec main_entry(map()) :: String.t()
  def main_entry(%{"main" => main}) when is_binary(main), do: main
  def main_entry(%{"module" => mod}) when is_binary(mod), do: mod
  def main_entry(_), do: "index.js"

  @doc """
  Lists all entry points (main, module, browser, types, exports).
  """
  @spec entry_points(map()) :: [String.t()]
  def entry_points(data) do
    fields = ~w(main module browser types typings)

    explicit =
      Enum.flat_map(fields, fn field ->
        case Map.get(data, field) do
          val when is_binary(val) -> [val]
          _ -> []
        end
      end)

    (explicit ++ exports_files(data))
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Checks if package.json has a files whitelist.
  """
  @spec has_whitelist?(map()) :: boolean()
  def has_whitelist?(data), do: whitelist(data) != nil

  @doc """
  Returns the list of always-included file patterns.
  """
  @spec default_includes :: [String.t()]
  def default_includes, do: @always_included

  defp exports_files(%{"exports" => exports}) when is_binary(exports), do: [exports]

  defp exports_files(%{"exports" => exports}) when is_map(exports) do
    exports
    |> flatten_exports()
    |> Enum.filter(&is_binary/1)
  end

  defp exports_files(_), do: []

  defp flatten_exports(map) when is_map(map),
    do: Enum.flat_map(map, fn {_, v} -> flatten_exports(v) end)

  defp flatten_exports(val), do: [val]
end
