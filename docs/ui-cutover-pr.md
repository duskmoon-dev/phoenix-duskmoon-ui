# Consume the published Duskmoon toolchain in the UI umbrella

Ordinary UI work currently shares the native toolchain's umbrella and release
cycle. This cutover keeps only `phoenix_duskmoon` and `duskmoon_storybook` here and
pins the complete published B0=9.16.16 Hex cohort. UI assets still rebuild, while
strict precompiled guards and compiler instrumentation prevent Duskmoon native
source builds. The public component API/dependency boundary, UI package names,
manifest-v1 behavior, hooks/forms and exports remain compatible.

Toolchain apps/resources/tests move to the paired destination extraction with
source path/hash provenance. UI-specific browser regressions remain here. UI-only
release automation stages and verifies Hex/npm U, keeps B independent, checks the
actual production application set, and preserves immutable retry behavior.
The optional candidate helper uses all eight packages in isolated source mode.

Validation: cold independent UI build passed 3,099 component + 22 Storybook tests,
56 JS tests, both real JS/CSS bundles/icons and zero Duskmoon native compiler
invocations. All 47 historical B0 archives matched checksums. Live `.heex` CSS HMR,
React hook/LiveView startup, production assets and the 51-app runtime release
passed. Actual final Hex/npm archive consumers and published B0 Alpine amd64
native/assets smoke passed. Candidate OXC source sentinel and full UI regression
passed separately. Format, warnings-as-errors compile, policy/release tests and
actionlint passed; full evidence and limits are in `docs/verification-report.md`.

Published B0 has an existing Storybook `.exs` CSS watcher limitation tracked in
[UI #199](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/issues/199), with an
explicit-build workaround. Alpine arm64 runtime and full Nix realization remain
unverified environment gates. B1=9.16.17 remains unpublished; its full matrix,
registry/musl proof and cross-repository credentials are future release gates.

Merge order: review/merge destination extraction first, retain and confirm verified
B0, then review/merge this UI cutover. B0 allows cutover before B1 publication.
Enable release credentials afterward; formal B releases create one pinned UI
upgrade PR, with review and a separate U release. See both release runbooks.
This description prepares a local PR; no remote PR, push or publication occurred.
