# Configuration

npm_ex reads configuration from environment variables, Elixir application config, and `.npmrc` files where applicable.

Environment variables take precedence over application config.

## Registry and auth

```elixir
config :duskmoon_npm,
  registry: "https://registry.npmjs.org",
  token: System.get_env("NPM_TOKEN"),
  mirror: "https://registry.npmmirror.com"
```

Environment variables:

```bash
NPM_REGISTRY=https://registry.npmjs.org
NPM_TOKEN=npm_...
NPM_MIRROR=https://registry.npmmirror.com
```

`NPM_REGISTRY`, `NPM_TOKEN`, and `NPM_MIRROR` intentionally use npm-compatible names.

## Cache and install paths

```elixir
config :duskmoon_npm,
  cache_dir: Path.expand("~/.npm_ex"),
  install_dir: "/tmp/npm-installs"
```

Environment variables:

```bash
NPM_EX_CACHE_DIR=~/.npm_ex
NPM_INSTALL_DIR=/tmp/npm-installs
```

`cache_dir` stores registry/cache state shared across projects. `install_dir` controls runtime installs through `NPM.install/2`.

## Exotic dependency policy

```elixir
config :duskmoon_npm,
  block_exotic_subdeps: true,
  exotic_deps: []
```

Environment variables:

```bash
NPM_EX_BLOCK_EXOTIC_SUBDEPS=true
NPM_EX_EXOTIC_DEPS=github:org/repo#sha,file:../local-package
```

`exotic_deps` is an exact-spec allowlist for direct dependencies. Transitive exotic dependencies are blocked by default.

## Registry policy

```elixir
config :duskmoon_npm,
  allowed_registries: ["https://registry.npmjs.org"],
  allow_registry_redirects: false
```

Environment variables:

```bash
NPM_EX_ALLOWED_REGISTRIES=https://registry.npmjs.org,https://registry.npmmirror.com
NPM_EX_ALLOW_REGISTRY_REDIRECTS=false
```

Allowed registries are compared by origin.

## Age warnings

```elixir
config :duskmoon_npm,
  package_age_warning_days: 7,
  version_age_warning_days: 3
```

Environment variables:

```bash
NPM_EX_PACKAGE_AGE_WARNING_DAYS=7
NPM_EX_VERSION_AGE_WARNING_DAYS=3
```

Set either value to `0` to disable that warning.

## Compromised-package audits

```elixir
config :duskmoon_npm,
  compromised_db_path: Path.expand("~/.npm_ex/security/compromised_packages.json"),
  compromised_sources: [:local],
  compromised_policy: :error
```

Environment variables:

```bash
NPM_EX_COMPROMISED_DB_PATH=~/.npm_ex/security/compromised_packages.json
NPM_EX_COMPROMISED_SOURCES=local
NPM_EX_COMPROMISED_POLICY=error
```

`compromised_policy` can be `:error`, `:warn`, or `:off`.

## Inspect effective config

```bash
mix npm.config
```

This prints the active registry, cache path, auth status, link strategy, compromised-package database path, compromised-package sources, and compromised-package policy.
