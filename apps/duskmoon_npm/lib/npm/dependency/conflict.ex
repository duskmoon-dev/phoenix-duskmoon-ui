defmodule NPM.Dependency.Conflict do
  @moduledoc """
  Detects version conflicts between dependency groups.

  Finds packages that appear in multiple groups (dependencies,
  devDependencies, etc.) with different version ranges.
  """

  @dep_fields ~w(dependencies devDependencies peerDependencies optionalDependencies)

  @doc """
  Finds packages with conflicting ranges across dependency groups.
  """
  @spec find(map()) :: [map()]
  def find(pkg_data) do
    all_entries = collect_entries(pkg_data)

    all_entries
    |> Enum.group_by(& &1.name)
    |> Enum.flat_map(fn {name, entries} ->
      ranges = entries |> Enum.map(& &1.range) |> Enum.uniq()

      if length(ranges) > 1 do
        [%{name: name, entries: entries, ranges: ranges}]
      else
        []
      end
    end)
    |> Enum.sort_by(& &1.name)
  end

  @doc """
  Checks if there are any conflicts.
  """
  @spec conflicts?(map()) :: boolean()
  def conflicts?(pkg_data), do: find(pkg_data) != []

  @doc """
  Counts conflicts.
  """
  @spec count(map()) :: non_neg_integer()
  def count(pkg_data), do: find(pkg_data) |> length()

  @doc """
  Finds packages that appear in multiple groups (even with same range).
  """
  @spec duplicated(map()) :: [%{name: String.t(), groups: [String.t()]}]
  def duplicated(pkg_data) do
    all_entries = collect_entries(pkg_data)

    all_entries
    |> Enum.group_by(& &1.name)
    |> Enum.filter(fn {_name, entries} -> match?([_, _ | _], entries) end)
    |> Enum.map(fn {name, entries} -> %{name: name, groups: Enum.map(entries, & &1.group)} end)
    |> Enum.sort_by(& &1.name)
  end

  @doc """
  Formats conflict report.
  """
  @spec format([map()]) :: String.t()
  def format([]), do: "No version conflicts."

  def format(conflicts) do
    Enum.map_join(conflicts, "\n", fn c ->
      ranges = Enum.map_join(c.entries, ", ", fn e -> "#{e.group}: #{e.range}" end)
      "#{c.name}: #{ranges}"
    end)
  end

  defp collect_entries(pkg_data) do
    Enum.flat_map(@dep_fields, &entries_for_field(pkg_data, &1))
  end

  defp entries_for_field(pkg_data, field) do
    case Map.get(pkg_data, field) do
      deps when is_map(deps) ->
        Enum.map(deps, fn {name, range} -> %{name: name, range: range, group: field} end)

      _ ->
        []
    end
  end
end
