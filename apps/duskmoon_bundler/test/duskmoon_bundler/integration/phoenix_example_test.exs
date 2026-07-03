defmodule DuskmoonBundler.Integration.PhoenixExampleTest do
  use ExUnit.Case, async: false

  @moduletag :integration

  import Plug.Test
  import Plug.Conn

  @app_dir Path.expand("../../..", __DIR__)
  @example_dir Path.expand("fixtures/vanilla", __DIR__)
  @assets_root Path.join(@example_dir, "assets")

  describe "dev server" do
    setup do
      DuskmoonBundler.Cache.clear()
      :ok
    end

    test "serves entry module with HMR preamble and rewritten imports" do
      conn = call_dev_server("/assets/js/app.ts")

      assert conn.status == 200
      assert content_type(conn) =~ "javascript"
      assert conn.resp_body =~ "createHotContext"
      assert conn.resp_body =~ "/@vendor/phoenix.js"
      assert conn.resp_body =~ "/@vendor/phoenix_html.js"
      assert conn.resp_body =~ "/@vendor/phoenix_live_view.js"
      refute conn.resp_body =~ ~s(from 'phoenix')
      refute conn.resp_body =~ ~s(from 'phoenix_html')
      refute conn.resp_body =~ ~s(from 'phoenix_live_view')
    end

    test "serves hook modules with HMR preamble" do
      conn = call_dev_server("/assets/js/hooks/clock.ts")

      assert conn.status == 200
      assert conn.resp_body =~ "createHotContext"
      assert conn.resp_body =~ "clearInterval"
    end

    test "rewrites relative imports to absolute dev paths" do
      conn = call_dev_server("/assets/js/app.ts")

      assert conn.resp_body =~ "/assets/js/hooks/clock"
      assert conn.resp_body =~ "/assets/js/hooks/env-mode"
    end

    test "serves vendor phoenix module" do
      conn = call_dev_server("/@vendor/phoenix.js")

      assert conn.status == 200
      assert content_type(conn) =~ "javascript"
      assert conn.resp_body =~ "Socket"
      assert conn.resp_body =~ "Channel"
    end

    test "serves vendor phoenix_live_view module" do
      conn = call_dev_server("/@vendor/phoenix_live_view.js")

      assert conn.status == 200
      assert content_type(conn) =~ "javascript"
      assert conn.resp_body =~ "LiveSocket"
    end

    test "serves vendor phoenix_html module" do
      conn = call_dev_server("/@vendor/phoenix_html.js")

      assert conn.status == 200
      assert content_type(conn) =~ "javascript"
    end

    test "serves JSON modules" do
      conn = call_dev_server("/assets/js/config.json")

      assert conn.status == 200
      assert conn.resp_body =~ "export default"
    end

    test "serves static assets" do
      conn = call_dev_server("/assets/images/duskmoon_bundler.svg")

      assert conn.status == 200
      assert content_type(conn) =~ "svg"
    end
  end

  defp call_dev_server(path) do
    opts =
      DuskmoonBundler.DevServer.init(
        root: @assets_root,
        prefix: "/assets",
        resolve_dirs: [Path.expand("../../deps", @app_dir)]
      )

    conn(:get, path) |> DuskmoonBundler.DevServer.call(opts)
  end

  defp content_type(conn) do
    get_resp_header(conn, "content-type") |> hd()
  end
end

