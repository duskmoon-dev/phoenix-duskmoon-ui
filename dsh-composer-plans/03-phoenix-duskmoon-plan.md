# 03 — Phoenix Duskmoon: Composer Transport and Lifecycle Plan

## Goal

Extend Phoenix React Chat to carry composer features into Sigma. Keep one React root, the transcript, and Sigma's portal. Phoenix owns transport, correlation, and lifecycle; React owns editing; Sigma owns catalogs, admission, persistence, and execution.

The [master plan](00-master-plan.md)—**Shared contracts**, **ComposerDocument v1**, **Submission and receipts**, **Providers**, and **Queue projection**—is authoritative. New API/event names below are proposals until frozen there. PHX-01–05 are implemented in this checkout as a local candidate; the verification record below separates repository acceptance from release and Sigma adoption.

## 1. Reviewed baseline

Repository: `duskmoon-dev/phoenix-duskmoon-ui` at `8d4128f0f43011693cdbf48e583a34b5ab92810e`.

Compared with `b76de4a83a49435e715e18114778b2c2c730862f`, eight commits changed 34 files. React Chat source, guide, and tests are unchanged. Relevant changes concern dependencies, packaging, and package management. [P1]

| Area | Current baseline | Planning consequence |
| --- | --- | --- |
| Public package | `phoenix_duskmoon` 10.0.12; Components 0.5.5; Core/CSS Art 1.20.8; Elements 1.10.2; React/React DOM 19.3.1 | Adopt the published composer-capable cohort after its upstream acceptance gates. Do not invent future versions. |
| Public integration | `dm_react_chat`, `createDuskmoonReactChat`, `useChatSubmission`, `ReactChat`, `initialState`, `reduceChat` | Extend these exports additively. |
| DOM ownership | `phx-update="ignore"`; configurable `Composer` and message renderers | Preserve React ownership and the current portal; do not mount a second root. |
| Submission helper | Generates `request_id` for each invocation, guards concurrent calls, returns the complete acknowledgement | Add logical submission identity separately from transport correlation. |
| Recovery | Reconnect requests a snapshot; message sequence gaps trigger sync; timeout/disconnect reject pending UI promises | Represent possibly dispatched outcomes as unknown and reconcile explicitly. |
| Build | `mix npm.*`, DuskmoonBundler, `package-lock.json`, published precompiled toolchain | Follow current `AGENTS.md`. CI still uses Bun as a test runner, not the package manager. |

Evidence: instructions/packaging [P2–P3], implementation [P4–P7], CI [P8].

### Boundaries

- Reuse Core classes and upstream React features. Do not implement another mention parser, editor, attachment picker, or queue scheduler here.
- Keep `dm_chat` / `dm_chat_input` and custom-element users compatible. Elements parity is outside Sigma's critical path.
- Preserve message rendering, metrics, tool state, scroll behavior, Retry/Resend/Fork semantics, and server task ownership.
- Keep provider endpoints, skill catalogs, model policy, filesystem access, and Sigma protocol conversion in the consuming application.
- Keep ordinary `phoenix_duskmoon/react-chat`, shared hooks, and root exports free of eager rich-editor/Lexical imports. Inject a rich Composer through the existing factory or a separately loaded optional entry.

## 2. Contract requirements

### Structured content and capabilities

Carry `ComposerDocument` with `schemaVersion: 1`, ordered `content` entries of text/reference/quote, and optional command identity `{providerId, commandId}`. Preserve reference identities and extension fields allowed by the master contract; do not flatten the document to a text string in the generic bridge.

Preserve `operation: prompt | command`. Catalog reload and similar commands may finish without admitting a prompt. Their accepted receipts carry action results without invented turn IDs, delivery, or persistence promises. The application descriptor determines the operation; a leading slash does not.

