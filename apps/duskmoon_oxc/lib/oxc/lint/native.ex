defmodule OXC.Lint.Native do
  @moduledoc false

  native_version = Mix.Project.config()[:version]
  local_dev? = Mix.env() == :dev and Mix.Project.config()[:build_path] == "../../_build"

  build_from_source =
    local_dev? or System.get_env("DUSKMOON_BUILD_NATIVE_FROM_SOURCE") in ["1", "true"]

  use RustlerPrecompiled,
    otp_app: :duskmoon_oxc,
    crate: "oxc_lint_nif",
    base_url:
      "https://github.com/duskmoon-dev/phoenix-duskmoon-ui/releases/download/v#{native_version}",
    force_build: build_from_source or System.get_env("OXC_EX_BUILD") in ["1", "true"],
    targets: ~w(
      aarch64-apple-darwin
      aarch64-unknown-linux-gnu
      x86_64-apple-darwin
      x86_64-pc-windows-gnu
      x86_64-unknown-freebsd
      x86_64-unknown-linux-gnu
    ),
    version: native_version

  @spec lint(iodata(), String.t(), [String.t()], [{String.t(), String.t()}], boolean()) ::
          {:ok, [map()]} | {:error, [String.t()]}
  def lint(_source, _filename, _plugins, _rules, _fix), do: :erlang.nif_error(:nif_not_loaded)
end
