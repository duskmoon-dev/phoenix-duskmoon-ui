defmodule DuskmoonBundler.Runtime.Config do
  @moduledoc """
  Runtime-safe DuskmoonBundler configuration reader.

  This module intentionally reads application environment directly and avoids
  `Mix.env/0` and build-pipeline structs so it can run inside releases.
  """

  alias DuskmoonBundler.Paths

  defstruct entry: Paths.entry(),
            outdir: Paths.static(),
            prefix: Paths.prefix(),
            root: Paths.assets(),
            name: nil

  @keys [:entry, :outdir, :prefix, :root, :name]

  @doc """
  Resolve runtime asset configuration.

  Existing projects keep their `config :duskmoon_bundler` settings. The runtime
  app also accepts `config :duskmoon_bundler_runtime` for release-only overrides.
  """
  def resolve(profile \\ nil, overrides \\ []) do
    runtime_flat = Application.get_all_env(:duskmoon_bundler_runtime)
    bundler_flat = Application.get_all_env(:duskmoon_bundler)

    runtime_profile = profile_env(:duskmoon_bundler_runtime, profile)
    bundler_profile = profile_env(:duskmoon_bundler, profile)

    %__MODULE__{}
    |> Map.merge(take_config(bundler_flat))
    |> Map.merge(take_config(runtime_flat))
    |> Map.merge(take_config(bundler_profile))
    |> Map.merge(take_config(runtime_profile))
    |> Map.merge(%{prefix: prefix(runtime_flat, bundler_flat, runtime_profile, bundler_profile)})
    |> Map.merge(overrides |> Keyword.take(@keys) |> Map.new())
  end

  def endpoint_from(%{__struct__: Plug.Conn, private: %{phoenix_endpoint: endpoint}}),
    do: endpoint

  def endpoint_from(%{endpoint: endpoint}), do: endpoint
  def endpoint_from(endpoint) when is_atom(endpoint), do: endpoint
  def endpoint_from(_other), do: nil

  def otp_app(nil), do: nil

  def otp_app(endpoint) do
    endpoint.config(:otp_app)
  rescue
    _ -> nil
  end

  def code_reloader?(nil), do: false

  def code_reloader?(endpoint) do
    endpoint.config(:code_reloader)
  rescue
    _ -> false
  end

  defp profile_env(_app, nil), do: []

  defp profile_env(app, profile) when is_atom(profile) do
    Application.get_env(app, profile, [])
  end

  defp take_config(config) do
    config
    |> Keyword.take(@keys)
    |> Map.new()
  end

  defp prefix(runtime_flat, bundler_flat, runtime_profile, bundler_profile) do
    profile_server_prefix =
      Keyword.get(runtime_profile, :server, [])
      |> Keyword.get(:prefix)

    bundler_profile_server_prefix =
      Keyword.get(bundler_profile, :server, [])
      |> Keyword.get(:prefix)

    runtime_server_prefix =
      Keyword.get(runtime_flat, :server, [])
      |> Keyword.get(:prefix)

    bundler_server_prefix =
      Keyword.get(bundler_flat, :server, [])
      |> Keyword.get(:prefix)

    profile_server_prefix ||
      bundler_profile_server_prefix ||
      runtime_server_prefix ||
      bundler_server_prefix ||
      Keyword.get(runtime_profile, :prefix) ||
      Keyword.get(bundler_profile, :prefix) ||
      Keyword.get(runtime_flat, :prefix) ||
      Keyword.get(bundler_flat, :prefix) ||
      Paths.prefix()
  end
end
