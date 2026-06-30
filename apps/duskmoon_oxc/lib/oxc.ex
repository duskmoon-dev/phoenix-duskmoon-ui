defmodule OXC do
  @moduledoc """
  Elixir bindings for the [OXC](https://oxc.rs) JavaScript toolchain.

  Provides fast JavaScript and TypeScript parsing, transformation, and
  minification via Rust NIFs. The file extension determines the dialect —
  `.js`, `.jsx`, `.ts`, `.tsx`.

      iex> {:ok, ast} = OXC.parse("const x = 1 + 2", "test.js")
      iex> ast.type
      :program

      iex> {:ok, js} = OXC.transform("const x: number = 42", "test.ts")
      iex> js
      "const x = 42;\\n"

  Source-taking APIs accept binaries and iodata. AST nodes are maps with atom
  keys, following the ESTree specification. The `:type` and `:kind` field values
  are snake_case atoms (e.g. `:import_declaration`, `:variable_declaration`).
  """

  defmodule Error do
    defexception [:message, :errors]

    @impl true
    def message(%{message: message}), do: message
  end

  @type source :: iodata()
  @type ast :: %{required(:type) => atom(), optional(atom()) => any()}
  @type error :: %{message: String.t()}
  @type code_with_sourcemap :: %{code: String.t(), sourcemap: String.t()}
  @type parse_result :: {:ok, ast()} | {:error, [error()]}
  @type transform_result :: {:ok, String.t() | code_with_sourcemap()} | {:error, [error()]}
  @type bundle_result :: {:ok, String.t() | code_with_sourcemap()} | {:error, [error()]}

  @doc """
  Parse JavaScript or TypeScript source code into an ESTree AST.

  The filename extension determines the dialect:
  - `.js` — JavaScript
  - `.jsx` — JavaScript with JSX
  - `.ts` — TypeScript
  - `.tsx` — TypeScript with JSX

  Returns `{:ok, ast}` where `ast` is a map with atom keys, or
  `{:error, errors}` with a list of parse error maps.

  ## Examples

      iex> {:ok, ast} = OXC.parse("const x = 1", "test.js")
      iex> [decl] = ast.body
      iex> decl.type
      :variable_declaration

      iex> {:error, [%{message: msg} | _]} = OXC.parse("const = ;", "bad.js")
      iex> is_binary(msg)
      true
  """
  @spec parse(source(), String.t()) :: parse_result()
  def parse(source, filename) do
    case OXC.Native.parse(source, filename) do
      {:ok, ast} -> {:ok, atomize_term_keys(ast)}
      {:error, errors} -> {:error, atomize_term_keys(errors)}
    end
  end

  @doc """
  Like `parse/2` but raises on parse errors.

  ## Examples

      iex> ast = OXC.parse!("const x = 1", "test.js")
      iex> ast.type
      :program
  """
  @spec parse!(source(), String.t()) :: ast()
  def parse!(source, filename) do
    case parse(source, filename) do
      {:ok, ast} ->
        ast

      {:error, errors} ->
        raise Error, message: "OXC parse error: #{inspect(errors)}", errors: errors
    end
  end

  @doc """
  Check if source code is syntactically valid.

  Faster than `parse/2` — skips AST serialization.

  ## Examples

      iex> OXC.valid?("const x = 1", "test.js")
      true

      iex> OXC.valid?("const = ;", "bad.js")
      false
  """
  @spec valid?(source(), String.t()) :: boolean()
  def valid?(source, filename) do
    OXC.Native.valid(source, filename)
  end

  @doc """
  Transform TypeScript/JSX source code into plain JavaScript.

  Strips type annotations, transforms JSX, and lowers syntax features.
  The filename extension determines the source dialect.

  ## Options

    * `:jsx` — JSX runtime, `:automatic` (default) or `:classic`
    * `:jsx_factory` — function for classic JSX (default: `"React.createElement"`)
    * `:jsx_fragment` — fragment for classic JSX (default: `"React.Fragment"`)
    * `:import_source` — JSX import source (e.g. `"vue"`, `"preact"`)
    * `:target` — downlevel target (e.g. `"es2019"`, `"chrome80"`)
    * `:sourcemap` — generate a source map (default: `false`). When `true`,
      returns `%{code: String.t(), sourcemap: String.t()}` instead of a plain string.

  ## Examples

      iex> {:ok, js} = OXC.transform("const x: number = 42", "test.ts")
      iex> js
      "const x = 42;\\n"

      iex> {:ok, js} = OXC.transform("<div />", "c.jsx", jsx: :classic)
      iex> js =~ "createElement"
      true
  """
  @spec transform(source(), String.t(), keyword()) :: transform_result()
  def transform(source, filename, opts \\ []) do
    case OXC.Native.transform(source, filename, normalize_transform_options(opts)) do
      {:ok, result} -> {:ok, normalize_native_result(result)}
      {:error, errors} -> {:error, atomize_term_keys(errors)}
    end
  end

  @doc """
  Like `transform/3` but raises on errors.

  ## Examples

      iex> OXC.transform!("const x: number = 42", "test.ts")
      "const x = 42;\\n"
  """
  @spec transform!(source(), String.t(), keyword()) :: String.t() | code_with_sourcemap()
  def transform!(source, filename, opts \\ []) do
    case transform(source, filename, opts) do
      {:ok, code} ->
        code

      {:error, errors} ->
        raise Error, message: "OXC transform error: #{inspect(errors)}", errors: errors
    end
  end

  @doc """
  Transform multiple source files in parallel using a Rust thread pool.

  Accepts a list of `{source, filename}` tuples and shared options.
  Returns a list of results in the same order, each being
  `{:ok, code}`, `{:ok, %{code: ..., sourcemap: ...}}`, or `{:error, errors}`.

  Significantly faster than calling `transform/3` sequentially for many files,
  since work is distributed across OS threads without BEAM scheduling overhead.

  ## Examples

      iex> results = OXC.transform_many([{"const x: number = 1", "a.ts"}, {"const y: number = 2", "b.ts"}])
      iex> length(results)
      2
      iex> {:ok, code} = hd(results)
      iex> code =~ "const x = 1"
      true
  """
  @spec transform_many([{source(), String.t()}], keyword()) :: [transform_result()]
  def transform_many(inputs, opts \\ []) do
    native_opts = normalize_transform_options(opts)

    OXC.Native.transform_many(inputs, native_opts)
    |> Enum.map(fn
      {:ok, result} -> {:ok, normalize_native_result(result)}
      {:error, errors} -> {:error, atomize_term_keys(errors)}
    end)
  end

  @doc """
  Minify JavaScript source code.

  Applies dead code elimination, constant folding, and whitespace removal.
  Optionally mangles variable names for smaller output.

  ## Options

    * `:mangle` — rename variables for shorter names (default: `true`)

  ## Examples

      iex> {:ok, min} = OXC.minify("if (false) { x() } y();", "test.js")
      iex> min =~ "y()"
      true
      iex> min =~ "x()"
      false
  """
  @spec minify(source(), String.t(), keyword()) :: {:ok, String.t()} | {:error, [error()]}
  def minify(source, filename, opts \\ []) do
    case OXC.Native.minify(source, filename, normalize_minify_options(opts)) do
      {:ok, code} -> {:ok, code}
      {:error, errors} -> {:error, atomize_term_keys(errors)}
    end
  end

  @doc """
  Like `minify/3` but raises on errors.

  ## Examples

      iex> min = OXC.minify!("const x = 1 + 2;", "test.js")
      iex> is_binary(min)
      true
  """
  @spec minify!(source(), String.t(), keyword()) :: String.t()
  def minify!(source, filename, opts \\ []) do
    case minify(source, filename, opts) do
      {:ok, code} ->
        code

      {:error, errors} ->
        raise Error, message: "OXC minify error: #{inspect(errors)}", errors: errors
    end
  end

  @doc """
  Select compact parser events by name.

  Available selectors:

    * `:import_sources` — import/export source maps with `:specifier`, `:type`, `:kind`, `:start`, and `:end`
    * `:import_specifiers` — import/export source strings only
    * `:asset_urls` — `new URL(..., import.meta.url)` maps with `:specifier`, `:start`, and `:end`
    * `:workers` — `new Worker(...)` and `new SharedWorker(...)` maps with `:specifier`, `:kind`, `:start`, and `:end`
    * `:glob_imports` — `import.meta.glob(...)` maps with `:patterns`, `:start`, and `:end`
    * `:import_meta_env` — `import.meta.env` maps with `:start` and `:end`
    * `:dynamic_import_templates` — template-literal `import(...)` maps with `:pattern`, `:start`, `:end`, `:template_start`, and `:template_end`
    * `:require_calls` — CommonJS `require(...)` maps with `:specifier`, `:start`, and `:end`

  ## Examples

      iex> {:ok, refs} = OXC.select("import { ref } from 'vue'", "test.js", :import_sources)
      iex> refs
      [%{specifier: "vue", type: :static, kind: :import, start: 20, end: 25}]
  """
  @spec select(source(), String.t(), atom()) :: {:ok, list()} | {:error, [error()]}
  def select(source, filename, selector) when is_atom(selector) do
    case OXC.Native.select(source, filename, selector_spec(selector)) do
      {:ok, results} -> {:ok, results}
      {:error, errors} -> {:error, atomize_term_keys(errors)}
    end
  end

  defp selector_spec(:import_sources) do
    [
      {{:import_source, :"$1", :"$2", :"$3", :"$4", :"$5"}, [],
       [
         %{specifier: :"$1", type: :"$2", kind: :"$3", start: :"$4", end: :"$5"}
       ]}
    ]
  end

  defp selector_spec(:import_specifiers) do
    [
      {{:import_source, :"$1", :"$2", :"$3", :"$4", :"$5"}, [], [:"$1"]}
    ]
  end

  defp selector_spec(:asset_urls) do
    [
      {{:asset_url, :"$1", :"$2", :"$3"}, [], [source_span_projection()]}
    ]
  end

  defp selector_spec(:workers) do
    [
      {{:worker, :"$1", :"$2", :"$3", :"$4"}, [],
       [
         %{specifier: :"$1", kind: :"$2", start: :"$3", end: :"$4"}
       ]}
    ]
  end

  defp selector_spec(:glob_imports) do
    [
      {{:glob_import, :"$1", :"$2", :"$3"}, [],
       [
         %{patterns: :"$1", start: :"$2", end: :"$3"}
       ]}
    ]
  end

  defp selector_spec(:import_meta_env) do
    [
      {{:import_meta_env, :"$1", :"$2"}, [],
       [
         %{start: :"$1", end: :"$2"}
       ]}
    ]
  end

  defp selector_spec(:dynamic_import_templates) do
    [
      {{:dynamic_import_template, :"$1", :"$2", :"$3", :"$4", :"$5"}, [],
       [
         %{pattern: :"$1", start: :"$2", end: :"$3", template_start: :"$4", template_end: :"$5"}
       ]}
    ]
  end

  defp selector_spec(:require_calls) do
    [
      {{:require_call, :"$1", :"$2", :"$3"}, [], [source_span_projection()]}
    ]
  end

  defp selector_spec(selector) do
    raise ArgumentError, "unknown OXC selector #{inspect(selector)}"
  end

  defp source_span_projection do
    %{specifier: :"$1", start: :"$2", end: :"$3"}
  end

  @doc """
  Rewrite import/export specifiers in a single pass.

  Parses the source, finds all import/export declarations
  (ImportDeclaration, ExportNamedDeclaration, ExportAllDeclaration,
  and dynamic ImportExpression), and calls `fun` with each specifier string.

  The callback returns:
    * `{:rewrite, new_specifier}` — replace the specifier
    * `:keep` — leave unchanged

  Returns `{:ok, patched_source}` or `{:error, errors}`.

  ## Examples

      iex> source = "import { ref } from 'vue'\\nimport a from './utils'"
      iex> {:ok, result} = OXC.rewrite_specifiers(source, "test.js", fn
      ...>   "vue" -> {:rewrite, "/@vendor/vue.js"}
      ...>   _ -> :keep
      ...> end)
      iex> result
      "import { ref } from '/@vendor/vue.js'\\nimport a from './utils'"
  """
  @spec rewrite_specifiers(source(), String.t(), (String.t() -> {:rewrite, iodata()} | :keep)) ::
          {:ok, String.t()} | {:error, [error()]}
  def rewrite_specifiers(source, filename, fun) when is_function(fun, 1) do
    source = IO.iodata_to_binary(source)

    case select(source, filename, :import_sources) do
      {:ok, imports} ->
        patches =
          Enum.reduce(imports, [], fn %{specifier: specifier, start: start, end: finish}, acc ->
            case fun.(specifier) do
              {:rewrite, new} -> [%{start: start + 1, end: finish - 1, change: new} | acc]
              :keep -> acc
            end
          end)

        {:ok, patch_string(source, patches)}

      {:error, _} = error ->
        error
    end
  end

  @doc """
  Like `rewrite_specifiers/3` but raises on errors.
  """
  @spec rewrite_specifiers!(source(), String.t(), (String.t() -> {:rewrite, iodata()} | :keep)) ::
          String.t()
  def rewrite_specifiers!(source, filename, fun) do
    case rewrite_specifiers(source, filename, fun) do
      {:ok, result} ->
        result

      {:error, errors} ->
        raise Error, message: "OXC rewrite_specifiers error: #{inspect(errors)}", errors: errors
    end
  end

  @doc """
  Bundle JavaScript/TypeScript into a single output file.

  Accepts either a filesystem entry path or a list of `{filename, source}`
  tuples representing a virtual project. Filesystem entries resolve packages
  through the real project directory (`:cwd`); virtual projects are useful for
  tests and generated sources.

  ## Options

    * `:entry` — entry module filename when bundling virtual `files`, for example
      `"main.ts"`
    * `:cwd` — project directory for filesystem entries and package resolution
    * `:format` — output format: `:iife` (default), `:esm`, or `:cjs`
    * `:minify` — minify the output (default: `false`)
    * `:treeshake` — enable tree-shaking to remove unused exports (default: `false`)
    * `:banner` — string to prepend before the IIFE (e.g. `"/* v1.0 */"`)
    * `:footer` — string to append after the IIFE
    * `:preamble` — code to inject at the top of the IIFE function body,
      before any bundled modules (e.g. `"const { ref } = Vue;"`)
    * `:external` — list of specifiers to treat as external and preserve
      as imports in the output (e.g. `["react", "scheduler"]`)
    * `:exports` — output export mode: `:auto`, `:default`, `:named`, or `:none`
    * `:preserve_entry_signatures` — Rolldown entry signature mode:
      `:strict`, `:allow_extension`, `:exports_only`, or `false`
    * `:conditions` — package export conditions used by Rolldown's resolver,
      for example `["browser", "import", "default"]`
    * `:main_fields` — package.json fields used for package entry resolution
    * `:modules` — module directories used by the resolver
    * `:define` — compile-time replacements, map of `%{"process.env.NODE_ENV" => ~s("production")}`
    * `:sourcemap` — generate a source map (default: `false`). When `true`,
      returns `%{code: String.t(), sourcemap: String.t()}` instead of a plain string.
    * `:drop_console` — remove `console.*` calls during minification (default: `false`)
    * `:jsx` — JSX runtime, `:automatic` (default) or `:classic`
    * `:jsx_factory` — function for classic JSX (default: `"React.createElement"`)
    * `:jsx_fragment` — fragment for classic JSX (default: `"React.Fragment"`)
    * `:import_source` — JSX import source (e.g. `"vue"`, `"preact"`)
    * `:target` — downlevel target (e.g. `"es2019"`, `"chrome80"`)
    * `:module_types` — map of file extension to loader type, e.g.
      `%{".css" => :empty, ".ttf" => :dataurl}`. Supported loaders:
      `:js`, `:jsx`, `:ts`, `:tsx`, `:json`, `:text`, `:base64`,
      `:dataurl`, `:binary`, `:empty`, `:css`, `:asset`.

  ## Examples

      iex> files = [
      ...>   {"event.ts", "export class Event { type: string; constructor(type: string) { this.type = type } }"},
      ...>   {"target.ts", "import { Event } from './event'\\nexport class Target extends Event {}"}
      ...> ]
      iex> {:ok, js} = OXC.bundle(files, entry: "target.ts")
      iex> String.contains?(js, "Event")
      true
      iex> String.contains?(js, "Target")
      true
      iex> String.contains?(js, "import ")
      false
  """
  @spec bundle(String.t() | [{String.t(), source()}], keyword()) :: bundle_result()
  def bundle(input, opts \\ [])

  def bundle(entry, opts) when is_binary(entry) do
    case OXC.Native.bundle_entry(entry, normalize_bundle_options(opts)) do
      {:ok, result} -> {:ok, normalize_native_result(result)}
      {:error, errors} -> {:error, atomize_term_keys(errors)}
    end
  end

  def bundle(files, opts) when is_list(files) do
    if Keyword.get(opts, :entry, "") == "" do
      {:error, [%{message: "bundle/2 requires :entry, for example: entry: \"main.ts\""}]}
    else
      case OXC.Native.bundle(files, normalize_bundle_options(opts)) do
        {:ok, result} -> {:ok, normalize_native_result(result)}
        {:error, errors} -> {:error, atomize_term_keys(errors)}
      end
    end
  end

  @doc """
  Like `bundle/2` but raises on errors.
  """
  @spec bundle!(String.t() | [{String.t(), source()}], keyword()) ::
          String.t() | code_with_sourcemap()
  def bundle!(files, opts \\ []) do
    case bundle(files, opts) do
      {:ok, result} ->
        result

      {:error, errors} ->
        raise Error, message: "OXC bundle error: #{inspect(errors)}", errors: errors
    end
  end

  defp normalize_transform_options(opts) do
    %{
      jsx: normalize_jsx_runtime(Keyword.get(opts, :jsx, :automatic)),
      jsx_factory: Keyword.get(opts, :jsx_factory, ""),
      jsx_fragment: Keyword.get(opts, :jsx_fragment, ""),
      import_source: Keyword.get(opts, :import_source, ""),
      target: Keyword.get(opts, :target, ""),
      sourcemap: Keyword.get(opts, :sourcemap, false)
    }
  end

  defp normalize_minify_options(opts) do
    %{mangle: Keyword.get(opts, :mangle, true)}
  end

  defp normalize_bundle_options(opts) do
    %{
      entry: Keyword.get(opts, :entry, ""),
      cwd: Keyword.get(opts, :cwd, ""),
      format: opts |> Keyword.get(:format, :iife) |> Atom.to_string(),
      exports: opts |> Keyword.get(:exports, :auto) |> Atom.to_string(),
      minify: Keyword.get(opts, :minify, false),
      treeshake: Keyword.get(opts, :treeshake, false),
      banner: Keyword.get(opts, :banner),
      footer: Keyword.get(opts, :footer),
      preamble: Keyword.get(opts, :preamble),
      define: Keyword.get(opts, :define, %{}),
      module_types: normalize_module_types(Keyword.get(opts, :module_types, %{})),
      external: Keyword.get(opts, :external, []),
      preserve_entry_signatures:
        normalize_preserve_entry_signatures(Keyword.get(opts, :preserve_entry_signatures)),
      conditions: Keyword.get(opts, :conditions, []),
      main_fields: Keyword.get(opts, :main_fields, []),
      modules: Keyword.get(opts, :modules, []),
      sourcemap: Keyword.get(opts, :sourcemap, false),
      drop_console: Keyword.get(opts, :drop_console, false),
      jsx: normalize_jsx_runtime(Keyword.get(opts, :jsx, :automatic)),
      jsx_factory: Keyword.get(opts, :jsx_factory, ""),
      jsx_fragment: Keyword.get(opts, :jsx_fragment, ""),
      import_source: Keyword.get(opts, :import_source, ""),
      target: Keyword.get(opts, :target, "")
    }
  end

  defp normalize_preserve_entry_signatures(nil), do: ""
  defp normalize_preserve_entry_signatures(false), do: "false"
  defp normalize_preserve_entry_signatures(value) when is_atom(value), do: Atom.to_string(value)
  defp normalize_preserve_entry_signatures(value) when is_binary(value), do: value
  defp normalize_preserve_entry_signatures(_value), do: ""

  defp normalize_module_types(types) when is_map(types) do
    Map.new(types, fn {ext, loader} -> {to_string(ext), to_string(loader)} end)
  end

  defp normalize_jsx_runtime(runtime) when is_atom(runtime), do: Atom.to_string(runtime)
  defp normalize_jsx_runtime(runtime) when is_binary(runtime), do: runtime
  defp normalize_jsx_runtime(_runtime), do: "automatic"

  defp normalize_native_result(result) when is_map(result), do: atomize_term_keys(result)
  defp normalize_native_result(result), do: result

  # Safe to use String.to_atom/1 here: ESTree has a fixed, bounded set of
  # property names and node types. Untrusted user input (JS source code)
  # only affects string *values*, not map keys — those come from OXC's
  # serializer which emits a known set of ESTree field names.
  defp atomize_term_keys(map) when is_map(map) do
    Map.new(map, fn {key, value} ->
      atom_key = if is_binary(key), do: String.to_atom(key), else: key
      {atom_key, atomize_value(atom_key, value)}
    end)
  end

  defp atomize_term_keys(list) when is_list(list), do: Enum.map(list, &atomize_term_keys/1)
  defp atomize_term_keys(value), do: value

  defp atomize_value(:type, value) when is_binary(value), do: to_snake_atom(value)
  defp atomize_value(:kind, value) when is_binary(value), do: to_snake_atom(value)
  defp atomize_value(_key, value), do: atomize_term_keys(value)

  defp to_snake_atom(value) do
    value |> Macro.underscore() |> String.to_atom()
  end

  # ── AST Traversal ──

  # ── Codegen ──

  @doc """
  Generate JavaScript source code from an AST map.

  Takes an ESTree AST (as returned by `parse/2` or constructed manually)
  and produces formatted JavaScript source code using OXC's code generator.

  Handles operator precedence, indentation, and semicolon insertion.

  ## Examples

      iex> ast = OXC.parse!("const x = 1 + 2", "test.js")
      iex> {:ok, js} = OXC.codegen(ast)
      iex> js =~ "const x = 1 + 2"
      true

      iex> ast = %{type: :program, body: [
      ...>   %{type: :variable_declaration, kind: :const, declarations: [
      ...>     %{type: :variable_declarator,
      ...>       id: %{type: :identifier, name: "x"},
      ...>       init: %{type: :literal, value: 42}}
      ...>   ]}
      ...> ]}
      iex> {:ok, js} = OXC.codegen(ast)
      iex> js =~ "const x = 42"
      true
  """
  @spec codegen(ast()) :: {:ok, String.t()} | {:error, [error()]}
  def codegen(ast) do
    case OXC.Native.codegen(deatomize_ast(ast)) do
      {:ok, code} -> {:ok, code}
      {:error, errors} -> {:error, atomize_term_keys(errors)}
    end
  end

  @doc """
  Like `codegen/1` but raises on errors.
  """
  @spec codegen!(ast()) :: String.t()
  def codegen!(ast) do
    case codegen(ast) do
      {:ok, code} ->
        code

      {:error, errors} ->
        raise Error, message: "OXC codegen error: #{inspect(errors)}", errors: errors
    end
  end

  @doc """
  Substitute `$placeholders` in an AST with provided values.

  Walks the AST and replaces any identifier node whose name starts with `$`
  with the corresponding value from `bindings`.

  Binding values can be:
    * A string or iodata — replaced as an identifier name
    * `{:literal, value}` — replaced with a literal node (string, number,
      boolean, nil, map, or list — maps and lists are converted recursively
      into JS object/array expressions)
    * `{:expr, code}` — parsed as a JavaScript expression from a binary or iodata
    * A map with `:type` — spliced as a raw AST node

  ## Examples

      iex> {:ok, ast} = OXC.parse("const x = $value", "t.js")
      iex> ast = OXC.bind(ast, value: {:literal, 42})
      iex> OXC.codegen!(ast) =~ "const x = 42"
      true

      iex> {:ok, ast} = OXC.parse("const $name = 1", "t.js")
      iex> ast = OXC.bind(ast, name: "myVar")
      iex> OXC.codegen!(ast) =~ "const myVar = 1"
      true
  """
  @spec bind(ast(), keyword()) :: ast()
  def bind(ast, bindings) when is_list(bindings) do
    lookup = Map.new(bindings, fn {k, v} -> {"$#{k}", resolve_binding(v)} end)

    postwalk(ast, fn
      %{type: :identifier, name: "$" <> _ = name} = node ->
        case Map.get(lookup, name) do
          nil -> node
          {:rename, new_name} -> %{node | name: new_name}
          {:node, ast_node} -> ast_node
        end

      node ->
        node
    end)
  end

  defp resolve_binding(value) when is_binary(value), do: {:rename, value}
  defp resolve_binding(value) when is_list(value), do: {:rename, IO.iodata_to_binary(value)}
  defp resolve_binding({:literal, lit}), do: {:node, literal_to_ast(lit)}

  defp resolve_binding({:expr, code}) when is_binary(code) or is_list(code),
    do: {:node, parse_expression!(code)}

  defp resolve_binding(%{type: _} = node), do: {:node, node}

  @doc """
  Replace `$placeholder` statements, properties, or elements with a list of nodes.

  Finds expression statements, shorthand object properties, or array elements
  whose identifier name starts with `$` and replaces them with the provided
  nodes. Accepts a single item or a list. Strings and iodata items are
  auto-parsed as JS.

  ## Examples

      iex> {:ok, ast} = OXC.parse("function f() { $body }", "t.js")
      iex> ast = OXC.splice(ast, :body, ["const x = 1;", "return x;"])
      iex> js = OXC.codegen!(ast)
      iex> js =~ "const x = 1" and js =~ "return x"
      true

      iex> {:ok, ast} = OXC.parse("const obj = {a: 1, $rest}", "t.js")
      iex> ast = OXC.splice(ast, :rest, ["b: 2", "c: 3"])
      iex> js = OXC.codegen!(ast)
      iex> js =~ "b: 2" and js =~ "c: 3"
      true
  """
  @spec splice(ast(), atom(), ast() | iodata() | [ast() | iodata()]) :: ast()
  def splice(ast, name, replacement) when is_atom(name) do
    placeholder = "$#{name}"
    items = List.wrap(replacement)

    postwalk(ast, fn
      %{type: :program, body: body} = node ->
        %{node | body: splice_statements(body, placeholder, items)}

      %{type: :block_statement, body: body} = node ->
        %{node | body: splice_statements(body, placeholder, items)}

      %{type: :object_expression, properties: props} = node ->
        %{node | properties: splice_properties(props, placeholder, items)}

      %{type: :array_expression, elements: elems} = node ->
        %{node | elements: splice_elements(elems, placeholder, items)}

      %{type: type, body: body} = node when type in [:function_body, :class_body] ->
        %{node | body: splice_statements(body, placeholder, items)}

      node ->
        node
    end)
  end

  defp splice_statements(stmts, placeholder, items) do
    Enum.flat_map(stmts, fn
      %{type: :expression_statement, expression: %{type: :identifier, name: ^placeholder}} ->
        Enum.map(items, &resolve_splice_statement/1)

      other ->
        [other]
    end)
  end

  defp splice_properties(props, placeholder, items) do
    Enum.flat_map(props, fn
      %{type: :property, shorthand: true, key: %{type: :identifier, name: ^placeholder}} ->
        Enum.map(items, &resolve_splice_property/1)

      other ->
        [other]
    end)
  end

  defp splice_elements(elems, placeholder, items) do
    Enum.flat_map(elems, fn
      %{type: :identifier, name: ^placeholder} ->
        Enum.map(items, &resolve_splice_element/1)

      other ->
        [other]
    end)
  end

  defp resolve_splice_statement(item) when is_binary(item) or is_list(item) do
    item = IO.iodata_to_binary(item)

    case parse(item, "splice.js") do
      {:ok, %{body: [stmt]}} ->
        stmt

      _ ->
        %{body: [%{body: %{body: [stmt]}}]} = parse!("function _(){" <> item <> "}", "splice.js")
        stmt
    end
  end

  defp resolve_splice_statement(%{type: _} = node), do: node

  defp resolve_splice_property(item) when is_binary(item) or is_list(item) do
    ast = parse!(["({", item, "})"], "splice.js")
    [%{type: :expression_statement, expression: expr}] = ast.body

    props =
      case expr do
        %{type: :parenthesized_expression, expression: %{properties: p}} -> p
        %{type: :object_expression, properties: p} -> p
        %{properties: p} -> p
      end

    [prop] = props
    prop
  end

  defp resolve_splice_property(%{type: _} = node), do: node

  defp resolve_splice_element(item) when is_binary(item) or is_list(item) do
    parse_expression!(item)
  end

  defp resolve_splice_element(%{type: _} = node), do: node

  defp parse_expression!(code) do
    ast = parse!(code, "expr.js")

    case ast.body do
      [%{type: :expression_statement, expression: expr}] -> expr
      _ -> raise Error, message: "Expected a single expression: #{code}", errors: []
    end
  end

  defp literal_to_ast(value) when is_binary(value), do: %{type: :literal, value: value}
  defp literal_to_ast(value) when is_number(value), do: %{type: :literal, value: value}
  defp literal_to_ast(value) when is_boolean(value), do: %{type: :literal, value: value}
  defp literal_to_ast(nil), do: %{type: :literal, value: nil}

  defp literal_to_ast(map) when is_map(map) do
    %{
      type: :object_expression,
      properties:
        Enum.map(map, fn {k, v} ->
          %{
            type: :property,
            key: %{type: :identifier, name: to_string(k)},
            value: literal_to_ast(v),
            kind: :init,
            shorthand: false,
            computed: false,
            method: false
          }
        end)
    }
  end

  defp literal_to_ast(list) when is_list(list) do
    %{type: :array_expression, elements: Enum.map(list, &literal_to_ast/1)}
  end

  # Convert atom keys/values back to strings for the Rust NIF
  defp deatomize_ast(map) when is_map(map) do
    Map.new(map, fn {key, value} ->
      str_key = if is_atom(key), do: deatomize_key(key), else: key
      {str_key, deatomize_value(key, value)}
    end)
  end

  defp deatomize_ast(list) when is_list(list), do: Enum.map(list, &deatomize_ast/1)
  defp deatomize_ast(value), do: value

  defp deatomize_key(:super_class), do: :superClass
  defp deatomize_key(key), do: key

  defp deatomize_value(:type, value) when is_atom(value), do: value
  defp deatomize_value(:kind, value) when is_atom(value), do: value
  defp deatomize_value(_key, value), do: deatomize_ast(value)

  @doc """
  Walk an AST tree, calling `fun` on every node (any map with a `:type` key).

  Descends into all map values and list elements to reach nested AST
  nodes, including maps without a `:type` key (which are skipped for
  the callback but still traversed).

  ## Examples

      iex> {:ok, ast} = OXC.parse("const x = 1", "test.js")
      iex> OXC.walk(ast, fn
      ...>   %{type: :identifier, name: name} -> send(self(), {:id, name})
      ...>   _ -> :ok
      ...> end)
      iex> receive do {:id, name} -> name end
      "x"
  """
  @spec walk(ast() | [ast()], (map() -> any())) :: :ok
  def walk(nodes, fun) when is_list(nodes) and is_function(fun, 1) do
    Enum.each(nodes, &walk(&1, fun))
  end

  def walk(node, fun) when is_map(node) and is_function(fun, 1) do
    if Map.has_key?(node, :type), do: fun.(node)

    node
    |> Map.values()
    |> Enum.each(fn
      child when is_map(child) -> walk(child, fun)
      children when is_list(children) -> Enum.each(children, &walk_child(&1, fun))
      _ -> :ok
    end)
  end

  def walk(_node, _fun), do: :ok

  defp walk_child(node, fun) when is_map(node), do: walk(node, fun)
  defp walk_child(_node, _fun), do: :ok

  @doc """
  Depth-first post-order traversal, like `Macro.postwalk/2`.

  Visits every AST node (map with a `:type` key). Children are visited
  first, then the node itself. The callback returns the (possibly modified)
  node.

  Accepts a single AST node or a list of nodes.

  ## Examples

      iex> {:ok, ast} = OXC.parse("const x = 1", "test.js")
      iex> OXC.postwalk(ast, fn
      ...>   %{type: :identifier, name: "x"} = node -> %{node | name: "y"}
      ...>   node -> node
      ...> end)
      iex> :ok
      :ok
  """
  @spec postwalk(ast() | [ast()], (map() -> map())) :: map() | [map()]
  def postwalk(nodes, fun) when is_list(nodes) and is_function(fun, 1) do
    Enum.map(nodes, fn
      n when is_map(n) -> postwalk(n, fun)
      n -> n
    end)
  end

  def postwalk(node, fun) when is_map(node) and is_function(fun, 1) do
    updated =
      Map.new(node, fn
        {k, child} when is_map(child) ->
          {k, postwalk(child, fun)}

        {k, children} when is_list(children) ->
          {k,
           Enum.map(children, fn
             c when is_map(c) -> postwalk(c, fun)
             c -> c
           end)}

        pair ->
          pair
      end)

    if Map.has_key?(updated, :type), do: fun.(updated), else: updated
  end

  def postwalk(node, _fun), do: node

  @doc """
  Depth-first post-order traversal with accumulator, like `Macro.postwalk/3`.

  The callback receives each AST node and the accumulator, and must return
  `{node, acc}`. Use this to collect data while traversing.

  Accepts a single AST node or a list of nodes.

  ## Examples

      iex> source = "import { ref } from 'vue'\\nimport a from './utils'"
      iex> {:ok, ast} = OXC.parse(source, "test.ts")
      iex> {_ast, patches} = OXC.postwalk(ast, [], fn
      ...>   %{type: :import_declaration, source: %{value: "vue"} = src} = node, patches ->
      ...>     {node, [%{start: src.start, end: src.end, change: "'/@vendor/vue.js'"} | patches]}
      ...>   node, patches ->
      ...>     {node, patches}
      ...> end)
      iex> OXC.patch_string(source, patches)
      "import { ref } from '/@vendor/vue.js'\\nimport a from './utils'"
  """
  @spec postwalk(ast() | [ast()], acc, (map(), acc -> {map(), acc})) :: {map() | [map()], acc}
        when acc: term()
  def postwalk(nodes, acc, fun) when is_list(nodes) and is_function(fun, 2) do
    Enum.map_reduce(nodes, acc, fn
      node, a when is_map(node) -> postwalk(node, a, fun)
      node, a -> {node, a}
    end)
  end

  def postwalk(node, acc, fun) when is_map(node) and is_function(fun, 2) do
    {updated, acc} =
      Enum.reduce(Map.keys(node), {node, acc}, fn key, {n, a} ->
        case Map.fetch!(n, key) do
          child when is_map(child) ->
            {new_child, a} = postwalk(child, a, fun)
            {Map.put(n, key, new_child), a}

          children when is_list(children) ->
            {new_children, a} =
              Enum.map_reduce(children, a, fn
                child, a when is_map(child) -> postwalk(child, a, fun)
                child, a -> {child, a}
              end)

            {Map.put(n, key, new_children), a}

          _ ->
            {n, a}
        end
      end)

    if Map.has_key?(updated, :type), do: fun.(updated, acc), else: {updated, acc}
  end

  def postwalk(node, acc, _fun), do: {node, acc}

  @doc """
  Collect AST nodes that match a filter function.

  The function receives each node (map with `:type` key) and should return
  `{:keep, value}` to include it in results, or `:skip` to exclude it.

  ## Examples

      iex> {:ok, ast} = OXC.parse("const x = y + z", "test.js")
      iex> OXC.collect(ast, fn
      ...>   %{type: :identifier, name: name} -> {:keep, name}
      ...>   _ -> :skip
      ...> end)
      ["x", "y", "z"]
  """
  @spec collect(ast(), (map() -> {:keep, any()} | :skip)) :: [any()]
  def collect(node, fun) do
    node
    |> do_collect(fun, [])
    |> Enum.reverse()
  end

  defp do_collect(node, fun, acc) when is_map(node) do
    acc =
      if Map.has_key?(node, :type) do
        case fun.(node) do
          {:keep, value} -> [value | acc]
          :skip -> acc
        end
      else
        acc
      end

    Enum.reduce(Map.values(node), acc, fn
      child, a when is_map(child) ->
        do_collect(child, fun, a)

      children, a when is_list(children) ->
        Enum.reduce(children, a, &do_collect_child(&1, fun, &2))

      _, a ->
        a
    end)
  end

  defp do_collect(_node, _fun, acc), do: acc

  defp do_collect_child(node, fun, acc) when is_map(node), do: do_collect(node, fun, acc)
  defp do_collect_child(_node, _fun, acc), do: acc

  # ── Source Patching ──

  @type patch :: %{start: non_neg_integer(), end: non_neg_integer(), change: iodata()}

  @doc """
  Apply patches to source code, like `Sourceror.patch_string/2`.

  Each patch is a map with `:start` (byte offset), `:end` (byte offset),
  and `:change` (replacement iodata). Patches are applied in reverse
  offset order so that earlier patches don't shift later offsets.

  When multiple patches target the same `{start, end}` range, only the
  first one is applied and duplicates are silently dropped.

  Use with `postwalk/3` to collect patches from the AST, then apply
  them to the original source string.

  ## Examples

      iex> OXC.patch_string("hello world", [%{start: 6, end: 11, change: "elixir"}])
      "hello elixir"

      iex> source = "import { ref } from 'vue'"
      iex> OXC.patch_string(source, [%{start: 20, end: 25, change: "'/@vendor/vue.js'"}])
      "import { ref } from '/@vendor/vue.js'"
  """
  @spec patch_string(source(), [patch()]) :: String.t()
  def patch_string(source, patches) do
    source = IO.iodata_to_binary(source)

    {chunks, offset} =
      patches
      |> Enum.uniq_by(fn %{start: s, end: e} -> {s, e} end)
      |> Enum.sort_by(fn %{start: s} -> s end)
      |> Enum.reduce({[], 0}, fn %{start: s, end: e, change: replacement}, {chunks, offset} ->
        chunk = binary_part(source, offset, s - offset)
        {[replacement, chunk | chunks], e}
      end)

    tail = binary_part(source, offset, byte_size(source) - offset)
    IO.iodata_to_binary(Enum.reverse([tail | chunks]))
  end
end
