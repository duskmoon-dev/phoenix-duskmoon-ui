# Repository split verification

Checked on 2026-10-13. Local implementation is complete; neither branch is merged.
Both repositories use `codex/bundler-extraction`. Review the paired descriptions
in [ui-cutover-pr.md](ui-cutover-pr.md) and the destination's
`docs/extraction-pr.md` before rollout.

| Repository | Implementation head before final evidence/documentation commits |
| --- | --- |
| `phoenix-duskmoon-ui` | `4df3ff78ff3c3c4b112ab6697df6c131f01de634` |
| `duskmoon-bundler` | `27cc3088ad427a751b84a52debc277c1162263d9` |

Final handoff commits contain documentation/evidence only. Obtain their actual
heads with `git rev-parse HEAD` in each checkout; the final handoff records them.
Original anchors are UI `bca8e460adabe0454dd41125ed71a02662807767` and destination
`5251f8a29231d8cf3f8f9ff4507ad428d2b1cde6`. Origins remain unchanged. The tracked
inventory classifies all 11,371 original paths; destination import preceded UI
removal, with every moved/duplicated/split original hash verified.

## Result and evidence boundaries

The UI umbrella contains only `phoenix_duskmoon` and `duskmoon_storybook`, with
the actual published **B0=9.16.16** cohort fixed in `BUNDLER_VERSION` and `mix.lock`.
The public component package retains its existing dependency boundary. U remains
9.16.16 and is independent of B. Destination **B1=9.16.17** is an unpublished
stable candidate with new native URLs; historical tags, packages and native
assets are unchanged. All eight B0 registry packages and all 47 historical
archives were checked, including anonymous downloads and checksum/release digest
agreement. See [b0-registry.json](verification/b0-registry.json),
[b0-native-artifacts.json](verification/b0-native-artifacts.json), and
[local-acceptance.json](verification/local-acceptance.json) for durable results,
hashes, measured timings and environment versions.

Host checks used Elixir 1.18.5, OTP 28 (erts16.4.0.5), Bun 1.3.13 and Chromium.
Explicit source candidate builds used Rust 1.95.0 and Zig 0.16.0. Other existing
dependencies, including MDEx, still require native code; the acceptance condition
is zero **Duskmoon toolchain** native source compilations on the ordinary UI path.

| Acceptance scenario | Actual local result |
| --- | --- |
| Independent extraction | Destination source compile with warnings as errors; 655 tests + 2 doctests; complete inventory/hash verification. |
| Cold ordinary UI build | Fresh archived checkout at `c805bb89`, no destination checkout, fresh deps/build/JS/native caches; 3,099 component + 22 Storybook tests and 56 JS tests passed. Both real JS/CSS bundles and 7,447 MDI + 2,050 BSI icons built. Compiler trap log is empty. |
| Representative UI utility | Disposable Storybook `p-[37px]` class appears in cold production CSS. No regression was removed to use B0. |
| Live development | Published B0 Storybook startup, connected LiveView and React form hook passed. A fresh `.heex` `p-[61px]` utility was absent before, present in served CSS after, and delivered a filtered bundler WebSocket `type=update, css=true`. Server/probe compiler logs are empty. |
| Strict native failures | UI policy tests (5) reject source flags through actual Config evaluation. Destination policy tests (4) plus real Rustler/Zigler missing/corrupt download cases (4) passed with isolated compiler traps and no fallback NIF. |
| Candidate-native integration | All eight staged B1 packages overridden only in an external UI snapshot; five Rust crates and QuickBEAM source-built. Disposable OXC native sentinel returns false through `OXC.valid?/2`; published B0 returns true for the same valid JS. Full 3,099 + 22 Elixir/56 JS suites and both assets/icons passed. |
| Package integrity | All eight destination host Hex archives built/inspected; full-cohort external source consumer passed all six native loaders. Final UI Hex/npm archives were unpacked outside both repositories; compile, component/runtime boundary and every npm export passed. |
| Production/runtime | Actual Storybook release contains 51 required applications, excluding the seven Duskmoon compiler apps; homepage and digested JS/CSS returned HTTP 200. Manifest-v1 regression passed with published B0 and staged B1 runtime. Production server stopped. |
| Historical/musl compatibility | All 47 unchanged B0 archives downloaded and matched hashes. Fresh Alpine amd64 registry/native + production JS/Tailwind smoke passed without cargo/rustc/zig. |
| UI release planning | Five pure release tests and final U-only plan passed: exactly `phoenix_duskmoon`, no native matrix or toolchain publication. Root and child `mix version.sync` passed. |
| Bundler release/retry/upgrade planning | Seven pure destination release tests and three CLI retry tests passed. Full47 cohort/public-assets/registry verification precedes one pinned upgrade. Retry checks reject conflicting outputs, reuse verified assets and adopted UI main, and avoid duplicate/empty upgrades. |
| Workflow/static checks | Both repositories passed `mix format --check-formatted` and warnings-as-errors compile in their respective modes. All workflows passed actionlint 1.7.11; Nix syntax passed. |

