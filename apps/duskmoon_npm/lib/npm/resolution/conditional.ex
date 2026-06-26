defmodule NPM.Resolution.Conditional do
  @moduledoc """
  Resolves conditional exports/imports from package.json.

  Handles the `exports` and `imports` fields with condition keys like
  `import`, `require`, `default`, `node`, `browser`, `types`.
  """

  @known_conditions ~w(import require default node browser types development production)

  @doc """
  Resolves an export path for given conditions.
  """
  @spec resolve(map() | String.t(), [String.t()]) :: String.t() | nil
  def resolve(path, _conditions) when is_binary(path), do: path

  def resolve(exports, conditions) when is_map(exports) do
    Enum.find_value(conditions ++ ["default"], fn cond_key ->
      case Map.get(exports, cond_key) do
        nil -> nil
        nested when is_map(nested) -> resolve(nested, conditions)
        path when is_binary(path) -> path
      end
    end)
  end

  def resolve(_, _), do: nil

  @doc """
  Returns all conditions used in an exports map.
  """
  @spec conditions(map() | String.t()) :: [String.t()]
  def conditions(path) when is_binary(path), do: []

  def conditions(exports) when is_map(exports) do
    exports
    |> Enum.flat_map(fn {key, val} ->
      nested = if is_map(val), do: conditions(val), else: []
      [key | nested]
    end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  def conditions(_), do: []

  @doc """
  Checks if an exports map uses a specific condition.
  """
  @spec uses_condition?(map(), String.t()) :: boolean()
  def uses_condition?(exports, condition) do
    condition in conditions(exports)
  end

  @doc """
  Returns unknown (non-standard) conditions.
  """
  @spec unknown_conditions(map()) :: [String.t()]
  def unknown_conditions(exports) do
    exports
    |> conditions()
    |> Enum.reject(&(&1 in @known_conditions or String.starts_with?(&1, ".")))
  end

  @doc """
  Lists all known condition names.
  """
  @spec known_conditions :: [String.t()]
  def known_conditions, do: @known_conditions
end
