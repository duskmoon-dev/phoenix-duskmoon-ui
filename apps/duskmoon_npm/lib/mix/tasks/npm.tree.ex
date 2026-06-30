defmodule Mix.Tasks.Npm.Tree do
  @shortdoc "Show dependency tree"

  @moduledoc """
  Display the full dependency tree from `npm.lock`.

      mix npm.tree

  Shows which packages depend on which, with version info.
  """

  use Mix.Task

  @impl true
  def run([]) do
    Application.ensure_all_started(:req)

    with {:ok, project} <- NPM.Workspace.read_all(),
         {:ok, lockfile} <- NPM.Lockfile.read() do
      if lockfile == %{} do
        Mix.shell().info("No packages installed.")
      else
        print_tree(project.dependencies, project.dev_dependencies, lockfile)
      end
    end
  end

  def run(_) do
    Mix.shell().error("Usage: mix npm.tree")
  end

  defp print_tree(deps, dev_deps, lockfile) do
    print_group("dependencies", deps, lockfile)
    print_group("devDependencies", dev_deps, lockfile)
  end

  defp print_group(_label, group, _lockfile) when map_size(group) == 0, do: :ok

  defp print_group(label, group, lockfile) do
    Mix.shell().info(label <> ":")

    group
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.each(fn {name, _range} ->
      version = get_in(lockfile, [name, Access.key(:version)]) || "?"
      Mix.shell().info("├── #{name}@#{version}")
      print_subtree(name, lockfile, "│   ", MapSet.new([name]))
    end)
  end

  defp print_subtree(name, lockfile, prefix, seen) do
    case Map.get(lockfile, name) do
      nil -> :ok
      entry -> print_deps_tree(entry.dependencies, lockfile, prefix, seen)
    end
  end

  defp print_deps_tree(deps, lockfile, prefix, seen) do
    deps
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.each(&print_dep(&1, lockfile, prefix, seen))
  end

  defp print_dep({dep_name, _range}, lockfile, prefix, seen) do
    dep_version = get_in(lockfile, [dep_name, Access.key(:version)]) || "?"

    if MapSet.member?(seen, dep_name) do
      Mix.shell().info("#{prefix}└── #{dep_name}@#{dep_version} (circular)")
    else
      Mix.shell().info("#{prefix}└── #{dep_name}@#{dep_version}")
      print_subtree(dep_name, lockfile, prefix <> "    ", MapSet.put(seen, dep_name))
    end
  end
end
