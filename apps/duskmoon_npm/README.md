# NPM

[![Hex.pm](https://img.shields.io/hexpm/v/npm.svg)](https://hex.pm/packages/npm)
[![CI](https://github.com/elixir-volt/npm_ex/actions/workflows/ci.yml/badge.svg)](https://github.com/elixir-volt/npm_ex/actions/workflows/ci.yml)

npm package management for Elixir — resolve, fetch, cache, and link npm packages from Mix without requiring Node.js for installation.

```sh
mix npm.install lodash
mix npm.exec eslint .
```

`npm_ex` reads `package.json`, resolves npm semver with PubGrub, writes `npm.lock`, and links packages into `node_modules/`.

## Why npm_ex

Elixir projects increasingly need JavaScript packages for assets, formatters, linters, browser libraries, and runtime integrations. npm_ex keeps that workflow inside Mix:

- no `npm install` step required for dependency resolution or linking
- reproducible installs through `npm.lock`
- global package cache in `~/.npm_ex/cache/`
- npm registry auth, mirrors, scoped registries, peer/deprecation warnings
- CI-friendly Mix tasks for install, verify, audit, outdated, tree, and exec

## Installation

```elixir
def deps do
  [{:duskmoon_npm, "~> 9.5.1"}]
end
```

```sh
mix npm.init
mix npm.install lodash
```

## Elixir umbrella projects

For umbrella projects, prefer npm workspaces for frontend assets:

- keep one root `package.json` with a `workspaces` list such as `["apps/*"]`
- keep a `package.json` in each Phoenix web app that owns assets
- run `mix npm.install` from the umbrella root so npm_ex resolves all workspace manifests into one root `npm.lock` and `node_modules/`

Example root manifest:

```json
{
  "name": "my_umbrella",
  "private": true,
  "workspaces": ["apps/*"],
  "dependencies": {
    "tailwindcss": "4.3.0"
  }
}
```

Example Phoenix web app manifest:

```json
{
  "name": "my_app_web",
  "private": true,
  "dependencies": {
    "phoenix_html": "file:../../deps/phoenix_html"
  },
  "devDependencies": {
    "postcss": "8.5.15"
  }
}
```

npm_ex links workspace packages and local directory `file:` packages into the root `node_modules/` and resolves registry dependencies into `npm.lock`.

## Common workflows

```sh
# Install and maintain dependencies
mix npm.install
mix npm.install lodash@^4.0
mix npm.install eslint --save-dev
mix npm.update
mix npm.remove lodash

# CI / reproducibility
mix npm.install --frozen
mix npm.ci
mix npm.verify

# Inspect dependency state
mix npm.list
mix npm.tree
mix npm.why accepts
mix npm.outdated

# Run scripts and binaries
mix npm.run build
mix npm.exec eslint .

# Registry, cache, and config
mix npm.info express
mix npm.search react
mix npm.cache status
mix npm.config
```

## How installs work

1. Read root `package.json` dependencies, workspace package dependencies, dev dependencies, optional dependencies, and root overrides.
2. Resolve the full dependency tree using [duskmoon_hex_solver](https://hex.pm/packages/duskmoon_hex_solver) and the bundled npm semver parser.
3. Fetch registry packuments and tarballs with integrity verification.
4. Store package contents in the global cache.
5. Link registry packages plus local workspace packages into `node_modules/` and write `npm.lock`.

`npm_ex` uses its own `npm.lock` because it is not npm. `package.json` remains the shared manifest; `npm.lock` records npm_ex's resolved dependency graph and security policy.

## Supply-chain safety

npm_ex is intentionally conservative around install-time code execution:

- package lifecycle hooks are **not executed automatically**
- packages declaring `preinstall`, `install`, `postinstall`, or `prepare` are installed but reported as warnings
- tarball paths are validated before extraction to prevent cache escapes
- transitive git, URL, GitHub shorthand, and `file:` dependencies are blocked by default
- direct exotic dependencies require an explicit `exotic_deps` allowlist entry
- registry origins and redirects are policy checked
- newly created packages and freshly published versions can warn during install

This blocks common install-time credential stealers that rely on postinstall hooks reading files like `.env` and exfiltrating secrets during dependency installation.

## Auditing malicious packages

`mix npm.audit` supports npm vulnerability checks and OSV/OpenSSF malicious-package intelligence:

```sh
# npm registry vulnerability audit
mix npm.audit

# Strict online OSV malicious-package gate
mix npm.audit --osv

# Refresh the shared local malicious-package cache for the current lockfile
mix npm.audit --osv --write-cache --policy warn

# Deterministic offline gate using the shared cache or configured DB
mix npm.audit --compromised
```

`--write-cache` merges matching OSV advisories into `~/.npm_ex/security/compromised_packages.json` by default. `mix npm.audit --osv` fails closed when OSV cannot be queried; `mix npm.audit --compromised` is offline and deterministic.

OpenSSF/OSV is the default-compatible open data source. Socket, Snyk, and Phylum provide valuable proprietary intelligence or install-time firewall workflows; they fit best as external scanners/proxies or future optional integrations rather than default npm_ex install dependencies.

## Configuration

Most projects only need the defaults. Use `mix npm.config` to inspect effective settings.

Common environment variables:

- `NPM_REGISTRY`, `NPM_TOKEN`, `NPM_MIRROR`
- `NPM_EX_CACHE_DIR`, `NPM_INSTALL_DIR`
- `NPM_EX_BLOCK_EXOTIC_SUBDEPS`, `NPM_EX_EXOTIC_DEPS`
- `NPM_EX_ALLOWED_REGISTRIES`, `NPM_EX_ALLOW_REGISTRY_REDIRECTS`
- `NPM_EX_PACKAGE_AGE_WARNING_DAYS`, `NPM_EX_VERSION_AGE_WARNING_DAYS`
- `NPM_EX_COMPROMISED_DB_PATH`, `NPM_EX_COMPROMISED_POLICY`

Elixir application config is also supported:

```elixir
config :duskmoon_npm,
  registry: "https://registry.npmjs.org",
  token: System.get_env("NPM_TOKEN"),
  cache_dir: Path.expand("~/.npm_ex"),
  block_exotic_subdeps: true,
  exotic_deps: [],
  allowed_registries: ["https://registry.npmjs.org"],
  allow_registry_redirects: false,
  package_age_warning_days: 7,
  version_age_warning_days: 3,
  compromised_db_path: Path.expand("~/.npm_ex/security/compromised_packages.json"),
  compromised_policy: :error
```

## API organization

The main public API is `NPM`. Supporting modules are grouped by domain: `NPM.Package.*`, `NPM.Dependency.*`, `NPM.Lockfile.*`, `NPM.Security.*`, `NPM.Registry.*`, `NPM.Config.*`, `NPM.Install.*`, `NPM.Node.*`, `NPM.NodeModules.*`, and `NPM.Diagnostics.*`.

See `CHANGELOG.md` for the 0.7 migration map from older pre-namespace module names.

## Documentation

Full guides and API documentation are available on [HexDocs](https://hexdocs.pm/npm):

- Getting Started
- Dependency Workflows
- CI and Reproducibility
- Supply-Chain Safety
- Malicious Package Audits
- Configuration
- CLI and configuration cheatsheets

## License

MIT © 2026 Danila Poyarkov
