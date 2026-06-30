defmodule NPM.Workspace do
  @moduledoc """
  Workspace management for npm monorepos.

  Handles discovery and resolution of workspace packages defined
  in the root `package.json` via the `workspaces` field.
  """

  @dep_fields [
    dependencies: "dependencies",
    dev_dependencies: "devDependencies",
    optional_dependencies: "optionalDependencies"
  ]

  @type project :: %{
          dependencies: %{String.t() => String.t()},
          dev_dependencies: %{String.t() => String.t()},
          optional_dependencies: %{String.t() => String.t()},
          local_links: %{String.t() => String.t()}
        }

  @doc """
  Reads dependency groups from the root package and workspace packages.

  Registry dependencies are merged across the root `package.json` and every
  workspace `package.json`. Local `workspace:` and directory `file:`
  dependencies are returned as `:local_links` so they can be linked into the
  root `node_modules/` without registry resolution.
  """
  @spec read_all(String.t()) :: {:ok, project()} | {:error, term()}
  def read_all(root_dir \\ ".") do
    with {:ok, manifests} <- manifests(root_dir),
         {:ok, local_links} <- collect_local_links(manifests),
         {:ok, groups} <- dependency_groups(manifests, local_links) do
      {:ok, Map.put(groups, :local_links, local_links)}
    end
  end

  @doc """
  Returns the dependency map that should be resolved for install.
  """
  @spec install_dependencies(project(), keyword()) ::
          {:ok, %{String.t() => String.t()}} | {:error, term()}
  def install_dependencies(project, opts \\ []) do
    groups =
      if opts[:production] do
        [project.dependencies, project.optional_dependencies]
      else
        [project.dependencies, project.dev_dependencies, project.optional_dependencies]
      end

    merge_dependency_maps(groups)
  end

  @doc """
  Reads root and workspace package manifests.
  """
  @spec manifests(String.t()) :: {:ok, [map()]} | {:error, term()}
  def manifests(root_dir \\ ".") do
    root_dir = Path.expand(root_dir)
    root_path = Path.join(root_dir, "package.json")

    with {:ok, root_data} <- read_manifest(root_path),
         {:ok, workspace_patterns} <- NPM.Package.JSON.read_workspaces(root_path),
         {:ok, workspace_manifests} <- read_workspace_manifests(root_dir, workspace_patterns) do
      {:ok,
       [%{path: root_path, dir: root_dir, root?: true, data: root_data} | workspace_manifests]}
    end
  end

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

  defp read_workspace_manifests(root_dir, patterns) do
    manifests =
      patterns
      |> NPM.Package.JSON.expand_workspaces(root_dir)
      |> Enum.map(&Path.expand/1)
      |> Enum.uniq()
      |> Enum.sort()
      |> Enum.reduce_while({:ok, []}, fn dir, {:ok, acc} ->
        path = Path.join(dir, "package.json")

        case read_manifest(path) do
          {:ok, data} -> {:cont, {:ok, [%{path: path, dir: dir, root?: false, data: data} | acc]}}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)

    case manifests do
      {:ok, list} -> {:ok, Enum.reverse(list)}
      error -> error
    end
  end

  defp read_manifest(path) do
    case NPM.JSON.read_file(path) do
      {:ok, data} when is_map(data) -> {:ok, data}
      {:ok, _} -> {:error, {:invalid_package_json, path}}
      {:error, :enoent} -> {:ok, %{}}
      {:error, reason} -> {:error, reason}
    end
  end

  defp collect_local_links(manifests) do
    workspace_links = workspace_package_links(manifests)

    manifests
    |> dependency_entries()
    |> Enum.reduce_while({:ok, workspace_links}, fn {manifest, name, range}, {:ok, acc} ->
      cond do
        workspace_range?(range) ->
          if Map.has_key?(acc, name) do
            {:cont, {:ok, acc}}
          else
            {:halt, {:error, {:unknown_workspace_dependency, name, manifest.path}}}
          end

        file_range?(range) ->
          case file_link(name, range, manifest.dir) do
            {:ok, {link_name, path}} -> put_local_link(acc, link_name, path)
            {:error, reason} -> {:halt, {:error, reason}}
          end

        true ->
          {:cont, {:ok, acc}}
      end
    end)
  end

  defp workspace_package_links(manifests) do
    manifests
    |> Enum.reject(& &1.root?)
    |> Enum.flat_map(fn manifest ->
      case package_name(manifest) do
        nil -> []
        name -> [{name, manifest.dir}]
      end
    end)
    |> Map.new()
  end

  defp package_name(%{data: data, dir: dir}) do
    case Map.get(data, "name") do
      name when is_binary(name) and name != "" -> name
      _ -> Path.basename(dir)
    end
  end

  defp dependency_entries(manifests) do
    Enum.flat_map(manifests, fn manifest ->
      Enum.flat_map(@dep_fields, fn {_key, field} ->
        manifest.data
        |> Map.get(field, %{})
        |> map_entries()
        |> Enum.map(fn {name, range} -> {manifest, name, range} end)
      end)
    end)
  end

  defp dependency_groups(manifests, local_links) do
    initial = %{dependencies: %{}, dev_dependencies: %{}, optional_dependencies: %{}}

    Enum.reduce_while(manifests, {:ok, initial}, fn manifest, {:ok, acc} ->
      case merge_manifest_dependencies(acc, manifest, local_links) do
        {:ok, updated} -> {:cont, {:ok, updated}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  defp merge_manifest_dependencies(acc, manifest, local_links) do
    Enum.reduce_while(@dep_fields, {:ok, acc}, fn {key, field}, {:ok, current} ->
      deps = manifest.data |> Map.get(field, %{}) |> map_entries()

      case merge_dependency_group(Map.fetch!(current, key), deps, manifest, local_links) do
        {:ok, group} -> {:cont, {:ok, Map.put(current, key, group)}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  defp merge_dependency_group(group, deps, manifest, local_links) do
    Enum.reduce_while(deps, {:ok, group}, fn {name, range}, {:ok, acc} ->
      if local_dependency?(name, range, local_links) do
        {:cont, {:ok, acc}}
      else
        merge_dependency(acc, name, range, manifest.path)
      end
    end)
  end

  defp merge_dependency_maps(groups) do
    groups
    |> Enum.reduce_while({:ok, %{}}, fn group, {:ok, acc} ->
      result =
        Enum.reduce_while(group, {:ok, acc}, fn {name, range}, {:ok, inner_acc} ->
          merge_dependency(inner_acc, name, range, "package.json")
        end)

      case result do
        {:ok, updated} -> {:cont, {:ok, updated}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  defp merge_dependency(acc, name, range, path) do
    case Map.fetch(acc, name) do
      {:ok, ^range} ->
        {:cont, {:ok, acc}}

      {:ok, existing} ->
        {:halt, {:error, {:conflicting_workspace_dependency, name, existing, range, path}}}

      :error ->
        {:cont, {:ok, Map.put(acc, name, range)}}
    end
  end

  defp map_entries(map) when is_map(map) do
    Enum.flat_map(map, fn
      {name, range} when is_binary(name) and is_binary(range) -> [{name, range}]
      _ -> []
    end)
  end

  defp map_entries(_), do: []

  defp local_dependency?(name, range, local_links) do
    Map.has_key?(local_links, name) or workspace_range?(range) or file_range?(range)
  end

  defp workspace_range?("workspace:" <> _), do: true
  defp workspace_range?(_), do: false

  defp file_range?("file:" <> _), do: true
  defp file_range?(_), do: false

  defp file_link(name, "file:" <> path, base_dir) do
    package_dir = Path.expand(path, base_dir)
    package_json = Path.join(package_dir, "package.json")

    case NPM.JSON.read_file(package_json) do
      {:ok, data} when is_map(data) -> {:ok, {name, package_dir}}
      {:ok, _} -> {:error, {:invalid_file_dependency, name, package_json}}
      {:error, :enoent} -> {:error, {:missing_file_dependency, name, package_dir}}
      {:error, reason} -> {:error, reason}
    end
  end

  defp put_local_link(acc, name, path) do
    case Map.fetch(acc, name) do
      {:ok, ^path} ->
        {:cont, {:ok, acc}}

      {:ok, existing} ->
        {:halt, {:error, {:conflicting_local_dependency, name, existing, path}}}

      :error ->
        {:cont, {:ok, Map.put(acc, name, path)}}
    end
  end
end
