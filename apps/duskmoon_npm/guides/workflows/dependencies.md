# Dependency Workflows

## Add packages

```bash
mix npm.install lodash
mix npm.install lodash@^4.17
mix npm.install @types/node@^20
```

By default packages are saved to `dependencies`.

## Development dependencies

```bash
mix npm.install eslint --save-dev
```

Development dependencies are skipped during production installs:

```bash
mix npm.install --production
```

## Exact versions

```bash
mix npm.install lodash --save-exact
```

Without `--save-exact`, npm_ex uses npm-style semver ranges when adding registry packages.

## Remove packages

```bash
mix npm.remove lodash
```

`mix npm.uninstall` is also available as an alias.

## Update packages

Update all packages within their configured ranges:

```bash
mix npm.update
```

Update one package:

```bash
mix npm.update lodash
```

## Inspect dependencies

```bash
mix npm.list
mix npm.tree
mix npm.why accepts
mix npm.outdated
mix npm.deprecations
mix npm.licenses
```

## Fetch from lockfile

If `npm.lock` already exists, fetch and link locked packages without re-resolving:

```bash
mix npm.get
```

## Clean installed packages

```bash
mix npm.clean
```

This removes `node_modules/`. The global cache is left intact.

## Cache maintenance

```bash
mix npm.cache status
mix npm.cache clean
```

Downloaded packages are cached globally so repeated installs across projects reuse the same package contents.
