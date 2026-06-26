defmodule NPM.Dependency.Sort do
  alias NPM.Dependency.Graph

  @moduledoc """
  Topological sorting of packages for correct install/build order.
  """

  @doc """
  Topologically sorts packages so dependencies come before dependents.
  """
  @spec sort(map()) :: {:ok, [String.t()]} | {:error, :cycle}
  def sort(adj) do
    in_degree = compute_in_degree(adj)

    queue =
      in_degree |> Enum.filter(fn {_, d} -> d == 0 end) |> Enum.map(&elem(&1, 0)) |> Enum.sort()

    topo_sort(adj, in_degree, queue, [])
  end

  @doc """
  Returns install order — topological sort where leaves come first.
  """
  @spec install_order(map()) :: [String.t()]
  def install_order(adj) do
    {:ok, order} = sort(adj)
    Enum.reverse(order)
  end

  @doc """
  Returns build order levels — packages that can be built in parallel.
  """
  @spec parallel_levels(map()) :: [[String.t()]]
  def parallel_levels(adj) do
    rev = Graph.reverse(adj)
    in_degree = compute_in_degree(rev)
    build_levels(rev, in_degree, [])
  end

  @doc """
  Counts the number of levels (maximum parallelism depth).
  """
  @spec level_count(map()) :: non_neg_integer()
  def level_count(adj), do: parallel_levels(adj) |> length()

  defp compute_in_degree(adj) do
    base = Map.new(Map.keys(adj), &{&1, 0})

    Enum.reduce(adj, base, fn {_, deps}, acc ->
      Enum.reduce(deps, acc, fn dep, inner ->
        Map.update(inner, dep, 1, &(&1 + 1))
      end)
    end)
  end

  defp topo_sort(_adj, _in_degree, [], result) do
    {:ok, Enum.reverse(result)}
  end

  defp topo_sort(adj, in_degree, [node | rest], result) do
    deps = Map.get(adj, node, [])

    new_in_degree =
      Enum.reduce(deps, in_degree, fn dep, acc ->
        Map.update!(acc, dep, &(&1 - 1))
      end)

    new_ready =
      deps
      |> Enum.filter(fn dep -> Map.get(new_in_degree, dep) == 0 end)
      |> Enum.sort()

    topo_sort(adj, new_in_degree, Enum.sort(rest ++ new_ready), [node | result])
  end

  defp build_levels(adj, in_degree, levels) do
    ready =
      in_degree |> Enum.filter(fn {_, d} -> d == 0 end) |> Enum.map(&elem(&1, 0)) |> Enum.sort()

    if ready == [] do
      Enum.reverse(levels)
    else
      new_in_degree =
        ready
        |> Enum.reduce(Map.drop(in_degree, ready), &decrement_deps(adj, &1, &2))

      build_levels(adj, new_in_degree, [ready | levels])
    end
  end

  defp decrement_deps(adj, node, in_degree) do
    adj
    |> Map.get(node, [])
    |> Enum.reduce(in_degree, fn dep, acc -> Map.update(acc, dep, 0, &max(&1 - 1, 0)) end)
  end
end
