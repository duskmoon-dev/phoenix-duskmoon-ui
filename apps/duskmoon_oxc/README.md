# OXC

Elixir bindings for the [OXC](https://oxc.rs) JavaScript toolchain via Rust NIFs.

Parse, transform, minify, lint, and generate JavaScript/TypeScript at native speed.

## Features

- **Parse** JS/TS/JSX/TSX into ESTree AST (maps with atom keys, snake_case types)
- **Codegen** — serialize AST maps back to JavaScript source via OXC's code generator
- **Bind** — substitute `$placeholders` in parsed AST (quasiquoting for JS)
- **Transform** TypeScript → JavaScript, JSX → `createElement`/`jsx` calls
- **Minify** with dead code elimination, constant folding, and variable mangling
- **Lint** with 650+ built-in oxlint rules + custom Elixir rules
- **Bundle** multiple TS/JS modules into a single IIFE with dependency resolution
- **Rewrite specifiers** — rewrite import/export paths in a single pass
- **Collect imports** — typed import analysis (static/dynamic, import/export/export_all)
- **Walk/Collect** helpers for AST traversal and node filtering
- **Postwalk** with accumulator for AST-based source patching (like `Macro.postwalk/3`)
- **Patch string** — apply byte-offset patches to source (like `Sourceror.patch_string/2`)
- **Import extraction** — fast NIF-level import specifier extraction

## Installation

```elixir
def deps do
  [
    {:duskmoon_oxc, "~> 9.0"}
  ]
end
```

Precompiled NIFs are available for macOS (aarch64, x86_64) and Linux (aarch64, x86_64, musl).
Building from source requires a Rust toolchain (`rustup` recommended).

## Usage

Source-taking APIs accept binaries and `iodata()`.

### Parse

```elixir
{:ok, ast} = OXC.parse("const x = 1 + 2", "test.js")
ast.type
# :program

[stmt] = ast.body
stmt.expression
# %{type: :binary_expression, operator: "+", left: %{value: 1}, right: %{value: 2}}
```

File extension determines the dialect — `.js`, `.jsx`, `.ts`, `.tsx`:

```elixir
{:ok, ast} = OXC.parse("const x: number = 42", "test.ts")
{:ok, ast} = OXC.parse("<App />", "component.tsx")
```

AST node `:type` and `:kind` values are snake_case atoms (e.g. `:import_declaration`, `:variable_declaration`, `:const`).

### Codegen

Generate JavaScript source from an AST map — the inverse of `parse/2`.
Uses OXC's code generator for correct operator precedence, formatting, and semicolons:

```elixir
{:ok, ast} = OXC.parse("const x = 1 + 2", "test.js")
{:ok, js} = OXC.codegen(ast)
# "const x = 1 + 2;\n"
```

Construct AST by hand and generate JS:

```elixir
ast = %{type: :program, body: [
  %{type: :function_declaration,
    id: %{type: :identifier, name: "add"},
    params: [%{type: :identifier, name: "a"}, %{type: :identifier, name: "b"}],
    body: %{type: :block_statement, body: [
      %{type: :return_statement, argument: %{type: :binary_expression, operator: "+",
        left: %{type: :identifier, name: "a"}, right: %{type: :identifier, name: "b"}}}
    ]}}
]}

OXC.codegen!(ast)
# "function add(a, b) {\n\treturn a + b;\n}\n"
```

### Bind (Quasiquoting)

Parse a JS template with `$placeholders`, substitute values, and generate code.
Like Elixir's `quote`/`unquote` but for JavaScript:

```elixir
js =
  OXC.parse!("const $name = $value", "t.js")
  |> OXC.bind(name: "count", value: {:literal, 0})
  |> OXC.codegen!()
# "const count = 0;\n"
```

Binding values can be:
- A string or iodata — replaces the identifier name
- `{:literal, value}` — replaces with a literal node (string, number, boolean, nil)
- `{:expr, code}` — parses JavaScript expression code from a binary or iodata
- A map with `:type` — splices a raw AST node

```elixir
# Splice an AST node
expr = %{type: :binary_expression, operator: "+",
         left: %{type: :literal, value: 1},
         right: %{type: :literal, value: 2}}

js =
  OXC.parse!("const result = $expr", "t.js")
  |> OXC.bind(expr: expr)
  |> OXC.codegen!()
# "const result = 1 + 2;\n"
```

Use `.js`/`.ts` files as templates with full editor support:

```elixir
# priv/templates/api-client.js — real JS, full syntax highlighting
# import { z } from "zod";
# export const $schema = z.object($fields);
# export async function $listFn(params = {}) { ... }

template = File.read!("priv/templates/api-client.js")
ast = OXC.parse!(template, "api-client.js")

js =
  ast
  |> OXC.bind(schema: "userSchema", listFn: "listUsers", ...)
  |> OXC.codegen!()
```

### Transform

Strip TypeScript types and transform JSX:

```elixir
{:ok, js} = OXC.transform("const x: number = 42", "test.ts")
# "const x = 42;\n"

{:ok, js} = OXC.transform("<App />", "app.tsx")
# Uses automatic JSX runtime by default

{:ok, js} = OXC.transform("<App />", "app.jsx", jsx: :classic)
# Uses React.createElement
```

With source maps:

```elixir
{:ok, %{code: js, sourcemap: map}} = OXC.transform(code, "app.ts", sourcemap: true)
```

Target specific environments:

```elixir
{:ok, js} = OXC.transform("const x = a ?? b", "test.js", target: "es2019")
# Nullish coalescing lowered to ternary
```

Custom JSX import source (Vue, Preact, etc.):

```elixir
{:ok, js} = OXC.transform("<div />", "app.jsx", import_source: "vue")
# Imports from vue/jsx-runtime instead of react/jsx-runtime
```

### Minify

```elixir
{:ok, min} = OXC.minify("const x = 1 + 2; console.log(x);", "test.js")
# Constants folded, whitespace removed, variables mangled

{:ok, min} = OXC.minify(code, "test.js", mangle: false)
# Compress without renaming variables
```

### Lint

Lint JavaScript/TypeScript with oxlint's 650+ built-in rules:

```elixir
{:ok, diags} = OXC.Lint.run("x == y", "test.js",
  rules: %{"eqeqeq" => :deny})
# [%{rule: "eqeqeq", message: "Require the use of === and !==", severity: :deny, ...}]

{:ok, []} = OXC.Lint.run("export const x = 1;\n", "test.ts")
```

Enable specific plugins:

```elixir
{:ok, diags} = OXC.Lint.run(source, "app.tsx",
  plugins: [:react, :typescript],
  rules: %{"no-console" => :warn, "react/no-danger" => :deny})
```

Available plugins: `:react`, `:typescript`, `:unicorn`, `:import`, `:jsdoc`,
`:jest`, `:vitest`, `:jsx_a11y`, `:nextjs`, `:react_perf`, `:promise`,
`:node`, `:vue`, `:oxc`.

#### Type-Aware Linting

Run TypeScript type-aware rules through `tsgolint` headless mode by passing a
file list and `type_aware: true`:

```elixir
{:ok, diags} = OXC.Lint.run(["lib/app.ts"],
  type_aware: true,
  tsgolint: "tsgolint",
  type_check: true,
  rules: %{"typescript/no-floating-promises" => :deny})
```

The `:tsgolint` option can be a native `tsgolint` executable or the npm shim
from `oxlint-tsgolint`. `type_check: true` also reports TypeScript syntactic and
semantic diagnostics.

#### Custom Elixir Rules

Write project-specific lint rules in Elixir using the same AST from `OXC.parse/2`:

```elixir
defmodule MyApp.NoConsoleLog do
  @behaviour OXC.Lint.Rule

  @impl true
  def meta do
    %{name: "my-app/no-console-log",
      description: "Disallow console.log in production code",
      category: :restriction, fixable: false}
  end

  @impl true
  def run(ast, _context) do
    OXC.collect(ast, fn
      %{type: :call_expression,
        callee: %{type: :member_expression,
                  object: %{type: :identifier, name: "console"},
                  property: %{type: :identifier, name: "log"}},
        start: start, end: stop} ->
        {:keep, %{span: {start, stop}, message: "Unexpected console.log"}}
      _ -> :skip
    end)
  end
end

{:ok, diags} = OXC.Lint.run(source, "app.ts",
  custom_rules: [{MyApp.NoConsoleLog, :warn}])
```

### Parser Event Selection

Select compact parser-backed events without serializing the full AST:

```elixir
source = "import { ref } from 'vue'\nexport { foo } from './foo'\nimport('./lazy')"
{:ok, refs} = OXC.select(source, "test.js", :import_sources)
```

Use `:import_specifiers` when only source strings are needed, `:asset_urls`
for `new URL(..., import.meta.url)` references, `:workers` for worker
constructors using `new URL(..., import.meta.url)`, `:glob_imports` for
`import.meta.glob(...)` calls, and `:import_meta_env` for `import.meta.env`
references.

### Rewrite Specifiers

Rewrite import/export specifiers in a single pass without AST walking:

```elixir
source = "import { ref } from 'vue'\nimport a from './utils'"

{:ok, result} = OXC.rewrite_specifiers(source, "test.js", fn
  "vue" -> {:rewrite, "/@vendor/vue.js"}
  _ -> :keep
end)
# "import { ref } from '/@vendor/vue.js'\nimport a from './utils'"
```

Handles `ImportDeclaration`, `ExportNamedDeclaration`, `ExportAllDeclaration`, and dynamic `import()`.

### Validate

Fast syntax check without building an AST:

```elixir
OXC.valid?("const x = 1", "test.js")
# true

OXC.valid?("const = ;", "bad.js")
# false
```

### AST Traversal

```elixir
{:ok, ast} = OXC.parse("import a from 'a'; import b from 'b'; const x = 1;", "test.js")

# Walk every node
OXC.walk(ast, fn
  %{type: :identifier, name: name} -> IO.puts(name)
  _ -> :ok
end)

# Collect specific nodes
imports = OXC.collect(ast, fn
  %{type: :import_declaration} = node -> {:keep, node}
  _ -> :skip
end)
```

### AST Postwalk and Source Patching

Rewrite source code by walking the AST and collecting byte-offset patches:

```elixir
source = "import { ref } from 'vue'\nimport { h } from 'preact'"
{:ok, ast} = OXC.parse(source, "test.ts")

{_ast, patches} =
  OXC.postwalk(ast, [], fn
    %{type: :import_declaration, source: %{value: "vue", start: s, end: e}}, acc ->
      {nil, [%{start: s, end: e, change: "'/@vendor/vue.js'"} | acc]}
    node, acc ->
      {node, acc}
  end)

rewritten = OXC.patch_string(source, patches)
# "import { ref } from '/@vendor/vue.js'\nimport { h } from 'preact'"
```

`postwalk/2` visits nodes depth-first (children before parent), like `Macro.postwalk/2`.
`postwalk/3` adds an accumulator for collecting data during traversal.
`patch_string/2` applies patches in reverse offset order so positions stay valid.

All traversal functions (`walk/2`, `postwalk/2`, `postwalk/3`) accept either a single AST node or a list of nodes.

### Bundle

Bundle multiple TypeScript/JavaScript modules into a single IIFE script.
Treats the provided files as a virtual project, resolves their imports,
transforms TS/JSX, and bundles the result:

```elixir
files = [
  {"event.ts", "export class Event { type: string; constructor(t: string) { this.type = t } }"},
  {"target.ts", "import { Event } from './event'\nexport class Target extends Event {}"}
]

{:ok, js} = OXC.bundle(files, entry: "target.ts")
```

Options:

```elixir
# Minify with variable mangling
{:ok, js} = OXC.bundle(files, entry: "target.ts", minify: true)

# Tree-shaking (remove unused exports)
{:ok, js} = OXC.bundle(files, entry: "target.ts", treeshake: true)

# Inject code at the top of the IIFE body
{:ok, js} = OXC.bundle(files, entry: "app.ts", preamble: "const { ref } = Vue;")

# Compile-time replacements (like esbuild/Bun define)
{:ok, js} = OXC.bundle(files, entry: "target.ts", define: %{"process.env.NODE_ENV" => ~s("production")})

# Source maps
{:ok, %{code: js, sourcemap: map}} = OXC.bundle(files, entry: "target.ts", sourcemap: true)

# Output format: :iife (default), :esm, or :cjs
{:ok, js} = OXC.bundle(files, entry: "target.ts", format: :esm)

# Remove console.* calls
{:ok, js} = OXC.bundle(files, entry: "target.ts", minify: true, drop_console: true)

# Target-specific downleveling
{:ok, js} = OXC.bundle(files, entry: "target.ts", target: "es2020")

# Banner and footer
{:ok, js} = OXC.bundle(files, entry: "target.ts", banner: "/* MIT */", footer: "/* v1.0 */")
```

For multi-entry builds that need access to all generated chunks and assets, use
`OXC.Bundle`:

```elixir
alias OXC.Bundle

{:ok, result} =
  Bundle.new()
  |> Bundle.entries([
    %{name: "app", import: "app.js", source: "import { shared } from './shared.js'; console.log(shared);"},
    %{name: "admin", import: "admin.js", source: "import { shared } from './shared.js'; console.log(shared);"}
  ])
  |> Bundle.files([{"shared.js", "export const shared = 1;"}])
  |> Bundle.format(:esm)
  |> Bundle.output(entry_file_names: "[name].js", chunk_file_names: "chunks/[name]-[hash].js")
  |> Bundle.run()

Enum.map(result.outputs, & &1.file_name)
#=> ["app.js", "admin.js", "chunks/shared-....js"]
```

### Bang Variants

All functions have bang variants that raise `OXC.Error` on failure:

```elixir
ast = OXC.parse!("const x = 1", "test.js")
js = OXC.transform!("const x: number = 42", "test.ts")
min = OXC.minify!("const x = 1 + 2;", "test.js")
js = OXC.codegen!(ast)
```

### Error Handling

All functions return `{:ok, result}` or `{:error, errors}` where errors are
maps with a `:message` key:

```elixir
{:error, [%{message: "Expected a semicolon or ..."}]} = OXC.parse("const = ;", "bad.js")
```

## How It Works

OXC is a collection of high-performance JavaScript tools written in Rust.
This library wraps `oxc_parser`, `oxc_transformer`, `oxc_minifier`,
`oxc_transformer_plugins`, `oxc_codegen`, and `oxc_linter` via
[Rustler](https://github.com/rusterlium/rustler) NIFs, and uses
Rolldown/OXC for `bundle/2`.

All NIF calls run on the dirty CPU scheduler so they don't block the BEAM.

For **parse**, the parser produces ESTree JSON via OXC's serializer,
Rustler encodes it as BEAM terms, and the Elixir wrapper normalizes
AST keys to atoms with snake_case type values.

For **codegen**, the reverse happens: the Elixir AST map (BEAM terms) is
read directly by the NIF via Rustler's Term API, reconstructed into OXC's
arena-allocated AST using `AstBuilder`, and then emitted as JavaScript
via `oxc_codegen`.

For **lint**, oxlint's built-in rules run natively in Rust. Custom rules
written in Elixir receive the same parsed AST and run in the BEAM.

## Part of Elixir Volt

oxc gives Elixir native-speed JS/TS parsing, transforming, linting, and bundling through the OXC toolchain.

It is part of a frontend stack that runs inside the BEAM — builds, JS
runtimes, icons, and Vue-to-LiveView compilation as supervised parts of the
application instead of external toolchain processes. See the
[Elixir Volt](https://github.com/elixir-volt) organization for the rest, and
[Building Blocks for the Future Web](https://github.com/elixir-vibe/building-blocks)
for the thesis, architecture, and roadmap that tie them together.

## License

MIT
