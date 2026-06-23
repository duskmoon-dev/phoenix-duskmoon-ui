defmodule DuskmoonBundler.PluginRunnerTest do
  use ExUnit.Case, async: true

  defmodule UppercasePlugin do
    @behaviour DuskmoonBundler.Plugin

    @impl true
    def name, do: "uppercase"

    @impl true
    def transform(code, _path) do
      {:ok, String.upcase(code)}
    end
  end

  defmodule PrePlugin do
    @behaviour DuskmoonBundler.Plugin
    def name, do: "pre"
    def enforce, do: :pre
    def transform(code, _path), do: {:ok, code <> "pre"}
  end

  defmodule NormalPlugin do
    @behaviour DuskmoonBundler.Plugin
    def name, do: "normal"
    def transform(code, _path), do: {:ok, code <> "normal"}
  end

  defmodule PostPlugin do
    @behaviour DuskmoonBundler.Plugin
    def name, do: "post"
    def enforce, do: :post
    def transform(code, _path), do: {:ok, code <> "post"}
  end

  defmodule VirtualPlugin do
    @behaviour DuskmoonBundler.Plugin

    @impl true
    def name, do: "virtual"

    @impl true
    def resolve("virtual:config", _importer), do: {:ok, "virtual:config"}
    def resolve(_, _), do: nil

    @impl true
    def load("virtual:config"), do: {:ok, "export default {debug: true};\n"}
    def load(_), do: nil
  end

  describe "transform/3" do
    test "pipes code through transform hooks" do
      result = DuskmoonBundler.PluginRunner.transform([UppercasePlugin], "hello", "test.js")
      assert result == "HELLO"
    end

    test "skips plugins without transform" do
      result = DuskmoonBundler.PluginRunner.transform([VirtualPlugin], "hello", "test.js")
      assert result == "hello"
    end

    test "orders transforms by enforce phase" do
      result =
        DuskmoonBundler.PluginRunner.transform(
          [PostPlugin, NormalPlugin, PrePlugin],
          "",
          "test.js"
        )

      assert result == "prenormalpost"
    end

    test "chains multiple transforms" do
      defmodule PrefixPlugin do
        @behaviour DuskmoonBundler.Plugin
        def name, do: "prefix"
        def transform(code, _path), do: {:ok, "/* duskmoon_bundler */\n" <> code}
      end

      result =
        DuskmoonBundler.PluginRunner.transform(
          [PrefixPlugin, UppercasePlugin],
          "hello",
          "test.js"
        )

      assert result == "/* DUSKMOON_BUNDLER */\nHELLO"
    end
  end

  describe "define/2" do
    test "collects plugin-provided defines" do
      defmodule DefinePlugin do
        @behaviour DuskmoonBundler.Plugin
        def name, do: "define"
        def define(mode), do: %{"import.meta.env.CUSTOM_MODE" => Jason.encode!(mode)}
      end

      assert DuskmoonBundler.PluginRunner.define([DefinePlugin], "production") == %{
               "__VUE_OPTIONS_API__" => "true",
               "__VUE_PROD_DEVTOOLS__" => "false",
               "__VUE_PROD_HYDRATION_MISMATCH_DETAILS__" => "false",
               "import.meta.env.CUSTOM_MODE" => ~s("production")
             }
    end

    test "passes tuple options to define callbacks" do
      defmodule ConfiguredDefinePlugin do
        @behaviour DuskmoonBundler.Plugin
        def name, do: "configured-define"
        def define(_mode, opts), do: Keyword.fetch!(opts, :define)
      end

      assert DuskmoonBundler.PluginRunner.define(
               [{ConfiguredDefinePlugin, define: %{"APP" => "true"}}],
               "test"
             )[
               "APP"
             ] == "true"
    end
  end

  describe "resolve/3" do
    test "resolves via plugin" do
      assert {:ok, "virtual:config"} =
               DuskmoonBundler.PluginRunner.resolve([VirtualPlugin], "virtual:config", nil)
    end

    test "returns nil when no plugin matches" do
      assert nil == DuskmoonBundler.PluginRunner.resolve([VirtualPlugin], "vue", nil)
    end
  end

  describe "load/2" do
    test "loads virtual module content" do
      assert {:ok, code} = DuskmoonBundler.PluginRunner.load([VirtualPlugin], "virtual:config")
      assert code =~ "debug"
    end

    test "returns nil for unhandled paths" do
      assert nil == DuskmoonBundler.PluginRunner.load([VirtualPlugin], "other.js")
    end
  end

  describe "extensions/2" do
    test "configured built-in plugins replace defaults instead of being dropped" do
      plugins =
        DuskmoonBundler.PluginRunner.plugins([{DuskmoonBundler.Plugin.Svelte, marker: true}])

      refute DuskmoonBundler.Plugin.Svelte in plugins
      assert {DuskmoonBundler.Plugin.Svelte, marker: true} in plugins
      assert DuskmoonBundler.Plugin.Vue in plugins
      assert DuskmoonBundler.Plugin.React in plugins
    end

    test "passes tuple options to plugins with arity-aware callbacks" do
      defmodule ConfiguredExtensionsPlugin do
        @behaviour DuskmoonBundler.Plugin
        def name, do: "configured-extensions"
        def extensions(:compile, opts), do: Keyword.fetch!(opts, :extensions)
        def extensions(_, _opts), do: []
      end

      assert ".widget" in DuskmoonBundler.PluginRunner.extensions(
               [{ConfiguredExtensionsPlugin, extensions: [".widget"]}],
               :compile
             )
    end

    test "includes built-in Vue extensions and custom plugin extensions" do
      defmodule SfcPlugin do
        @behaviour DuskmoonBundler.Plugin
        def name, do: "sfc"
        def extensions(:compile), do: [".sfc"]
        def extensions(_), do: []
      end

      assert ".vue" in DuskmoonBundler.PluginRunner.extensions([], :compile)
      assert ".svelte" in DuskmoonBundler.PluginRunner.extensions([], :compile)
      assert ".sfc" in DuskmoonBundler.PluginRunner.extensions([SfcPlugin], :compile)
    end
  end
end
