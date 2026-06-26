defmodule NPM.Registry.URL do
  @moduledoc """
  Constructs registry API URLs for package operations.
  """

  @default_registry "https://registry.npmjs.org"

  @doc """
  Returns the package metadata URL.
  """
  @spec package_url(String.t(), String.t()) :: String.t()
  def package_url(name, registry \\ @default_registry) do
    "#{normalize(registry)}/#{encode_name(name)}"
  end

  @doc """
  Returns the URL for a specific version.
  """
  @spec version_url(String.t(), String.t(), String.t()) :: String.t()
  def version_url(name, version, registry \\ @default_registry) do
    "#{package_url(name, registry)}/#{version}"
  end

  @doc """
  Returns the tarball URL.
  """
  @spec tarball_url(String.t(), String.t(), String.t()) :: String.t()
  def tarball_url(name, version, registry \\ @default_registry) do
    base = normalize(registry)
    basename = Path.basename(name)
    "#{base}/#{encode_name(name)}/-/#{basename}-#{version}.tgz"
  end

  @doc """
  Returns the search API URL.
  """
  @spec search_url(String.t(), keyword()) :: String.t()
  def search_url(query, opts \\ []) do
    registry = Keyword.get(opts, :registry, @default_registry)
    size = Keyword.get(opts, :size, 20)
    "#{normalize(registry)}/-/v1/search?text=#{URI.encode(query)}&size=#{size}"
  end

  @doc """
  Returns the abbreviated (corgi) metadata URL.
  """
  @spec abbreviated_url(String.t(), String.t()) :: String.t()
  def abbreviated_url(name, registry \\ @default_registry) do
    package_url(name, registry)
  end

  @doc """
  Checks if a URL points to the default npm registry.
  """
  @spec default_registry?(String.t()) :: boolean()
  def default_registry?(url) do
    normalized = normalize(url)
    normalized == @default_registry or normalized == "https://registry.npmmirror.com"
  end

  @doc """
  Returns the default registry URL.
  """
  @spec default_registry :: String.t()
  def default_registry, do: @default_registry

  defp normalize(url), do: String.trim_trailing(url, "/")

  defp encode_name(name) do
    if NPM.Scope.scoped?(name) do
      name |> String.replace("/", "%2f")
    else
      name
    end
  end
end
