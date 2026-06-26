defmodule NPM.Stats do
  @moduledoc """
  Collects statistics about the project's npm dependencies.

  Provides aggregate insights: package counts, version freshness,
  dependency types, maintainer diversity, etc.
  """

  @type project_stats :: %{
          total_packages: non_neg_integer(),
          direct_deps: non_neg_integer(),
          transitive_deps: non_neg_integer(),
          with_install_scripts: non_neg_integer(),
          avg_dep_count: float(),
          max_dep_chain: non_neg_integer(),
          scoped_packages: non_neg_integer()
        }

  @doc """
  Computes statistics from a lockfile and root dependencies.
  """
  @spec compute(map(), map()) :: project_stats()
  def compute(lockfile, root_deps) do
    direct_names = MapSet.new(Map.keys(root_deps))
    all_names = Map.keys(lockfile)

    dep_counts =
      Enum.map(lockfile, fn {_name, entry} ->
        map_size(entry.dependencies)
      end)

    %{
      total_packages: length(all_names),
      direct_deps: MapSet.size(direct_names),
      transitive_deps:
        length(all_names) - MapSet.size(MapSet.intersection(direct_names, MapSet.new(all_names))),
      with_install_scripts: 0,
      avg_dep_count: safe_avg(dep_counts),
      max_dep_chain: max_chain_depth(lockfile, root_deps),
      scoped_packages: Enum.count(all_names, &String.starts_with?(&1, "@"))
    }
  end

  @doc """
  Computes version distribution across the lockfile.

  Returns a map of major version buckets.
  """
  @spec version_distribution(map()) :: %{String.t() => non_neg_integer()}
  def version_distribution(lockfile) do
    lockfile
    |> Enum.map(fn {_name, entry} -> major_version(entry.version) end)
    |> Enum.frequencies()
    |> Enum.sort_by(&elem(&1, 0))
    |> Map.new()
  end

  @doc """
  Returns the dependency-to-package ratio (how connected the graph is).
  """
  @spec connectivity(map()) :: float()
  def connectivity(lockfile) when map_size(lockfile) == 0, do: 0.0

  def connectivity(lockfile) do
    total_dep_edges =
      Enum.reduce(lockfile, 0, fn {_name, entry}, acc ->
        acc + map_size(entry.dependencies)
      end)

    total_dep_edges / map_size(lockfile)
  end

  @doc """
  Finds the most depended-upon packages (highest fan-in).
  """
  @spec most_depended(map(), non_neg_integer()) :: [{String.t(), non_neg_integer()}]
  def most_depended(lockfile, n \\ 10) do
    lockfile
    |> Enum.flat_map(fn {_name, entry} -> Map.keys(entry.dependencies) end)
    |> Enum.frequencies()
    |> Enum.sort_by(&elem(&1, 1), :desc)
    |> Enum.take(n)
  end

  defp safe_avg([]), do: 0.0
  defp safe_avg(list), do: Enum.sum(list) / length(list)

  defp major_version(version) do
    case String.split(version, ".") do
      [major | _] -> "#{major}.x"
      _ -> "other"
    end
  end

  defp max_chain_depth(lockfile, root_deps) do
    root_deps
    |> Map.keys()
    |> Enum.map(&chain_depth(&1, lockfile, MapSet.new()))
    |> Enum.max(fn -> 0 end)
  end

  defp chain_depth(name, lockfile, visited) do
    cond do
      MapSet.member?(visited, name) -> 0
      not Map.has_key?(lockfile, name) -> 1
      true -> 1 + max_child_depth(lockfile[name], lockfile, MapSet.put(visited, name))
    end
  end

  defp max_child_depth(entry, lockfile, visited) do
    entry.dependencies
    |> Map.keys()
    |> Enum.map(&chain_depth(&1, lockfile, visited))
    |> Enum.max(fn -> 0 end)
  end
end
