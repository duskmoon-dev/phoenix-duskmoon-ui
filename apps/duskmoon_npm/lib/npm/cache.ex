defmodule NPM.Cache do
  alias NPM.Security.RegistryPolicy

  @moduledoc """
  Global package cache.

  Downloaded packages are stored in `~/.npm_ex/cache/<name>/<version>/`
  and reused across projects. The cache is populated on first install
  and checked before downloading from the registry.
  """

  @doc "Root directory of the global cache."
  @spec dir :: String.t()
  def dir do
    NPM.Config.cache_dir()
  end

  @doc "Path to a specific package version in the cache."
  @spec package_dir(String.t(), String.t()) :: String.t()
  def package_dir(name, version) do
    Path.join([dir(), "cache", name, version])
  end

  @doc "Check if a package version is already cached."
  @spec cached?(String.t(), String.t()) :: boolean()
  def cached?(name, version) do
    File.exists?(Path.join(package_dir(name, version), "package.json"))
  end

  @doc """
  Ensure a package version is in the cache.

  Downloads and extracts the tarball if not already cached.
  Returns `{:ok, cache_path}`, `{:ok, :missing_optional}` when an
  optional package fails to fetch, or `{:error, reason}`.
  """
  @spec ensure(String.t(), String.t(), String.t(), String.t(), keyword()) ::
          {:ok, String.t()} | {:ok, :missing_optional} | {:error, term()}
  def ensure(name, version, tarball_url, integrity, opts \\ []) do
    dest = package_dir(name, version)

    if cached?(name, version) do
      {:ok, dest}
    else
      try do
        RegistryPolicy.validate_url!(tarball_url)

        case NPM.Tarball.fetch_and_extract(tarball_url, integrity, dest) do
          {:ok, _count} ->
            {:ok, dest}

          {:error, reason} ->
            handle_fetch_error(reason, dest, opts)
        end
      rescue
        error in RegistryPolicy.Error ->
          handle_fetch_error(error, dest, opts)
      end
    end
  end

  defp handle_fetch_error(reason, dest, opts) do
    if Keyword.get(opts, :optional?, false) do
      File.rm_rf(dest)
      {:ok, :missing_optional}
    else
      {:error, reason}
    end
  end
end
