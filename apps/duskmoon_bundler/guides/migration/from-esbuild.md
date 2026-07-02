# Migrating from esbuild

The easiest way to migrate is the installer:

```bash
mix igniter.install duskmoon_bundler
```

It automatically removes `esbuild` and `tailwind` deps and replaces them with DuskmoonBundler configuration.

## Manual Migration

### 1. Replace Dependencies

Remove from `mix.exs`:

```elixir
{:esbuild, "~> 0.8"},
{:tailwind, "~> 0.2"}
```

Add:

```elixir
{:duskmoon_bundler_runtime, "~> 9.7"},
{:duskmoon_bundler, "~> 9.7", runtime: Mix.env() == :dev}
```

Do not use `only: :dev` for `:duskmoon_bundler`; production asset build aliases may run under `MIX_ENV=prod`. The `runtime:` option keeps the build/dev app out of production releases.

### 2. Replace Config

Remove `config :esbuild` and `config :tailwind` blocks from `config/config.exs`.

Add DuskmoonBundler config (see [Getting Started](../introduction/getting-started.md)).

If your esbuild setup uses `NODE_PATH` to resolve packages outside `node_modules`, add those directories to `resolve_dirs` instead:

```elixir
config :duskmoon_bundler,
  entry: "assets/js/app.js",
  outdir: "priv/static/assets",
  resolve_dirs: [Mix.Project.build_path()]
```

Phoenix LiveView colocated JavaScript uses this pattern. LiveView writes compiled hook modules to `_build/$MIX_ENV/phoenix-colocated/`, and imports them as `"phoenix-colocated/my_app"`. Adding `Mix.Project.build_path()` lets DuskmoonBundler resolve and bundle those imports.

### 3. Replace Endpoint Plug

Remove the esbuild/tailwind watchers from `config/dev.exs` and add the DuskmoonBundler dev server plug to your endpoint.

### 4. Replace Build Aliases

Update `assets.build` and `assets.deploy` in `mix.exs`:

```elixir
"assets.build": ["duskmoon_bundler.build --tailwind"],
"assets.deploy": ["duskmoon_bundler.build --tailwind", "phx.digest"]
```

### 5. Remove Binaries

Delete any cached esbuild/tailwind binaries:

```bash
rm -rf _build/esbuild* _build/tailwind*
```
