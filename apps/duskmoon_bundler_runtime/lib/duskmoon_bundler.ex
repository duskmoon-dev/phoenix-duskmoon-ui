defmodule DuskmoonBundler do
  @moduledoc """
  Runtime helpers for DuskmoonBundler-managed production assets.

  `DuskmoonBundler.static_path/2` and `DuskmoonBundler.Preload.tags/2` are kept
  in this namespace so existing Phoenix templates continue to work while the
  heavy build and development toolchain lives in the `:duskmoon_bundler` app.
  """

  alias DuskmoonBundler.Runtime.Config
  alias DuskmoonBundler.StaticPath
  alias DuskmoonBundler.URL

  @doc """
  Returns the browser path for a DuskmoonBundler-managed static asset.

  In development, JavaScript entry paths point at the source module served by
  `DuskmoonBundler.DevServer`. In production, this reads `manifest.json` and
  returns the built asset path, passing the result through Phoenix
  `static_path/1` when an endpoint is available.
  """
  def static_path(conn_or_socket_or_endpoint_or_uri, path, overrides \\ []) do
    profile = Keyword.get(overrides, :profile)
    config = Config.resolve(profile, Keyword.delete(overrides, :profile))
    endpoint = Config.endpoint_from(conn_or_socket_or_endpoint_or_uri)

    resolved_path =
      if Config.code_reloader?(endpoint) do
        dev_static_path(path, config)
      else
        built_static_path(conn_or_socket_or_endpoint_or_uri, path, config)
      end

    conn_or_socket_or_endpoint_or_uri
    |> phoenix_static_path(resolved_path)
    |> ensure_leading_slash()
  end

  @doc """
  Returns the browser URL for a DuskmoonBundler-managed static asset.
  """
  def static_url(conn_or_socket_or_endpoint, path, overrides \\ []) do
    resolved_path = static_path(conn_or_socket_or_endpoint, path, overrides)

    case conn_or_socket_or_endpoint do
      %{__struct__: Plug.Conn, private: %{phoenix_static_url: static_url}} ->
        static_url <> resolved_path

      %{__struct__: Plug.Conn, private: %{phoenix_endpoint: endpoint}} ->
        endpoint.static_url() <> resolved_path

      %{endpoint: endpoint} ->
        endpoint.static_url() <> resolved_path

      endpoint when is_atom(endpoint) ->
        endpoint.static_url() <> resolved_path

      other ->
        raise ArgumentError,
              "expected a %Plug.Conn{}, a %Phoenix.Socket{}, a struct with an :endpoint key, " <>
                "or a Phoenix.Endpoint when building static url for #{path}, got: #{inspect(other)}"
    end
  end

  @doc """
  Returns the browser path for the configured DuskmoonBundler entry.

  In development this points at the source module served by `DuskmoonBundler.DevServer`.
  In production it reads `manifest.json` and returns the built asset path.
  """
  @deprecated "use DuskmoonBundler.static_path/2 with the compiled asset path instead"
  def entry_path(endpoint, overrides \\ []) do
    profile = Keyword.get(overrides, :profile)
    config = Config.resolve(profile, Keyword.delete(overrides, :profile))
    name = config.name || entry_name(config.entry)

    static_path(endpoint, URL.join(URL.join(config.prefix, "js"), "#{name}.js"), overrides)
  end

  defp dev_static_path(path, config) do
    name = config.name || entry_name(config.entry)
    js_path = URL.join(URL.join(config.prefix, "js"), "#{name}.js")

    if normalize_path(path) == normalize_path(js_path) do
      config.prefix
      |> Path.join(Path.relative_to(config.entry |> List.wrap() |> hd(), config.root))
      |> ensure_leading_slash()
    else
      ensure_leading_slash(path)
    end
  end

  defp built_static_path(conn_or_socket_or_endpoint_or_uri, path, config) do
    case StaticPath.resolve(conn_or_socket_or_endpoint_or_uri, path, config) do
      {:ok, resolved_path} -> resolved_path
      {:error, _error} -> ensure_leading_slash(path)
    end
  end

  defp phoenix_static_path(%{__struct__: Plug.Conn, private: private}, path) do
    case private do
      %{phoenix_static_url: _} -> path
      %{phoenix_endpoint: endpoint} -> safe_endpoint_static_path(endpoint, path)
      _ -> path
    end
  end

  defp phoenix_static_path(%URI{} = uri, path), do: (uri.path || "") <> path

  defp phoenix_static_path(%{endpoint: endpoint}, path),
    do: safe_endpoint_static_path(endpoint, path)

  defp phoenix_static_path(endpoint, path) when is_atom(endpoint),
    do: safe_endpoint_static_path(endpoint, path)

  defp phoenix_static_path(_other, path), do: path

  defp safe_endpoint_static_path(endpoint, path) do
    endpoint.static_path(path)
  rescue
    UndefinedFunctionError -> path
  end

  defp entry_name(entry) do
    entry
    |> List.wrap()
    |> hd()
    |> Path.basename()
    |> Path.rootname()
  end

  defp normalize_path(path), do: "/" <> (path |> to_string() |> String.trim_leading("/"))

  defp ensure_leading_slash("/" <> _ = path), do: path
  defp ensure_leading_slash(path), do: "/" <> path
end
