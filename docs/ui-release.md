# Independent UI releases

The UI version **U** synchronizes `mix.exs`, `apps/phoenix_duskmoon/mix.exs`,
`apps/phoenix_duskmoon/package.json` and the Bun workspace lock. Toolchain **B**
uses `~> 10.0` requirements and is resolved by the complete eight-package Hex
lock cohort. The public component package does not require the build toolchain.

Commit a reviewed U version change before running **UI Release** (`release.yml`).
Select the dispatch ref whose head is that release commit and provide `version=U`
and the complete immutable `source_sha`. A mismatch between workflow/source SHA
fails, keeping the workflow definition and build inputs fixed together. The workflow never
bumps B, builds native artifacts, generates checksums, or publishes toolchain
packages. It resolves with `mix deps.get --check-locked`, checks the complete
registry dependency cohort, and uses `scripts/with-precompiled-toolchain.sh`
for real component/browser tests, hooks, production JS/CSS/icons and Storybook
assets. It inspects the actual Storybook `.rel` application list and tests an
isolated staged UI consumer and npm exports. MDEx remains an independent native
dependency; the zero-source-build guarantee applies to Duskmoon's toolchain.

Dry-run planning records `source_dirty` and has no publication side effects.
Formal validation/publication requires a clean immutable source checkout:


```sh
elixir .github/scripts/release_test.exs
elixir .github/scripts/ui_release.exs plan U FULL_UI_SHA
elixir scripts/check-toolchain.exs
scripts/with-precompiled-toolchain.sh mix prepublish
elixir .github/scripts/ui_package.exs stage /tmp/ui-package
elixir .github/scripts/ui_package.exs smoke /tmp/ui-package
```

`U` and `FULL_UI_SHA` above are placeholders. An existing stage directory is
refused. UI CI and package E2E run on both pushes and pull requests, including
GitHub App/PAT upgrade events. No destination checkout is used on these paths.
The separate candidate integration script is only used by an explicit bundler
release lane and never substitutes source dependencies into the committed lock.

## Repository setup

Configure a protected `release` environment, approvals, and a UI-owned Hex API
key (`HEX_API_KEY`) authorized only to publish `phoenix_duskmoon`. Configure npm
trusted publishing for this repository's `release.yml` workflow and release
environment; the publishing job requests `id-token: write` for provenance.
Do not reuse or copy the toolchain repository's secrets. Registry ownership and
trusted-publisher configuration are prerequisites, not changes made by this
migration. Docker/Storybook retains `DOCKERHUB_USER`, `DOCKERHUB_PASSWD` and
`GHCR_TOKEN`, with container-publishing permission scoped to its job.

The release workflow publishes expected Hex/npm tarballs and provenance as
immutable UI release assets, then publishes exactly U to both registries. It
never uses `--replace`, asset overwrite, a moved tag, or a push to main. Existing
matching bytes are reused; conflicting bytes stop publication. The public
GitHub release may therefore exist while a registry publish is still pending;
completion means both registries, the versioned HexDocs site, Alpine consumers
and the Storybook image workflow succeeded. Missing versioned docs are published
separately; retries reuse reachable docs and verify the staged Hex archive stayed
unchanged. Assets and `ui-release.json` record source/lock/package
hashes. U release tags remain in this repository; historical native releases
and their bytes remain untouched.

## Partial recovery and upgrades

Rerun the same U/SHA only after inspecting its provenance and any failed gate.
Matching already-published outputs are reused; a byte conflict requires a new
reviewed U. Never delete a release or overwrite packages to retry. A Docker or
UI regression failure does not undo a successful B release.

The destination's `docs/upgrade-ui.md` describes the version-pinned one-way
upgrade PR/manual command. Review its dependency requirements, `mix.lock` and
`docs/bundler-upgrades/vB.json` changes and require the full UI CI/test/E2E checks.
Merge and the next UI release remain normal reviewed operations. Cross-repository
credentials are separately configured in the destination; ordinary
`GITHUB_TOKEN` does not perform the upgrade.

## Migration verification recorded locally

On 2026-10-13, `elixir .github/scripts/release_test.exs` passed all five
side-effect-free version/ref, package-order, immutable-retry and complete-cohort
adoption tests. `actionlint` v1.7.11 accepted every UI workflow. The U=9.16.16
release plan listed exactly `phoenix_duskmoon`, no native builds and no toolchain
publication, with B=9.16.16 and actual root lock hashes.

`elixir .github/scripts/ui_package.exs stage /tmp/duskmoon-ui-release-stage-final`
and `... smoke /tmp/duskmoon-ui-release-stage-final` built actual final Hex/npm archives,
unpacked them outside the checkout, compiled the Hex contents with warnings as
errors, verified the component/runtime-only application boundary and checked all
npm exports from the packed archive. It passed. The retained manifest-v1
regression ran with `elixir .github/scripts/runtime_consumer.exs 9.16.16`:
1 test, 0 failures. `bun test --cwd apps/phoenix_duskmoon` passed 56 tests.
These are local package checks, not a live U publication or workflow-run claim.

The small functional `release_support.exs` helper is intentionally duplicated in
each repository so neither release pipeline depends on the other checkout.
Both copies have their own script contract tests. Dependency/download caches are
scoped by repository, locks, dependency mode, platform/libc and Elixir/OTP; the
explicit cold UI acceptance helper bypasses caches.
