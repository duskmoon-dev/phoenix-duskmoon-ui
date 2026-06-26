defmodule NPM.SideEffects do
  @moduledoc """
  Analyzes the `sideEffects` field from package.json.

  Used by bundlers (webpack, rollup, esbuild) for tree-shaking.
  """

  @doc """
  Extracts the sideEffects value.
  """
  @spec get(map()) :: boolean() | [String.t()] | nil
  def get(%{"sideEffects" => val}), do: val
  def get(_), do: nil

  @doc """
  Checks if the package is fully tree-shakeable (sideEffects: false).
  """
  @spec tree_shakeable?(map()) :: boolean()
  def tree_shakeable?(%{"sideEffects" => false}), do: true
  def tree_shakeable?(_), do: false

  @doc """
  Checks if the package declares any side effects.
  """
  @spec has_side_effects?(map()) :: boolean()
  def has_side_effects?(%{"sideEffects" => false}), do: false
  def has_side_effects?(%{"sideEffects" => []}), do: false
  def has_side_effects?(_), do: true

  @doc """
  Returns files with side effects (when sideEffects is an array).
  """
  @spec files_with_side_effects(map()) :: [String.t()]
  def files_with_side_effects(%{"sideEffects" => files}) when is_list(files), do: files
  def files_with_side_effects(_), do: []

  @doc """
  Checks if a specific file has side effects.
  """
  @spec file_has_side_effects?(String.t(), map()) :: boolean()
  def file_has_side_effects?(_file, %{"sideEffects" => false}), do: false

  def file_has_side_effects?(file, %{"sideEffects" => patterns}) when is_list(patterns) do
    Enum.any?(patterns, &file_matches?(&1, file))
  end

  def file_has_side_effects?(_, _), do: true

  @doc """
  Counts tree-shakeable packages.
  """
  @spec stats([map()]) :: map()
  def stats(packages) do
    shakeable = Enum.count(packages, &tree_shakeable?/1)
    with_array = Enum.count(packages, &is_list(get(&1)))

    %{
      total: length(packages),
      tree_shakeable: shakeable,
      partial: with_array,
      unknown: length(packages) - shakeable - with_array
    }
  end

  defp file_matches?(pattern, file) do
    if String.contains?(pattern, "*") do
      regex_str = pattern |> Regex.escape() |> String.replace("\\*", ".*")
      Regex.match?(~r/^#{regex_str}$/, file)
    else
      file == pattern
    end
  end
end
