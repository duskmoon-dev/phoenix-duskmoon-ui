defmodule NPM.JSON do
  @moduledoc """
  JSON helpers for npm manifest and lock files.

  `npm_ex` writes generated JSON files such as `package.json`, `npm.lock`, and
  shrinkwrap files. Those files should be stable across repeated writes, so maps
  are recursively converted to `Jason.OrderedObject` values sorted by key before
  encoding. Jason handles the actual JSON encoding, escaping, duplicate-key
  checks, and pretty formatting.
  """

  @doc "Encode a term as pretty-printed JSON with recursively sorted object keys."
  @spec encode_pretty(term()) :: String.t()
  def encode_pretty(data) do
    data
    |> sort_objects()
    |> Jason.encode!(pretty: true, maps: :strict)
    |> Kernel.<>("\n")
  end

  @doc "Decode JSON into maps with string keys."
  @spec decode(iodata()) :: {:ok, term()} | {:error, Jason.DecodeError.t()}
  def decode(data), do: Jason.decode(data)

  @doc "Decode JSON into maps with string keys, raising on invalid input."
  @spec decode!(iodata()) :: term()
  def decode!(data), do: Jason.decode!(data)

  @doc "Read and decode a JSON file."
  @spec read_file(String.t()) :: {:ok, term()} | {:error, term()}
  def read_file(path) do
    case File.read(path) do
      {:ok, content} -> decode(content)
      error -> error
    end
  end

  defp sort_objects(map) when is_map(map) do
    map
    |> Enum.map(fn {key, value} -> {key, sort_objects(value)} end)
    |> Enum.sort_by(fn {key, _value} -> to_string(key) end)
    |> Jason.OrderedObject.new()
  end

  defp sort_objects(list) when is_list(list), do: Enum.map(list, &sort_objects/1)
  defp sort_objects(value), do: value
end