## Commands and retained local logs

Ordinary and cold checks:

```sh
elixir scripts/check-toolchain.exs
elixir scripts/native-policy-test.exs
elixir scripts/prepare-candidate-test.exs
scripts/with-precompiled-toolchain.sh mix format --check-formatted
scripts/with-precompiled-toolchain.sh mix compile --warnings-as-errors
scripts/cold-ui-check.sh
elixir .github/scripts/release_test.exs
elixir .github/scripts/runtime_consumer.exs 9.16.16
elixir .github/scripts/ui_package.exs stage /tmp/duskmoon-ui-release-stage-final
elixir .github/scripts/ui_package.exs smoke /tmp/duskmoon-ui-release-stage-final
```

The final stage already exists; choose a new absolute stage directory on a retry.
The actual final UI tar hashes are in `verification/local-acceptance.json`.
`/tmp/duskmoon-cold-ui-final.log` retains the cold run; the empty invocation log
is `/tmp/duskmoon-cold-ui.oJJn7A/native-invocations.log`. The full ordinary final
compile log is `/tmp/duskmoon-ui-final-compile.log`, with empty
`/tmp/duskmoon-ui-final-compile-invocations.log`. Live evidence was generated by
`/tmp/duskmoon-storybook-heex-smoke.exs`; its sanitized JSON is retained here in
`verification/local-acceptance.json`. The disposable probe was removed and its
browser and development server stopped.

Candidate preparation recorded its original UI SHA `039a030a...`, working patch
and staged-cohort hashes. Later browser-readiness/Config guard fixes were copied
into that disposable snapshot before successful final validation. The OXC native
probe exists only in the disposable stage. Candidate logs are
`/tmp/duskmoon-ui-candidate-{test,assets,js}.log`; the snapshot lock selected HTTP
family 0.21.5, while both repository locks retain existing 0.21.3. This source/path
lane proves the modified native code ran; it does not prove a published or
precompiled B1. `scripts/candidate-integration.sh` documents its reproducible,
isolated full-cohort lane and requires destination Rust/Zig SDK provisioning.

Final package log: `/tmp/duskmoon-ui-package-smoke-final.log`. Alpine amd64 log:
`/tmp/duskmoon-b0-alpine-amd64-retry.log`; initial registry timeout was retried
with `HEX_HTTP_TIMEOUT=120` and `HEX_HTTP_CONCURRENCY=1`. The image digest and log
hash are retained in the evidence JSON. Standalone toolchain commands and package
hashes are recorded in the destination verification report and
`docs/local-verification.json`.

## Remaining gates and rollout

- B0 has an existing `.story.exs` watch-extension limitation: Phoenix reloads
  story markup, but new Tailwind utilities need an explicit asset build. Supported
  `.heex` HMR and production `.exs` scanning passed. The required upstream Bug /
  `internal request` is [UI #199](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/issues/199),
  severity `needed`, with a callsite TODO and documented manual workaround in
  [bundler-extraction.md](bundler-extraction.md).
- Alpine arm64 runtime was not exercised: the local container attempt returned
  `exec format error` without an emulator. No privileged binfmt setup was done.
- Full Nix/devenv realization remains unverified after a stalled/truncated remote
  nixpkgs fetch. Syntax and upstream `zig_0_16` existence were checked, and actual
  source builds used Zig 0.16.0.
- B1's complete cross-platform native47 build, final release checksums, public
  assets, registry/musl consumers and live upgrade PR are operational release
  gates. Host-only candidate archives and pure automation tests do not satisfy
  those gates. Cross-repository App/PAT coordination and repository release
  credentials/environments remain unconfigured.
- Review/merge destination first, confirm the verified B0 cohort, then review/
  merge UI. B0 permits this cutover before publishing B1. Afterwards configure
  credentials and release B1 through the destination runbook; adopt it through
  one reviewed pinned UI PR and release the next independent U.

Only local implementation/commits were authorized. Nothing was pushed, merged,
tagged, published or deployed; settings/secrets were not changed. The upstream
issue above was the explicit AGENTS-required remote write. Remote PRs were not
created; paired PR descriptions are local files. Exact bootstrap, release,
manual-upgrade and partial-retry commands are in [ui-release.md](ui-release.md)
and the destination `docs/releasing.md` / `docs/upgrade-ui.md`.
