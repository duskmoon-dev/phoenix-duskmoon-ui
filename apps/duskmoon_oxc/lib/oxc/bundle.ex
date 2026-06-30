defmodule OXC.Bundle do
  @moduledoc """
  Composable JavaScript bundling pipeline.

  Build immutable bundle configuration with pipeline-friendly functions, then
  execute the native Rolldown run once with `run/1`.
  """

  alias OXC.Bundle.{Entry, Result}

  defstruct entries: [],
            files: [],
            cwd: "",
            outdir: nil,
            format: :esm,
            exports: :auto,
            minify: false,
            treeshake: false,
            sourcemap: false,
            drop_console: false,
            banner: nil,
            footer: nil,
            preamble: nil,
            define: %{},
            external: [],
            conditions: [],
            main_fields: [],
            modules: [],
            module_types: %{},
            preserve_entry_signatures: nil,
            jsx: :automatic,
            jsx_factory: "",
            jsx_fragment: "",
            import_source: "",
            target: "",
            entry_file_names: nil,
            chunk_file_names: nil,
            asset_file_names: nil

  @type t :: %__MODULE__{}

  @spec new(keyword()) :: t()
  def new(opts \\ []) do
    struct!(__MODULE__)
    |> entries(Keyword.get(opts, :entries, []))
    |> apply_opts(Keyword.delete(opts, :entries))
  end

  @spec entry(
          t(),
          Entry.t()
          | map()
          | {String.t(), String.t()}
          | {String.t(), String.t(), iodata()}
          | String.t()
        ) :: t()
  def entry(%__MODULE__{} = bundle, entry), do: entries(bundle, bundle.entries ++ [entry])

  def file(%__MODULE__{} = bundle, {path, source}),
    do: files(bundle, bundle.files ++ [{path, source}])

  def files(%__MODULE__{} = bundle, files) when is_list(files), do: %{bundle | files: files}

  @spec entries(t(), [
          Entry.t()
          | map()
          | {String.t(), String.t()}
          | {String.t(), String.t(), iodata()}
          | String.t()
        ]) :: t()
  def entries(%__MODULE__{} = bundle, entries) when is_list(entries) do
    %{bundle | entries: Enum.map(entries, &Entry.new/1)}
  end

  def cwd(%__MODULE__{} = bundle, cwd), do: %{bundle | cwd: cwd || ""}
  def outdir(%__MODULE__{} = bundle, outdir), do: %{bundle | outdir: outdir}
  def format(%__MODULE__{} = bundle, format), do: %{bundle | format: format}

  def resolve(%__MODULE__{} = bundle, opts) do
    %{
      bundle
      | external: Keyword.get(opts, :external, bundle.external),
        conditions: Keyword.get(opts, :conditions, bundle.conditions),
        main_fields: Keyword.get(opts, :main_fields, bundle.main_fields),
        modules: Keyword.get(opts, :modules, bundle.modules)
    }
  end

  def transform(%__MODULE__{} = bundle, opts) do
    %{
      bundle
      | jsx: Keyword.get(opts, :jsx, bundle.jsx),
        jsx_factory: Keyword.get(opts, :jsx_factory, bundle.jsx_factory),
        jsx_fragment: Keyword.get(opts, :jsx_fragment, bundle.jsx_fragment),
        import_source: Keyword.get(opts, :import_source, bundle.import_source),
        target: Keyword.get(opts, :target, bundle.target),
        define: Keyword.get(opts, :define, bundle.define),
        module_types: Keyword.get(opts, :module_types, bundle.module_types)
    }
  end

  def output(%__MODULE__{} = bundle, opts) do
    %{
      bundle
      | entry_file_names: Keyword.get(opts, :entry_file_names, bundle.entry_file_names),
        chunk_file_names: Keyword.get(opts, :chunk_file_names, bundle.chunk_file_names),
        asset_file_names: Keyword.get(opts, :asset_file_names, bundle.asset_file_names),
        banner: Keyword.get(opts, :banner, bundle.banner),
        footer: Keyword.get(opts, :footer, bundle.footer),
        preamble: Keyword.get(opts, :preamble, bundle.preamble),
        sourcemap: Keyword.get(opts, :sourcemap, bundle.sourcemap),
        exports: Keyword.get(opts, :exports, bundle.exports),
        preserve_entry_signatures:
          Keyword.get(opts, :preserve_entry_signatures, bundle.preserve_entry_signatures)
    }
  end

  def minify(%__MODULE__{} = bundle, value \\ true), do: %{bundle | minify: value}
  def treeshake(%__MODULE__{} = bundle, value \\ true), do: %{bundle | treeshake: value}

  @spec run(t()) :: {:ok, Result.t()} | {:error, [map()]}
  def run(%__MODULE__{} = bundle) do
    case OXC.Native.bundle_run(to_native(bundle)) do
      {:ok, result} -> {:ok, Result.new(result)}
      {:error, errors} -> {:error, errors}
    end
  end

  defp apply_opts(bundle, opts) do
    Enum.reduce(opts, bundle, fn
      {:cwd, value}, acc -> cwd(acc, value)
      {:outdir, value}, acc -> outdir(acc, value)
      {:format, value}, acc -> format(acc, value)
      {:resolve, value}, acc -> resolve(acc, value)
      {:transform, value}, acc -> transform(acc, value)
      {:output, value}, acc -> output(acc, value)
      {:minify, value}, acc -> minify(acc, value)
      {:treeshake, value}, acc -> treeshake(acc, value)
      {key, value}, acc when is_map_key(acc, key) -> Map.put(acc, key, value)
      _other, acc -> acc
    end)
  end

  defp to_native(%__MODULE__{} = bundle) do
    %{
      entries: Enum.map(bundle.entries, &Entry.to_native/1),
      files: Enum.map(bundle.files, fn {path, source} -> %{path: path, source: source} end),
      cwd: bundle.cwd || "",
      outdir: bundle.outdir,
      format: bundle.format,
      exports: bundle.exports,
      minify: bundle.minify,
      treeshake: bundle.treeshake,
      sourcemap: bundle.sourcemap,
      drop_console: bundle.drop_console,
      banner: bundle.banner,
      footer: bundle.footer,
      preamble: bundle.preamble,
      define: bundle.define,
      external: bundle.external,
      conditions: bundle.conditions,
      main_fields: bundle.main_fields,
      modules: bundle.modules,
      module_types: bundle.module_types,
      preserve_entry_signatures: bundle.preserve_entry_signatures,
      jsx: bundle.jsx,
      jsx_factory: bundle.jsx_factory,
      jsx_fragment: bundle.jsx_fragment,
      import_source: bundle.import_source,
      target: bundle.target,
      entry_file_names: bundle.entry_file_names,
      chunk_file_names: bundle.chunk_file_names,
      asset_file_names: bundle.asset_file_names
    }
  end
end