Pass capabilities, supported intents, provider descriptors, and controlled queue projection through the existing component context. Capabilities describe what the application can perform; they are not permission grants. Unsupported versions or actions produce a clear local validation error before dispatch. Backend authorization and semantic validation remain mandatory application responsibilities.

The legacy `{text}` path remains supported. An adapter must explicitly opt into the structured contract; an old server's `status: "ok"` must not be fabricated into a complete versioned receipt.

### Identity and receipt semantics

| Identity or field | Meaning and rule |
| --- | --- |
| `clientSubmissionId` | One logical submission of an immutable document/options snapshot. Preserve it across explicit transport retry and reconciliation. A new edited submission gets a new identity. |
| `request_id` | One physical bridge request. Keep its mapping to the logical submission; a new transport attempt may use a new request ID. |
| Application scope and mount generation | The adapter supplies an opaque key for the master's `scope`, covering conversation and repository/context identity. Bind dispatches, replies, queries, and projections to that key and instance generation; payloads cannot override it. A changed key invalidates the generation even when `conversation_id` stays the same. |
| Draft revision | Correlates a receipt with the submitted snapshot; React decides whether current input is still eligible for clearing. |
| Server projection revision | Orders capabilities, admission, and queue state independently of local edits and message sequences. |
| Receipt | Preserve operation and `outcome: accepted/rejected/unknown`. Accepted prompt receipts carry actual `delivery: immediate/follow_up/steer` and `persistence: volatile/durable`; command receipts carry their action result. Preserve actual runtime/queue IDs when supplied; do not generate missing IDs. |

An acknowledgement confirms only its stated result. Volatile acceptance does not prove journal commit, crash recovery, execution start, or completion. Only an explicit backend response establishes rejection; missing/malformed responses, disconnect, and timeout after possible dispatch leave an uncertain outcome.

### Recovery and ownership

Keep transport correlation records bounded, but register unresolved logical IDs and their snapshot linkage with an application recovery owner before dispatch. That owner outlives the hook and preserves attempts across remount/navigation and rollout rollback. The immutable snapshot belongs to React/the application; the bridge owns only transport correlation. Cleanup or capacity limits may release an unresolved transport record only after its recovery linkage is accepted by that owner, never through silent eviction.

After reconnect, request an authoritative snapshot and receipt reconciliation for unresolved logical IDs. Missing evidence remains `unknown`; absence from a queue proves neither rejection nor completion. No automatic prompt replay is permitted. An in-memory recovery owner does not survive a page reload: document supported retention explicitly, preserve versioned JSON through the host's chosen storage when required, and mark lost local files for reselection. Client-side retention does not upgrade volatile server admission to durable.

Protect callbacks with application scope, instance generation, and correlation checks. A late reply may update its original recovery record, but cannot modify a changed scope or clear newer input. Unmount releases listeners and client work after recovery handoff; it never issues Stop or cancels a server-owned run.

Editing, selection, IME, attachment changes, and safe clearing remain React responsibilities. The Phoenix hook returns receipts and connection state without assigning draft values or calling reset after send.

## 3. Implementation work packages

### PHX-01 — Freeze the additive bridge contract

Primary files, relative to `apps/phoenix_duskmoon`: `lib/phoenix_duskmoon/component/data_display/react_chat.ex`, `assets/js/react_chat/index.js`, and `guides/react-chat.md`.

- [x] Map the master contract to the existing mount snapshot and bridge context. Add explicit protocol/capability descriptors without requiring Sigma-specific fields.
- [x] Keep existing action mappings and success handling available for legacy consumers. Specify where structured submissions and additional configured actions are enabled.
- [x] Reject missing action mappings locally; never push an undefined event name.
- [x] Document the distinction between logical submission ID, bridge request ID, draft revision, and server revision.
- [x] Accept the opaque application scope key through the host adapter. Do not derive context from `conversation_id` alone or add Sigma-specific repository fields to the generic hook.
- [x] Define an application adapter interface that receives versioned JSON and returns an explicit receipt. Preserve the full application receipt and rejection details.
- [x] Support prompt and command operations without forcing successful commands through prompt admission or transcript insertion.

