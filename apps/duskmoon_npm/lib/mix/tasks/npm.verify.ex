defmodule Mix.Tasks.Npm.Verify do
  @shortdoc "Verify node_modules matches lockfile"

  @moduledoc """
  Check that `node_modules` matches `package-lock.json`.

      mix npm.verify

  Reports missing and extraneous packages. Useful for CI
  to ensure `mix npm.get` was run after lockfile changes.
  """

  use Mix.Task

  @impl true
  def run([]) do
    Application.ensure_all_started(:req)

    case NPM.Lockfile.read() do
      {:ok, lockfile} when lockfile == %{} ->
        Mix.shell().info("No lockfile. Nothing to verify.")

      {:ok, lockfile} ->
        case NPM.Workspace.read_all() do
          {:ok, project} ->
            expected = expected_packages(lockfile, project.local_links)
            skipped = NPM.Install.Linker.skipped_packages(lockfile)

            expected
            |> NPM.NodeModules.diff()
            |> ignore_missing(skipped)
            |> report_diff(map_size(expected) - MapSet.size(skipped))

          {:error, reason} ->
            Mix.raise("npm.verify failed: #{inspect(reason)}")
        end

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

  defp report_diff({[], []}, count) do
    Mix.shell().info("node_modules matches lockfile (#{count} packages)")
  end

  defp report_diff({missing, extra}, _count) do
    Enum.each(missing, &Mix.shell().error("  missing: #{&1}"))
    Enum.each(extra, &Mix.shell().error("  extra: #{&1}"))
    Mix.raise("node_modules does not match lockfile")
  end
end
