# Migration progress

Last updated: 2026-10-13. Both local branches: `codex/bundler-extraction`.

- Source/destination anchors and clean working trees confirmed; origins unchanged.
- Full toolchain snapshot imported and source inventory committed before removal.
- Eight toolchain apps removed from active UI umbrella; UI-specific browser regression
  relocated with its browser support.
- B0 9.16.16 registry cohort resolves; published six native modules executed in an
  external consumer. B1 9.16.17 is reserved only as an unpublished candidate.
- UI warnings-as-errors compile and 56 JS tests passed. Both real UI asset bundles
  and icon resources built. Full UI regression and cold-copy checks continue.
- Release automation is being implemented and tested without remote side effects.

Resume from `docs/verification-report.md` and the destination progress/runbook.
No push, tag, publish, deployment or remote settings mutation has been authorized.
