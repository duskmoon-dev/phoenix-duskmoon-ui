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
