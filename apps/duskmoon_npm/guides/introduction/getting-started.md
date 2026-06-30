# Getting Started

## Install npm_ex

Add `:npm` to your Mix dependencies:

```elixir
def deps do
  [{:duskmoon_npm, "~> 9.5.1"}]
end
```

Fetch dependencies:

```bash
mix deps.get
```

## Create `package.json`

For a new project:

```bash
mix npm.init
```

This creates a minimal `package.json` in the project root.

If your project already has a `package.json`, npm_ex will use it directly.

## Umbrella Phoenix assets

In an Elixir umbrella, use npm workspaces instead of separate install roots for each Phoenix web app.

Put a root `package.json` at the umbrella root:

```json
{
  "name": "my_umbrella",
  "private": true,
  "workspaces": ["apps/*"]
}
```

Then put a `package.json` in each Phoenix web app that owns frontend assets:

```json
{
  "name": "my_app_web",
  "private": true,
  "dependencies": {
    "phoenix_html": "file:../../deps/phoenix_html"
  }
}
```

Run `mix npm.install` from the umbrella root. npm_ex reads the root manifest plus workspace manifests, resolves registry dependencies into one root `npm.lock`, and links workspace/local packages into root `node_modules/`.

## Add dependencies

```bash
mix npm.install lodash
mix npm.install @types/node@^20
mix npm.install eslint --save-dev
```

npm_ex updates `package.json`, resolves the dependency graph, downloads packages into the global cache, links `node_modules/`, and writes `npm.lock`.

## Install existing dependencies

```bash
mix npm.install
```

Use this after editing `package.json` or cloning a project.

## Run package binaries

Executables from package `bin` fields are linked into `node_modules/.bin/`:

```bash
mix npm.exec eslint .
```

## Run package scripts

```json
{
  "scripts": {
    "build": "vite build"
  }
}
```

```bash
mix npm.run build
```

## Commit files

Commit:

- `package.json`
- `npm.lock`

Do not commit `node_modules/`.

## CI install

Use frozen mode in CI so lockfile drift fails the build:

```bash
mix npm.ci
```

Equivalent:

```bash
mix npm.install --frozen
```

See [CI and reproducibility](../workflows/ci.md) for a full workflow.
