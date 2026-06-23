defmodule DuskmoonBundler.EnvTest do
  use ExUnit.Case, async: true

  @fixture_dir Path.expand("fixtures/env", __DIR__)

  setup do
    File.mkdir_p!(@fixture_dir)
    on_exit(fn -> File.rm_rf!(@fixture_dir) end)
    :ok
  end

  describe "load_env_files/2" do
    test "parses key=value pairs" do
      File.write!(
        Path.join(@fixture_dir, ".env"),
        "DUSKMOON_BUNDLER_API=https://api.test\nDUSKMOON_BUNDLER_DEBUG=true\n"
      )

      result = DuskmoonBundler.Env.load_env_files(@fixture_dir, "production")
      assert result["DUSKMOON_BUNDLER_API"] == "https://api.test"
      assert result["DUSKMOON_BUNDLER_DEBUG"] == "true"
    end

    test "ignores comments and blank lines" do
      File.write!(Path.join(@fixture_dir, ".env"), "# comment\n\nDUSKMOON_BUNDLER_KEY=value\n")

      result = DuskmoonBundler.Env.load_env_files(@fixture_dir, "production")
      assert result["DUSKMOON_BUNDLER_KEY"] == "value"
    end

    test "handles quoted values" do
      File.write!(
        Path.join(@fixture_dir, ".env"),
        ~s(DUSKMOON_BUNDLER_MSG="hello world"\nDUSKMOON_BUNDLER_NAME='test'\n)
      )

      result = DuskmoonBundler.Env.load_env_files(@fixture_dir, "production")
      assert result["DUSKMOON_BUNDLER_MSG"] == "hello world"
      assert result["DUSKMOON_BUNDLER_NAME"] == "test"
    end

    test "handles export prefix" do
      File.write!(Path.join(@fixture_dir, ".env"), "export DUSKMOON_BUNDLER_KEY=exported\n")

      result = DuskmoonBundler.Env.load_env_files(@fixture_dir, "production")
      assert result["DUSKMOON_BUNDLER_KEY"] == "exported"
    end

    test "mode-specific env files override base" do
      File.write!(Path.join(@fixture_dir, ".env"), "DUSKMOON_BUNDLER_URL=base\n")
      File.write!(Path.join(@fixture_dir, ".env.production"), "DUSKMOON_BUNDLER_URL=prod\n")

      result = DuskmoonBundler.Env.load_env_files(@fixture_dir, "production")
      assert result["DUSKMOON_BUNDLER_URL"] == "prod"
    end
  end

  describe "define/1" do
    test "generates define map with DUSKMOON_BUNDLER_ prefix" do
      File.write!(
        Path.join(@fixture_dir, ".env"),
        "DUSKMOON_BUNDLER_API=http://localhost\nSECRET=hidden\n"
      )

      defines = DuskmoonBundler.Env.define(root: @fixture_dir, mode: "development")

      assert defines["import.meta.env.DUSKMOON_BUNDLER_API"] == ~s("http://localhost")
      refute Map.has_key?(defines, "import.meta.env.SECRET")
    end

    test "includes MODE, DEV, PROD, and NODE_ENV" do
      defines = DuskmoonBundler.Env.define(root: @fixture_dir, mode: "development")

      assert defines["import.meta.env.MODE"] == ~s("development")
      assert defines["import.meta.env.DEV"] == "true"
      assert defines["import.meta.env.PROD"] == "false"
      assert defines["process.env.NODE_ENV"] == ~s("development")
    end

    test "production mode" do
      defines = DuskmoonBundler.Env.define(root: @fixture_dir, mode: "production")

      assert defines["import.meta.env.DEV"] == "false"
      assert defines["import.meta.env.PROD"] == "true"
    end

    test "extra env takes precedence" do
      File.write!(Path.join(@fixture_dir, ".env"), "DUSKMOON_BUNDLER_KEY=file\n")

      defines =
        DuskmoonBundler.Env.define(
          root: @fixture_dir,
          env: %{"DUSKMOON_BUNDLER_KEY" => "override"}
        )

      assert defines["import.meta.env.DUSKMOON_BUNDLER_KEY"] == ~s("override")
    end

    test "supports custom env prefix" do
      File.write!(
        Path.join(@fixture_dir, ".env"),
        "VITE_API=http://vite.test\nDUSKMOON_BUNDLER_API=http://duskmoon_bundler.test\n"
      )

      defines = DuskmoonBundler.Env.define(root: @fixture_dir, env_prefix: "VITE_")

      assert defines["import.meta.env.VITE_API"] == ~s("http://vite.test")
      refute Map.has_key?(defines, "import.meta.env.DUSKMOON_BUNDLER_API")
    end

    test "supports multiple env prefixes" do
      File.write!(
        Path.join(@fixture_dir, ".env"),
        "VITE_API=http://vite.test\nPUBLIC_KEY=ok\nSECRET=no\n"
      )

      defines = DuskmoonBundler.Env.define(root: @fixture_dir, env_prefix: ["VITE_", "PUBLIC_"])

      assert defines["import.meta.env.VITE_API"] == ~s("http://vite.test")
      assert defines["import.meta.env.PUBLIC_KEY"] == ~s("ok")
      refute Map.has_key?(defines, "import.meta.env.SECRET")
    end
  end
end
