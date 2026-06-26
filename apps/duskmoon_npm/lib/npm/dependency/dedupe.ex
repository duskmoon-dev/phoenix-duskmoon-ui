defmodule NPM.Dependency.Dedupe do
  @moduledoc """
  Analyzes and deduplicates npm dependency trees.

  Finds packages that appear multiple times in the lockfile (or could
  be hoisted) and suggests which duplicates can be removed. This is the
  logic behind `mix npm.dedupe`.
  """

  @doc """
  Finds packages installed at multiple versions.

  Returns maps with the base package name and sorted distinct versions.
  """
  @spec find(map()) :: [%{name: String.t(), versions: [String.t()]}]
  def find(lockfile) do
    lockfile
    |> Enum.group_by(
      fn {name, _entry} -> base_name(name) end,
      fn {_name, entry} -> entry_version(entry) end
    )
    |> Enum.filter(fn {_name, versions} -> length(Enum.uniq(versions)) > 1 end)
    |> Enum.map(fn {name, versions} ->
      %{name: name, versions: versions |> Enum.uniq() |> Enum.sort()}
    end)
    |> Enum.sort_by(& &1.name)
  end

  @doc """
  Finds packages in the lockfile that could potentially be deduped.

  Returns a list of `{name, versions}` where `versions` is a list of
  version strings for packages that appear in multiple forms.
  """
  @spec find_duplicates(map()) :: [{String.t(), [String.t()]}]
  def find_duplicates(lockfile) do
    lockfile
    |> find()
    |> Enum.map(fn duplicate -> {duplicate.name, duplicate.versions} end)
  end

  @doc """
  Counts package groups installed at multiple versions.
  """
  @spec count(map()) :: non_neg_integer()
  def count(lockfile), do: lockfile |> find() |> length()

  @doc """
  Formats duplicate report for display.
  """
  @spec format_report([%{name: String.t(), versions: [String.t()]}]) :: String.t()
  def format_report([]), do: "No duplicate packages found."

  def format_report(dupes) do
    header = "Duplicate packages (#{length(dupes)}):\n"

    body =
      Enum.map_join(dupes, "\n", fn duplicate ->
        "  #{duplicate.name}: #{Enum.join(duplicate.versions, ", ")}"
      end)

    header <> body
  end

  @doc """
  Returns the number of extra package versions that dedupe could remove.
  """
  @spec potential_savings([%{name: String.t(), versions: [String.t()]}]) :: non_neg_integer()
  def potential_savings(dupes) do
    Enum.sum(Enum.map(dupes, fn duplicate -> length(duplicate.versions) - 1 end))
  end

  @doc """
  Calculates how many bytes could be saved by deduplication.

  This is an estimate based on the number of duplicate package entries.
  """
  @spec savings_estimate(map()) :: %{packages: non_neg_integer(), duplicates: non_neg_integer()}
  def savings_estimate(lockfile) do
    %{packages: map_size(lockfile), duplicates: lockfile |> find() |> potential_savings()}
  end

  @doc """
  Finds the best version of a package that satisfies all dependents.

  Given a package name and a lockfile, looks at all packages that depend
  on it and finds a version (if any) that satisfies all their ranges.
  """
  @spec best_shared_version(String.t(), map()) :: {:ok, String.t()} | :no_common_version
  def best_shared_version(name, lockfile) do
    ranges =
      lockfile
      |> Enum.flat_map(fn {_pkg, entry} ->
        case Map.get(entry.dependencies, name) do
          nil -> []
          range -> [range]
        end
      end)
      |> Enum.uniq()

    case Map.get(lockfile, name) do
      nil ->
        :no_common_version

      entry ->
        if Enum.all?(ranges, &version_satisfies?(entry.version, &1)) do
          {:ok, entry.version}
        else
          :no_common_version
        end
    end
  end

  @doc """
  Returns a summary of the deduplication analysis.
  """
  @spec summary(map()) :: %{
          total_packages: non_neg_integer(),
          unique_packages: non_neg_integer(),
          duplicate_groups: non_neg_integer(),
          saveable: non_neg_integer()
        }
  def summary(lockfile) do
    dupes = find_duplicates(lockfile)
    savings = savings_estimate(lockfile)

    %{
      total_packages: map_size(lockfile),
      unique_packages:
        lockfile |> Enum.map(fn {n, _} -> base_name(n) end) |> Enum.uniq() |> length(),
      duplicate_groups: length(dupes),
      saveable: savings.duplicates
    }
  end

  defp base_name(name) do
    name |> String.split("/node_modules/") |> List.last()
  end

  defp entry_version(%{version: version}), do: version
  defp entry_version(%{"version" => version}), do: version
  defp entry_version(_), do: "unknown"

  defp version_satisfies?(version, range) do
    NPMSemver.matches?(version, range)
  rescue
    _ -> false
  end
end
