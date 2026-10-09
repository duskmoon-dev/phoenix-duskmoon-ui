defmodule NPM.TarballTest do
  use ExUnit.Case, async: true

  defmodule Server do
    @moduledoc false
    import Plug.Conn

    def init(tarball), do: tarball

    def call(conn, tarball) do
      case conn.request_path do
        "/redirect" ->
          conn |> put_resp_header("location", "/package.tgz") |> send_resp(302, "")

        "/transport-gzip" ->
          conn
          |> put_resp_content_type("application/octet-stream")
          |> put_resp_header("content-encoding", "gzip")
          |> send_resp(200, :zlib.gzip(tarball))

        _ ->
          conn |> put_resp_content_type("application/octet-stream") |> send_resp(200, tarball)
      end
    end
  end

  @tag :tmp_dir
  test "downloads archive bytes, checks integrity, follows redirects and extracts", %{
    tmp_dir: dir
  } do
    archive = Path.join(dir, "package.tgz")

    :ok =
      :erl_tar.create(
        String.to_charlist(archive),
        [{~c"package/index.js", "export default 1"}],
        [:compressed]
      )

    body = File.read!(archive)
    integrity = "sha512-" <> Base.encode64(:crypto.hash(:sha512, body))
    server = start_supervised!({Bandit, plug: {Server, body}, ip: {127, 0, 0, 1}, port: 0})
    {:ok, {_ip, port}} = ThousandIsland.listener_info(server)
    dest = Path.join(dir, "extracted")

    assert {:ok, 1} =
             NPM.Tarball.fetch_and_extract("http://127.0.0.1:#{port}/redirect", integrity, dest)

    assert File.read!(Path.join(dest, "index.js")) == "export default 1"

    assert {:ok, 1} =
             NPM.Tarball.fetch_and_extract(
               "http://127.0.0.1:#{port}/transport-gzip",
               integrity,
               dest
             )

    assert {:error, :integrity_mismatch} =
             NPM.Tarball.fetch_and_extract(
               "http://127.0.0.1:#{port}/package.tgz",
               "sha512-invalid",
               dest
             )
  end
end