**Exit:** fixtures cover a legacy text consumer and a structured consumer using the same public factory. Unsupported-version and unsupported-capability behavior is deterministic.

### PHX-02 — Correlate submissions and uncertain outcomes

Primary files: `assets/js/react_chat/chat.js` and `index.js`.

- [x] Extend `useChatSubmission` additively so structured callers supply the `clientSubmissionId` created with their immutable attempt. Preserve its existing `{submit, busy, notice}` API for old callers.
- [x] Generate or accept the physical `request_id`, record both identities, and never replace a supplied logical ID merely because transport is retried.
- [x] Track whether failure happened before dispatch or after dispatch became possible. Expose a typed uncertain outcome and correlation metadata for timeout/disconnect while retaining compatible promise rejection behavior where needed.
- [x] Normalize typed uncertain transport errors to `outcome: unknown` in the structured adapter. A generic catch must not collapse them to legacy `false` or backend rejection.
- [x] Validate response correlation before resolving the matching attempt. Preserve actual admission IDs, actual delivery, persistence, and backend rejection information unchanged.
- [x] Register recovery linkage before dispatch and update the application owner on uncertainty/resolution. Capacity cleanup and disposal must preserve every unresolved logical ID and snapshot reference.
- [x] Keep one synchronous duplicate-dispatch guard. Distinguish transport pending, runtime active, and unresolved attempts; the application controls admission of unrelated submissions.
- [x] Leave document clearing to upstream React. Return only the evidence needed for its snapshot/revision check.

**Exit:** a deliberately lost acknowledgement cannot cause a duplicate automatic send, a new logical ID for the same retry, or a success/clear in another conversation.

### PHX-03 — Reconcile controlled composer and queue state

Primary files: `assets/js/react_chat/state.js` and `index.js`.

- [x] Extend the existing reducer/context with controlled composer projection. Do not introduce a separate canonical session store or another React root.
- [x] Define a revisioned composer-state update, provisionally `chat.composer-state`, alongside the existing full snapshot. Freeze its exact name and envelope in the master contract before implementation.
- [x] Support capability/queue-only updates without manufacturing a transcript message. Message sequences cannot serve as the revision for unrelated queue changes.
- [x] Apply snapshot replacement atomically. Ignore stale projection revisions, recognize gaps where delta ordering requires them, and request one bounded resync rather than continuing with unreliable state.
- [x] Include unresolved logical submission IDs in an opt-in sync request. Preserve application-provided receipts and authoritative queue IDs/statuses on reconciliation.
- [x] Forward queue actions through explicit configured actions with scope, item identity, and expected revision. React renders the projection; the application decides edit/remove/promote-to-steering support and schedules execution.
- [x] Preserve Stop as an explicit request. Continue showing the application's cancelling/active state until its projection confirms a transition.

**Exit:** reorder, duplicate, missing, and late events cannot revive removed items, regress queue state, or fabricate execution.

### PHX-04 — Preserve one root and application adapters

- [x] Retain `createDuskmoonReactChat({Composer, renderMessage})` and Sigma's existing portal boundary.
- [x] Load the optional rich component through factory injection or a distinct optional entry. Standard imports must remain editor-free; preserve the single existing root when the rich component becomes available.
- [x] Keep ordinary LiveView patches from replacing the React subtree or portal contents. Do not register a second submit path on an outer form.
- [x] Define scope switching: explicit remount with application draft/recovery stores, or an explicit context switch with generation invalidation. Repository/context changes invalidate stale work even with the same conversation ID. Merely changing `data-chat` is insufficient for the current hook.
- [x] If extracting portal placement is useful, add an optional instance-scoped target to the existing factory; keep inline rendering as the default. Do not hardcode Sigma's DOM ID in the package.
- [x] Bind provider callbacks through the factory/application adapter. Preserve correlation/cancellation; do not embed Sigma URLs or serialize functions into HEEX JSON.
- [x] Keep browser `File`/`Blob` objects outside the structured JSON bridge. Use application upload adapters and serializable attachment references. Sigma's existing bounded inline-image encoding remains an explicitly documented legacy application adapter during migration.

