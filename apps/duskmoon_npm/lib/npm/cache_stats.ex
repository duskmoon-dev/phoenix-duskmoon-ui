defmodule NPM.CacheStats do
  @moduledoc """
  Provides statistics about the npm package cache.
  """

  @doc """
  Computes cache hit/miss statistics for a lockfile.
  """
  @spec hit_miss(map()) :: %{
          hits: non_neg_integer(),
          misses: non_neg_integer(),
          total: non_neg_integer()
        }
  def hit_miss(lockfile) do
    results = Enum.map(lockfile, fn {name, entry} -> NPM.Cache.cached?(name, entry.version) end)
    hits = Enum.count(results, & &1)
    total = length(results)

    %{hits: hits, misses: total - hits, total: total}
  end

  @doc """
  Computes the hit rate as a percentage.
  """
  @spec hit_rate(map()) :: float()
  def hit_rate(lockfile) do
    stats = hit_miss(lockfile)
    if stats.total == 0, do: 100.0, else: Float.round(stats.hits / stats.total * 100, 1)
  end

  @doc """
  Estimates cache size on disk.
  """
  @spec disk_size() :: non_neg_integer()
  def disk_size do
    cache_dir = Path.join(NPM.Cache.dir(), "cache")

    if File.exists?(cache_dir) do
      walk_size(cache_dir)
    else
      0
    end
  end

  @doc """
  Lists cached packages with versions.
  """
  @spec list_cached() :: [{String.t(), [String.t()]}]
  def list_cached do
    cache_dir = Path.join(NPM.Cache.dir(), "cache")

    if File.exists?(cache_dir) do
      cache_dir
      |> File.ls!()
      |> Enum.flat_map(&list_package_versions(cache_dir, &1))
      |> Enum.sort_by(&elem(&1, 0))
    else
      []
    end
  end

  @doc """
  Formats cache statistics for display.
  """
  @spec format(map()) :: String.t()
  def format(stats) do
    rate = if stats.total == 0, do: 100.0, else: Float.round(stats.hits / stats.total * 100, 1)

    "Cache: #{stats.hits}/#{stats.total} hits (#{rate}%), #{stats.misses} to fetch"
  end

  @doc """
  Formats a byte size in human-readable form.
  """
  @spec format_size(non_neg_integer()) :: String.t()
  defdelegate format_size(bytes), to: NPM.FormatUtil

  defp walk_size(path) do
    case File.stat(path) do
      {:ok, %{type: :regular, size: size}} ->
        size

      {:ok, %{type: :directory}} ->
        path
        |> File.ls!()
        |> Enum.reduce(0, fn entry, acc -> acc + walk_size(Path.join(path, entry)) end)

      _ ->
        0
    end
  end

  defp list_package_versions(cache_dir, name) do
    pkg_dir = Path.join(cache_dir, name)

    case File.ls(pkg_dir) do
      {:ok, versions} ->
        dirs = Enum.filter(versions, &File.dir?(Path.join(pkg_dir, &1)))
        if dirs == [], do: [], else: [{name, Enum.sort(dirs)}]

      _ ->
        []
    end
  end
end
