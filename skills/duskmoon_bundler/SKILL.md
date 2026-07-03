---
name: duskmoon-bundler
description: >
  Setup and use DuskmoonBundler for Phoenix and Phoenix LiveView assets. Use when
  installing or configuring :duskmoon_bundler, :duskmoon_bundler_runtime, or
  duskmoon_npm; replacing esbuild, Tailwind CLI, Bun, npm, or yarn workflows;
  adding DuskmoonBundler.DevServer; defining named bundler profiles; wiring
  static_path or preload tags; building assets with mix duskmoon_bundler.build;
  installing packages with mix npm.install; or running JS/TS format and lint tasks.
---

# Duskmoon Bundler

Use DuskmoonBundler as the Phoenix asset toolchain for JavaScript, TypeScript,
CSS, Tailwind v4, HMR, production manifests, JS/TS formatting and linting, and
npm package management through `duskmoon_npm`. Keep setup small and prefer the
installer unless the user is in an umbrella, custom endpoint, or migration path
that needs manual edits.

Current repository package version: `9.7.1` for `duskmoon_bundler`,
`duskmoon_bundler_runtime`, and `duskmoon_npm`.

## Setup Path

Prefer the Igniter installer for normal Phoenix apps:

```bash
mix igniter.install duskmoon_bundler
mix phx.server
```

The installer should remove esbuild and tailwind, add the DuskmoonBundler deps,
add config, add `DuskmoonBundler.DevServer`, add the dev watcher, update asset
aliases, and register `DuskmoonBundler.Formatter`.

Treat DuskmoonBundler plus `duskmoon_npm` as the replacement for Phoenix's
esbuild/Tailwind binary setup and Bun/npm/yarn package install workflows. Use
Mix tasks such as `mix npm.install` instead of `bun add`, `bun install`,
`npm install`, or `yarn install`.

Use manual setup when reviewing, repairing, or configuring an app without
running Igniter. Add both dependencies:

```elixir
def deps do
  [
    {:duskmoon_bundler_runtime, "~> 9.7"},
    {:duskmoon_bundler, "~> 9.7", runtime: Mix.env() == :dev}
  ]
end
```

Do not set `:duskmoon_bundler` to `only: :dev`; production asset aliases often
run under `MIX_ENV=prod`. The `runtime:` option keeps the build toolchain out of
releases while leaving Mix tasks available.

`duskmoon_npm` is a DuskmoonBundler dependency. Add it explicitly only when a
project needs npm package-management tasks without depending on
`:duskmoon_bundler`:

```elixir
{:duskmoon_npm, "~> 9.7"}
```

## NPM Package Management

Use `duskmoon_npm` for package manifests, installs, scripts, and local package
binaries. It reads `package.json`, resolves npm semver, writes `npm.lock`, links
`node_modules/`, and keeps package installation inside Mix.

For a new project:

```bash
mix npm.init
mix npm.install
```

For existing dependencies after cloning or editing `package.json`:

```bash
mix npm.install
```

Add packages through Mix instead of Bun/npm/yarn:

```bash
mix npm.install lodash
mix npm.install @types/node@^20
mix npm.install eslint --save-dev
mix npm.install lodash --save-exact
```

Use CI/frozen installs when the lockfile must not drift:

```bash
mix npm.ci
mix npm.install --frozen
mix npm.verify
```

Run package scripts and local binaries with:

```bash
mix npm.run build
mix npm.exec eslint .
```

For umbrella Phoenix assets, prefer one root `package.json` with workspaces and
per-web-app manifests for apps that own assets:

```json
{
  "name": "my_umbrella",
  "private": true,
  "workspaces": ["apps/*"]
}
```

Run `mix npm.install` from the umbrella root so `duskmoon_npm` resolves the root
manifest and all workspace manifests into one root `npm.lock` and
`node_modules/`.

Commit `package.json` and `npm.lock`. Do not commit `node_modules/`. Package
lifecycle hooks are not executed automatically; packages declaring install hooks
are installed with warnings for supply-chain safety.

## Build Config

Configure a single app in `config/config.exs`:

```elixir
config :duskmoon_bundler,
  entry: "assets/js/app.ts",
  root: "assets",
  target: :es2020,
  sourcemap: :hidden,
  tailwind: [
    css: "assets/css/app.css",
    sources: [
      %{base: "lib/", pattern: "**/*.{ex,heex}"},
      %{base: "assets/", pattern: "**/*.{js,ts,jsx,tsx}"}
    ]
  ]
```

Use named profiles for umbrellas or multiple web apps. Apply the same profile to
config, watchers, `DuskmoonBundler.DevServer`, build commands, and runtime
helpers:

```elixir
config :duskmoon_bundler, :my_app_web,
  root: "apps/my_app_web/assets",
  entry: "apps/my_app_web/assets/js/app.js",
  outdir: "apps/my_app_web/priv/static/assets",
  resolve_dirs: ["apps", "deps"],
  tailwind: [
    css: "apps/my_app_web/assets/css/app.css",
    sources: [
      %{base: "apps/my_app_web/lib", pattern: "**/*.{ex,exs,heex}"},
      %{base: "apps/my_app_web/assets", pattern: "**/*.{css,js,ts,jsx,tsx}"}
    ]
  ],
  server: [
    watch_dirs: ["apps/my_app_web/lib", "apps/my_app_web/assets"]
  ]
```

Use this repository as a local example: `config/config.exs` defines the
`:phoenix_duskmoon` and `:duskmoon_storybook` profiles.

