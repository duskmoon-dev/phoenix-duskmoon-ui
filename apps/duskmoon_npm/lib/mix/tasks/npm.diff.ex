defmodule Mix.Tasks.Npm.Diff do
  @shortdoc "Show changes between lockfile versions"

  @moduledoc """
  Show what changed since the last `npm.lock` was committed.

      mix npm.diff

  Compares the current `npm.lock` with the git HEAD version and
  shows added, removed, and updated packages.
  """

  use Mix.Task

  @impl true
  def run([]) do
    Application.ensure_all_started(:req)

    case read_git_lockfile() do
      {:ok, old_lockfile} ->
        case NPM.Lockfile.read() do
          {:ok, new_lockfile} ->
            print_diff(old_lockfile, new_lockfile)

          {:error, _} ->
            Mix.shell().error("Cannot read npm.lock")
        end

      {:error, :not_committed} ->
        Mix.shell().info("npm.lock is not tracked by git.")
    end
  end

  def run(_) do
    Mix.shell().error("Usage: mix npm.diff")
  end

  defp read_git_lockfile do
    case System.cmd("git", ["show", "HEAD:npm.lock"], stderr_to_stdout: true) do
      {content, 0} ->
        data = NPM.JSON.decode!(content)
        lockfile = NPM.Lockfile.parse_packages(Map.get(data, "packages", %{}))
        {:ok, lockfile}

      {_, _} ->
        {:error, :not_committed}
    end
  end

  defp print_diff(old, new) when old == new do
    Mix.shell().info("No changes in npm.lock")
  end

  defp print_diff(old, new) do
    added = Map.keys(new) -- Map.keys(old)
    removed = Map.keys(old) -- Map.keys(new)

    updated =
      for key <- Map.keys(new),
          Map.has_key?(old, key),
          old[key].version != new[key].version,
          do: key

    if added == [] and removed == [] and updated == [] do
      Mix.shell().info("No version changes in npm.lock")
    else
      Enum.each(Enum.sort(added), &Mix.shell().info("+ #{&1}@#{new[&1].version}"))
      Enum.each(Enum.sort(removed), &Mix.shell().info("- #{&1}@#{old[&1].version}"))

      Enum.each(Enum.sort(updated), fn key ->
        Mix.shell().info("↑ #{key} #{old[key].version} → #{new[key].version}")
      end)
    end
  end
end
