defmodule DuskmoonBundlerRuntimePackageTest do
  use ExUnit.Case, async: true

  defmodule ProdEndpoint do
    def config(:code_reloader), do: false
  end

  test "runtime package resolves manifests without build package modules" do
    refute Code.ensure_loaded?(DuskmoonBundler.Builder)
    assert Code.ensure_loaded?(DuskmoonBundlerRuntime)
    assert Code.ensure_loaded?(DuskmoonBundler)

    outdir =
      Path.join(
        System.tmp_dir!(),
        "duskmoon-runtime-e2e-#{System.unique_integer([:positive])}"
      )

    File.mkdir_p!(Path.join(outdir, "js"))

    manifest = %{
      "manifest_version" => 1,
      "entries" => %{
        "app.js" => %{
          "file" => "app-digested.js",
          "imports" => ["vendor-digested.js"]
        },
        "vendor-digested.js" => %{"file" => "vendor-digested.js"}
      }
    }

    File.write!(
      Path.join([outdir, "js", "manifest.json"]),
      JSON.encode!(manifest)
    )

    assert DuskmoonBundler.static_path(ProdEndpoint, "/assets/js/app.js",
             outdir: outdir,
             prefix: "/assets"
           ) == "/assets/js/app-digested.js"

    assert DuskmoonBundler.Preload.tags(ProdEndpoint, "/assets/js/app.js",
             outdir: outdir,
             prefix: "/assets"
           ) == ~s(<link rel="modulepreload" href="/assets/js/vendor-digested.js">)
  end
end
