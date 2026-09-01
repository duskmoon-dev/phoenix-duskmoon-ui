defmodule Mix.Tasks.Npm.Rebuild do
  @shortdoc "Rebuild node_modules from lockfile"

  @moduledoc """
  Remove root and workspace-local `node_modules/` directories, then reinstall
  from the root lockfile.

      mix npm.rebuild

  Unlike `mix npm.clean`, this also removes installs nested under declared npm
  workspaces so they cannot shadow packages restored at the root.
  """

  use Mix.Task

  @impl true
  def run([]) do
    Application.ensure_all_started(:req)

    case NPM.Workspace.manifests() do
      {:ok, manifests} ->
        remove_node_modules(manifests)
        NPM.get()

      {:error, reason} ->
        Mix.raise("npm.rebuild failed: #{inspect(reason)}")
    end
  end

  def run(_) do
    Mix.shell().error("Usage: mix npm.rebuild")
  end

  defp remove_node_modules(manifests) do
    root_dir = manifests |> Enum.find(& &1.root?) |> Map.fetch!(:dir)
    node_modules_dirs = Enum.map(manifests, &Path.join(&1.dir, "node_modules"))

    case Enum.find(node_modules_dirs, &(not inside_dir?(root_dir, &1))) do
      nil ->
        Enum.each(node_modules_dirs, &remove_node_modules(&1, root_dir))

      outside_dir ->
        Mix.raise("npm.rebuild refused workspace outside root: #{outside_dir}")
    end
  end

  defp remove_node_modules(node_modules, root_dir) do
    if File.exists?(node_modules) do
      File.rm_rf!(node_modules)
      Mix.shell().info("Removed #{Path.relative_to(node_modules, root_dir)}/")
    end
  end

  defp inside_dir?(parent, child) do
    parent = parent |> Path.expand() |> Path.split()
    child = child |> Path.expand() |> Path.split()

    List.starts_with?(child, parent)
  end
end