**Exit:** the generic package works with two independent chat mounts and a fixture application with no Sigma dependency.

### PHX-05 — Demonstrate and document the complete integration

Update `apps/duskmoon_storybook/assets/js/react_chat.js`, the React Chat LiveView example, and `apps/phoenix_duskmoon/guides/react-chat.md`.

- [x] Demonstrate structured references, commands, controlled options, queued projection, and actual-delivery receipts with fixture providers.
- [x] Provide explicit scenarios for rejected submission, unknown admission, volatile acceptance, durable acceptance, reconnect reconciliation, and editing while pending.
- [x] Show the file upload boundary accurately. A file preview or rejected demo submission is not evidence that upload transport exists.
- [x] Document application responsibilities, stable identities, provider cancellation, queue revisions, conversation switching, and lifecycle cleanup.

## 4. Acceptance tests

Extend existing helper, hook, reducer, browser, and HEEX tests around observable behavior.

| ID | Required result |
| --- | --- |
| PHX-A01 | Legacy text submissions, custom Composer/message renderers, target routing, and old hook registration continue to work. |
| PHX-A02 | Structured document, operation, command identity, reference IDs, options, intent, and receipt fields survive unchanged; an accepted command returns its result without invented prompt admission or turn IDs. |
| PHX-A03 | Double activation sends once; explicit retry retains `clientSubmissionId`; distinct physical requests remain correlated. |
| PHX-A04 | A typed timeout/disconnect after possible dispatch becomes an unknown structured receipt, never legacy `false`; input remains recoverable and no automatic resend occurs. |
| PHX-A05 | An accepted volatile receipt is displayed without claiming durable commit; absent backend IDs stay absent. |
| PHX-A06 | Late replies for another mount, opaque application scope, generation, or superseded draft cannot clear or overwrite input; test a repository/context switch with unchanged `conversation_id`. |
| PHX-A07 | Reconnect replaces projection from a snapshot and reconciles attempts; omitted/unresolved attempts remain unknown. |
| PHX-A08 | Queue-only updates work without transcript changes; stale/duplicate revisions and unsupported queue actions are handled explicitly. |
| PHX-A09 | Two mounts and a portal preserve focus, selection, IME composition, and edits through unrelated LiveView patches and streaming updates. |
| PHX-A10 | Capacity cleanup, unmount/navigation, and rollback preserve unresolved IDs/snapshot linkage in the application owner while releasing listeners/timers/portals; no Stop is sent. Reload behavior matches the declared storage capability. |
| PHX-A11 | Raw File/Blob objects never enter the semantic document or generic JSON serialization. The explicitly supported, bounded Sigma inline-image adapter remains compatible; rejected/failed preparation or upload does not submit incomplete content. |
| PHX-A12 | A packaged Hex consumer resolves ordinary and optional rich entries correctly. Built ordinary/root/shared-hook import graphs exclude eager Lexical loading; rich mode loads one editor runtime into the existing root, with one compatible React installation. |

## 5. Validation, packaging, and rollout

Use current repository commands: `mix deps.get --check-locked`, `mix npm.ci`, and the strict-precompiled wrapper for format, compilation, ExUnit, Storybook build, and package smoke checks. Run the existing CI hook/browser lane with Bun 1.3.13 and Chrome; Bun remains a test runtime, not a restored dependency-install/build requirement. Inspect `AGENTS.md` and the upstream-sync skill again at implementation time. [P2, P8]

