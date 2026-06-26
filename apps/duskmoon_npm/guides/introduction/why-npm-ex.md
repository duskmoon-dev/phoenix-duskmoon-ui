# Why npm_ex

Elixir applications often need npm packages for frontend assets, JavaScript tooling, browser libraries, or runtime integrations. Traditionally that adds a second package manager and a separate `npm install` step.

npm_ex keeps npm dependency management inside Mix.

## What npm_ex provides

- dependency resolution from `package.json`
- npm semver support, including ranges such as `^1.2.0`, `~1.2`, and `>=1 <2`
- a reproducible `npm.lock`
- a global package cache under `~/.npm_ex/cache/`
- `node_modules/` linking and `node_modules/.bin/` executables
- Mix tasks for install, update, audit, verify, outdated, tree, and exec
- security policies for lifecycle scripts, exotic dependencies, registries, and malicious package intelligence

## What npm_ex is not

npm_ex is not the npm CLI and does not try to share npm's lockfile format. `package.json` is the shared manifest; `npm.lock` is npm_ex's reproducibility file.

npm_ex also does not execute package lifecycle hooks automatically. That is a deliberate security choice. Packages that declare install hooks are still installed, but hooks are ignored and reported.

## When to use npm_ex

Use npm_ex when you want npm packages managed as part of an Elixir build or runtime workflow:

- Phoenix asset dependencies
- JS/TS formatters and linters invoked from Mix
- packages needed by Elixir libraries at runtime
- CI installs without a separate npm step
- apps that want npm dependency state visible in Mix tasks

If your project already has a large Node toolchain driven by npm, pnpm, or yarn, npm_ex can still coexist with it, but it is most valuable when Mix should own the install workflow.
