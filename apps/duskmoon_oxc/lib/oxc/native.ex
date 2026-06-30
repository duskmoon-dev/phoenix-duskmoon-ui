defmodule OXC.Native do
  native_version = Mix.Project.config()[:version]
  local_dev? = Mix.env() == :dev and Mix.Project.config()[:build_path] == "../../_build"

  build_from_source =
    local_dev? or System.get_env("DUSKMOON_BUILD_NATIVE_FROM_SOURCE") in ["1", "true"]

  use RustlerPrecompiled,
    otp_app: :duskmoon_oxc,
    crate: "oxc_ex_nif",
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

  @spec parse(iodata(), String.t()) :: {:ok, map()} | {:error, list()}
  def parse(_source, _filename), do: :erlang.nif_error(:nif_not_loaded)

  @spec valid(iodata(), String.t()) :: boolean()
  def valid(_source, _filename), do: :erlang.nif_error(:nif_not_loaded)

  @spec transform(iodata(), String.t(), map()) :: {:ok, String.t() | map()} | {:error, list()}
  def transform(_source, _filename, _opts), do: :erlang.nif_error(:nif_not_loaded)

  @spec minify(iodata(), String.t(), map()) :: {:ok, String.t()} | {:error, list()}
  def minify(_source, _filename, _opts), do: :erlang.nif_error(:nif_not_loaded)

  @spec bundle([{String.t(), iodata()}], map()) ::
          {:ok, String.t() | map()} | {:error, [String.t()]}
  def bundle(_files, _opts), do: :erlang.nif_error(:nif_not_loaded)

  @spec bundle_entry(String.t(), map()) :: {:ok, String.t() | map()} | {:error, [String.t()]}
  def bundle_entry(_entry, _opts), do: :erlang.nif_error(:nif_not_loaded)

  @spec bundle_run(map()) :: {:ok, map()} | {:error, [map()]}
  def bundle_run(_opts), do: :erlang.nif_error(:nif_not_loaded)

  @spec select(iodata(), String.t(), list()) :: {:ok, list()} | {:error, [String.t()]}
  def select(_source, _filename, _spec), do: :erlang.nif_error(:nif_not_loaded)

  @spec transform_many([{iodata(), String.t()}], map()) :: list()
  def transform_many(_inputs, _opts), do: :erlang.nif_error(:nif_not_loaded)

  @spec codegen(map()) :: {:ok, String.t()} | {:error, list()}
  def codegen(_ast), do: :erlang.nif_error(:nif_not_loaded)
end
