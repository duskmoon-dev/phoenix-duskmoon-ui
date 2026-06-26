defmodule NPM.Tree do
  @moduledoc """
  Formats and renders dependency trees for display.

  Provides `npm ls` style tree output from lockfile data.
  """

  @doc """
  Builds a tree structure from a lockfile and root dependencies.

  Returns a nested map representing the dependency tree.
  """
  @spec build(map(), map()) :: map()
  def build(lockfile, root_deps) do
    Map.new(root_deps, fn {name, range} ->
      entry = Map.get(lockfile, name)
      children = if entry, do: build_children(entry, lockfile, MapSet.new([name])), else: %{}
      version = if entry, do: entry.version, else: "MISSING"
      {name, %{version: version, range: range, children: children}}
    end)
  end

  @doc """
  Formats a dependency tree as a string.
  """
  @spec format(map()) :: String.t()
  def format(tree) do
    tree
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map_join("\n", fn {name, node} ->
      format_node(name, node, "")
    end)
  end

  @doc """
  Flattens a tree to a list of all packages with their depths.
  """
  @spec flatten(map(), non_neg_integer()) :: [{String.t(), String.t(), non_neg_integer()}]
  def flatten(tree, depth \\ 0) do
    Enum.flat_map(tree, fn {name, node} ->
      [{name, node.version, depth} | flatten(node.children, depth + 1)]
    end)
  end

  @doc """
  Returns the maximum depth of the tree.
  """
  @spec max_depth(map()) :: non_neg_integer()
  def max_depth(tree) when map_size(tree) == 0, do: 0

  def max_depth(tree) do
    tree
    |> Enum.map(fn {_name, node} -> 1 + max_depth(node.children) end)
    |> Enum.max()
  end

  @doc """
  Counts total packages in the tree (including nested).
  """
  @spec count(map()) :: non_neg_integer()
  def count(tree) do
    Enum.reduce(tree, 0, fn {_name, node}, acc ->
      acc + 1 + count(node.children)
    end)
  end

  @doc """
  Filters the tree to only show packages matching a pattern.
  """
  @spec filter(map(), String.t()) :: map()
  def filter(tree, pattern) do
    regex = Regex.compile!(pattern, "i")

    tree
    |> Enum.flat_map(fn {name, node} ->
      filtered_children = filter(node.children, pattern)

      if Regex.match?(regex, name) or map_size(filtered_children) > 0 do
        [{name, %{node | children: filtered_children}}]
      else
        []
      end
    end)
    |> Map.new()
  end

  defp build_children(entry, lockfile, visited) do
    entry.dependencies
    |> Enum.flat_map(&build_child(&1, lockfile, visited))
    |> Map.new()
  end

  defp build_child({dep_name, range}, lockfile, visited) do
    if MapSet.member?(visited, dep_name) do
      [{dep_name, %{version: "(circular)", range: range, children: %{}}}]
    else
      resolve_child(dep_name, range, lockfile, visited)
    end
  end

  defp resolve_child(dep_name, range, lockfile, visited) do
    case Map.get(lockfile, dep_name) do
      nil ->
        [{dep_name, %{version: "MISSING", range: range, children: %{}}}]

      dep_entry ->
        children = build_children(dep_entry, lockfile, MapSet.put(visited, dep_name))
        [{dep_name, %{version: dep_entry.version, range: range, children: children}}]
    end
  end

  defp format_node(name, node, prefix) do
    line = "#{prefix}#{name}@#{node.version}"

    children =
      node.children
      |> Enum.sort_by(&elem(&1, 0))
      |> Enum.map_join("\n", fn {child_name, child_node} ->
        format_node(child_name, child_node, prefix <> "  ")
      end)

    if children == "", do: line, else: "#{line}\n#{children}"
  end
end
