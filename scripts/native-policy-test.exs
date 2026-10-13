Code.require_file("native-policy.exs", __DIR__)
ExUnit.start()

defmodule DuskmoonUI.NativePolicyTest do
  use ExUnit.Case, async: true
  alias DuskmoonUI.NativePolicy

  test "ordinary builds reject legacy and global source flags" do
    for flag <-
          ~w(DUSKMOON_BUILD_NATIVE_FROM_SOURCE OXC_EX_BUILD OXIDE_EX_BUILD VIZE_EX_BUILD QUICKBEAM_BUILD RUSTLER_PRECOMPILED_FORCE_BUILD_ALL ZIGLER_PRECOMPILED_FORCE_BUILD_ALL) do
      assert_raise RuntimeError, ~r/Strict precompiled toolchain conflicts/, fn ->
        NativePolicy.validate!(&Map.get(%{flag => "true"}, &1), fn _, _, default -> default end)
      end
    end
  end

  test "source mode requires the explicit isolated candidate lane" do
    assert_raise RuntimeError, ~r/isolated candidate/, fn ->
      NativePolicy.validate!(&Map.get(%{"DUSKMOON_NATIVE_MODE" => "source"}, &1))
    end

    assert :ok =
             NativePolicy.validate!(
               &Map.get(
                 %{"DUSKMOON_NATIVE_MODE" => "source", "DUSKMOON_CANDIDATE_INTEGRATION" => "1"},
                 &1
               )
             )
  end

  test "ordinary builds reject compile configuration overrides" do
    for loader <- [:rustler_precompiled, :zigler_precompiled] do
      config = fn
        ^loader, :force_build, _ -> [duskmoon_oxc: true]
        _, _, default -> default
      end

      assert_raise RuntimeError, ~r/force_build duskmoon_oxc/, fn ->
        NativePolicy.validate!(fn _ -> nil end, config)
      end
    end
  end

  test "precompiled mode permits false legacy flags" do
    assert :ok =
             NativePolicy.validate!(
               fn
                 "DUSKMOON_NATIVE_MODE" -> "precompiled"
                 _ -> "0"
               end,
               fn _, _, default -> default end
             )
  end

  test "config evaluation rejects force builds before application env is loaded" do
    for loader <- [:rustler_precompiled, :zigler_precompiled],
        setting <- ["force_build_all: true", "force_build: [duskmoon_oxc: true]"] do
      assert_raise RuntimeError, ~r/Strict precompiled toolchain conflicts/, fn ->
        Config.Reader.eval!(
          "native-conflict.exs",
          """
          import Config
          config #{inspect(loader)}, #{setting}
          DuskmoonUI.NativePolicy.validate_config!(fn _ -> nil end)
          """
        )
      end
    end
  end
end
