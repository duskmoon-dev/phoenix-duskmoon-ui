defmodule DuskmoonBundler.JS.ResolverTest do
  use ExUnit.Case, async: true

  describe "resolve/2" do
    test "resolves exact alias" do
      aliases = %{"@" => "/app/assets/src"}
      assert {:ok, "/app/assets/src"} = DuskmoonBundler.JS.Resolver.resolve("@", aliases)
    end

    test "resolves alias with subpath" do
      aliases = %{"@" => "/app/assets/src"}
      {:ok, result} = DuskmoonBundler.JS.Resolver.resolve("@/utils/foo", aliases)
      assert result =~ "assets/src/utils/foo"
    end

    test "resolves longer aliases first" do
      aliases = %{
        "@" => "/app/src",
        "@components" => "/app/src/components"
      }

      {:ok, result} = DuskmoonBundler.JS.Resolver.resolve("@components/Button", aliases)
      assert result =~ "components/Button"
      refute result =~ "src/components/Button" and result =~ "src/@components"
    end

    test "returns :pass for no match" do
      aliases = %{"@" => "/app/src"}
      assert :pass = DuskmoonBundler.JS.Resolver.resolve("vue", aliases)
    end

    test "returns :pass for empty aliases" do
      assert :pass = DuskmoonBundler.JS.Resolver.resolve("anything", %{})
    end
  end
end
