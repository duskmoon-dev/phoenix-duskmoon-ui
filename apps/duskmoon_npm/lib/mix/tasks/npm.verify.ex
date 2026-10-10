defmodule Mix.Tasks.Npm.Verify do
  @shortdoc "Verify node_modules matches lockfile"

  @moduledoc """
  Check that `node_modules` matches `package-lock.json`.

      mix npm.verify

  Reports missing and extraneous packages, plus packages in workspace-local
  `node_modules/` directories that are absent from the lockfile. Useful
  for CI to ensure `mix npm.get` was run after lockfile changes.
  """

  use Mix.Task

  @impl true
  def run([]) do
    Application.ensure_all_started(:http_fetch)

    with {:ok, lockfile} <- NPM.Lockfile.read(),
         {:ok, nested_lockfile} <- NPM.Lockfile.read_nested() do
      if lockfile == %{} and nested_lockfile == %{} do
        Mix.shell().info("No lockfile. Nothing to verify.")
      else
        with {:ok, _dependencies, local_links} <- NPM.Workspace.frozen_dependencies([]),
             {:ok, manifests} <- NPM.Workspace.manifests() do
          expected = expected_packages(lockfile, local_links)
          skipped = NPM.Install.Linker.skipped_packages(lockfile)
          shadowing = workspace_shadowing_packages(manifests, nested_lockfile)
          {missing_nested, mismatched} = nested_diff(nested_lockfile)
          {missing, extra} = expected |> NPM.NodeModules.diff() |> ignore_missing(skipped)

          report_diff(
            {missing ++ missing_nested, extra},
            shadowing,
            mismatched,
            map_size(expected) + map_size(nested_lockfile) - MapSet.size(skipped)
          )
        else
          {:error, reason} ->
            Mix.raise("npm.verify failed: #{inspect(reason)}")
        end
      end
    else
      {:error, reason} ->
        Mix.raise("npm.verify failed: #{inspect(reason)}")
    end
  end

  def run(_) do
    Mix.raise("Usage: mix npm.verify")
  end

  defp expected_packages(lockfile, local_links) do
    Map.merge(lockfile, Map.new(local_links, fn {name, _path} -> {name, %{}} end))
  end

  defp ignore_missing({missing, extra}, skipped) do
    {Enum.reject(missing, &MapSet.member?(skipped, &1)), extra}
  end

  defp workspace_shadowing_packages(manifests, nested_lockfile) do
    root_dir = manifests |> Enum.find(& &1.root?) |> Map.fetch!(:dir)

    manifests
    |> Enum.reject(& &1.root?)
    |> Enum.flat_map(fn manifest ->
      node_modules = Path.join(manifest.dir, "node_modules")
      relative_dir = Path.relative_to(node_modules, root_dir)

      node_modules
      |> NPM.NodeModules.installed()
      |> Enum.map(&Path.join(relative_dir, &1))
    end)
    |> Enum.reject(&Map.has_key?(nested_lockfile, &1))
    |> Enum.sort()
  end

  defp nested_diff(nested_lockfile) do
    Enum.reduce(nested_lockfile, {[], []}, fn {location, entry}, {missing, mismatched} ->
      case NPM.JSON.read_file(Path.join(location, "package.json")) do
        {:ok, %{"version" => version}} when version == entry.version -> {missing, mismatched}
        {:ok, _} -> {missing, [location | mismatched]}
        {:error, _} -> {[location | missing], mismatched}
      end
    end)
  end

  defp report_diff({[], []}, [], [], count) do
    Mix.shell().info("node_modules matches lockfile (#{count} packages)")
  end

  defp report_diff({missing, extra}, shadowing, mismatched, _count) do
    Enum.each(missing, &Mix.shell().error("  missing: #{&1}"))
    Enum.each(extra, &Mix.shell().error("  extra: #{&1}"))
    Enum.each(shadowing, &Mix.shell().error("  shadowing: #{&1}"))
    Enum.each(mismatched, &Mix.shell().error("  mismatch: #{&1}"))
    Mix.raise("node_modules does not match lockfile")
  end
end
