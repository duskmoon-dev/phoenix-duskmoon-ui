defmodule DuskmoonBundler.Cache do
  @moduledoc """
  ETS-backed module cache keyed by path.

  Caches compiled output so repeated requests for unchanged files
  skip the compilation step entirely.
  """

  @table :duskmoon_bundler_cache

  @type entry :: DuskmoonBundler.DevServer.CacheEntry.t()

  @type cache_entry :: %{mtime: integer(), entry: entry()}

  @doc "Create the cache ETS table. Called once from Application.start/2."
  @spec create_table :: :ok
  def create_table, do: DuskmoonBundler.ETS.create_named_set(@table)

  @doc "Look up a cached entry. Returns `nil` on miss."
  @spec get(String.t(), integer()) :: entry() | nil
  def get(path, mtime) do
    case :ets.lookup(@table, path) do
      [{^path, %{mtime: ^mtime, entry: entry}}] -> entry
      _ -> nil
    end
  end

  @doc "Look up any cached entry for a file path regardless of mtime."
  @spec get_file(String.t()) :: entry() | nil
  def get_file(path) do
    case :ets.lookup(@table, path) do
      [{^path, %{entry: entry}}] -> entry
      [] -> get_file_variant(path)
    end
  end

  @doc "Store a compiled entry."
  @spec put(String.t(), integer(), entry()) :: :ok
  def put(path, mtime, entry) do
    :ets.insert(@table, {path, %{mtime: mtime, entry: entry}})
    :ok
  end

  @doc "Evict the entry for a cache key."
  @spec evict(String.t()) :: :ok
  def evict(key) do
    :ets.delete(@table, key)
    :ok
  end

  @doc "Evict all cache entries derived from a file path, including variant keys like `path <> \"?import\"`."
  @spec evict_file(String.t()) :: :ok
  def evict_file(path) do
    @table
    |> :ets.tab2list()
    |> Enum.each(fn {key, _entry} ->
      if file_variant_key?(key, path), do: :ets.delete(@table, key)
    end)

    :ok
  end

  @doc "Clear all cached entries."
  @spec clear :: :ok
  def clear do
    :ets.delete_all_objects(@table)
    :ok
  end

  defp get_file_variant(path) do
    @table
    |> :ets.tab2list()
    |> Enum.find_value(fn
      {key, %{entry: entry}} ->
        if file_variant_key?(key, path), do: entry

      _ ->
        nil
    end)
  end

  defp file_variant_key?(key, path) when is_binary(key) do
    key == path or String.starts_with?(key, path <> "?")
  end

  defp file_variant_key?(_key, _path) do
    false
  end
end
