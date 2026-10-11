defmodule NPM.RegistryTest do
  use ExUnit.Case, async: false

  defmodule Server do
    @moduledoc false
    import Plug.Conn

    def init(options), do: options

    def call(conn, {owner, attempts}) do
      attempt = Agent.get_and_update(attempts, fn count -> {count, count + 1} end)
      send(owner, {:registry_request, conn.request_path, conn.req_headers})

      case conn.request_path do
        "/retry" when attempt == 0 ->
          send_resp(conn, 503, "unavailable")

        _ ->
          body = JSON.encode!(%{"name" => "example", "versions" => %{"1.0.0" => %{}}})

          conn
          |> put_resp_content_type("application/vnd.npm.install-v1+json")
          |> put_resp_header("content-encoding", "gzip")
          |> send_resp(200, :zlib.gzip(body))
      end
    end
  end

  setup do
    old_registry = Application.get_env(:duskmoon_npm, :registry)
    old_allowed = Application.get_env(:duskmoon_npm, :allowed_registries)
    old_env_allowed = System.get_env("NPM_EX_ALLOWED_REGISTRIES")

    System.delete_env("NPM_EX_ALLOWED_REGISTRIES")

    on_exit(fn ->
      restore_app_env(:registry, old_registry)
      restore_app_env(:allowed_registries, old_allowed)
      restore_env("NPM_EX_ALLOWED_REGISTRIES", old_env_allowed)
    end)

    :ok
  end

  @tag :tmp_dir
  test "fetches compressed registry metadata and retries service failures", %{tmp_dir: dir} do
    configure_http_registry(dir)

    assert {:ok, %{name: "example", versions: %{"1.0.0" => _}}} =
             NPM.Registry.get_packument("retry")

    assert_received {:registry_request, "/retry", headers}
    assert {"accept", "application/vnd.npm.install-v1+json"} in headers
    assert {"authorization", "Bearer registry-test-token"} in headers
    assert_received {:registry_request, "/retry", _headers}

    assert {:ok, %{name: "example"}} = NPM.Registry.get_packument("retry")
    refute_received {:registry_request, _, _headers}
  end

  test "rewrites integrity-protected tarballs to the configured registry origin" do
    Application.put_env(:duskmoon_npm, :registry, "https://npm.gsmlg.dev")
    Application.put_env(:duskmoon_npm, :allowed_registries, ["https://npm.gsmlg.dev"])

    assert NPM.Registry.__normalized_tarball_url__(
             "@scope/pkg",
             "1.2.3",
             "https://registry.npmjs.org/@scope/pkg/-/pkg-1.2.3.tgz",
             "sha512-hash"
           ) == "https://npm.gsmlg.dev/@scope%2fpkg/-/pkg-1.2.3.tgz"
  end

  test "keeps no-integrity cross-origin tarballs for later fetch-time validation" do
    Application.put_env(:duskmoon_npm, :registry, "https://npm.gsmlg.dev")
    Application.put_env(:duskmoon_npm, :allowed_registries, ["https://npm.gsmlg.dev"])

    assert NPM.Registry.__normalized_tarball_url__(
             "pkg",
             "1.2.3",
             "https://registry.npmjs.org/pkg/-/pkg-1.2.3.tgz",
             ""
           ) == "https://registry.npmjs.org/pkg/-/pkg-1.2.3.tgz"
  end

  defp restore_app_env(key, nil), do: Application.delete_env(:duskmoon_npm, key)
  defp restore_app_env(key, value), do: Application.put_env(:duskmoon_npm, key, value)

  defp restore_env(key, nil), do: System.delete_env(key)
  defp restore_env(key, value), do: System.put_env(key, value)

  defp configure_http_registry(dir) do
    for key <- [
          "NPM_REGISTRY",
          "NPM_TOKEN",
          "NPM_EX_CACHE_DIR",
          "NPM_EX_ALLOW_REGISTRY_REDIRECTS"
        ] do
      value = System.get_env(key)
      System.delete_env(key)
      on_exit(fn -> restore_env(key, value) end)
    end

    for {key, value} <- [
          cache_dir: dir,
          token: "registry-test-token",
          allow_registry_redirects: false
        ] do
      old_value = Application.get_env(:duskmoon_npm, key)
      Application.put_env(:duskmoon_npm, key, value)
      on_exit(fn -> restore_app_env(key, old_value) end)
    end

    attempts = start_supervised!({Agent, fn -> 0 end})

    server =
      start_supervised!({Bandit, plug: {Server, {self(), attempts}}, ip: {127, 0, 0, 1}, port: 0})

    {:ok, {_ip, port}} = ThousandIsland.listener_info(server)
    registry = "http://127.0.0.1:#{port}"
    Application.put_env(:duskmoon_npm, :registry, registry)
    Application.put_env(:duskmoon_npm, :allowed_registries, [registry])
  end
end
