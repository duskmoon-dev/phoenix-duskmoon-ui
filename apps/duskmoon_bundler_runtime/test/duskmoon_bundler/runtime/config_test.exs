defmodule DuskmoonBundler.Runtime.ConfigTest do
  use ExUnit.Case, async: false

  alias DuskmoonBundler.Runtime.Config

  setup do
    bundler_env = Application.get_all_env(:duskmoon_bundler)
    runtime_env = Application.get_all_env(:duskmoon_bundler_runtime)

    on_exit(fn ->
      restore_env(:duskmoon_bundler, bundler_env)
      restore_env(:duskmoon_bundler_runtime, runtime_env)
    end)

    :ok
  end

  test "reads legacy bundler config" do
    Application.put_env(:duskmoon_bundler, :entry, "assets/js/legacy.ts")
    Application.put_env(:duskmoon_bundler, :server, prefix: "/legacy-assets")

    assert %Config{entry: "assets/js/legacy.ts", prefix: "/legacy-assets"} = Config.resolve()
  end

  test "runtime config overrides legacy bundler config" do
    Application.put_env(:duskmoon_bundler, :outdir, "priv/static/legacy")
    Application.put_env(:duskmoon_bundler_runtime, :outdir, "priv/static/runtime")

    assert %Config{outdir: "priv/static/runtime"} = Config.resolve()
  end

  test "profile runtime config overrides profile bundler config" do
    Application.put_env(:duskmoon_bundler, :admin, outdir: "priv/static/legacy")
    Application.put_env(:duskmoon_bundler_runtime, :admin, outdir: "priv/static/runtime")

    assert %Config{outdir: "priv/static/runtime"} = Config.resolve(:admin)
  end

  defp restore_env(app, env) do
    for {key, _value} <- Application.get_all_env(app) do
      Application.delete_env(app, key)
    end

    for {key, value} <- env do
      Application.put_env(app, key, value)
    end
  end
end
