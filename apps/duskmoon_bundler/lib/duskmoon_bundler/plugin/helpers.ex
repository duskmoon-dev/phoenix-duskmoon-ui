defmodule DuskmoonBundler.Plugin.Helpers do
  @moduledoc false

  def cache_hash(nil), do: nil
  def cache_hash(""), do: nil

  def cache_hash(value) do
    :crypto.hash(:sha256, :erlang.term_to_binary(value))
    |> Base.encode16(case: :lower)
    |> binary_part(0, 12)
  end

  def stringify_keys(options) when is_map(options) or is_list(options) do
    Map.new(options, fn {key, value} -> {to_string(key), value} end)
  end
end
