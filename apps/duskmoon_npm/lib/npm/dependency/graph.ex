defmodule NPM.Dependency.Graph do
  @moduledoc """
  Dependency graph operations on the lockfile.

  Provides adjacency-list based graph algorithms for analyzing
  the dependency structure: detecting cycles, computing fan-in/out,
  and finding orphans.
  """

  @doc """
  Build an adjacency list from the lockfile.

  Returns `%{name => [dep_name, ...]}`.
  """
  @spec adjacency_list(%{String.t() => NPM.Lockfile.entry()}) :: %{String.t() => [String.t()]}
  def adjacency_list(lockfile) do
    Map.new(lockfile, fn {name, entry} ->
      {name, Map.keys(entry.dependencies) |> Enum.sort()}
    end)
  end

  @doc """
  Compute fan-out (number of dependencies) for each package.
  """
  @spec fan_out(%{String.t() => [String.t()]}) :: %{String.t() => non_neg_integer()}
  def fan_out(adj) do
    Map.new(adj, fn {name, deps} -> {name, length(deps)} end)
  end

  @doc """
  Compute fan-in (number of dependents) for each package.
  """
  @spec fan_in(%{String.t() => [String.t()]}) :: %{String.t() => non_neg_integer()}
  def fan_in(adj) do
    all_names = Map.keys(adj)
    base = Map.new(all_names, &{&1, 0})

    Enum.reduce(adj, base, fn {_name, deps}, acc ->
      Enum.reduce(deps, acc, fn dep, inner_acc ->
        Map.update(inner_acc, dep, 1, &(&1 + 1))
      end)
    end)
  end

  @doc """
  Find leaf packages (no dependencies).
  """
  @spec leaves(%{String.t() => [String.t()]}) :: [String.t()]
  def leaves(adj) do
    adj
    |> Enum.filter(fn {_, deps} -> deps == [] end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sort()
  end

  @doc """
  Find root packages (not depended on by any other package).
  """
  @spec roots(%{String.t() => [String.t()]}) :: [String.t()]
  def roots(adj) do
    all_deps = adj |> Map.values() |> List.flatten() |> MapSet.new()
    adj |> Map.keys() |> Enum.reject(&MapSet.member?(all_deps, &1)) |> Enum.sort()
  end

  @doc """
  Detect circular dependencies. Returns list of cycle paths.

  Uses Erlang's `:digraph_utils` for reliable cycle detection.
  """
  @spec cycles(%{String.t() => [String.t()]}) :: [[String.t()]]
  def cycles(adj) do
    g = :digraph.new()

    try do
      Enum.each(adj, fn {name, _} -> :digraph.add_vertex(g, name) end)

      Enum.each(adj, fn {name, deps} ->
        Enum.each(deps, fn dep ->
          :digraph.add_vertex(g, dep)
          :digraph.add_edge(g, name, dep)
        end)
      end)

      components = :digraph_utils.cyclic_strong_components(g)

      components
      |> Enum.filter(fn component ->
        length(component) > 1 or self_loop?(g, component)
      end)
      |> Enum.map(&Enum.sort/1)
      |> Enum.uniq()
    after
      :digraph.delete(g)
    end
  end

  @doc """
  Compute the transitive closure — all reachable packages from a root.
  """
  @spec transitive_deps(%{String.t() => [String.t()]}, String.t()) :: MapSet.t(String.t())
  def transitive_deps(adj, root) do
    walk(adj, [root], MapSet.new())
  end

  @doc """
  Find the shortest path between two packages.
  """
  @spec shortest_path(%{String.t() => [String.t()]}, String.t(), String.t()) :: [String.t()] | nil
  def shortest_path(adj, from, to) do
    bfs(adj, [{[from]}], MapSet.new([from]), to)
  end

  @doc """
  Compute the maximum dependency depth from a package.
  """
  @spec max_depth(%{String.t() => [String.t()]}, String.t()) :: non_neg_integer()
  def max_depth(adj, root) do
    depth(adj, root, MapSet.new())
  end

  @doc """
  Compute impact score — how many packages transitively depend on a package.
  """
  @spec impact(%{String.t() => [String.t()]}, String.t()) :: non_neg_integer()
  def impact(adj, package) do
    reverse = reverse(adj)

    if Map.has_key?(reverse, package) do
      reverse |> transitive_deps(package) |> MapSet.size()
    else
      0
    end
  end

  @doc """
  Reverse the graph so all edges point from dependencies to dependents.
  """
  @spec reverse(%{String.t() => [String.t()]}) :: %{String.t() => [String.t()]}
  def reverse(adj) do
    base = Map.new(Map.keys(adj), &{&1, []})

    Enum.reduce(adj, base, fn {name, deps}, acc ->
      Enum.reduce(deps, acc, fn dep, inner ->
        Map.update(inner, dep, [name], &[name | &1])
      end)
    end)
  end

  defp walk(_adj, [], visited), do: visited

  defp walk(adj, [node | rest], visited) do
    deps = Map.get(adj, node, [])
    new_deps = Enum.reject(deps, &MapSet.member?(visited, &1))
    walk(adj, new_deps ++ rest, MapSet.union(visited, MapSet.new(new_deps)))
  end

  defp bfs(_adj, [], _visited, _target), do: nil

  defp bfs(adj, [{path} | rest], visited, target) do
    current = hd(path)

    if current == target do
      Enum.reverse(path)
    else
      neighbors = Map.get(adj, current, [])

      new_paths =
        for neighbor <- neighbors, not MapSet.member?(visited, neighbor), do: {[neighbor | path]}

      new_visited = MapSet.union(visited, MapSet.new(Enum.map(neighbors, & &1)))
      bfs(adj, rest ++ new_paths, new_visited, target)
    end
  end

  defp depth(adj, node, visited) do
    if MapSet.member?(visited, node) do
      0
    else
      deps = Map.get(adj, node, [])
      new_visited = MapSet.put(visited, node)

      case deps do
        [] -> 0
        _ -> 1 + (deps |> Enum.map(&depth(adj, &1, new_visited)) |> Enum.max())
      end
    end
  end

  defp self_loop?(g, [v]) do
    Enum.any?(:digraph.out_edges(g, v), fn edge ->
      {_, ^v, ^v, _} = :digraph.edge(g, edge)
      true
    end)
  rescue
    _ -> false
  end

  defp self_loop?(_, _), do: false
end
