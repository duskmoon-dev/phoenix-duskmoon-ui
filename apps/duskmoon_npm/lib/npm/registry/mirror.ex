defmodule NPM.Registry.Mirror do
  @moduledoc """
  Support for registry mirror URLs and fallback.

  Configure mirrors for faster downloads from geographically
  closer servers, with automatic fallback to the primary registry.
  """

  @default_mirrors %{
    "china" => "https://registry.npmmirror.com",
    "yarn" => "https://registry.yarnpkg.com",
    "npmjs" => "https://registry.npmjs.org"
  }

  @doc """
  Get the configured mirror URL, or the default registry.
  """
  @spec mirror_url :: String.t()
  def mirror_url do
    NPM.Config.mirror_url()
  end

  @doc """
  List known mirror names and URLs.
  """
  @spec known_mirrors :: %{String.t() => String.t()}
  def known_mirrors, do: @default_mirrors

  @doc """
  Get a specific mirror URL by name.
  """
  @spec get_mirror(String.t()) :: String.t() | nil
  def get_mirror(name) do
    Map.get(@default_mirrors, name)
  end

  @doc """
  Check if a URL is a known mirror.
  """
  @spec known_mirror?(String.t()) :: boolean()
  def known_mirror?(url) do
    url in Map.values(@default_mirrors)
  end

  @doc """
  Rewrite a tarball URL to use a mirror.

  Replaces the registry hostname with the mirror hostname.
  """
  @spec rewrite_tarball_url(String.t(), String.t()) :: String.t()
  def rewrite_tarball_url(tarball_url, mirror_url) do
    original = URI.parse(tarball_url)
    mirror = URI.parse(mirror_url)

    original
    |> Map.put(:host, mirror.host)
    |> Map.put(:scheme, mirror.scheme)
    |> Map.put(:port, mirror.port)
    |> URI.to_string()
  end
end
