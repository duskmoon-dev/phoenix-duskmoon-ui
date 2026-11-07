# Duskmoon Core chat composer implementation plan

**Repository:** duskmoon-dev/duskmoonui\
**Prepared:** 2026-11-01\
**Baseline:** main at [12ca4f5](https://github.com/duskmoon-dev/duskmoonui/tree/12ca4f5c3b8e6f994da144d087c624e489e7ca7b), Core 1.20.8\
**Depends on:** the component anatomy and state vocabulary in [00-master-plan.md](00-master-plan.md).\
**Implementation status:** planned.

## Goal and boundary

Extend the existing Chat composer styles so duskmoon-react can implement the selected DeepSeek Harness input features with the Duskmoon visual system. Core owns reusable CSS, visual states, class contracts, themes, and documentation examples. React owns editing, keyboard behavior, provider queries, file intake, and submission state. Phoenix and Sigma own transport and domain behavior.

Keep the work inside the existing Core package. Elements may consume the resulting CSS exports, but an Elements composer implementation is not a prerequisite.

## Current entry points

The existing source already supplies the composer shell, textarea, actions, hint, and queue tray. Preserve those class names and their behavior. The composer uses a currentColor border and focus ring; the queue is a presentation surface whose dispatch and mutations belong to the application.

| Existing path | Purpose in this work |
| --- | --- |
| packages/core/src/components/chat.css | Authoritative Chat CSS and new composer part styles |
| packages/core/src/components/chat.ts | Legacy component style API that must remain consistent |
| packages/core/src/tailwind-plugin.ts | Plugin registration and export compatibility |
| packages/core/scripts/build-css.ts | Aggregate, component, standalone and ESM stylesheet outputs |
| packages/core/src/types/ | Locate and extend actual public class/type declarations if the new API requires them |
| packages/docs/src/content/docs/en/components/chat.mdx | Public component anatomy, state examples and migration notes |
| packages/core/tests/data-display/chat-composer.spec.ts | Composer focus, sizing, variants and responsive behavior |
| packages/core/tests/data-display/chat-queue.spec.ts | Queue layout, touch actions, bounded scrolling and accessibility |
| packages/core/tests/unit/chat.test.ts | Existing structural CSS contract assertions |

Source references: [Chat CSS](https://github.com/duskmoon-dev/duskmoonui/blob/12ca4f5c3b8e6f994da144d087c624e489e7ca7b/packages/core/src/components/chat.css), [legacy styles](https://github.com/duskmoon-dev/duskmoonui/blob/12ca4f5c3b8e6f994da144d087c624e489e7ca7b/packages/core/src/components/chat.ts), [build pipeline](https://github.com/duskmoon-dev/duskmoonui/blob/12ca4f5c3b8e6f994da144d087c624e489e7ca7b/packages/core/scripts/build-css.ts), [package exports and scripts](https://github.com/duskmoon-dev/duskmoonui/blob/12ca4f5c3b8e6f994da144d087c624e489e7ca7b/packages/core/package.json).

## Proposed component anatomy

Finalize exact class names with the React implementer before adding selectors. Reuse an existing Duskmoon control when it already supplies the required appearance. New names below are proposals, not existing exports.

| Part | Responsibility | States to demonstrate |
| --- | --- | --- |
| Existing chat-composer shell | Surface, spacing, focus containment, semantic variant | Default, focus, disabled, read-only, error |
| Editor surface | Shared typography for the native textarea and optional rich editor | Empty placeholder, long draft, overflow, selection |
| Reference chip | Inline atomic reference label with optional icon and remove affordance | Selected, invalid, resolving, long label |
| Quote block or chip | Quoted text, attribution and remove affordance | Multiline, truncated preview, selected |
| Attachment tray and item | Preview, filename, status and retry/remove actions | Validating, uploading, ready, error, cancelled |
| Suggestion panel | Group headings, rows, empty/loading/error status and directory breadcrumb | Active row, unavailable row, nested directory |
| Composer toolbar | Existing buttons/selects plus application-provided controls | Wrapping on small screens, icon and text labels |
| Composer status | Pending admission, uncertainty and validation messages | Polite status text, actionable errors |
| Existing queue tray | Confirmed items, pending mutations and available actions | Idle, editing, stale/conflict, consuming |

Do not encode model names, file-type policies, permission presets, keyboard shortcuts or queue scheduling rules in CSS. A state class or data attribute describes what the component is displaying; it does not implement the state transition.

## Implementation slices

### CORE-1 — Freeze anatomy and add the shared visual parts

**Prerequisite:** C0 in the master plan has assigned the document and submission vocabulary; React has identified the DOM parts it needs.

- [ ] Inventory existing Chat, Chip, Menu/Popover, Button, Select, Upload and progress styles before introducing new selectors.
- [ ] Publish a short anatomy table in the Chat documentation showing required classes, optional parts, state attributes and expected semantic elements.
- [ ] Extend chat.css with the smallest set of reusable composer parts needed by React.
- [ ] Support textarea and contenteditable surfaces without global contenteditable selectors or editor-library-specific class names.
- [ ] Use logical properties for layout and truncation. Bound editor, attachment and suggestion overflow without clipping the primary action.
- [ ] Keep attachment and queue actions reachable on touch devices without hover.
- [ ] Apply the same contract to chat.ts and any existing public type declarations affected by it.

**Acceptance:** the existing plain composer and queue examples retain their layout. Static examples can represent every new part without importing React or an editor runtime.

### CORE-2 — Theme, focus and overlay integration

- [ ] Follow the repository's current color-role rules. Surface text uses on-surface or on-variant-container; filled controls retain the matching fill/content pair.
- [ ] Preserve all seven semantic composer variants and the ghost variant. Do not replace the existing currentColor border/focus pattern with unrelated tokens.
- [ ] Verify Sunshine and Moonlight for normal, selected, disabled, invalid and loading states; smoke-check the remaining shipped themes.
- [ ] Provide visible focus on reference removal, attachment retry/removal, suggestion navigation targets and queue actions.
- [ ] Style suggestion surfaces using the established native popover approach where appropriate. Follow current tooltip and dialog rules; do not introduce another overlay or focus-trap system.
- [ ] Keep behavior-specific ARIA management in React. Document the expected semantic relationships so a styled example does not imply that CSS supplies keyboard or screen-reader behavior.
- [ ] Keep placeholder, caret, selected-text and semantic-node text readable in both editor modes.
- [ ] Respect reduced-motion preferences for any new progress or transition effect.

**Acceptance:** keyboard focus is visible, overlays are not clipped by the composer, and long labels do not hide actions at 320 px width in both LTR and RTL examples.

Repository conventions: [AGENTS.md](https://github.com/duskmoon-dev/duskmoonui/blob/12ca4f5c3b8e6f994da144d087c624e489e7ca7b/AGENTS.md).

### CORE-3 — Export parity and consumer documentation

- [ ] Build all existing CSS outputs from the same source. Confirm the new classes exist in aggregate CSS, component CSS, standalone output, the Tailwind plugin path and the generated ESM stylesheet module.
- [ ] Keep generated CSSStyleSheet access safe in environments where that browser API is unavailable.
- [ ] Add examples for plain composition, references and quotes, attachment progress/error, suggestions, and queue actions.
- [ ] Explain that examples show visual states; application-specific providers, admission, uploads and queue commands are supplied by higher layers.
- [ ] Keep component styling in Core. The documentation site must remain a consumer of Core, with no private replacement composer CSS.
- [ ] Document additive class changes and the minimum Core version required by the forthcoming React release.

**Acceptance:** a downstream React fixture can use the new styles from the published build outputs without importing Core source files or documentation styles.

## Verification

Extend the existing suites around the risks introduced by these changes. Avoid a second large test harness or snapshots for every possible combination.

| Check | Required evidence |
| --- | --- |
| Existing API compatibility | Current composer and queue browser tests still pass |
| Responsive input | 320 px layout, long unbroken text, long reference label, many attachments and wrapped toolbar |
| Theme behavior | Sunshine/Moonlight contrast and visible state differences; seven semantic variants and ghost remain usable |
| Direction | LTR and RTL order, truncation and action placement |
| Focus and touch | No hover-only destructive or primary action; focused actions remain visible while lists scroll |
| Overlay layout | Suggestion popup remains usable near viewport edges and within the actual chat container |
| Export parity | Built consumer fixture uses the same class/state contract through every supported output |
| Styling boundary | No new editor, networking or application runtime dependency in Core |

Use the current repository commands. At the verified baseline, the relevant commands are bun run build:core and bun run typecheck at the root; bun test tests/unit and bun run test:data-display inside packages/core; and bun run build:docs for the documentation build. Run targeted Playwright files while iterating, then the required repository gates before release. Preserve the current runner/configuration instead of introducing a new test tool for this feature.

The existing tests already cover composer variants, focus/resize, small-screen layout, hidden queue rows, bounded queue scrolling and touch accessibility: [composer tests](https://github.com/duskmoon-dev/duskmoonui/blob/12ca4f5c3b8e6f994da144d087c624e489e7ca7b/packages/core/tests/data-display/chat-composer.spec.ts), [queue tests](https://github.com/duskmoon-dev/duskmoonui/blob/12ca4f5c3b8e6f994da144d087c624e489e7ca7b/packages/core/tests/data-display/chat-queue.spec.ts).

## Release and rollback

Ship additive styles before the React package begins relying on them. Record the actual published version in the master compatibility table; do not hard-code a future version in advance. Preserve existing selectors so applications that upgrade Core before React continue to work.

Rollback consists of keeping the older React composer path and withholding new component usage. Avoid a CSS-only rollback that removes selectors while a deployed React release still renders them. No application data migration belongs in this repository.

## Definition of done

- [ ] Reusable styles cover the agreed input feature anatomy.
- [ ] Existing classes and visual behavior remain compatible.
- [ ] CSS, legacy plugin styles and published export surfaces agree.
- [ ] Required themes, small-screen behavior, focus and touch interactions pass their focused checks.
- [ ] Documentation demonstrates the new parts using Core styles.
- [ ] The React implementer has a stable class contract and an actual compatible package version.

## Codex execution brief

Implement CORE-1 through CORE-3 in duskmoon-dev/duskmoonui using this plan and the master plan. Read the current AGENTS.md and relevant package instructions first. Reconcile changes since the pinned baseline, retain existing public behavior, and use the repository's current build and test commands. Limit changes to reusable styles, their public contract, documentation and directly relevant verification. Report the changed files, validation results, compatibility impact and downstream version requirement. Follow the repository's existing branch, commit and release policy.
