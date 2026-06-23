defmodule DuskmoonBundler.JS.AssetTest do
  use ExUnit.Case, async: true

  test "reads TypeScript assets from priv/ts" do
    code = DuskmoonBundler.JS.Asset.read!("dev/hmr-client.ts")
    assert code =~ "const proto"
  end

  test "rewrites type-checkable support imports to runtime client URL" do
    code =
      DuskmoonBundler.JS.Asset.compiled_template!("dev/hmr-preamble.ts",
        mod_url: "/assets/app.ts"
      )

    assert code =~ ~s(from "/@duskmoon_bundler/client.js")
    refute code =~ "./hmr-client"
  end
end
