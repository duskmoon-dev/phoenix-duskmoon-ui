defmodule NPM.TreeFormat do
  @moduledoc """
  Formats dependency trees for terminal display.
  """

  @doc """
  Formats a flat dependency map as a tree string.
  """
  @spec format(map(), keyword()) :: String.t()
  def format(lockfile, opts \\ []) do
    depth = Keyword.get(opts, :depth, :infinity)
    root = Keyword.get(opts, :root, "project")

    lines = lockfile |> Map.keys() |> Enum.sort() |> format_children(lockfile, "", depth, 0)
    Enum.join([root | lines], "\n")
  end

  @doc """
  Formats a single package entry with version.
  """
  @spec format_entry(String.t(), map()) :: String.t()
  def format_entry(name, %{version: version}), do: "#{name}@#{version}"
  def format_entry(name, %{"version" => version}), do: "#{name}@#{version}"
  def format_entry(name, _), do: name

  @doc """
  Counts the total packages in the tree.
  """
  @spec count(map()) :: non_neg_integer()
  def count(lockfile), do: map_size(lockfile)

  @doc """
  Returns max depth of the dependency tree.
  """
  @spec max_depth(map()) :: non_neg_integer()
  def max_depth(lockfile) when map_size(lockfile) == 0, do: 0

  def max_depth(lockfile) do
    has_sub_deps = Enum.any?(lockfile, fn {_, entry} -> dep_count(entry) > 0 end)
    if has_sub_deps, do: 2, else: 1
  end

  @doc """
  Formats dependency count summary.
  """
  @spec summary(map()) :: String.t()
  def summary(lockfile) do
    total = count(lockfile)
    direct = Enum.count(lockfile, fn {_, entry} -> dep_count(entry) == 0 end)
    "#{total} packages (#{direct} leaf, #{total - direct} with sub-deps)"
  end

  defp format_children(names, lockfile, prefix, max_depth, current_depth) do
    last_idx = length(names) - 1

    names
    |> Enum.with_index()
    |> Enum.flat_map(fn {name, idx} ->
      is_last = idx == last_idx
      connector = if is_last, do: "└── ", else: "├── "
      child_prefix = if is_last, do: "    ", else: "│   "
      entry = Map.get(lockfile, name, %{})
      line = "#{prefix}#{connector}#{format_entry(name, entry)}"

      children = sub_dep_names(entry)

      if children != [] and depth_ok?(max_depth, current_depth) do
        [
          line
          | format_children(
              children,
              lockfile,
              prefix <> child_prefix,
              max_depth,
              current_depth + 1
            )
        ]
      else
        [line]
      end
    end)
  end

  defp sub_dep_names(%{dependencies: deps}) when is_map(deps), do: Map.keys(deps) |> Enum.sort()

  defp sub_dep_names(%{"dependencies" => deps}) when is_map(deps),
    do: Map.keys(deps) |> Enum.sort()

  defp sub_dep_names(_), do: []

  defp dep_count(entry), do: entry |> sub_dep_names() |> length()

  defp depth_ok?(:infinity, _), do: true
  defp depth_ok?(max, current), do: current < max
end
