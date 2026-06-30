defmodule Vize.Native do
  native_version = Mix.Project.config()[:version]
  build_from_source = System.get_env("DUSKMOON_BUILD_NATIVE_FROM_SOURCE") in ["1", "true"]

  use RustlerPrecompiled,
    otp_app: :duskmoon_vize,
    crate: "vize_ex_nif",
    base_url:
      "https://github.com/duskmoon-dev/phoenix-duskmoon-ui/releases/download/v#{native_version}",
    force_build: build_from_source or System.get_env("VIZE_EX_BUILD") in ["1", "true"],
    targets: ~w(
      aarch64-apple-darwin
      aarch64-unknown-linux-gnu
      x86_64-apple-darwin
      x86_64-pc-windows-gnu
      x86_64-unknown-freebsd
      x86_64-unknown-linux-gnu
    ),
    version: native_version

  @spec parse_sfc_nif(String.t()) :: {:ok, map()} | {:error, String.t()}
  def parse_sfc_nif(_source), do: :erlang.nif_error(:nif_not_loaded)

  @spec analyze_sfc_nif(String.t(), String.t()) :: {:ok, map()} | {:error, String.t()}
  def analyze_sfc_nif(_source, _mode), do: :erlang.nif_error(:nif_not_loaded)

  @spec compile_sfc_nif(
          String.t(),
          String.t(),
          String.t(),
          boolean(),
          boolean(),
          boolean(),
          boolean()
        ) :: {:ok, map()} | {:error, String.t()}
  def compile_sfc_nif(
        _source,
        _filename,
        _scope_id,
        _vapor,
        _ssr,
        _custom_renderer,
        _strip_types
      ),
      do: :erlang.nif_error(:nif_not_loaded)

  @spec compile_template_nif(String.t(), String.t(), boolean()) ::
          {:ok, map()} | {:error, list()}
  def compile_template_nif(_source, _mode, _ssr), do: :erlang.nif_error(:nif_not_loaded)

  @spec compile_ssr_nif(String.t()) :: {:ok, map()} | {:error, list()}
  def compile_ssr_nif(_source), do: :erlang.nif_error(:nif_not_loaded)

  @spec compile_vapor_nif(String.t(), boolean(), boolean(), String.t()) ::
          {:ok, map()} | {:error, list()}
  def compile_vapor_nif(_source, _ssr, _diagnostics, _template_syntax),
    do: :erlang.nif_error(:nif_not_loaded)

  @spec vapor_ir_nif(String.t()) :: {:ok, map()} | {:error, list()}
  def vapor_ir_nif(_source), do: :erlang.nif_error(:nif_not_loaded)

  @spec vapor_split_nif(String.t()) :: {:ok, map()} | {:error, list()}
  def vapor_split_nif(_source), do: :erlang.nif_error(:nif_not_loaded)

  @spec lint_nif(String.t(), String.t()) :: {:ok, list()}
  def lint_nif(_source, _filename), do: :erlang.nif_error(:nif_not_loaded)

  @spec select_css_nif(String.t(), String.t(), boolean(), boolean(), list()) ::
          {:ok, [map()]} | {:error, [String.t()]}
  def select_css_nif(_source, _filename, _custom_media, _css_modules, _selector),
    do: :erlang.nif_error(:nif_not_loaded)

  @spec parse_css_ast_nif(String.t(), String.t(), boolean(), boolean()) :: {:ok, map()}
  def parse_css_ast_nif(_source, _filename, _custom_media, _css_modules),
    do: :erlang.nif_error(:nif_not_loaded)

  @spec print_css_ast_nif(map(), boolean(), integer(), integer(), integer()) :: {:ok, map()}
  def print_css_ast_nif(_ast, _minify, _chrome, _firefox, _safari),
    do: :erlang.nif_error(:nif_not_loaded)

  @spec compile_css_nif(
          String.t(),
          boolean(),
          boolean(),
          String.t(),
          String.t(),
          integer(),
          integer(),
          integer(),
          boolean()
        ) :: {:ok, map()}
  def compile_css_nif(
        _source,
        _minify,
        _scoped,
        _scope_id,
        _filename,
        _chrome,
        _firefox,
        _safari,
        _css_modules
      ),
      do: :erlang.nif_error(:nif_not_loaded)

  @spec bundle_css_nif(
          String.t(),
          boolean(),
          integer(),
          integer(),
          integer(),
          boolean()
        ) :: {:ok, map()}
  def bundle_css_nif(_entry_path, _minify, _chrome, _firefox, _safari, _css_modules),
    do: :erlang.nif_error(:nif_not_loaded)

  @spec generate_dts_nif(String.t(), String.t()) :: {:ok, map()} | {:error, String.t()}
  def generate_dts_nif(_source, _filename), do: :erlang.nif_error(:nif_not_loaded)
end
