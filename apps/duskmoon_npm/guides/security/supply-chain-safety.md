# Supply-Chain Safety

npm packages can execute code during installation in npm, pnpm, and yarn through lifecycle hooks such as `postinstall`. npm_ex does not run those hooks automatically.

## Lifecycle scripts

Packages declaring `preinstall`, `install`, `postinstall`, or `prepare` are installed, but npm_ex reports the ignored hooks as warnings.

This mitigates install-time attacks that steal environment variables, `.env` files, registry tokens, SSH keys, or CI credentials during dependency installation.

If you need to run scripts, do it explicitly and review the package first.

## Tarball extraction

npm_ex validates tarball entries before extraction. Absolute paths and path traversal entries are rejected so package contents cannot escape the cache directory.

## Exotic dependencies

Transitive exotic dependencies from published package metadata are blocked by default. This includes:

- `git:` and `git+...` specs
- GitHub shorthands such as `org/repo#sha`
- `http:` and `https:` tarball specs
- `file:` specs

Direct exotic dependencies are also blocked unless their exact spec is allowlisted:

```elixir
config :duskmoon_npm,
  exotic_deps: ["github:org/repo#sha"]
```

or:

```bash
NPM_EX_EXOTIC_DEPS=github:org/repo#sha mix npm.install
```

## Registry policy

npm_ex checks registry origins for packuments and tarballs. By default allowed origins are derived from the configured registry and mirror. Cross-origin redirects are disabled by default.

```elixir
config :duskmoon_npm,
  allowed_registries: ["https://registry.npmjs.org"],
  allow_registry_redirects: false
```

## Age heuristics

Newly created packages and freshly published versions can be reported as warnings. These heuristics are not proof of compromise; they are prompts for extra review.

```elixir
config :duskmoon_npm,
  package_age_warning_days: 7,
  version_age_warning_days: 3
```

Set thresholds to `0` to disable warnings.

## Lockfile policy

`npm.lock` records dependency security policy. Installs treat lockfiles generated with weaker or incompatible policy as stale, forcing a re-resolution under the current policy.