## Dev Server

Add the dev server plug inside the endpoint's `code_reloading?` path so it can
serve source modules and HMR endpoints in development:

```elixir
if code_reloading? do
  plug DuskmoonBundler.DevServer, root: "assets"
end
```

For named profiles, pass the profile and match the prefix to the assets you want
the dev server to handle:

```elixir
if code_reloading? do
  plug DuskmoonBundler.DevServer,
    profile: :my_app_web,
    root: "apps/my_app_web/assets/js",
    prefix: "/assets/js"
end
```

Start the watcher from `config/dev.exs`:

```elixir
config :my_app, MyAppWeb.Endpoint,
  watchers: [
    duskmoon_bundler: {Mix.Tasks.DuskmoonBundler.Dev, :run, [~w(--tailwind)]}
  ]
```

For a profile watcher:

```elixir
config :my_app, MyAppWeb.Endpoint,
  watchers: [
    duskmoon_bundler: {Mix.Tasks.DuskmoonBundler.Dev, :run, [["my_app_web"]]}
  ]
```

Use `mix duskmoon_bundler.dev` or `mix duskmoon_bundler.dev my_app_web` when
starting the watcher directly.

## Layout Tags

Use runtime helpers in layouts instead of hard-coded built filenames:

```heex
<link phx-track-static rel="stylesheet" href={DuskmoonBundler.static_path(@endpoint, "/assets/css/app.css")} />
<script defer phx-track-static type="module" src={DuskmoonBundler.static_path(@endpoint, "/assets/js/app.js")}></script>
<%= DuskmoonBundler.Preload.tags(@endpoint, "/assets/js/app.js") %>
```

Pass `profile: :my_app_web` for named profile assets:

```heex
<script
  defer
  type="module"
  src={DuskmoonBundler.static_path(MyAppWeb.Endpoint, "/assets/js/app.js", profile: :my_app_web)}
>
</script>
```

`duskmoon_bundler_runtime` owns these helpers and reads production manifests
without starting the dev/build toolchain.

## Production Build

Use asset aliases for Phoenix projects:

```elixir
defp aliases do
  [
    "assets.build": ["duskmoon_bundler.build --tailwind"],
    "assets.deploy": ["duskmoon_bundler.build --tailwind", "phx.digest"]
  ]
end
```

Build manually when needed:

```bash
mix duskmoon_bundler.build
mix duskmoon_bundler.build my_app_web
mix duskmoon_bundler.build my_app_web --tailwind
```

Common production options:

- Use `sourcemap: :hidden` or `--sourcemap hidden` for error tracking without
  exposing source map URLs.
- Use `asset_url_prefix` or `--asset-url-prefix` to change public asset URLs
  without changing `outdir`.
- Use `public_dir` only when intentionally preserving Vite-style public
  directory behavior.
- Keep `hash: true` for normal production builds; use `hash: false` only when a
  package or fixture needs stable filenames.
- Use `external: ~w(phoenix phoenix_html phoenix_live_view)` when those packages
  are provided by the host page.

## Formatting And Linting

Register the formatter when JS/TS files should be formatted by `mix format`:

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

Configure format and lint behavior in Elixir config:

```elixir
config :duskmoon_bundler, :format,
  print_width: 100,
  semi: false,
  single_quote: true,
  trailing_comma: :none,
  arrow_parens: :always

config :duskmoon_bundler, :lint,
  plugins: [:typescript],
  rules: %{
    "no-debugger" => :deny,
    "eqeqeq" => :deny
  }
```

Use these commands:

```bash
mix format
mix duskmoon_bundler.js.format
mix duskmoon_bundler.lint
mix duskmoon_bundler.js.check
mix duskmoon_bundler.js.check --type-aware --type-check
```

Configure `config :duskmoon_bundler, :lint, tsgolint: "...", cwd: "..."` when
type-aware checks need a project-local `tsgolint` executable.

## Validation

After setup or changes, run the smallest checks that prove the edited surface:

```bash
mix deps.get
mix npm.install  # when package.json exists or npm deps changed
mix compile --warnings-as-errors
mix format --check-formatted
mix duskmoon_bundler.js.check
mix duskmoon_bundler.build --tailwind
```

For named profiles, validate the profile explicitly:

```bash
mix duskmoon_bundler.build my_app_web --tailwind
```

When editing this umbrella repository, run commands from the repository root and
scope builds to the touched profile when possible, for example:

```bash
mix duskmoon_bundler.build phoenix_duskmoon
mix duskmoon_bundler.build duskmoon_storybook
```

## Troubleshooting

If dev assets 404, verify `root`, `prefix`, and the requested layout path match.
For example, a layout path of `/assets/js/app.js` usually needs a dev server
prefix of `/assets/js` or a root that makes the requested relative path resolve.

If production helpers cannot find an asset, check that the build wrote
`manifest.json` below the configured `outdir` and that the layout path matches
the original source asset path, such as `/assets/js/app.js`.

If Tailwind classes are missing, expand the `tailwind[:sources]` list to include
all HEEX, EEx, Elixir, JS, TS, JSX, TSX, Vue, Svelte, or Solid files that contain
class names.

If umbrella assets resolve packages incorrectly, set `resolve_dirs: ["apps", "deps"]`
or add the project-specific directories that contain dependencies.

If `mix npm.exec` cannot find a binary, run `mix npm.install` first and confirm
the package exposes a `bin` entry under `node_modules/.bin/`.
