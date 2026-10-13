# Duskmoon Bundler extraction

The UI repository owns `phoenix_duskmoon` and `duskmoon_storybook`. The independent
[duskmoon-bundler](https://github.com/duskmoon-dev/duskmoon-bundler) repository owns
`duskmoon_bundler`, `duskmoon_bundler_runtime`, `duskmoon_oxc`, `duskmoon_oxide`,
`duskmoon_vize`, `duskmoon_quickbeam`, `duskmoon_npm`, and `duskmoon_hex_solver`.
Application, module, Hex and npm names remain unchanged. The UI root remains a
small two-application umbrella.

## Bootstrap and versions

The initial consumer baseline B0 is **9.16.16**. All eight versions were found on
Hex on 2026-10-13, and their actual registry requirements resolve together. The
historical UI release contains 47 native assets. Registry and artifact evidence
is in `docs/verification/`; executable regression results are recorded in
`docs/verification-report.md`. The native URL in these already published packages
still points to the UI repository's `v9.16.16`. Historical tags, releases and assets
remain untouched.

`BUNDLER_VERSION` pins B, and the root `mix.lock` fixes the actual eight-package
cohort. The first independent bundler release candidate is B1 **9.16.17**, above
the current registry versions and checked as unused. It is unpublished. Its new
artifacts belong to `duskmoon-bundler/releases/download/v9.16.17`; its loaders must
never reuse historical binaries under that new version.

U is the synchronized `phoenix_duskmoon` Hex/npm version. B is the synchronized
eight-package toolchain version. Updating B does not bump U; normal UI release
automation chooses U after the upgrade PR passes review and regression.

The provenance-preserving import records source SHA
`bca8e460adabe0454dd41125ed71a02662807767` and destination baseline
`5251f8a29231d8cf3f8f9ff4507ad428d2b1cde6`. Every original tracked path is classified
in `docs/migration-inventory.json`. The destination committed the full import
before this branch removed active toolchain sources.

## UI development

No destination checkout is required:

```sh
mix deps.get
bun install --frozen-lockfile
elixir scripts/check-toolchain.exs
scripts/with-precompiled-toolchain.sh mix compile --warnings-as-errors
scripts/with-precompiled-toolchain.sh mix test
scripts/with-precompiled-toolchain.sh mix prepublish
scripts/with-precompiled-toolchain.sh mix duskmoon_bundler.build duskmoon_storybook
mix phx.server
```

The build tool remains available in `MIX_ENV=prod`; `runtime: false` prevents its
inclusion as a Storybook runtime dependency and does not prevent compilation.
`duskmoon_bundler_runtime` provides manifest/static-path/preload behavior in
production. `scripts/check-release-applications.exs` verifies the actual release
application set. The public `phoenix_duskmoon` component package retains its own
dependency boundary and does not acquire a mandatory bundler dependency.

The UI Bun workspace contains only UI and Storybook. UI asset profiles, explicit
Tailwind source scanning, JS/CSS/icons, LiveView hooks, forms, and browser tests
remain here. Internal HMR/compiler profiles, fixtures and lint tooling moved to
the toolchain repository. The UI-specific dev-vendor browser regression moved to
Storybook; shared browser support is intentionally duplicated for independent
checkouts.

Ordinary UI builds use strict precompiled mode. Legacy Duskmoon, OXC, Oxide, Vize,
QuickBEAM and global Rustler/Zigler source flags conflict with that lane and fail
before compilation. The wrapper records native invocations and refuses Duskmoon
source compiler calls. Published loaders verify archive checksums and fail on
missing/corrupt archives. Third-party dependencies such as MDEx and the HTTP
family retain their own native requirements; this split promises zero **Duskmoon**
native source compilations, not removal of all NIFs.

## Candidate integration

For explicitly requested local toolchain development:

```sh
scripts/candidate-integration.sh /absolute/path/to/duskmoon-bundler
```

This helper stages all eight candidate packages, snapshots the UI, overrides the
complete closure in that disposable snapshot, and uses independent deps/build/
lock state and explicit source mode. It records UI SHA/patch and staging hashes.
It cannot enter normal UI CI or public metadata. Candidate source validation is
separate from registry-installed precompiled validation. Stable B versions avoid
RustlerPrecompiled's prerelease force-build behavior; a `-dev` build does not
prove the released precompiled path.

## Rollout and recovery

1. Review and merge the destination extraction, retaining all unpublished fixes.
2. Confirm B0 registry/native compatibility and the independent UI checks recorded
   here. B0 permits the initial UI cutover before publishing B1.
3. Review and merge this independently tested UI consumer cutover.
4. Configure repository environments/credentials from the two release runbooks.
   A formal B1 release builds the full matrix, exposes immutable native assets,
   publishes and verifies all eight packages, then opens one pinned UI upgrade PR.
5. Review that PR and its full asset/regression checks, then release the next U.

A future UI feature that needs an unpublished toolchain fix must stay gated until
that B is actually published and verified. Never invent lock entries or suppress
its regression. A partial B release does not initiate adoption; retry only missing
steps after checking existing immutable outputs. A failed UI upgrade leaves the
successful B intact and the PR pending. No rollback or reciprocal dispatch loop
is added.

See `docs/ui-release.md` and the destination release/upgrade runbooks for exact
commands, package staging, approval environments, narrowly scoped credentials,
manual pinned upgrades, retry behavior and merge order. This migration authorizes
local implementation and verification only; pushing, publication, tags, deployment
and settings/secrets changes remain separate operational steps.
