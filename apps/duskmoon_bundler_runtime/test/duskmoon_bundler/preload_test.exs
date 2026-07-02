defmodule DuskmoonBundler.PreloadTest do
  use ExUnit.Case, async: true

  defmodule ProdEndpoint do
    def config(:code_reloader), do: false
  end

  defmodule DevEndpoint do
    def config(:code_reloader), do: true
  end

  describe "tags/2" do
    test "generates modulepreload links from manifest map" do
      manifest =
        DuskmoonBundler.Manifest.wrap(%{
          "app.js" => "app-abc123.js",
          "app-admin.js" => "app-admin-def456.js",
          "app.css" => "app-789abc.css"
        })

      result = DuskmoonBundler.Preload.tags(manifest, prefix: "/assets/js")

      assert result =~ ~s(rel="modulepreload")
      assert result =~ "app-abc123.js"
      assert result =~ "app-admin-def456.js"
      refute result =~ ".css"
    end

    test "preloads only static imports for a selected manifest entry" do
      manifest = %{
        "app.js" => %{
          "file" => "app-abc123.js",
          "imports" => ["common-def456.js"],
          "dynamicImports" => ["lazy-fedcba.js"]
        },
        "common-def456.js" => %{"file" => "common-def456.js", "imports" => ["vendor-111111.js"]},
        "vendor-111111.js" => %{"file" => "vendor-111111.js"},
        "lazy-fedcba.js" => %{"file" => "lazy-fedcba.js"}
      }

      result = DuskmoonBundler.Preload.tags(manifest, prefix: "/assets/js", entry: "app.js")

      assert result =~ "common-def456.js"
      assert result =~ "vendor-111111.js"
      refute result =~ "app-abc123.js"
      refute result =~ "lazy-fedcba.js"
    end

    test "resolves endpoint and entry path through production manifest" do
      outdir = tmp_dir("endpoint-preload")
      js_outdir = Path.join(outdir, "js")
      File.mkdir_p!(js_outdir)

      write_manifest(js_outdir, %{
        "app.js" => %{
          "file" => "app-abc123.js",
          "imports" => ["common-def456.js"]
        },
        "common-def456.js" => %{"file" => "common-def456.js"}
      })

      result =
        DuskmoonBundler.Preload.tags(ProdEndpoint, "/assets/js/app.js",
          outdir: outdir,
          prefix: "/assets"
        )

      assert result =~ ~s(href="/assets/js/common-def456.js")
      refute result =~ "app-abc123.js"
    end

    test "returns no preload tags in development" do
      assert DuskmoonBundler.Preload.tags(DevEndpoint, "/assets/js/app.js") == ""
    end

    test "joins prefix with URI semantics" do
      manifest = %{"app.js" => "app-abc123.js"}

      result =
        DuskmoonBundler.Preload.tags(manifest, prefix: "https://cdn.example.com/assets/js/")

      assert result =~ ~s(href="https://cdn.example.com/assets/js/app-abc123.js")
      refute result =~ "https:/cdn.example.com"
    end

    test "reads from manifest file" do
      dir = tmp_dir("preload-file")
      File.mkdir_p!(dir)
      path = Path.join(dir, "manifest.json")
      File.write!(path, JSON.encode!(DuskmoonBundler.Manifest.wrap(%{"app.js" => "app-abc.js"})))

      result = DuskmoonBundler.Preload.tags(path)
      assert result =~ "app-abc.js"
    end

    test "escapes href attribute values" do
      manifest = %{"bad.js" => ~s|bad" onclick="alert(1).js|}

      result = DuskmoonBundler.Preload.tags(manifest)

      assert result =~ "&quot;"
      refute result =~ ~s(href="/assets/bad" onclick=)
    end

    test "does not recurse forever on cyclic imports" do
      manifest = %{
        "app.js" => %{"file" => "app.js", "imports" => ["a.js"]},
        "a.js" => %{"file" => "a.js", "imports" => ["b.js"]},
        "b.js" => %{"file" => "b.js", "imports" => ["a.js"]}
      }

      result = DuskmoonBundler.Preload.tags(manifest, entry: "app.js")

      assert result =~ "a.js"
      assert result =~ "b.js"
    end
  end

  defp write_manifest(outdir, entries) do
    Path.join(outdir, "manifest.json")
    |> File.write!(DuskmoonBundler.Manifest.wrap(entries) |> JSON.encode!())
  end

  defp tmp_dir(name) do
    Path.join([
      System.tmp_dir!(),
      "duskmoon_bundler_runtime-test-#{System.unique_integer([:positive])}",
      name
    ])
  end
end
