# Plan 02 — Duskmoon React chat composer features

Status: implementation plan; no implementation or release is claimed.\
Prepared: 2026-11-01.\
Repository: `duskmoon-dev/duskmoon-react`.\
Reviewed baseline: `95704b4e8d39e1a30a5df1d7c16213dca938228b`, package version `0.5.5`.

## Goal and ownership

Deliver reusable chat input behavior in `@duskmoon-dev/components`, using dsh as a feature reference and Duskmoon as the visual system. The delivery chain is **duskmoonui styles → duskmoon-react features → phoenix_duskmoon application components and bridge → Sigma policies and runtime**. Elements is an optional sibling implementation, not a dependency or completion gate.

Keep the existing plain `Chat.Composer` API. Add an explicit, optional `/chat/rich` entry with a rich composer, backed by shared internal modules and a lazily loaded editor adapter. The rich component's final export name is proposed and must be settled in the master contract gate. Initially create no separate npm package or repository.

This repository owns editing, suggestion interaction, attachment intake UI, action presentation, queue presentation, and generic lifecycle behavior. Phoenix owns its transport integration. Sigma owns reference resolution, command execution, model availability, file processing, queue mutation, storage policy, and agent execution. React must not import either application's stores or APIs.

## Verified starting point

| Entry point | Existing behavior to preserve |
| --- | --- |
| [ChatComposer.tsx](https://github.com/duskmoon-dev/duskmoon-react/blob/95704b4e8d39e1a30a5df1d7c16213dca938228b/packages/components/src/components/chat/ChatComposer.tsx) | Controlled string and `File[]`; native textarea; autosizing; completions; IME guards; independent Stop; asynchronous admission; revision-aware text clearing and attachment occurrence tracking |
| [Chat.types.ts](https://github.com/duskmoon-dev/duskmoon-react/blob/95704b4e8d39e1a30a5df1d7c16213dca938228b/packages/components/src/components/chat/Chat.types.ts) | Existing callback, submission, completion, attachment, and queue contracts |
| [ChatPrimitives.tsx](https://github.com/duskmoon-dev/duskmoon-react/blob/95704b4e8d39e1a30a5df1d7c16213dca938228b/packages/components/src/components/chat/ChatPrimitives.tsx) | Composable input area/actions and application-controlled `Chat.Queue` |
| [ChatComposer.test.tsx](https://github.com/duskmoon-dev/duskmoon-react/blob/95704b4e8d39e1a30a5df1d7c16213dca938228b/packages/components/src/components/chat/ChatComposer.test.tsx) | Rejection, pending edits/files, remount, composition, completion, and follow-up regressions |
| [Browser fixture and tests](https://github.com/duskmoon-dev/duskmoon-react/blob/95704b4e8d39e1a30a5df1d7c16213dca938228b/test/e2e/chat-composer.test.ts) | Real browser sizing, files, keyboard, accessibility, and pending admission scenarios |
| [build.ts](https://github.com/duskmoon-dev/duskmoon-react/blob/95704b4e8d39e1a30a5df1d7c16213dca938228b/packages/components/build.ts) | Explicit exports/build entries; client and root builds currently use `splitting: false` |

The [comparison from 0.5.3 to this baseline](https://github.com/duskmoon-dev/duskmoon-react/compare/9fc785511e85653edf22f4125b8718f33b187725...95704b4e8d39e1a30a5df1d7c16213dca938228b) leaves the Composer, types, and primitives unchanged. Recent functional changes affect Select popover behavior and Timeline styling; one Chat CSS assertion was removed. Reuse the updated Select where appropriate, without assuming its positioning covers a caret-anchored suggestion popup.

The [current AGENTS.md](https://github.com/duskmoon-dev/duskmoon-react/blob/95704b4e8d39e1a30a5df1d7c16213dca938228b/AGENTS.md) declares Agent Note project `duskmoon`, variant `react`. The implementation should follow that policy at meaningful validated boundaries; writing this plan does not claim a feature has shipped.

## Contracts and compatibility

The companion `00-master-plan.md` is authoritative for **Shared contracts**, **ComposerDocument v1**, **Submission and receipts**, **Providers**, and **Queue projection**. Do not create competing wire schemas in this repository.

The semantic document has `schemaVersion: 1`, ordered text/reference/quote content, and optional command identity. References and quotes have stable occurrence identities; references distinguish provider identity, reference identity, display label, and plain-text projection. Validity restored from storage is not authoritative. Runtime `File` objects, object URLs, Lexical JSON, node keys, and editor history do not enter this persistent contract.

Preserve these existing guarantees:

- Plain `value`, `onValueChange`, `onSubmit({value, files})`, completion, rendering, and ref behavior remain compatible.
- Ordinary Enter remains a newline and Ctrl/Cmd+Enter submits in the existing plain component. Configurable dsh-style shortcuts require explicit opt-in.
- Composition and legacy key code 229 never cause submission or candidate commitment. Consumer `preventDefault()` remains respected.
- `busy` gates admission while leaving editing available; `generating` can show Stop while allowing follow-ups. A pending submission must not disable editing merely to simplify state handling.
- Existing asynchronous false/exception behavior preserves the draft. Acceptance clears only the unchanged submitted revision and accepted attachment occurrences.
- Rich mode has one controlled semantic document input. Plain text is a projection for preview/export, not a second controlled input or a string callback round trip.

## Implementation slices

### R0 — Freeze the additive API and fixtures

Dependency: the master's contract gate and Core's agreed classes/tokens.

- Record the final rich export name, typed provider interfaces, document update callback, draft revision semantics, action configuration, and submission callback in `Chat.types.ts` or adjacent public type modules.
- Keep the `/chat` and root barrels free of rich editor imports. Public semantic types must not expose Lexical classes.
- Publish contract fixtures covering mixed text/references/quotes, claimed commands, missing providers, accepted/rejected/unknown receipts, and authoritative queue updates.
- Add compatibility type fixtures using the current plain API, including consumer callbacks and forwarded textarea props.

Exit: Phoenix and Sigma can implement against the same fixtures without interpreting private editor state. The plain API has no required new props.

### R1 — Extract shared behavior without changing defaults

Suggested internal location: `packages/components/src/components/chat/composer/`. File names are implementation suggestions, not additional package APIs.

Separate semantic document transforms, action eligibility, provider request bookkeeping, attachment occurrence bookkeeping, and submission snapshots from the shell. Prefer pure functions and reducers for these transitions. Keep DOM selection and editor history inside the editor adapter.

Use a single shared shell for attachment previews, suggestions, errors, actions, and accessible status. The plain and rich entries select an editor adapter rather than growing unrelated copies of the composer. Preserve existing native textarea mounting, sizing, and event forwarding during extraction. Provide scoped draft load/save callbacks with generation-safe restore; the host chooses storage and retention. Do not hardcode sessionStorage keys or persist binary objects.

Exit: existing Composer unit/browser fixtures still pass. There is no behavior change attributable merely to refactoring.

### R2 — Add the optional rich editor adapter

Dependency: R0–R1. Use a pinned, internally consistent Lexical dependency set; validate its required APIs instead of copying code against current unpinned documentation. Keep a single Lexical runtime in a consuming application and externalize peer dependencies appropriately.

Implement only the required editing model: Markdown source text, atomic references, a leading claimed command, and quote nodes. Do not expand this task into a general document editor.

- Reference insertion, deletion, selection, and replacement are coherent editor transactions. A label must not replace its stable reference identity.
- Deleting command arguments retains the command identity; deleting the command token exits command mode; undo restores both content and identity.
- Skill tokens that remain editable text must not accidentally become atomic commands.
- Quote insertion preserves ordered placement and attribution metadata, with the agreed plain-text/Markdown export. Expose typed insertion commands for message-selection actions and external host controls.
- Lexical owns editing transactions, selection, and undo/redo. The surrounding reducer owns submission/provider/UI state. Avoid a second per-keystroke history.
- Mount once per editor instance. Ignore controlled echoes of the same revision. Explicit external replacements carry an origin/revision and follow a documented history policy.
- Cancel listeners, observers, queries, and editor work on disposal. Remounts restore semantic content; durable undo history is not promised.

Initially keep editor-specific DOM reads behind an adapter boundary. Native or injected node renderers are preferable to importing dsh's React portal implementation wholesale. No Elements compatibility claim is needed for this milestone.

Exit: atomic editing, composition, clipboard, undo/redo, and semantic round-trip tests pass in a real browser. A rich draft never silently flattens when the editor fails to load.

### R3 — Implement reusable completion providers

Dependency: R1; integrate with R2 when rich mode is ready.

Support leading commands, skills, and `@` reference providers through the master provider contract. Supply generic grouping, loading, errors, empty results, disabled candidates, folder navigation, breadcrumbs, and selected-item behavior. Sigma supplies source data and authorization-aware lookup; the library does not scan a repository or execute a command. Keep provider selection actions (`insert`, `drill`, `invoke`) distinct from submitting a prompt; `invoke` calls a host handler.

Requests must carry conversation/repository scope, editor instance generation, document revision, trigger range, and query identity. Abort superseded work and independently discard late results from providers that ignore cancellation. Give candidates stable provider-derived identities rather than array indexes. Revalidate the insertion range before committing a result.

Define keyboard precedence: composition, active popup, explicit editor/command actions, configured submission, then ordinary editing. Escape dismisses the popup before any higher-level action. Candidate navigation preserves editor focus and valid ARIA relationships.

Exit: moving the caret, switching sessions, deleting the trigger, changing providers, and out-of-order responses cannot insert stale content. Selecting a candidate never also submits.

### R4 — Unify attachment intake and lifecycle

Dependency: R1; compatible with both editors.

Route picker, paste, and drop through one configurable intake policy. Expose rejected items and reasons consistently. Preserve mixed paste text according to the agreed clipboard policy instead of silently discarding it when a file is present.

Separate local attachment occurrences from upload/preparation results and sendable handles. Keep binaries outside persistent documents. Hosts provide preparation/upload callbacks, accepted types, limits, and cancellation; there are no hardcoded Sigma image limits or DeepSeek endpoints.

Use stable occurrence IDs: removing and re-adding the same `File` is a new selection. Late preparation results must not resurrect removed files or modify another session. Release preview URLs when their occurrence is removed or its owner is disposed. Draft recovery must explicitly mark local files requiring reattachment unless the host provides a supported binary recovery strategy.

Exit: all three intake paths enforce the same policy; partial failures are visible; an admitted submission cannot erase newly selected attachments.

### R5 — Add explicit intent, receipt, and recovery handling

Dependency: R0–R1 and a fake host implementing the master receipt contract; integrate attachment snapshots with R4. The shared/plain path can ship in M1. Rich editor/provider integration follows R2–R3 in M2 and must not hold the M1 parity release open.

Represent run state separately from submission state. Derive available `send`, `follow_up`, and `steer` intents from host capabilities and current admission rules. Stop remains independent. Do not infer that every running backend supports steering or queue editing.

Distinguish `operation: prompt` from `operation: command`. A non-prompt action such as Sigma's `/reload-tools` returns an action result, without invented turn, queue, delivery, or durable-prompt claims. The host catalog determines command semantics.

Create an immutable snapshot and stable `clientSubmissionId` before invoking the host; capture `targetTurnId` for steering. Preserve the ID through authorized retry or reconciliation. A new user submission receives a new ID.

Handle outcomes explicitly:

| Outcome | Required UI behavior |
| --- | --- |
| `accepted` | For prompts, preserve actual delivery (`immediate`, `follow_up`, or `steer`), available message/turn/queue IDs, and explicit persistence level; for commands, retain the action result; apply revision-safe clearing |
| `rejected` | Retain recoverable content and show the host reason; allow correction and a new logical submission |
| `unknown` | Retain the submitted snapshot and its ID separately from any newer draft; expose recovery/status actions; do not automatically send a duplicate |

An acknowledgment represents meaningful admission, not automatically durability. Generic transport success is insufficient for rich acceptance. Legacy boolean callbacks retain existing semantics; rich host adapters map typed uncertain transport failures to `unknown`.

If the user edits while awaiting a receipt, preserve the newer document; never splice matching substrings to simulate clearing. Scope receipts to application context (including repository), conversation, instance, and submission. An old receipt may update its original recovery record but must not clear the current editor.

Before unmount or navigation, hand unresolved IDs, semantic snapshots, and recovery linkage to a host owner that outlives the composer. Never silently evict unresolved attempts. Reload recovery follows the host's declared persistence policy; in-memory retention must not promise it.

Exit: delayed acceptance, timeout-after-admission, rejection, unmount, and session-switch scenarios preserve every recoverable draft without automatic duplicate execution.

### R6 — Add controlled queue and settings presentation

Dependency: R0, R1, R5; server features are independently capability-gated.

Extend existing `Chat.Queue` rather than implementing a scheduler. Receive authoritative queue items and revisions from the host. Offer supported steer/edit/remove actions, record pending actions, and reconcile only from authoritative results. Do not locally dequeue upon click.

Editing a queued item must account for the item starting execution before the request arrives. The host determines whether edit/restore is allowed and returns the canonical outcome. Unsupported operations remain hidden or explicitly unavailable; a cosmetic button is not a delivered feature.

Provide reusable slots or small presentation components for model selection, reasoning effort, and mode/policy choices. Hosts supply choices, selected values, unavailable reasons, and acknowledgment callbacks. UI selection does not itself change backend configuration. Optional dictation stays an injected capability and must not delay the required composer release.

Exit: queue projection survives reordering, stale actions, and reconnect snapshots; settings cannot display a false authoritative success.

### R7 — Package, document, and hand off

Add the optional rich subpath to `packages/components/package.json`, declaration output, and the explicit build entries. The current `splitting: false` build makes emitted-artifact verification mandatory: a source-level dynamic import alone does not prove isolation. Inspect the built import graph and bundle report to prove that ordinary root and `/chat` consumers do not eagerly include or initialize Lexical. Verify exactly one editor runtime in the rich fixture.

Extend existing Chat documentation and previews with a generic fake host. Demonstrate plain compatibility, rich references/commands/quotes, rejected and unknown outcomes, attachment failures, active-turn intents, and authoritative queues. Clearly distinguish available UI features from host-provided execution capabilities.

Use Core's published classes/tokens. Any missing reusable visual rule goes to the Core plan; avoid embedding a second theme in React. Follow the repository's fixed-version Changesets group, including its version checks, without inventing a release version in this plan.

Exit: a packaged artifact can be consumed by the existing Phoenix React Chat extension point without copying composer logic into Phoenix or Sigma.

## Acceptance and validation

| Scenario | Required evidence |
| --- | --- |
| Existing consumers | Plain API/type fixtures and existing Composer regressions unchanged |
| Pending submission | New edits and files survive delayed acceptance; editing remains available when only admission is busy |
| IME | Chinese/Japanese composition, candidate selection, and Enter never double-commit or submit |
| Atomic nodes | Caret movement, deletion, range selection, clipboard, and undo/redo preserve identity and ordering |
| Claimed command | Empty arguments retain claim; token deletion exits; undo restores |
| Command result | A successful non-prompt command does not fabricate a prompt receipt or queued turn |
| Async providers | Abort plus scope/generation checks reject stale results and invalid ranges |
| Receipts | Accepted/rejected/unknown, actual delivery, IDs, and persistence remain distinguishable |
| Recovery | Unknown outcomes keep snapshots; old receipts never clear a new conversation |
| Attachments | Picker/paste/drop parity, re-add identity, cancellation, URL cleanup, and reattachment state |
| Queue | Pending controls do not mutate authoritative membership; stale edit/steer/remove is reconciled |
| Accessibility | Keyboard-only use, readable labels, focus restoration, screen-reader status, narrow layouts, both themes |
| Packaging | Legacy import graph excludes editor runtime; rich build loads it once; SSR import/hydration and Next.js smoke pass |

Run focused unit and contract tests during each slice. At the release gate run the repository's build, typecheck, lint, affected formatting, component tests, bundle-size checks, Next.js smoke build, and version checks. Use the checked-in Playwright Composer suite against the docs development server (`DOCS_TEST_URL`, default `http://127.0.0.1:4334`) and extend its fixture for rich mode. Add an explicit browser CI invocation: the reviewed CI workflow runs Bun tests but does not run this Playwright suite. Do not describe synthetic composition events as a substitute for real IME verification.

## Rollout, rollback, and completion

For M1, deliver R0–R1 with attachment intake, compatible completion adapters and the shared submission/receipt behavior from R3–R5; perform the relevant R7 packaging checks for that cohort. M2 adds the optional rich editor and semantic providers. M3 enables queue controls as authoritative backend capabilities arrive. Release each additive cohort before Phoenix and Sigma opt in. Core styling and React feature work can proceed in parallel after the shared contract gate; each integrated release must use matching supported versions.

Rollback disables the rich integration while leaving the legacy entry and existing conversations available. Preserve semantic drafts and unresolved submission snapshots; do not overwrite them with a lossy string or blindly resend them. If a draft cannot be edited by the fallback, present a readable preserved preview and an explicit recovery/export path.

Completion requires the packaged component, public contracts, browser evidence, compatibility notes, and a Phoenix consumption fixture. It does not require migrating Elements, changing Sigma's agent loop, or claiming that UI admission alone makes a message durable.
