defmodule NPM.HoistingConflict do
  @moduledoc """
  Detects hoisting conflicts in the dependency tree.

  When multiple packages depend on different versions of the same
  package, only one can be hoisted to the top level.
  """

  @doc """
  Finds packages with conflicting version requirements.
  """
  @spec find(map()) :: [map()]
  def find(lockfile) do
    lockfile
    |> collect_requirements()
    |> Enum.filter(fn {_name, reqs} -> length(reqs) > 1 end)
    |> Enum.map(fn {name, reqs} ->
      versions = Enum.map(reqs, & &1.version) |> Enum.uniq()

      %{
        package: name,
        versions: Enum.sort(versions),
        required_by: Enum.map(reqs, & &1.required_by) |> Enum.sort(),
        conflict: length(versions) > 1
      }
    end)
    |> Enum.filter(& &1.conflict)
    |> Enum.sort_by(& &1.package)
  end

  @doc """
  Counts the number of hoisting conflicts.
  """
  @spec count(map()) :: non_neg_integer()
  def count(lockfile), do: lockfile |> find() |> length()

  @doc """
  Checks if there are any hoisting conflicts.
  """
  @spec conflicts?(map()) :: boolean()
  def conflicts?(lockfile), do: count(lockfile) > 0

  @doc """
  Formats conflict report.
  """
  @spec format_report([map()]) :: String.t()
  def format_report([]), do: "No hoisting conflicts."

  def format_report(conflicts) do
    header = "#{length(conflicts)} hoisting conflicts:\n"

    details =
      Enum.map_join(conflicts, "\n", fn c ->
        versions = Enum.join(c.versions, ", ")
        by = Enum.join(c.required_by, ", ")
        "  #{c.package}: #{versions} (required by: #{by})"
      end)

    header <> details
  end

  defp collect_requirements(lockfile) do
    lockfile
    |> Enum.flat_map(fn {parent, entry} ->
      entry |> extract_deps() |> Enum.flat_map(&resolve_dep(&1, parent, lockfile))
    end)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
  end

  defp resolve_dep({dep_name, range}, parent, lockfile) do
    case Map.get(lockfile, dep_name) do
      %{version: version} -> [{dep_name, %{version: version, required_by: parent, range: range}}]
      _ -> []
    end
  end

  defp extract_deps(%{dependencies: deps}) when is_map(deps), do: Map.to_list(deps)
  defp extract_deps(%{"dependencies" => deps}) when is_map(deps), do: Map.to_list(deps)
  defp extract_deps(_), do: []
end
