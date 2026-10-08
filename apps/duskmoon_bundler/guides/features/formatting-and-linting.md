# Formatting and Linting

## Formatting

`DuskmoonBundler.Formatter` is a `mix format` plugin — JS/TS files are formatted alongside Elixir using oxfmt via NIF (~30× faster than Prettier).

For a new project, add to `.formatter.exs`:

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

Or format all assets discovered by the standalone task:

```bash
mix duskmoon_bundler.js.format
```

### Configuration

With no configuration, the profile uses two-space indentation, an 80-column
print width, semicolons, double quotes, trailing commas, spaces inside object
braces, parentheses around arrow parameters, and LF line endings. Formatting
normalizes the whole selected file, including spacing and line wrapping.

To match a project that uses single quotes, omits semicolons and trailing commas,
and wraps at 100 columns, put this in `config/config.exs`:

```elixir
config :duskmoon_bundler, :format,
  print_width: 100,
  semi: false,
  single_quote: true,
  trailing_comma: :none,
  arrow_parens: :always
```

Use the [OXC.Format options](https://hexdocs.pm/duskmoon_oxc/OXC.Format.html) to
choose the project's profile. Options reduce style differences but do not
preserve arbitrary whitespace or provide changed-line-only formatting.

If `config :duskmoon_bundler, :format` is unset, the formatter searches the
working directory, then the configured assets directory, for `.oxfmtrc.json`,
`.oxfmtrc`, `.prettierrc.json`, or `.prettierrc`, in that order. These files must
contain JSON. For example, the equivalent `.oxfmtrc.json` is:

```json
{
  "printWidth": 100,
  "semi": false,
  "singleQuote": true,
  "trailingComma": "none",
  "arrowParens": "always"
}
```

Elixir configuration takes precedence over the JSON file; the two are not
merged. JavaScript configuration files and Prettier plugins are not loaded.

### Incremental adoption in an existing Phoenix project

Changing asset build tools does not require changing formatter configuration.
Keep the existing JavaScript formatter during the build migration if desired,
then adopt `DuskmoonBundler.Formatter` in a separate change:

1. Choose and configure the formatting profile before converting files.
2. Add the plugin while preserving the project's existing Elixir inputs and
   formatter plugins. Add only individual adopted JS/TS files or a dedicated
   directory of new files to `inputs`, rather than the entire assets tree:

   ```elixir
   [
     plugins: [Phoenix.LiveView.HTMLFormatter, DuskmoonBundler.Formatter],
     inputs: [
       "{mix,.formatter}.exs",
       "{config,lib,test}/**/*.{ex,exs,heex}",
       "assets/js/hooks/new_hook.js"
     ]
   ]
   ```

   In an umbrella, configure this in the relevant app's `.formatter.exs`,
   with paths relative to that app. Keep the root's `subdirectories` setting.

3. Convert and review the selected file explicitly:

   ```bash
   mix format assets/js/hooks/new_hook.js
   git diff -- assets/js/hooks/new_hook.js
   mix format --check-formatted
   ```

   Commit the formatting conversion separately from functional changes.
   Existing API/Admin assets omitted from `inputs` are left untouched by
   argument-free `mix format` and are not checked by its CI check.
4. Expand `inputs` one reviewed file or directory at a time. When all assets
   have been converted, use a broad glob if desired. A one-time conversion of
   the entire tree is also supported, but should be reviewed and committed as
   its own formatting change.

An explicit filename passed to `mix format` bypasses the `inputs` selection;
avoid invoking it on unadopted files. `mix format --check-formatted` never
writes files, but will report a selected unconverted file as unformatted.

The standalone `mix duskmoon_bundler.js.format` and
`mix duskmoon_bundler.js.check` tasks discover files using the bundler's
`sources` and `ignore`, not `.formatter.exs` inputs. Do not add their broad
formatting checks to CI until those discovered files have been converted.
Use `mix format --check-formatted` for the incremental formatter gate; linting
can still run separately with `mix duskmoon_bundler.lint`.

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
