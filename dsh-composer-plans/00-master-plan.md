# DSH chat composer migration master plan

**Prepared:** 2026-11-01\
**Target application:** gsmlg-opt/sigma\
**Architecture:** accepted by the user; detailed contracts below are the implementation specification to stabilize in C0.\
**Status:** Phoenix PHX-01–05 are implemented and locally validated as a local candidate; see [03](03-phoenix-duskmoon-plan.md#local-implementation-and-verification--2026-11-07). Cross-repository release, Sigma adoption and M1–M3 acceptance remain outstanding.

## Outcome

Bring the selected DeepSeek Harness chat-input features into Sigma through the existing dependency direction:

**duskmoonui → duskmoon-react → phoenix_duskmoon → Sigma**

Core supplies the visual contract. React supplies reusable input behavior. Phoenix supplies the LiveView integration and transport lifecycle. Sigma supplies commands, references, model policy, uploads, admission, scheduling and persistence.

Build on the existing Chat composer and Phoenix React Chat integration. Keep pure composer logic inside duskmoon-react initially. A separate shared package and an Elements composer are outside the required delivery path.

## Plan files

| File | Owner and execution scope |
| --- | --- |
| [01-duskmoonui-plan.md](01-duskmoonui-plan.md) | Core styles, anatomy, theme coverage and export parity |
| [02-duskmoon-react-plan.md](02-duskmoon-react-plan.md) | Semantic document, editor adapter, providers, attachments and reusable interaction |
| [03-phoenix-duskmoon-plan.md](03-phoenix-duskmoon-plan.md) | Existing React Chat bridge, receipts, lifecycle and projection transport |
| [04-sigma-plan.md](04-sigma-plan.md) | Application adapters, runtime admission, durable recovery and authoritative queue operations |

Read this master plan together with the relevant repository plan. The shared contracts here take precedence over illustrative names in a repository plan. Proposed module/export names may be adjusted to match the current source layout without changing ownership or compatibility guarantees.

## Verified baseline

Implementation should re-read the current repository instructions and reconcile any changes after these commits.

| Repository | Inspected commit | Relevant baseline |
| --- | --- | --- |
| [deepseek-harness](https://github.com/deepseek-ai/deepseek-harness/tree/ce7073d51254c26cd63b22a60835b8f948deb447) | ce7073d | Feature reference |
| [duskmoonui](https://github.com/duskmoon-dev/duskmoonui/tree/12ca4f5c3b8e6f994da144d087c624e489e7ca7b) | 12ca4f5 | Core 1.20.8 |
| [duskmoon-react](https://github.com/duskmoon-dev/duskmoon-react/tree/95704b4e8d39e1a30a5df1d7c16213dca938228b) | 95704b4 | Components 0.5.5 |
| [phoenix-duskmoon-ui](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/tree/8d4128f0f43011693cdbf48e583a34b5ab92810e) | 8d4128f | Phoenix UI 10.0.12 |
| [Sigma](https://github.com/gsmlg-opt/sigma/tree/291ec1175c97014621c908eae9d4acad24dc7d55) | 291ec11 | Components 0.5.3, Core 1.20.7, Phoenix UI locked at 10.0.11 |

React already provides a controlled textarea composer, attachments, completion presentation, IME guards, pending-submission handling and revision-aware clearing. Phoenix already provides a React root, custom Composer integration, acknowledgement transport and reconnection snapshots. Sigma already uses that integration with a composer portal, image intake, text drafts and skill completion. These are the migration starting points, not replacement targets.

Sources: [React Composer](https://github.com/duskmoon-dev/duskmoon-react/blob/95704b4e8d39e1a30a5df1d7c16213dca938228b/packages/components/src/components/chat/ChatComposer.tsx), [Phoenix React Chat](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/blob/8d4128f0f43011693cdbf48e583a34b5ab92810e/apps/phoenix_duskmoon/assets/js/react_chat/chat.js), [Sigma integration](https://github.com/gsmlg-opt/sigma/blob/291ec1175c97014621c908eae9d4acad24dc7d55/apps/sigma_web/assets/js/hooks/session_chat.js), [Sigma asset dependencies](https://github.com/gsmlg-opt/sigma/blob/291ec1175c97014621c908eae9d4acad24dc7d55/apps/sigma_web/package.json), [Sigma dependency lock](https://github.com/gsmlg-opt/sigma/blob/291ec1175c97014621c908eae9d4acad24dc7d55/mix.lock).

## Feature scope and ownership

| Feature | Reusable React behavior | Sigma responsibility | Delivery |
| --- | --- | --- | --- |
| Growing input, keyboard and draft | Editor shell, composition guards, draft adapter and safe clearing | Scope/storage policy and chosen shortcuts | First usable increment |
| Picker, paste and drop | Unified intake, previews, progress/error, cancellation | Validation policy and existing image encoding/upload transport | First usable increment |
| Send, follow-up, steer and stop | Separate controls, eligibility and pending states | Runtime intent mapping and actual admission result | First usable increment |
| Slash commands and skills | Trigger detection, grouped suggestions, selection interaction | Catalog, argument expansion, unknown-command behavior and action execution | Structured input increment |
| File, folder and session references | Atomic nodes, suggestions, directory drill-down, clipboard behavior | Scoped search, authorization and context materialization | Structured input increment |
| Quotes | Insert/remove/undo, text and source presentation | Message provenance and permitted source lookup | Structured input increment |
| Waiting-message tray | Controlled rows and edit/remove/promote interaction | Queue identities, revisions, atomic mutations and execution | Queue and recovery increment |
| Model selector | Generic controlled selector and pending/error feedback | Model catalog, validation, persistence and active-run restrictions | Available-model parity |
| Effort, plan and permission controls | Capability-driven controls | Complete backend/provider or policy enforcement | Conditional follow-on |
| Context usage | Display the supplied projection | Authoritative usage/budget data | Conditional follow-on |
| Voice input | Optional transcription adapter and guarded insertion | Browser/provider choice, authorization and service integration | Optional; outside initial acceptance |

DSH supplies behavioral reference points: its [InputBar](https://github.com/deepseek-ai/deepseek-harness/blob/ce7073d51254c26cd63b22a60835b8f948deb447/packages/client/ui-conversation/src/client/skeleton/InputBar.tsx) combines editing, attachments, controls and running-state actions; its [submission policy](https://github.com/deepseek-ai/deepseek-harness/blob/ce7073d51254c26cd63b22a60835b8f948deb447/packages/client/ui-conversation/src/client/input/submission-policy.ts) maps gestures to queue/steer preferences. Adopt the useful interactions while retaining Sigma's command and runtime rules.

## Architecture decisions

1. **React owns the feature implementation.** Organize document, state, providers, attachment lifecycle and editor adapter as internal Chat modules. Extract a new package only after a second concrete consumer demonstrates a need.
2. **Keep the current plain Composer API.** Add an optional rich entry, provisionally /chat/rich, backed by the same internal shell/controller. A rich document is the controlled value in rich mode; a plain string is a derived export, not a second source of truth.
3. **Use an optional Lexical adapter for semantic editing.** Keep its editor state, DOM keys and serialized internals behind that adapter. Verify actual emitted import graphs so ordinary package and /chat imports do not eagerly load the rich editor.
4. **The editor owns editing transactions, selection and history.** The surrounding controller owns providers, attachments, submission attempts and draft lifecycle. Do not mirror every keystroke into a second independent editor state machine.
5. **Reuse one Phoenix React root and Sigma's current portal.** A second root, transcript rewrite or new composer-only hook is unnecessary.
6. **Sigma remains authoritative.** UI state cannot decide which files a session can read, whether a command is valid, when a prompt runs, or whether admission is durable.

## Shared contracts

C0 stabilizes these additive contracts, example fixtures and legacy adapters before parallel implementation. React owns their public TypeScript representation. Phoenix preserves their JSON meaning. Sigma validates and executes them. Shared fixtures may live in the existing repositories; a new shared package is not required.

### ComposerDocument v1

Use an ordered semantic document rather than editor-specific JSON or character offsets shared between JavaScript and Elixir.

| Field or node | Required meaning |
| --- | --- |
| schemaVersion | Integer 1 for this document format |
| content | Ordered array of text, reference and quote nodes |
| text node | Plain text, including line breaks; Markdown remains editable source |
| reference node | type, nodeId, providerId, refId, label and plainText |
| quote node | type, nodeId, text and optional source metadata |
| command | Optional providerId and commandId identifying a leading command; argument interpretation belongs to its provider |

A nodeId identifies an occurrence, so two chips referring to the same file remain separately editable. A refId identifies the provider's target. Labels and plainText support display, clipboard and previews; they do not authorize access or substitute for server resolution. Quote source metadata is untrusted until the application checks it.

Persist no File objects, object URLs, DOM references, callbacks, editor keys or Lexical state in this document. Preserve unknown or unsupported input for recovery and show an incompatibility state instead of silently dropping nodes. Define a migration from a legacy string to a single text node, plus versioned draft reading and explicit plain-text export.

Controlled updates need an origin/revision rule. An echo of the editor's own change must not reset selection or undo history. External replace, restore, scope switch and successful clear are explicit operations.

### Submission and receipts

Capture an immutable logical submission before asynchronous resolution or encoding begins.

| Submission field | Contract |
| --- | --- |
| protocolVersion | Version 1 for the new bridge payload; document schema version is separate |
| clientSubmissionId | Stable identifier for one logical operation, reused for reconciliation or an authorized retry |
| scope | Conversation identity plus an adapter-supplied opaque application context key, covering repository context; the server validates it |
| draftKey and draftRevision | Draft correlation and conditional clearing, not authorization |
| operation | prompt or command; non-prompt command actions must retain their own semantics |
| intent | For prompts: send, follow_up or steer |
| targetTurnId | Required for steering; identifies the active turn the operation intends to affect |
| document | ComposerDocument v1 snapshot |
| attachments | Stable attachment-entry identities and application-approved references/receipts |
| options | Validated, capability-supported settings captured for this operation |

The Phoenix request_id remains physical request/reply correlation. It must not be mistaken for durable idempotency. Preserve clientSubmissionId through the application adapter and runtime admission path.

| Receipt field | Contract |
| --- | --- |
| clientSubmissionId and scope | Identify the logical operation and its destination |
| outcome | accepted, rejected or unknown |
| operation | Distinguishes prompt admission from a command action |
| delivery | For an accepted prompt: actual immediate, follow_up or steer delivery |
| persistence | For an accepted prompt: volatile or durable admission |
| messageId, turnId, queueItemId | Include actual identities when the backend has assigned them |
| queueRevision | Include when the receipt relates to an authoritative queue change |
| result or error | Command result, structured rejection or explanation of an unresolved outcome |

An accepted prompt receipt means admission, not completed generation. Mark persistence durable only after the admission record and recoverable payload have committed. A command such as /reload-tools can succeed without creating a message or turn; return its action result without invented prompt identities.

Rules that every layer must preserve:

- A timeout, disconnect or missing reply after transmission produces an unknown outcome, not a fabricated rejection. The rich host adapter must translate a typed uncertain transport error into an unknown receipt instead of collapsing it into the legacy false result.
- Retain the submitted snapshot when the outcome is unknown. Do not automatically send it again.
- A status lookup may report not_found without establishing that a previously transmitted request can never arrive. Define reconciliation before enabling retries.
- On accepted admission, clear the submitted semantic document, including command identity and atomic nodes, only if its entire draft revision is still current. Remove only the accepted attachment entries whose identity still matches. Preserve later typing and newly selected files.
- Keep a recoverable attempt record until its admission status is resolved. An unresolved old attempt must not block all editing or overwrite a new draft.
- Prevent replies for another application context, conversation, composer instance generation or replaced attempt from mutating the current editor. A definitive late receipt can still resolve its original scoped recovery record. A context switch invalidates the generation even if the raw conversation ID stays the same.
- Transfer unresolved attempt identities and their recovery linkage to the application recovery owner before component cleanup. Bounded transport caches must not silently discard them; persist recoverable semantic snapshots according to the host's draft policy.
- Same logical ID with the same normalized payload returns the original admission result. Same ID with a different payload is a conflict.
- Durable admission deduplication does not imply exactly-once execution of model calls or external tools. Interrupted execution needs explicit runtime reconciliation.

### Running state and keyboard policy

Expose runtime state separately from submission state. Running, awaiting admission, uploading, disconnected and read-only are different conditions. An active model run must not automatically make the editor read-only.

Preserve existing React shortcuts by default: ordinary Enter inserts a newline and Ctrl/Cmd+Enter submits. Add an explicitly selected agent profile or application configuration for DSH-style behavior. In that profile, idle submission sends; the busy preference chooses follow-up or steering; the visible button and shortcut hint use the same policy.

Handle keyboard events in this order: IME composition, active suggestion menu, explicit editor/command actions, the configured submission action, then ordinary editing fallback. Never submit while composition is active. A suggestion-selection Enter must not also submit. Escape first closes the local menu or overlay; stopping a run requires an explicit, separately configured action.

Sigma's server resolves races between the displayed run state and actual admission. Steering targets a specific active turn; a stale steering target must be rejected or follow an explicitly advertised fallback, never silently create an unrelated new turn. Stop means cancel the current turn under existing Sigma semantics. Pausing or clearing queued follow-ups would be a separate operation.

### Providers

A suggestion request includes providerId, query, current scope, trigger/caret context, document revision and cancellation. Providers return stable candidate identities and explicit selection behavior: insert, drill into a directory, or invoke a command.

Abort superseded work and also check scope/query revision when results arrive. Cancellation alone is insufficient to prevent a stale result from replacing a newer list. Distinguish loading, empty, error and retry states. File discovery, remote skills, command catalogs and permitted source resolution remain application adapters.

### Attachments and draft persistence

Use one intake pipeline for picker, paste and drop. Each selected occurrence has a stable entry ID independent of File object identity. Validate consistently; expose preparation, uploading, ready, error and cancellation states. Retry or upload completion must not resurrect an entry the user removed.

Keep local File handles separate from the portable submission document. The initial Sigma adapter may preserve its existing validated inline-image encoding path. New uploaded-file support uses application-issued references or receipts; the generic bridge does not serialize arbitrary File objects.

Persist drafts by application scope. Preserve current text-draft restoration while migrating to versioned documents. A page refresh cannot restore an ordinary File handle: retain a durable upload reference if available, or show that the attachment needs reselection. Do not make a restored attachment appear ready merely because its filename survived.

### Queue projection

The backend supplies confirmed queue items, stable identities, ordering, allowed operations and a revision. React renders that projection. Pending admission and pending mutations may have local placeholders, but they are not confirmed scheduler entries.

Edit, remove and promote-to-steering requests include the target identity and expected revision. Promotion also supplies targetTurnId. The server atomically checks the active turn, rejects stale or already-consumed items and returns an updated projection. Initial queue editing may be text-only when references or attachments cannot yet be safely edited; expose that restriction as a capability.

Reconnect restores both runtime state and queue projection. Reconcile unresolved submissions by logical ID. Retain Sigma's existing execution loop and steering consumption points.

### Phoenix bridge v1 envelope (frozen)

The portable v1 JSON contract and cross-language examples are the published
`@duskmoon-dev/components@0.6.0/chat/contracts.v1.json` fixture, copied unchanged
into Phoenix's `test/fixtures/react_chat_contracts.v1.json`. The optional rich
entry is `@duskmoon-dev/components/chat/rich` (`RichChatComposer`). Ordinary
Phoenix imports use the plain `/chat` entry and factory injection.

Phoenix opts in with `protocol_version={1}`, `context_key` and a `composer` map.
The map contains `revision`, `capabilities`, serializable `providers`, controlled
`options`, and optional `queue` (the portable v1 queue projection). Runtime and
admission remain separate root fields, ordered by the composer revision.
`chat.composer-state` carries a complete replacement of that map; an optional
`previousRevision` requires contiguous ordering. It uses the existing `chat:event`
channel and `id`/`conversation_id` routing. All structured events, including
snapshots, also carry `protocolVersion: 1`, `scope: {contextKey, conversationId}`
and the physical mount's integer `instanceGeneration`, echoed from its request.
Queue revision and per-message sequence counters remain independent. Snapshots
retain message sequence tombstones; intentionally resetting counters requires
`chat.reset` with a strictly newer composer revision.

Structured dispatch carries the portable submission unchanged plus `request_id`,
`instanceGeneration`, `id` and `conversation_id`. The bound scope cannot be
overridden by a payload. A reply is
`{request_id, instanceGeneration, receipt: ComposerReceipt}`. No legacy status is
converted into a v1 receipt. Missing or malformed evidence becomes `unknown`.

The existing hook factory accepts `adapter({scope, instanceGeneration, config,
element})`, returning an application-owned `recovery` owner and optional runtime
`providers`, `authorizeRetry`, and `reconcileOnSync` flag. The bridge exposes
`submit(snapshot)`, `reconcile(snapshot)` and `mutateQueue(mutation, signal)`.
`reconcile` is an explicitly configured action. With `reconcileOnSync`, sync
requests include `unresolvedSubmissionIds`; authoritative snapshots carry
`receipts`. Missing receipts remain unknown. Queue actions are explicitly mapped
as `queue_edit`, `queue_remove`, `queue_promote`; replies carry
`{request_id, instanceGeneration, result: ComposerQueueMutationResult}`.

An explicit `switchContext(config)` invalidates generation and remounts only the
Composer within the existing root. A host may instead remount the hook using its
scoped draft/recovery stores. Changing `data-chat` alone is not a context switch.
These names freeze Phoenix transport only; they grant no Sigma runtime,
persistence, authorization, or rollout guarantees.

## Delivery sequence

### C0 — Contract and compatibility baseline

- [ ] Capture the current Sigma user flows as acceptance scenarios.
- [ ] Freeze the document, logical submission ID, receipt, capability and queue projection contracts above.
- [ ] Add cross-language fixtures for Unicode/CJK, repeated references, quotes, commands, attachments, accepted/rejected/unknown receipts and stale queue revisions.
- [ ] Define legacy adapters, capability negotiation and the behavior when the server supports only plain input.
- [ ] Select proposed public names and the optional rich export location.
- [ ] Record actual package/build entry points and existing required checks in each repository.

**Exit:** implementers can work against identical fixture meaning without inventing their own payloads.

### M1 — Existing input parity and truthful submission behavior

Deliver CORE-1/2 visual foundations, React shared intake/state behavior, Phoenix additive payload/receipt support, and Sigma's initial integration.

Preserve images, skill completion, draft restoration, existing shortcuts and the current portal. Add explicit intent mapping, atomic steering-target checks, in-process same-ID admission deduplication and real admission IDs/status. Initial accepted prompt receipts truthfully report volatile persistence; restart-safe deduplication arrives in M3. Command actions retain distinct results and unresolved-effect recovery. Keep automatic replay disabled.

**Exit:** Sigma can use the new reusable input infrastructure with no regression in current flows, and send/follow-up/steer/stop behavior is explicit.

### M2 — Structured composer features

Deliver the optional editor, semantic nodes, command/reference providers, quote insertion, versioned drafts and server-side reference materialization. Add generic toolbar controls backed by Sigma's already available model capabilities.

**Exit:** a user can compose text with references and quotes, select commands/skills, preserve that draft across supported lifecycle changes, and submit content that Sigma resolves correctly. An unsupported server cannot receive a silently flattened rich document.

### M3 — Authoritative queue and recovery

Complete durable admission records and lookup, queue item projections, mutation preconditions and reconnect/restart reconciliation. Activate queue edit/remove/promote only as the corresponding capability becomes real.

**Exit:** admission retry cannot create a second logical prompt, queue operations survive races with consumption, and restart recovery does not silently re-execute an uncertain operation.

### M4 — Conditional extensions

Add effort, plan/permission controls, context usage or voice only after their complete application contracts exist. These controls stay absent or explicitly unavailable until backend behavior is implemented. M4 is outside the initial feature acceptance gate.

## Parallel work and release order

After C0, Core visual work and Sigma backend admission work can proceed in parallel. React implements against the frozen anatomy/contracts. Phoenix develops transport fixtures against the same contracts. Sigma integration waits for real compatible artifacts, not speculative version numbers.

Release each usable cohort in dependency order: Core → React → Phoenix → Sigma. Record its exact package versions, lockfile changes, fixture version, supported capabilities and rollback flag. Phoenix ships its JavaScript through its existing package distribution; Sigma continues resolving phoenix_duskmoon assets from its Hex dependency and bundler configuration.

Use small reviewable slices from the repository plans. Do not combine editor replacement, durable queue design and application migration into one unreviewable change.

## Cross-repository acceptance matrix

| Scenario | Expected result |
| --- | --- |
| Chinese/Japanese IME plus Enter | Composition commits text without accidental submission |
| Suggestion Enter plus submit shortcut | Candidate insertion and submit are distinct actions |
| Type while admission is pending | Accepted snapshot clears safely; later text and files remain |
| Repeated reference to the same target | Each occurrence supports independent selection, removal and undo |
| Switch session during provider/upload/reply | Old asynchronous work cannot mutate the new session |
| Picker, paste and drop of the same invalid file | One consistent policy and visible error |
| Unknown admission followed by reconnect | Submitted snapshot remains recoverable; lookup runs before any retry |
| Same ID sent twice, same payload | One logical admission and the original receipt |
| Same ID sent twice, different payload | Explicit conflict; no replacement admission |
| Steer after the targeted run ends | Defined stale-target outcome; no accidental unrelated turn |
| Queue item consumed while being edited | Revision conflict and refreshed projection |
| Stop with follow-up items waiting | Current-run cancellation semantics are clear; no implied queue clearing |
| Ordinary package import or server render | No eager rich-editor runtime or browser-only initialization |
| Existing plain Composer consumer | Compatible props, defaults and existing behavior |
| Restricted reference or unsupported option | Server rejects it before execution |
| Runtime restart after durable admission | Receipt/projection reconciles without blind operation replay |

The repository plans assign these checks to the closest owner. Use a real browser against the Phoenix/Sigma bridge for IME, portal focus, lifecycle and selection behavior; pure reducer tests alone cannot establish those guarantees.

## Rollout and completion

Use separate capability switches for structured documents, explicit intent controls, queue mutations and durable recovery. Keep the current plain composer path available during rollout. Do not downgrade a rich draft destructively: preserve it and provide an explicit text export or compatible editor until the rich path is restored.

The initial migration is complete when M1–M3 pass in Sigma, compatible package versions and fixtures are recorded, current flows remain usable, and the DSH-inspired features operate through the agreed layers. Optional M4 features do not hold that gate open.

## Execution instruction

Give Codex this master plan and the relevant repository plan. Ask it to implement the next uncompleted slice, reconcile the current source with the pinned baseline, preserve public compatibility, and report concrete validation and unresolved dependencies. Follow each repository's current AGENTS.md, package-manager, branch and release rules. Record reusable validated findings under the repository's existing Agent Note policy when implementation reaches a verified boundary.
