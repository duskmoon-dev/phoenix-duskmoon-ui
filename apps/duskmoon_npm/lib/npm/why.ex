defmodule NPM.Why do
  @moduledoc """
  Explains why a package is installed by tracing through the dependency tree.

  Implements the `npm why` / `npm explain` functionality.
  """

  @type reason :: %{
          path: [String.t()],
          range: String.t() | nil,
          direct: boolean()
        }

  @doc """
  Explains why a package is in the lockfile.

  Returns a list of dependency paths that lead to the given package.
  Each path is a list of package names from root to the target.
  """
  @spec explain(String.t(), map(), map()) :: [reason()]
  def explain(target, lockfile, root_deps) do
    direct_reasons = direct_reasons(target, root_deps)
    transitive_reasons = transitive_reasons(target, lockfile, root_deps)
    direct_reasons ++ transitive_reasons
  end

  @doc """
  Returns a human-readable explanation string.
  """
  @spec format_reasons([reason()]) :: String.t()
  def format_reasons([]), do: "Package is not installed."

  def format_reasons(reasons) do
    Enum.map_join(reasons, "\n", &format_reason/1)
  end

  @doc """
  Checks if a package is a direct dependency.
  """
  @spec direct?(String.t(), map()) :: boolean()
  def direct?(name, root_deps) do
    Map.has_key?(root_deps, name)
  end

  @doc """
  Finds all packages that directly depend on the target.
  """
  @spec dependents(String.t(), map()) :: [String.t()]
  def dependents(target, lockfile) do
    lockfile
    |> Enum.filter(fn {_name, entry} ->
      Map.has_key?(entry.dependencies, target)
    end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sort()
  end

  defp direct_reasons(target, root_deps) do
    case Map.get(root_deps, target) do
      nil -> []
      range -> [%{path: [target], range: range, direct: true}]
    end
  end

  defp transitive_reasons(target, lockfile, root_deps) do
    lockfile
    |> Enum.filter(fn {_name, entry} ->
      Map.has_key?(entry.dependencies, target)
    end)
    |> Enum.flat_map(fn {parent, entry} ->
      range = entry.dependencies[target]

      parent_paths =
        if Map.has_key?(root_deps, parent) do
          [[parent, target]]
        else
          find_paths_to(parent, lockfile, root_deps, MapSet.new([target]))
          |> Enum.map(&(&1 ++ [target]))
        end

      Enum.map(parent_paths, fn path ->
        %{path: path, range: range, direct: false}
      end)
    end)
  end

  defp find_paths_to(target, lockfile, root_deps, visited) do
    if Map.has_key?(root_deps, target) do
      [[target]]
    else
      lockfile
      |> Enum.filter(fn {name, entry} ->
        Map.has_key?(entry.dependencies, target) and
          not MapSet.member?(visited, name)
      end)
      |> Enum.flat_map(fn {parent, _entry} ->
        find_paths_to(parent, lockfile, root_deps, MapSet.put(visited, parent))
        |> Enum.map(&(&1 ++ [target]))
      end)
    end
  end

  defp format_reason(%{path: path, range: range, direct: true}) do
    "#{hd(path)}@#{range} (direct dependency)"
  end

  defp format_reason(%{path: path, range: range}) do
    chain = Enum.join(path, " → ")
    last = path |> Enum.reverse() |> hd()
    "#{chain} (requires #{last}@#{range})"
  end
end
