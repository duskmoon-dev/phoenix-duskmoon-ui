defmodule NPM.Dependency.Phantom do
  @moduledoc """
  Detects phantom (undeclared) dependencies.

  A phantom dependency is one that can be required in code but is not
  declared in package.json — it only works because another package
  depends on it and it gets hoisted.
  """

  @doc """
  Finds packages in node_modules that aren't declared in package.json.
  """
  @spec detect(map(), map()) :: [String.t()]
  def detect(pkg_data, lockfile) do
    declared = declared_deps(pkg_data)

    lockfile
    |> Map.keys()
    |> Enum.reject(&MapSet.member?(declared, &1))
    |> Enum.sort()
  end

  @doc """
  Counts phantom dependencies.
  """
  @spec count(map(), map()) :: non_neg_integer()
  def count(pkg_data, lockfile), do: detect(pkg_data, lockfile) |> length()

  @doc """
  Checks if a specific package is a phantom dependency.
  """
  @spec phantom?(String.t(), map()) :: boolean()
  def phantom?(name, pkg_data) do
    not MapSet.member?(declared_deps(pkg_data), name)
  end

  @doc """
  Formats a report of phantom dependencies.
  """
  @spec format_report([String.t()]) :: String.t()
  def format_report([]), do: "No phantom dependencies detected."

  def format_report(phantoms) do
    header = "#{length(phantoms)} phantom dependencies (undeclared but available):\n"
    list = Enum.map_join(phantoms, "\n", &"  #{&1}")
    header <> list
  end

  defp declared_deps(pkg_data) do
    ~w(dependencies devDependencies optionalDependencies peerDependencies)
    |> Enum.flat_map(fn field ->
      case Map.get(pkg_data, field) do
        deps when is_map(deps) -> Map.keys(deps)
        _ -> []
      end
    end)
    |> MapSet.new()
  end
end
