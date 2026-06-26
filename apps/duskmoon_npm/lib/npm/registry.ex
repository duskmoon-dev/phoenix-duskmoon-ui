defmodule NPM.Registry do
  alias NPM.Security.RegistryPolicy

  @moduledoc """
  HTTP client for the npm registry.

  Fetches abbreviated packuments (version list + deps + dist info)
  using the npm registry API.
  """

  @max_retries 3

  @type packument :: %{
          name: String.t(),
          versions: %{String.t() => version_info()}
        }

  @type version_info :: %{
          dependencies: %{String.t() => String.t()},
          optional_dependencies: %{String.t() => String.t()},
          peer_dependencies: %{String.t() => String.t()},
          peer_dependencies_meta: %{String.t() => map()},
          bin: %{optional(String.t()) => String.t()},
          engines: %{String.t() => String.t()},
          os: [String.t()],
          cpu: [String.t()],
          has_install_script: boolean(),
          deprecated: String.t() | nil,
          created_at: String.t() | nil,
          published_at: String.t() | nil,
          dist: %{
            tarball: String.t(),
            integrity: String.t(),
            file_count: integer() | nil,
            unpacked_size: integer() | nil
          }
        }

  @doc "Get the configured registry URL."
  @spec registry_url :: String.t()
  def registry_url do
    NPM.Config.registry()
  end

  @doc "Fetch the abbreviated packument for a package."
  @spec get_packument(String.t()) :: {:ok, packument()} | {:error, term()}
  def get_packument(package) do
    case NPM.PackumentCache.get(package) do
      {:ok, packument} ->
        {:ok, packument}

      :miss ->
        fetch_packument(package)
    end
  end

  defp fetch_packument(package) do
    url = "#{registry_url()}/#{encode_package(package)}"
    headers = auth_headers() ++ [accept: "application/vnd.npm.install-v1+json"]
    fetch_with_retry(package, url, headers, @max_retries)
  end

  defp fetch_with_retry(package, url, headers, retries_left) do
    RegistryPolicy.validate_url!(url)

    result =
      Req.get(url,
        headers: headers,
        decode_body: false,
        redirect: NPM.Config.allow_registry_redirects?()
      )

    case classify_result(result) do
      {:ok, body} ->
        packument = body |> decode_body() |> parse_packument()
        NPM.PackumentCache.put(package, packument)
        {:ok, packument}

      {:retry, _} when retries_left > 0 ->
        retry(package, url, headers, retries_left)

      {_, error} ->
        error
    end
  end

  defp classify_result({:ok, %{status: 200, body: body}}), do: {:ok, body}
  defp classify_result({:ok, %{status: 404}}), do: {:error, {:error, :not_found}}
  defp classify_result({:ok, %{status: 401}}), do: {:error, {:error, :unauthorized}}
  defp classify_result({:ok, %{status: 403}}), do: {:error, {:error, :forbidden}}
  defp classify_result({:ok, %{status: s}}) when s >= 500, do: {:retry, {:error, {:http, s}}}
  defp classify_result({:ok, %{status: s}}), do: {:error, {:error, {:http, s}}}
  defp classify_result({:error, reason}), do: {:retry, {:error, reason}}

  defp retry(package, url, headers, retries_left) do
    Process.sleep(1000 * (@max_retries - retries_left + 1))
    fetch_with_retry(package, url, headers, retries_left - 1)
  end

  defp auth_headers do
    case NPM.Config.auth_token() do
      nil -> []
      token -> [authorization: "Bearer #{token}"]
    end
  end

  @doc "URL-encode a package name (handles scoped packages)."
  @spec encode_package(String.t()) :: String.t()
  def encode_package(package), do: String.replace(package, "/", "%2f")

  defp decode_body(body) when is_binary(body), do: NPM.JSON.decode!(body)
  defp decode_body(body) when is_map(body), do: body

  defp parse_packument(data) do
    times = Map.get(data, "time", %{})

    versions =
      for {version_str, info} <- Map.get(data, "versions", %{}), into: %{} do
        {version_str, parse_version_info(info, times)}
      end

    %{name: Map.get(data, "name", ""), versions: versions}
  end

  defp parse_version_info(info, times) do
    dist = Map.get(info, "dist", %{})
    tarball = Map.get(dist, "tarball", "")
    RegistryPolicy.validate_url!(tarball)

    %{
      dependencies: Map.get(info, "dependencies", %{}),
      peer_dependencies: Map.get(info, "peerDependencies", %{}),
      peer_dependencies_meta: Map.get(info, "peerDependenciesMeta", %{}),
      optional_dependencies: Map.get(info, "optionalDependencies", %{}),
      bin: parse_bin(info),
      engines: Map.get(info, "engines", %{}),
      os: Map.get(info, "os", []),
      cpu: Map.get(info, "cpu", []),
      has_install_script: Map.get(info, "hasInstallScript", false),
      deprecated: Map.get(info, "deprecated", nil),
      created_at: Map.get(times, "created"),
      published_at: Map.get(times, Map.get(info, "version", "")),
      dist: %{
        tarball: tarball,
        integrity: Map.get(dist, "integrity", ""),
        file_count: Map.get(dist, "fileCount"),
        unpacked_size: Map.get(dist, "unpackedSize")
      }
    }
  end

  defp parse_bin(%{"bin" => bin}) when is_map(bin), do: bin
  defp parse_bin(%{"bin" => bin}) when is_binary(bin), do: %{}
  defp parse_bin(_), do: %{}
end
