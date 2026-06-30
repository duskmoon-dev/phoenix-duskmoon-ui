# Mix Tasks

npm_ex exposes npm-like workflows as Mix tasks.

## Install and update

| Task | Purpose |
| --- | --- |
| `mix npm.init` | create `package.json` |
| `mix npm.install` | install dependencies from `package.json` and npm workspaces |
| `mix npm.install package` | add a package and install |
| `mix npm.install --frozen` | fail if `npm.lock` is stale |
| `mix npm.ci` | CI alias for frozen install |
| `mix npm.get` | fetch and link from `npm.lock` without re-resolving |
| `mix npm.update` | update all packages within configured ranges |
| `mix npm.update package` | update one package |
| `mix npm.remove package` | remove a package |
| `mix npm.prune` | remove extraneous packages |
| `mix npm.rebuild` | clean and reinstall from lockfile |

## Inspect dependency state

| Task | Purpose |
| --- | --- |
| `mix npm.list` / `mix npm.ls` | list installed packages |
| `mix npm.tree` | show dependency tree |
| `mix npm.why package` | explain why a package is installed |
| `mix npm.outdated` | show newer package versions |
| `mix npm.dedupe` | re-resolve to minimize duplicates |
| `mix npm.deprecations` | show deprecated packages |
| `mix npm.licenses` | list dependency licenses |
| `mix npm.fund` | show package funding info |
| `mix npm.stats` | show dependency statistics |
| `mix npm.size` | estimate installed package sizes |

## Run package code

| Task | Purpose |
| --- | --- |
| `mix npm.run script` | run a script from `package.json` |
| `mix npm.exec binary` | execute a binary from `node_modules/.bin` |

## Registry and package information

| Task | Purpose |
| --- | --- |
| `mix npm.info package` / `mix npm.view package` | show package metadata |
| `mix npm.search query` | search the registry |
| `mix npm.publish` | publish package to registry |
| `mix npm.token` | manage registry auth tokens |

## Verification and security

| Task | Purpose |
| --- | --- |
| `mix npm.verify` / `mix npm.check` | verify `node_modules` matches `npm.lock` |
| `mix npm.audit` | npm registry vulnerability audit |
| `mix npm.audit --osv` | online OSV malicious-package audit |
| `mix npm.audit --compromised` | offline malicious-package DB audit |
| `mix npm.doctor` | diagnose setup problems |

## Cache and config

| Task | Purpose |
| --- | --- |
| `mix npm.cache status` | show cache status |
| `mix npm.cache clean` | clean global cache |
| `mix npm.config` | show effective configuration |
| `mix npm.set` | modify configuration |
| `mix npm.completion` | shell completion helpers |

Run any task with invalid arguments to see its usage string. Full task moduledocs are available in the API reference.
