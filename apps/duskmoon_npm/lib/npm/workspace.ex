defmodule NPM.Workspace do
  @moduledoc """
  Workspace management for npm monorepos.

  Handles discovery and resolution of workspace packages defined
  in the root `package.json` via the `workspaces` field.
  """

  @doc """
  Discovers workspace packages from the root package.json.

  Reads the `workspaces` field and resolves glob patterns to actual
  package directories. Returns a list of workspace info maps.
  """
  @spec discover(String.t()) :: {:ok, [map()]} | {:error, term()}
  def discover(root_dir \\ ".") do
    pkg_path = Path.join(root_dir, "package.json")

    with {:ok, workspaces} <- NPM.Package.JSON.read_workspaces(pkg_path),
         packages <- resolve_workspaces(workspaces, root_dir) do
      {:ok, packages}
    end
  end

  @doc """
  Returns a list of workspace package names.
  """
  @spec names(String.t()) :: {:ok, [String.t()]} | {:error, term()}
  def names(root_dir \\ ".") do
    case discover(root_dir) do
      {:ok, packages} -> {:ok, Enum.map(packages, & &1.name)}
      error -> error
    end
  end

  @doc """
  Returns a dependency graph of inter-workspace dependencies.

  Finds which workspace packages depend on other workspace packages.
  """
  @spec dep_graph([map()]) :: %{String.t() => [String.t()]}
  def dep_graph(packages) do
    ws_names = MapSet.new(Enum.map(packages, & &1.name))

    Map.new(packages, fn pkg ->
      internal_deps =
        pkg.dependencies
        |> Map.keys()
        |> Enum.filter(&MapSet.member?(ws_names, &1))
        |> Enum.sort()

      {pkg.name, internal_deps}
    end)
  end

  @doc """
  Returns the topological build order for workspace packages.

  Packages with no inter-workspace dependencies come first.
  """
  @spec build_order([map()]) :: [String.t()]
  def build_order(packages) do
    graph = dep_graph(packages)
    topo_sort(graph)
  end

  @doc """
  Checks if a directory is a workspace root (has workspaces field).
  """
  @spec workspace_root?(String.t()) :: boolean()
  def workspace_root?(dir \\ ".") do
    case NPM.Package.JSON.read_workspaces(Path.join(dir, "package.json")) do
      {:ok, ws} when ws != [] -> true
      _ -> false
    end
  end

  defp resolve_workspaces(patterns, base_dir) do
    patterns
    |> NPM.Package.JSON.expand_workspaces(base_dir)
    |> Enum.flat_map(&read_workspace_package/1)
  end

  defp read_workspace_package(ws_dir) do
    pkg_path = Path.join(ws_dir, "package.json")

    case File.read(pkg_path) do
      {:ok, content} ->
        data = NPM.JSON.decode!(content)

        [
          %{
            name: data["name"] || Path.basename(ws_dir),
            version: data["version"] || "0.0.0",
            path: ws_dir,
            dependencies: Map.merge(data["dependencies"] || %{}, data["devDependencies"] || %{})
          }
        ]

      _ ->
        []
    end
  end

  defp topo_sort(adj) do
    g = :digraph.new()

    try do
      Enum.each(adj, fn {name, _} -> :digraph.add_vertex(g, name) end)

      Enum.each(adj, fn {name, deps} ->
        Enum.each(deps, fn dep ->
          :digraph.add_vertex(g, dep)
          :digraph.add_edge(g, dep, name)
        end)
      end)

      case :digraph_utils.topsort(g) do
        false -> Map.keys(adj)
        sorted -> sorted
      end
    after
      :digraph.delete(g)
    end
  end
end
