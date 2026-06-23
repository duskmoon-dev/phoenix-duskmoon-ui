defmodule DuskmoonBundler.ETS do
  @moduledoc "Small helpers for DuskmoonBundler's named ETS tables."

  @doc "Create a public named set table optimized for concurrent reads."
  def create_named_set(table) do
    if :ets.whereis(table) == :undefined do
      :ets.new(table, [:named_table, :set, :public, read_concurrency: true])
    end

    :ok
  end

  @doc "Insert one row into an ETS table and return `:ok`."
  def put(table, row) do
    :ets.insert(table, row)
    :ok
  end

  @doc "Delete one key from an ETS table and return `:ok`."
  def delete(table, key) do
    :ets.delete(table, key)
    :ok
  end

  @doc "Remove all rows from an ETS table and return `:ok`."
  def clear(table) do
    if :ets.whereis(table) == :undefined do
      create_named_set(table)
    else
      :ets.delete_all_objects(table)
    end

    :ok
  end
end
