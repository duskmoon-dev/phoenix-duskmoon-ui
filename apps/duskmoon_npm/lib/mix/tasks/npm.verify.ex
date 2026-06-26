defmodule Mix.Tasks.Npm.Verify do
  @shortdoc "Verify node_modules matches lockfile"

  @moduledoc """
  Check that `node_modules` matches `npm.lock`.

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
        lockfile |> NPM.NodeModules.diff() |> report_diff(map_size(lockfile))

      {:error, reason} ->
        Mix.shell().error("Failed: #{inspect(reason)}")
    end
  end

  def run(_) do
    Mix.shell().error("Usage: mix npm.verify")
  end

  defp report_diff({[], []}, count) do
    Mix.shell().info("node_modules matches lockfile (#{count} packages)")
  end

  defp report_diff({missing, extra}, _count) do
    Enum.each(missing, &Mix.shell().error("  missing: #{&1}"))
    Enum.each(extra, &Mix.shell().info("  extra: #{&1}"))
  end
end