Keep `./react-chat` exported and include its assets in both existing package distributions. Sigma must be able to resolve `phoenix_duskmoon/react-chat` from its Hex dependency through DuskmoonBundler; do not require a second npm `phoenix_duskmoon` installation. Verify the actual published upstream exports and lockfile cohort, not only local workspace linking.

Inspect emitted ordinary and rich consumer import graphs after bundling. A source-level dynamic import alone does not prove isolation: ordinary hook imports/server rendering must not eagerly include or initialize Lexical, while rich activation must load the optional editor once without remounting the chat root.

Roll out in this order:

1. Freeze the master contract and React fixtures.
2. Implement PHX-01/02 with legacy and structured paths.
3. Add revisioned recovery and controlled queue forwarding.
4. Complete Storybook and packaged-consumer acceptance.
5. Release through the existing synchronized Hex/npm UI process, then let Sigma adopt the verified package.

The initial slice may expose volatile receipts with no automatic replay. Durable recovery is complete only after Sigma's corresponding persistence and idempotency gates pass. Do not advertise those guarantees from this bridge alone.

Rollback selects a compatible composer/adapter cohort without modifying conversation history, rich drafts, or unresolved recovery records. Preserve unsupported drafts/attempts for explicit recovery/export rather than flattening or replaying them. Record tested versions and storage/capability limits. Done means every PHX scenario passes, the package works from Hex, and Sigma adopts it without a second root or duplicated domain logic.

## Local implementation and verification — 2026-11-07

PHX-01–05 are implemented against published Components 0.6.0, Core/CSS Art 1.21.0,
Elements/Art Elements 1.10.2, React/React DOM 19.3.1, and optional Lexical peers
0.53.0. Art Components is unused and was not added. The public Phoenix package
version remains 10.0.12; the candidate archives were validated locally and were
not published. Implementation is on `main`, based on `6ff28c73`.

The existing factory remains the composition boundary. Portal placement stays in
the injected application Composer; no additional portal API or React root was
needed. The shared fixture in
`apps/phoenix_duskmoon/test/fixtures/react_chat_contracts.v1.json` is checked against
the fixture actually shipped by Components 0.6.0. The master plan now freezes the
Phoenix v1 event and reply envelopes.

| Acceptance | Evidence in this repository |
| --- | --- |
| PHX-A01 | Existing composition, React rendering, helper and HEEX tests preserve legacy text, custom components, target routing and hooks. |
| PHX-A02–A06 | `react_chat_protocol.test.js` covers unchanged semantic JSON/receipts, commands, duplicate dispatch, authorized retry, uncertain transport, pre-dispatch validation, late replies and same-conversation context changes. The rich browser test verifies revision-safe clearing while typing. |
| PHX-A07–A08 | Protocol/reducer tests cover independent revisions, stale/gapped events, snapshot tombstones, reconciliation and queue mutations. `react_composer_live_test.exs` verifies actual server receipt/queue identities and restores them into a new socket with the same LiveView root. |
| PHX-A09 | The browser fixture checks two mounts, one root per mount, optional rich activation, CJK/IME, focus/selection, streaming and portal cleanup. A real Storybook session also preserved the rich draft/focus/selection through LiveView patches and streaming. |
| PHX-A10 | Protocol tests cover application handoff, capacity, cancellation, unmount, rollback lookup and late evidence. Unknown attempts survive in the application owner; disposal sends no Stop. Memory-only reload limits are documented. |
| PHX-A11 | Portable JSON rejects raw File/Blob objects. Encoded legacy image JSON remains compatible; the demo intentionally rejects file preparation and never claims an upload service. Sigma's actual upload application was not changed or exercised. |
| PHX-A12 | Integrated staged Hex/npm smoke builds an outside-checkout consumer and audits ordinary, hooks, root and dynamic rich graphs from the extracted Hex dependency. No npm Phoenix installation is used for resolution. |

Checks completed:

- Locked Hex dependency validation and frozen `mix npm.ci` passed, including
  the public-registry-only configuration used in CI. The lockfile retains the
  existing public-registry policy rather than the local environment allowlist.
