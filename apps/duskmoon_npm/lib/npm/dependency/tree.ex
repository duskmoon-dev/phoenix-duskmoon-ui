defmodule NPM.Dependency.Tree do
  @moduledoc """
  Build and query a dependency tree from the lockfile.

  Provides a structured view of the dependency graph, useful
  for `mix npm.tree`, `mix npm.why`, and deduplication.
  """

  @type tree_node :: %{
          name: String.t(),
          version: String.t(),
          children: [tree_node()]
        }

  @doc """
  Build a dependency tree from the lockfile.

  Returns a list of root-level nodes, each with their transitive
  dependencies as children.
  """
  @spec build(%{String.t() => NPM.Lockfile.entry()}, %{String.t() => String.t()}) :: [tree_node()]
  def build(lockfile, root_deps) do
    root_deps
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map(fn {name, _range} -> build_node(name, lockfile, MapSet.new()) end)
    |> Enum.reject(&is_nil/1)
  end

  @doc """
  Flatten the tree into a list of all package names.
  """
  @spec flatten([tree_node()]) :: [String.t()]
  def flatten(nodes) do
    nodes
    |> Enum.flat_map(fn node -> [node.name | flatten(node.children)] end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Find all paths from root to a target package.
  """
  @spec paths_to([tree_node()], String.t()) :: [[String.t()]]
  def paths_to(nodes, target) do
    Enum.flat_map(nodes, &find_paths(&1, target, []))
  end

  @doc """
  Get the depth of a package in the tree (0 = root dep).
  """
  @spec depth([tree_node()], String.t()) :: non_neg_integer() | nil
  def depth(nodes, target) do
    case paths_to(nodes, target) do
      [] -> nil
      paths -> paths |> Enum.map(&(length(&1) - 1)) |> Enum.min()
    end
  end

  @doc """
  Count total unique packages in the tree.
  """
  @spec count([tree_node()]) :: non_neg_integer()
  def count(nodes), do: flatten(nodes) |> length()

  defp build_node(name, lockfile, visited) do
    if MapSet.member?(visited, name),
      do: nil,
      else: do_build_node(name, lockfile, visited)
  end

  defp do_build_node(name, lockfile, visited) do
    case Map.get(lockfile, name) do
      nil ->
        nil

      entry ->
        children = build_children(entry.dependencies, lockfile, MapSet.put(visited, name))
        %{name: name, version: entry.version, children: children}
    end
  end

  defp build_children(deps, lockfile, visited) do
    deps
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map(fn {dep_name, _} -> build_node(dep_name, lockfile, visited) end)
    |> Enum.reject(&is_nil/1)
  end

  defp find_paths(node, target, path) do
    current_path = path ++ [node.name]

    own = if node.name == target, do: [current_path], else: []

    child_paths = Enum.flat_map(node.children, &find_paths(&1, target, current_path))

    own ++ child_paths
  end
end
