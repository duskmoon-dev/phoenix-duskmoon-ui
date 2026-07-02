defmodule DuskmoonBundler.ManifestTest do
  use ExUnit.Case, async: true

  alias DuskmoonBundler.Manifest

  test "wraps entries with schema version" do
    assert %{"manifest_version" => 1, "entries" => %{"app.js" => %{"file" => "app.js"}}} =
             Manifest.wrap(%{"app.js" => %{"file" => "app.js"}})
  end

  test "normalizes versioned manifest entries" do
    manifest = Manifest.wrap(%{"app.js" => %{"file" => "app-deadbeef.js"}})

    assert {:ok, %{"app.js" => %{"file" => "app-deadbeef.js"}}} = Manifest.entries(manifest)
  end

  test "normalizes legacy flat manifest entries" do
    assert {:ok, %{"app.js" => %{"file" => "app-deadbeef.js"}}} =
             Manifest.entries(%{"app.js" => %{"file" => "app-deadbeef.js"}})
  end

  test "returns clear error for missing manifest file" do
    path = Path.join(tmp_dir("missing"), "manifest.json")

    assert {:error, %Manifest.Error{} = error} = Manifest.read(path)
    assert Exception.message(error) =~ "manifest not found"
    assert Exception.message(error) =~ path
  end

  test "returns clear error for invalid JSON" do
    dir = tmp_dir("invalid")
    File.mkdir_p!(dir)
    path = Path.join(dir, "manifest.json")
    File.write!(path, "{")

    assert {:error, %Manifest.Error{} = error} = Manifest.read(path)
    assert Exception.message(error) =~ "not valid JSON"
  end

  test "returns clear error for unknown asset path" do
    dir = tmp_dir("unknown-asset")
    File.mkdir_p!(dir)

    Path.join(dir, "manifest.json")
    |> File.write!(Manifest.wrap(%{"app.js" => %{"file" => "app.js"}}) |> JSON.encode!())

    assert {:error, %Manifest.Error{} = error} =
             DuskmoonBundler.StaticPath.resolve(nil, "/assets/js/missing.js",
               outdir: dir,
               prefix: "/assets"
             )

    assert Exception.message(error) =~ ~s("/assets/js/missing.js")
    assert Exception.message(error) =~ "was not found"
  end

  test "rejects unsupported manifest schema versions" do
    assert {:error, %Manifest.Error{} = error} =
             Manifest.entries(%{"manifest_version" => 999, "entries" => %{}})

    assert Exception.message(error) =~ "unsupported manifest_version 999"
  end

  defp tmp_dir(name) do
    Path.join([
      System.tmp_dir!(),
      "duskmoon_bundler_runtime-test-#{System.unique_integer([:positive])}",
      name
    ])
  end
end
