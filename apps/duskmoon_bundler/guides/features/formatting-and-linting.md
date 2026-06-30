# Formatting and Linting

## Formatting

`DuskmoonBundler.Formatter` is a `mix format` plugin — JS/TS files are formatted alongside Elixir using oxfmt via NIF (~30× faster than Prettier).

Add to `.formatter.exs`:

```elixir
[
  plugins: [DuskmoonBundler.Formatter],
  inputs: [
    "{mix,.formatter}.exs",
    "{config,lib,test}/**/*.{ex,exs}",
    "assets/**/*.{js,ts,jsx,tsx}"
  ]
]
```

Or format manually:

```bash
mix duskmoon_bundler.js.format
```

### Configuration

```elixir
config :duskmoon_bundler, :format,
  print_width: 100,
  semi: false,
  single_quote: true,
  trailing_comma: :none,
  arrow_parens: :always
```

All [oxfmt options](https://hexdocs.pm/duskmoon_oxc/OXC.Format.html) are supported. Falls back to `.oxfmtrc.json` if no Elixir config is set.

## Linting

Lint JS/TS assets using oxlint via NIF — 650+ rules, no Node.js required:

```bash
mix duskmoon_bundler.lint
mix duskmoon_bundler.lint --plugin react --plugin typescript
```

Available plugins: `react`, `typescript`, `unicorn`, `import`, `jsdoc`, `jest`, `vitest`, `jsx_a11y`, `nextjs`, `react_perf`, `promise`, `node`, `vue`, `oxc`.

### Configuration

```elixir
config :duskmoon_bundler, :lint,
  plugins: [:typescript],
  rules: %{
    "no-debugger" => :deny,
    "eqeqeq" => :deny,
    "typescript/no-explicit-any" => :warn
  }
```

### Custom Rules

Custom lint rules can be written in Elixir using the `OXC.Lint.Rule` behaviour — see the [oxc docs](https://hexdocs.pm/duskmoon_oxc/OXC.Lint.Rule.html).

## Combined Check

Check formatting and lint in one command (useful for CI):

```bash
mix duskmoon_bundler.js.check
```

For TypeScript projects, run type-aware rules through `tsgolint` headless mode:

```bash
mix duskmoon_bundler.js.check --type-aware
mix duskmoon_bundler.js.check --type-aware --type-check
```

`--type-aware` also checks JavaScript-like scripts embedded in framework component files when the enabled plugin exposes them. DuskmoonBundler's built-in Vue and Svelte plugins expose `<script>` blocks as virtual `.js`, `.ts`, or `.tsx` modules for `tsgolint`, then map diagnostics back to the original `.vue` or `.svelte` file. Component templates are still handled by the normal syntax lint/format path; they are not passed to `tsgolint`.

Configure the executable when it is not on `PATH`:

```elixir
config :duskmoon_bundler, :lint,
  tsgolint: "./node_modules/.bin/tsgolint",
  rules: %{
    "correctness" => :deny,
    "typescript/no-floating-promises" => :deny
  }
```

Oxlint category rules such as `"correctness"` and syntax-only rules such as `"no-console"` apply to the normal lint path and are not forwarded to `tsgolint`. Type-aware rules follow Oxlint's `"typescript/*"` naming convention and are forwarded to `tsgolint` when `--type-aware` is enabled.

Exits with non-zero status on issues.
