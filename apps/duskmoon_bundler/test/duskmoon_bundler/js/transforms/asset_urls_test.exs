defmodule DuskmoonBundler.JS.Transforms.AssetURLsTest do
  use ExUnit.Case, async: true

  test "rewrites relative asset URLs into URL imports" do
    source = "const logo = new URL('./logo.svg', import.meta.url).href"

    result = DuskmoonBundler.JS.Transforms.AssetURLs.rewrite(source, "app.ts")

    assert result =~ ~s(import __duskmoon_bundler_asset_url_0 from "./logo.svg?url";)
    assert result =~ "new URL(__duskmoon_bundler_asset_url_0, import.meta.url).href"
  end

  test "ignores non-asset URL constructors" do
    source = "const page = new URL('./page.ts', import.meta.url).href"

    assert DuskmoonBundler.JS.Transforms.AssetURLs.rewrite(source, "app.ts") == source
  end

  test "does not treat arbitrary .url members as import.meta.url" do
    source = "const logo = new URL('./logo.svg', obj.url).href"

    assert DuskmoonBundler.JS.Transforms.AssetURLs.rewrite(source, "app.ts") == source
  end
end
