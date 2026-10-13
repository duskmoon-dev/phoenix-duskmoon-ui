# Migration progress

Last updated: 2026-10-13. Both local branches: `codex/bundler-extraction`.

- Source/destination anchors and clean working trees confirmed; origins unchanged.
- Full toolchain snapshot imported and source inventory committed before removal.
- Eight toolchain apps removed from active UI umbrella; UI-specific browser regression
  relocated with its browser support.
- B0 9.16.16 registry cohort resolves; all 47 historical archives were downloaded
  anonymously and checked against checksums/release digests. Published native
  modules executed in independent glibc and fresh Alpine amd64 consumers.
  B1 9.16.17 remains an unpublished destination candidate; U remains 9.16.16.
- Cold independent UI validation passed 3,099 component + 22 Storybook tests,
  56 JS tests, both real JS/CSS bundles and icons, with fresh caches and an empty
  Duskmoon native compiler invocation log. The representative class was generated.
- Full-eight-package source candidate integration passed the same suites/assets.
  A disposable OXC native sentinel proved candidate execution rather than B0 reuse.
- Final Hex/npm archives passed external consumer/exports checks. Production
  assets and the actual 51-app Storybook release boundary passed. Live `.heex` HMR,
  LiveView/React hook startup and zero native invocations passed; owned servers
  and temporary browsers/probes were stopped/removed.
- Independent release/upgrade workflows and pure retry/policy checks are complete;
  format, warnings-as-errors compile and actionlint passed. Local implementation
  and reviewable commits are complete; real rollout remains separately authorized.
- Known B0 `.exs` watcher limitation is tracked in upstream issue #199, with a
  callsite TODO and manual asset-build workaround. Alpine arm64 lacks local
  emulation; full Nix realization was blocked by a remote nixpkgs fetch. Full B1
  native47/publication and cross-repository coordination remain operational gates.

Review `docs/verification-report.md`, `docs/verification/local-acceptance.json`,
`docs/ui-cutover-pr.md` and the destination progress/runbooks. Implementation heads
before final documentation are UI `4df3ff78` and destination `27cc3088`.
No push, tag, publish, deployment or remote settings mutation was authorized or
performed. The upstream issue is the AGENTS-required remote write; PR descriptions
remain local.
