defmodule DuskmoonUI.NativePolicy do
  @moduledoc "Workspace guard for the published, precompiled toolchain lane."

  @flags ~w(DUSKMOON_BUILD_NATIVE_FROM_SOURCE OXC_EX_BUILD OXIDE_EX_BUILD VIZE_EX_BUILD QUICKBEAM_BUILD RUSTLER_PRECOMPILED_FORCE_BUILD_ALL ZIGLER_PRECOMPILED_FORCE_BUILD_ALL)
  @apps ~w(duskmoon_oxc duskmoon_oxide duskmoon_vize duskmoon_quickbeam)a

  @doc "Rejects source flags and compile configuration before any toolchain compilation."
  def validate!(env \\ &System.get_env/1, config \\ &Application.get_env/3) do
    mode = env.("DUSKMOON_NATIVE_MODE") || "precompiled"
    candidate? = env.("DUSKMOON_CANDIDATE_INTEGRATION") == "1"

    if mode == "source" and candidate? do
      :ok
    else
      if mode != "precompiled" do
        raise "Ordinary UI builds require DUSKMOON_NATIVE_MODE=precompiled; source mode is reserved for the isolated candidate helper"
      end

      for flag <- @flags, env.(flag) in ["1", "true"] do
        raise "Strict precompiled toolchain conflicts with #{flag}=#{env.(flag)}"
      end

      for loader <- [:rustler_precompiled, :zigler_precompiled] do
        if config.(loader, :force_build_all, false) do
          raise "Strict precompiled toolchain conflicts with #{loader} force_build_all"
        end

        flags = config.(loader, :force_build, [])

        for app <- @apps, Keyword.get(flags, app, false) do
          raise "Strict precompiled toolchain conflicts with #{loader} force_build #{app}"
        end
      end

      :ok
    end
  end
end
