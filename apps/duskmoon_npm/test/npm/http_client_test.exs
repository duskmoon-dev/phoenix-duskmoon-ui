defmodule NPM.HTTPClientTest do
  use ExUnit.Case, async: true

  defmodule Server do
    @moduledoc false
    import Plug.Conn

    def init(owner), do: owner

    def call(conn, owner) do
      case conn.request_path do
        "/json" ->
          conn |> put_resp_content_type("application/json") |> send_resp(200, ~s({"ok":true}))

        "/gzip" ->
          conn
          |> put_resp_content_type("application/json")
          |> put_resp_header("content-encoding", "gzip")
          |> send_resp(200, :zlib.gzip(~s({"ok":true})))

        "/deflate" ->
          conn
          |> put_resp_content_type("application/json")
          |> put_resp_header("content-encoding", "deflate")
          |> send_resp(200, :zlib.compress(~s({"ok":true})))

        "/gzip-chunked" ->
          body = :zlib.gzip(~s({"ok":true}))
          <<first::binary-size(10), last::binary>> = body

          conn =
            conn
            |> put_resp_content_type("application/json")
            |> put_resp_header("content-encoding", "gzip")
            |> send_chunked(200)

          {:ok, conn} = chunk(conn, first)
          {:ok, conn} = chunk(conn, last)
          conn

        "/invalid-gzip" ->
          conn
          |> put_resp_content_type("application/json")
          |> put_resp_header("content-encoding", "gzip")
          |> send_resp(200, "invalid compressed bytes")

        "/invalid-gzip-chunked" ->
          conn =
            conn
            |> put_resp_content_type("application/json")
            |> put_resp_header("content-encoding", "gzip")
            |> send_chunked(200)

          {:ok, conn} = chunk(conn, "invalid compressed bytes")
          conn

        "/redirect" ->
          conn |> put_resp_header("location", "/json") |> send_resp(302, "")

        "/echo" ->
          {:ok, body, conn} = read_body(conn)
          send(owner, {:request, conn.method, conn.req_headers, body})
          conn |> put_resp_content_type("application/json") |> send_resp(200, body)

        "/slow" ->
          Process.sleep(100)
          send_resp(conn, 200, "late")

        "/invalid-json" ->
          conn |> put_resp_content_type("application/json") |> send_resp(200, "{")

        "/osv" ->
          {:ok, body, conn} = read_body(conn)
          send(owner, {:osv_request, NPM.JSON.decode!(body)})

          conn
          |> put_resp_content_type("application/json")
          |> send_resp(200, ~s({"vulns":[{"id":"MAL-123"},{"id":"CVE-123"}]}))

        "/osv-batch" ->
          {:ok, body, conn} = read_body(conn)
          send(owner, {:osv_request, NPM.JSON.decode!(body)})

          conn
          |> put_resp_content_type("application/json")
          |> send_resp(200, ~s({"results":[{"vulns":[{"id":"MAL-123"}]}]}))

        _ ->
          send_resp(conn, 404, "missing")
      end
    end
  end

  setup do
    server = start_supervised!({Bandit, plug: {Server, self()}, ip: {127, 0, 0, 1}, port: 0})
    {:ok, {_ip, port}} = ThousandIsland.listener_info(server)
    %{url: "http://127.0.0.1:#{port}"}
  end

  test "decodes JSON while preserving raw responses on request", %{url: url} do
    assert {:ok, %{status: 200, body: %{"ok" => true}}} = NPM.HTTPClient.get(url <> "/json")

    assert {:ok, %{body: ~s({"ok":true})}} =
             NPM.HTTPClient.get(url <> "/json", decode_body: false)
  end

  test "decodes HTTP gzip and deflate before JSON or raw body processing", %{url: url} do
    for path <- ["/gzip", "/deflate", "/gzip-chunked"] do
      assert {:ok, %{body: %{"ok" => true}}} = NPM.HTTPClient.get(url <> path)

      assert {:ok, %{body: ~s({"ok":true})}} =
               NPM.HTTPClient.get(url <> path, decode_body: false)
    end
  end

  test "returns malformed compression as an error instead of decoding partial JSON", %{url: url} do
    assert {:error, {:invalid_content_encoding, "gzip"}} =
             NPM.HTTPClient.get(url <> "/invalid-gzip")

    assert {:error, {:invalid_content_encoding, "gzip"}} =
             NPM.HTTPClient.get(url <> "/invalid-gzip", decode_body: false)

    assert {:error, %RuntimeError{}} = NPM.HTTPClient.get(url <> "/invalid-gzip-chunked")
  end

  test "sends JSON and authorization headers", %{url: url} do
    assert {:ok, %{body: %{"package" => "example"}}} =
             NPM.HTTPClient.post(url <> "/echo",
               json: %{"package" => "example"},
               headers: [authorization: "Bearer test-token"]
             )

    assert_received {:request, "POST", headers, ~s({"package":"example"})}
    assert {"authorization", "Bearer test-token"} in headers
    assert {"content-type", "application/json"} in headers
    assert {"accept-encoding", "gzip, deflate"} in headers
  end

  test "sends raw PUT bodies", %{url: url} do
    assert {:ok, %{body: %{"version" => "1.0.0"}}} =
             NPM.HTTPClient.put(url <> "/echo",
               body: ~s({"version":"1.0.0"}),
               headers: [{"content-type", "application/json"}, {"Accept-Encoding", "identity"}]
             )

    assert_received {:request, "PUT", headers, ~s({"version":"1.0.0"})}
    assert {"accept-encoding", "identity"} in headers
    refute {"accept-encoding", "gzip, deflate"} in headers
  end

  test "returns redirects when disabled and follows them by default", %{url: url} do
    assert {:ok, %{status: 302}} = NPM.HTTPClient.get(url <> "/redirect", redirect: false)
    assert {:ok, %{status: 200, body: %{"ok" => true}}} = NPM.HTTPClient.get(url <> "/redirect")
  end

  test "keeps HTTP errors available and reports timeout and JSON failures", %{url: url} do
    assert {:ok, %{status: 404, body: "missing"}} = NPM.HTTPClient.get(url <> "/missing")
    assert {:error, _reason} = NPM.HTTPClient.get(url <> "/slow", timeout: 10)
    assert {:error, %Jason.DecodeError{}} = NPM.HTTPClient.get(url <> "/invalid-json")
  end

  test "returns errors for incomplete response bodies" do
    {:ok, listener} = :gen_tcp.listen(0, [:binary, active: false, ip: {127, 0, 0, 1}])
    on_exit(fn -> :gen_tcp.close(listener) end)
    {:ok, {_ip, port}} = :inet.sockname(listener)

    server =
      Task.async(fn ->
        {:ok, socket} = :gen_tcp.accept(listener)
        {:ok, _request} = :gen_tcp.recv(socket, 0, 1_000)
        :ok = :gen_tcp.send(socket, "HTTP/1.1 200 OK\r\nContent-Length: 20\r\n\r\nshort")
        :gen_tcp.close(socket)
      end)

    assert {:error, _reason} = NPM.HTTPClient.get("http://127.0.0.1:#{port}")
    Task.await(server)
  end

  test "OSV single and batch queries retain their JSON contracts", %{url: url} do
    assert {:ok, [%{"id" => "MAL-123"}]} =
             NPM.Security.Compromised.OSV.query_package("example", "1.0.0",
               endpoint: url <> "/osv"
             )

    assert_received {:osv_request,
                     %{
                       "package" => %{"name" => "example", "ecosystem" => "npm"},
                       "version" => "1.0.0"
                     }}

    assert {:ok, %{"example" => [%{"id" => "MAL-123"}]}} =
             NPM.Security.Compromised.OSV.query_packages(
               [{"example", "1.0.0"}, {"example", "1.0.0"}],
               batch_endpoint: url <> "/osv-batch"
             )

    assert_received {:osv_request, %{"queries" => [_one_query]}}
  end
end
