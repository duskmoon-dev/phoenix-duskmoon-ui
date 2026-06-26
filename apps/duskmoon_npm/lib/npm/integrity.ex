defmodule NPM.Integrity do
  @moduledoc """
  Verify package integrity using Subresource Integrity (SRI) hashes.

  npm packages include integrity strings in the format:
  `algorithm-base64hash` (e.g. `sha512-abc123...`).
  """

  @doc """
  Verify data against an SRI integrity string.

  Returns `:ok` if the hash matches, `{:error, :integrity_mismatch}` otherwise.
  Returns `:ok` for empty integrity strings (no verification).
  """
  @spec verify(binary(), String.t()) :: :ok | {:error, :integrity_mismatch}
  def verify(_data, ""), do: :ok
  def verify(_data, nil), do: :ok

  def verify(data, integrity) do
    if compute_and_match?(data, integrity), do: :ok, else: {:error, :integrity_mismatch}
  end

  @doc """
  Compute the SHA-512 SRI integrity string for binary data.
  """
  @spec compute_sha512(binary()) :: String.t()
  def compute_sha512(data) do
    hash = :crypto.hash(:sha512, data) |> Base.encode64()
    "sha512-#{hash}"
  end

  @doc """
  Compute the SHA-256 SRI integrity string for binary data.
  """
  @spec compute_sha256(binary()) :: String.t()
  def compute_sha256(data) do
    hash = :crypto.hash(:sha256, data) |> Base.encode64()
    "sha256-#{hash}"
  end

  @doc """
  Parse an SRI string into `{algorithm, hash}` tuple.
  """
  @spec parse(String.t()) :: {:ok, {String.t(), String.t()}} | :error
  def parse(integrity) when is_binary(integrity) do
    case String.split(integrity, "-", parts: 2) do
      [algo, hash] when algo in ["sha256", "sha384", "sha512"] -> {:ok, {algo, hash}}
      _ -> :error
    end
  end

  def parse(_), do: :error

  @doc """
  Get the algorithm used in an SRI string.
  """
  @spec algorithm(String.t()) :: String.t() | nil
  def algorithm(integrity) do
    case parse(integrity) do
      {:ok, {algo, _}} -> algo
      :error -> nil
    end
  end

  defp compute_and_match?(data, integrity) do
    case parse(integrity) do
      {:ok, {algo, expected_hash}} ->
        actual_hash = hash_data(algo, data)
        actual_hash == expected_hash

      :error ->
        false
    end
  end

  defp hash_data("sha256", data), do: :crypto.hash(:sha256, data) |> Base.encode64()
  defp hash_data("sha384", data), do: :crypto.hash(:sha384, data) |> Base.encode64()
  defp hash_data("sha512", data), do: :crypto.hash(:sha512, data) |> Base.encode64()
  defp hash_data(_, _data), do: ""
end