- Strict precompiled formatting and warnings-as-errors compilation passed.
- The existing Bun 1.3.13 browser/hook lane passed all 143 tests with Chromium 152.
  The final protocol-focused run passed 18 tests.
- Host library ExUnit passed 3,149 tests; focused HEEX/sidebar checks passed 6 tests.
  The final composer LiveView suite passed 8 tests on both host and Ubuntu.
- Ubuntu full Storybook ExUnit passed 83 tests before the reconnect regression was
  added. Full library ExUnit under its Chrome 157 had two unchanged sidebar layout
  assertion failures in `left_menu_browser_test.exs` (lines 39 and 185); those tests
  pass with host Chrome 152. Host full Storybook also encountered an incompatible
  native Vize/glibc build; the same Storybook suite and both asset builds passed in
  the Ubuntu environment. These environment-specific failures were not hidden or
  repaired outside composer scope.
- Real socket disconnect/reconnect completed synchronization with the same React
  root, original queue/revisions and accepted volatile receipt for an initially
  unknown attempt. No automatic send occurred, and no pending request remained.
  Commands, references/quotes, rejection, model controls and all queue actions were
  also exercised against LiveView. The browser console was clean.
- Fresh `.github/scripts/ui_package.exs stage` and integrated `smoke` passed.
  Ordinary/hook/root graphs contained zero Lexical modules. Rich mode contained
  45 optional editor modules outside its static import closure; all graphs had at
  most one React installation.

The Storybook server retains fixture state only in a supervised memory cache for
128 LiveView roots and 30 idle minutes. A reload/new root, expiry, eviction or server
restart can lose it. Its durable-admission scenario is explicitly simulated.

**Remaining rollout gates:** release/publication and Sigma adoption are not
part of this local implementation. The master M1–M3 gates still require Sigma's
actual authorization, materialization, upload, scheduling, durable persistence and
restart/idempotency checks. No deployed or end-to-end Sigma guarantee is claimed.

## Source references

- [P1 — Eight-commit baseline comparison](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/b76de4a83a49435e715e18114778b2c2c730862f...8d4128f0f43011693cdbf48e583a34b5ab92810e)
- [P2 — Current repository instructions](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/blob/8d4128f0f43011693cdbf48e583a34b5ab92810e/AGENTS.md)
- [P3 — Public package exports and dependencies](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/blob/8d4128f0f43011693cdbf48e583a34b5ab92810e/apps/phoenix_duskmoon/package.json)
- [P4 — React Chat composition and submission helper](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/blob/8d4128f0f43011693cdbf48e583a34b5ab92810e/apps/phoenix_duskmoon/assets/js/react_chat/chat.js)
- [P5 — LiveView bridge and lifecycle](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/blob/8d4128f0f43011693cdbf48e583a34b5ab92810e/apps/phoenix_duskmoon/assets/js/react_chat/index.js)
- [P6 — Existing state reducer](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/blob/8d4128f0f43011693cdbf48e583a34b5ab92810e/apps/phoenix_duskmoon/assets/js/react_chat/state.js)
- [P7 — HEEX component boundary](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/blob/8d4128f0f43011693cdbf48e583a34b5ab92810e/apps/phoenix_duskmoon/lib/phoenix_duskmoon/component/data_display/react_chat.ex)
- [P8 — Current installation, test, build, and release CI](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/blob/8d4128f0f43011693cdbf48e583a34b5ab92810e/.github/workflows/ci.yml)
- [P9 — Existing public integration guide](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/blob/8d4128f0f43011693cdbf48e583a34b5ab92810e/apps/phoenix_duskmoon/guides/react-chat.md)
- [P10 — Sigma's reviewed one-root composition](https://github.com/gsmlg-opt/sigma/blob/291ec1175c97014621c908eae9d4acad24dc7d55/apps/sigma_web/assets/js/hooks/session_chat.js)
