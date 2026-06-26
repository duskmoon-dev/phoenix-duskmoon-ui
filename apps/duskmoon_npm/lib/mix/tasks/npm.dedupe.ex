defmodule Mix.Tasks.Npm.Dedupe do
  @shortdoc "Deduplicate packages"

  @moduledoc """
  Re-resolve dependencies to minimize duplicate packages.

      mix npm.dedupe

  Re-runs the resolver from scratch to find an optimal solution
  with fewer total packages.
  """

  use Mix.Task

  @impl true
  def run([]) do
    Application.ensure_all_started(:req)

    case NPM.Lockfile.read() do
      {:ok, lockfile} when lockfile == %{} ->
        Mix.shell().info("No npm.lock found, run `mix npm.install` first.")

      {:ok, old_lockfile} ->
        count_before = map_size(old_lockfile)
        NPM.install([])
        report_dedupe(count_before)

      {:error, reason} ->
        Mix.shell().error("Failed to read lockfile: #{inspect(reason)}")
    end
  end

  def run(_) do
    Mix.shell().error("Usage: mix npm.dedupe")
  end

  defp report_dedupe(count_before) do
    {:ok, new_lockfile} = NPM.Lockfile.read()
    diff = count_before - map_size(new_lockfile)
    print_dedupe_result(diff)
  end

  defp print_dedupe_result(diff) when diff > 0 do
    Mix.shell().info("Removed #{diff} duplicate package#{if diff != 1, do: "s"}")
  end

  defp print_dedupe_result(_), do: Mix.shell().info("No duplicates found.")
end