defmodule DuskmoonBundler.Integration.PhoenixExampleBuildTest do
  use ExUnit.Case, async: false

  @moduletag :integration

  @app_dir Path.expand("../../..", __DIR__)
  @example_dir Path.expand("fixtures/vanilla", __DIR__)
  @assets_root Path.join(@example_dir, "assets")
  @outdir Path.join(@example_dir, "priv/static/assets")

  defmodule Endpoint do
    def config(:code_reloader), do: false
    def static_path(path), do: path
  end

  setup_all do
    File.rm_rf!(Path.join(@outdir, "js"))
    File.rm_rf!(Path.join(@outdir, "css"))
    on_exit(fn -> File.rm_rf!(@outdir) end)

    {output, status} =
      System.cmd("mix", build_args(),
        cd: @app_dir,
        env: [
          {"NPM_EX_ALLOWED_REGISTRIES",
           "https://registry.npmjs.org,https://npm.gsmlg.dev,https://nexus.gsmlg.net"}
        ],
        stderr_to_stdout: true
      )

    %{build_output: output, build_status: status}
  end

  test "exits successfully", %{build_status: status} do
    assert status == 0
  end

  test "produces JS bundle with Phoenix deps bundled in", %{build_status: 0} do
    js = File.read!(js_path())

    assert js =~ "LiveSocket"
    assert js =~ "phoenix"
    assert js =~ "_csrf_token"
    refute js =~ ~s(import "phoenix")
    refute js =~ ~s(import "phoenix_html")
  end

  test "includes glob imports in bundle", %{build_status: 0} do
    js = File.read!(js_path())

    assert js =~ "About"
    assert js =~ "Built with DuskmoonBundler"
    assert js =~ "Home"
  end

  test "produces valid manifest", %{build_status: 0} do
    manifest = @outdir |> Path.join("js/manifest.json") |> read_manifest_entries()

    assert_manifest_version(@outdir |> Path.join("js/manifest.json"))
    assert Map.has_key?(manifest, "app.js")
    assert manifest["app.js"]["file"] =~ ~r/^app-[a-f0-9]{8}\.js$/
  end

  test "produces valid Tailwind manifest", %{build_status: 0} do
    manifest = @outdir |> Path.join("css/manifest.json") |> read_manifest_entries()

    assert_manifest_version(@outdir |> Path.join("css/manifest.json"))
    assert Map.has_key?(manifest, "app.css")
    assert manifest["app.css"]["file"] =~ ~r/^app-[a-f0-9]{8}\.css$/
  end

  test "produces Tailwind CSS with utility classes from heex templates", %{build_status: 0} do
    manifest = @outdir |> Path.join("css/manifest.json") |> read_manifest_entries()
    css = File.read!(Path.join([@outdir, "css", manifest["app.css"]["file"]]))

    assert css =~ "rounded-2xl"
    assert css =~ "bg-amber-600"
    assert css =~ "font-semibold"
  end

  test "generates sourcemap", %{build_status: 0} do
    manifest = @outdir |> Path.join("js/manifest.json") |> read_manifest_entries()
    map_path = manifest["app.js"]["file"] <> ".map"
    map = [@outdir, "js", map_path] |> Path.join() |> File.read!() |> Jason.decode!()

    assert map["version"] == 3
  end

  test "DuskmoonBundler.static_path resolves hashed production assets", %{build_status: 0} do
    assert DuskmoonBundler.static_path(
             DuskmoonBundler.Integration.PhoenixExampleBuildTest.Endpoint,
             "/assets/js/app.js",
             outdir: @outdir,
             prefix: "/assets"
           ) =~ ~r|^/assets/js/app-[a-f0-9]{8}\.js$|

    assert DuskmoonBundler.static_path(
             DuskmoonBundler.Integration.PhoenixExampleBuildTest.Endpoint,
             "/assets/css/app.css",
             outdir: @outdir,
             prefix: "/assets"
           ) =~ ~r|^/assets/css/app-[a-f0-9]{8}\.css$|
  end

  defp js_path do
    manifest = @outdir |> Path.join("js/manifest.json") |> read_manifest_entries()
    Path.join([@outdir, "js", manifest["app.js"]["file"]])
  end

  defp build_args do
    [
      "duskmoon_bundler.build",
      "--entry",
      Path.join(@assets_root, "js/app.ts"),
      "--outdir",
      @outdir,
      "--tailwind",
      "--tailwind-css",
      Path.join(@assets_root, "css/app.css"),
      "--tailwind-source",
      Path.join(@example_dir, "lib"),
      "--resolve-dir",
      Path.expand("../../deps", @app_dir),
      "--hash",
      "--no-minify"
    ]
  end

  defp read_manifest_entries(path) do
    path
    |> File.read!()
    |> Jason.decode!()
    |> DuskmoonBundler.Manifest.entries!()
  end

  defp assert_manifest_version(path) do
    assert %{"manifest_version" => 1, "entries" => entries} =
             path |> File.read!() |> Jason.decode!()

    assert is_map(entries)
  end
end
