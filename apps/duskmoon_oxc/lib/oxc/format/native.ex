defmodule OXC.Format.Native do
  @moduledoc false

  native_version = Mix.Project.config()[:version]
  build_from_source = System.get_env("DUSKMOON_BUILD_NATIVE_FROM_SOURCE") in ["1", "true"]

  use RustlerPrecompiled,
    otp_app: :duskmoon_oxc,
    crate: "oxc_fmt_nif",
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

  @spec format(iodata(), String.t(), map()) :: {:ok, String.t()} | {:error, [String.t()]}
  def format(_source, _filename, _opts), do: :erlang.nif_error(:nif_not_loaded)
end
