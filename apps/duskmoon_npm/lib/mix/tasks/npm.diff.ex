defmodule Mix.Tasks.Npm.Diff do
  @shortdoc "Show changes between lockfile versions"

  @moduledoc """
  Show what changed since the last `package-lock.json` was committed.

      mix npm.diff

  Compares the current `package-lock.json` with the git HEAD version and
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
            Mix.shell().error("Cannot read package-lock.json")
        end

      {:error, :not_committed} ->
        Mix.shell().info("package-lock.json is not tracked by git.")
    end
  end

  def run(_) do
    Mix.shell().error("Usage: mix npm.diff")
  end

  defp read_git_lockfile do
    read_git_lockfile(NPM.Lockfile.default_path()) ||
      read_git_lockfile(NPM.Lockfile.legacy_path()) ||
      {:error, :not_committed}
  end

  defp read_git_lockfile(path) do
    case System.cmd("git", ["show", "HEAD:#{path}"], stderr_to_stdout: true) do
      {content, 0} -> {:ok, content |> NPM.JSON.decode!() |> NPM.Lockfile.parse()}
      {_, _} -> nil
    end
  end

  defp print_diff(old, new) when old == new do
    Mix.shell().info("No changes in package-lock.json")
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
      Mix.shell().info("No version changes in package-lock.json")
    else
      Enum.each(Enum.sort(added), &Mix.shell().info("+ #{&1}@#{new[&1].version}"))
      Enum.each(Enum.sort(removed), &Mix.shell().info("- #{&1}@#{old[&1].version}"))

      Enum.each(Enum.sort(updated), fn key ->
        Mix.shell().info("↑ #{key} #{old[key].version} → #{new[key].version}")
      end)
    end
  end
end
