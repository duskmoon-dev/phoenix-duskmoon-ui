defmodule VoltTest do
  use ExUnit.Case, async: true
  doctest DuskmoonBundler

  defmodule DevEndpoint do
    def config(:code_reloader), do: true
  end

  defmodule ProdEndpoint do
    def config(:code_reloader), do: false
  end

  defmodule StaticEndpoint do
    def config(:code_reloader), do: false
    def static_path("/assets/js/app.js"), do: "/assets/js/app-digested.js?vsn=d"
    def static_path(path), do: path
  end

  test "static_path points at source entry in development" do
    assert DuskmoonBundler.static_path(DevEndpoint, "/assets/js/app.js",
             entry: "assets/js/app.tsx",
             root: "assets",
             prefix: "/assets"
           ) == "/assets/js/app.tsx"
  end

  test "static_path reads production manifest" do
    outdir = tmp_dir("manifest")
    File.mkdir_p!(outdir)
    File.write!(Path.join(outdir, "manifest.json"), ~s({"app.js":{"file":"app-deadbeef.js"}}))

    assert DuskmoonBundler.static_path(ProdEndpoint, "/assets/js/app.js",
             entry: "assets/js/app.ts",
             outdir: outdir,
             prefix: "/assets"
           ) == "/assets/app-deadbeef.js"
  end

  test "static_path reads production manifest from build task js directory" do
    outdir = tmp_dir("manifest-js")
    js_outdir = Path.join(outdir, "js")
    File.mkdir_p!(js_outdir)
    File.write!(Path.join(js_outdir, "manifest.json"), ~s({"app.js":{"file":"app-cafebabe.js"}}))

    assert DuskmoonBundler.static_path(ProdEndpoint, "/assets/js/app.js",
             entry: "assets/js/app.ts",
             outdir: outdir,
             prefix: "/assets"
           ) == "/assets/js/app-cafebabe.js"
  end

  test "static_path prefers root manifest for backwards compatibility" do
    outdir = tmp_dir("manifest-precedence")
    js_outdir = Path.join(outdir, "js")
    File.mkdir_p!(js_outdir)
    File.write!(Path.join(outdir, "manifest.json"), ~s({"app.js":{"file":"app-root.js"}}))
    File.write!(Path.join(js_outdir, "manifest.json"), ~s({"app.js":{"file":"app-js.js"}}))

    assert DuskmoonBundler.static_path(ProdEndpoint, "/assets/js/app.js",
             entry: "assets/js/app.ts",
             outdir: outdir,
             prefix: "/assets"
           ) == "/assets/app-root.js"
  end

  test "static_path falls back to original path when manifest is missing" do
    outdir = tmp_dir("manifest-missing")

    assert DuskmoonBundler.static_path(ProdEndpoint, "/assets/js/app.js",
             entry: "assets/js/app.ts",
             outdir: outdir,
             prefix: "/assets"
           ) == "/assets/js/app.js"
  end

  test "static_path uses endpoint static_path for Phoenix digest lookup" do
    outdir = tmp_dir("manifest-static-path")
    js_outdir = Path.join(outdir, "js")
    File.mkdir_p!(js_outdir)
    File.write!(Path.join(js_outdir, "manifest.json"), ~s({"app.js":{"file":"app.js"}}))

    assert DuskmoonBundler.static_path(StaticEndpoint, "/assets/js/app.js",
             entry: "assets/js/app.ts",
             outdir: outdir,
             prefix: "/assets"
           ) == "/assets/js/app-digested.js?vsn=d"
  end

  test "static_path reads production manifest from build task css directory" do
    outdir = tmp_dir("manifest-css")
    css_outdir = Path.join(outdir, "css")
    File.mkdir_p!(css_outdir)

    File.write!(
      Path.join(css_outdir, "manifest.json"),
      ~s({"app.css":{"file":"app-deadbeef.css"}})
    )

    assert DuskmoonBundler.static_path(ProdEndpoint, "/assets/css/app.css",
             outdir: outdir,
             prefix: "/assets"
           ) == "/assets/css/app-deadbeef.css"
  end

  test "static_path resolves asset entries from production manifests" do
    outdir = tmp_dir("manifest-image")
    js_outdir = Path.join(outdir, "js")
    File.mkdir_p!(js_outdir)

    File.write!(
      Path.join(js_outdir, "manifest.json"),
      ~s({"images/logo.svg":{"file":"logo-deadbeef.svg"}})
    )

    assert DuskmoonBundler.static_path(ProdEndpoint, "/assets/images/logo.svg",
             outdir: outdir,
             prefix: "/assets"
           ) == "/assets/js/logo-deadbeef.svg"
  end

  defp tmp_dir(name) do
    Path.join([
      System.tmp_dir!(),
      "duskmoon_bundler-test-#{System.unique_integer([:positive])}",
      name
    ])
  end
end
