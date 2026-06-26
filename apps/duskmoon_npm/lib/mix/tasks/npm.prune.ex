defmodule Mix.Tasks.Npm.Prune do
  alias NPM.Install.Linker

  @shortdoc "Remove extraneous packages"

  @moduledoc """
  Remove packages from `node_modules/` not listed in `npm.lock`.

      mix npm.prune

  Useful after manually removing dependencies from `package.json`
  without running `mix npm.install`.
  """

  use Mix.Task

  @impl true
  def run([]) do
    Application.ensure_all_started(:req)

    case NPM.Lockfile.read() do
      {:ok, lockfile} -> do_prune(lockfile)
      {:error, reason} -> Mix.shell().error("Failed to read lockfile: #{inspect(reason)}")
    end
  end

  def run(_) do
    Mix.shell().error("Usage: mix npm.prune")
  end

  defp do_prune(lockfile) do
    expected = MapSet.new(Map.keys(lockfile))
    before_count = count_packages("node_modules")
    Linker.prune("node_modules", expected)
    print_result(before_count - count_packages("node_modules"))
  end

  defp print_result(removed) when removed > 0 do
    Mix.shell().info("Removed #{removed} extraneous package#{if removed != 1, do: "s"}")
  end

  defp print_result(_), do: Mix.shell().info("No extraneous packages found.")

  defp count_packages(nm_dir) do
    case File.ls(nm_dir) do
      {:ok, entries} ->
        entries
        |> Enum.reject(&String.starts_with?(&1, "."))
        |> Enum.count()

      {:error, _} ->
        0
    end
  end
end
