defmodule NPM.Dist do
  @moduledoc """
  Handles package distribution metadata.

  Parses dist info from registry responses including tarball URLs,
  shasum, integrity, and unpacked size.
  """

  @doc """
  Extracts dist metadata from a registry version entry.
  """
  @spec extract(map()) :: map()
  def extract(%{"dist" => dist}) when is_map(dist) do
    %{
      tarball: dist["tarball"],
      shasum: dist["shasum"],
      integrity: dist["integrity"],
      unpacked_size: dist["unpackedSize"],
      file_count: dist["fileCount"],
      npm_signature: dist["npm-signature"]
    }
  end

  def extract(_),
    do: %{
      tarball: nil,
      shasum: nil,
      integrity: nil,
      unpacked_size: nil,
      file_count: nil,
      npm_signature: nil
    }

  @doc """
  Checks if dist metadata has integrity hash.
  """
  @spec has_integrity?(map()) :: boolean()
  def has_integrity?(%{integrity: integrity}) when is_binary(integrity) and integrity != "",
    do: true

  def has_integrity?(_), do: false

  @doc """
  Extracts the tarball URL from dist metadata.
  """
  @spec tarball_url(map()) :: String.t() | nil
  def tarball_url(%{tarball: url}), do: url
  def tarball_url(_), do: nil

  @doc """
  Formats unpacked size for display.
  """
  @spec format_size(non_neg_integer() | nil) :: String.t()
  def format_size(nil), do: "unknown"
  def format_size(bytes) when bytes < 1024, do: "#{bytes} B"
  def format_size(bytes) when bytes < 1_048_576, do: "#{Float.round(bytes / 1024, 1)} KB"
  def format_size(bytes), do: "#{Float.round(bytes / 1_048_576, 1)} MB"

  @doc """
  Constructs a default tarball URL from registry and package info.
  """
  @spec default_tarball_url(String.t(), String.t(), String.t()) :: String.t()
  def default_tarball_url(registry, name, version) do
    encoded = URI.encode(name, &(&1 != ?/ and &1 != ?@))
    "#{String.trim_trailing(registry, "/")}/#{encoded}/-/#{Path.basename(name)}-#{version}.tgz"
  end

  @doc """
  Validates that dist metadata contains minimum required fields.
  """
  @spec valid?(map()) :: boolean()
  def valid?(%{tarball: tarball}) when is_binary(tarball) and tarball != "", do: true
  def valid?(_), do: false
end
