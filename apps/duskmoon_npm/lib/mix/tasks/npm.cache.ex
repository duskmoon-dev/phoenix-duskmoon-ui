defmodule Mix.Tasks.Npm.Cache do
  @shortdoc "Manage the npm package cache"

  @moduledoc """
  Manage the global npm package cache.

      mix npm.cache status   # Show cache location and size
      mix npm.cache clean    # Remove all cached packages
  """

  use Mix.Task

  @impl true
  def run(["status"]) do
    Application.ensure_all_started(:req)
    cache_dir = NPM.Cache.dir()

    if File.exists?(cache_dir) do
      {size, count} = dir_stats(cache_dir)
      Mix.shell().info("Cache: #{cache_dir}")
      Mix.shell().info("Size: #{NPM.FormatUtil.format_size(size)}")
      Mix.shell().info("Packages: #{count}")
    else
      Mix.shell().info("Cache: #{cache_dir} (empty)")
    end
  end

  def run(["clean"]) do
    Application.ensure_all_started(:req)
    cache_dir = NPM.Cache.dir()

    if File.exists?(cache_dir) do
      {size, count} = dir_stats(cache_dir)
      File.rm_rf!(cache_dir)
      Mix.shell().info("Removed #{count} packages (#{NPM.FormatUtil.format_size(size)})")
    else
      Mix.shell().info("Cache is already empty.")
    end
  end

  def run(_) do
    Mix.shell().error("Usage: mix npm.cache [status|clean]")
  end

  defp dir_stats(path) do
    path
    |> Path.join("**/*")
    |> Path.wildcard()
    |> Enum.reduce({0, 0}, fn file, {size, count} ->
      case File.stat(file) do
        {:ok, %{type: :regular, size: s}} -> {size + s, count + 1}
        _ -> {size, count}
      end
    end)
  end
end
