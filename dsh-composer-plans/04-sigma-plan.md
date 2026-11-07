# Sigma: DSH Composer Feature Migration Plan

**Status:** Implementation plan; no implementation performed.\
**Baseline:** `gsmlg-opt/sigma`, `main` at [`291ec1175c97014621c908eae9d4acad24dc7d55`](https://github.com/gsmlg-opt/sigma/tree/291ec1175c97014621c908eae9d4acad24dc7d55).\
**Architecture:** Core styles → React generic features → existing Phoenix React Chat bridge → Sigma application/runtime.\
**Contract authority:** `00-master-plan.md`, especially Shared contracts, ComposerDocument v1, Submission and receipts, Providers, and Queue projection. Names below are proposals where the master contract has not fixed them.

## 1. Objective and boundaries

Adopt DSH's composer interactions while retaining Sigma's execution model, application policies, and chat synchronization. Reuse the custom `Composer` portal in `apps/sigma_web/assets/js/hooks/session_chat.js`, `createDuskmoonReactChat`, `useChatSubmission`, and the existing `<.dm_react_chat>` mount. Keep `#chat-input-area` as the integration point. Do not replace the transcript, introduce another transport, or rewrite the Agent loop.

Follow the repository's [AGENTS.md][instructions]: Phoenix LiveView and Duskmoon components, functional Elixir boundaries, OTP lifecycle ownership, and compatibility with existing session formats. Generic editing, completion presentation, attachment intake, and keyboard behavior belong upstream; Sigma owns providers, materialization, validation, admission, execution, and persistence.

The pinned asset dependencies are `@duskmoon-dev/components` **0.5.3** and Core **1.20.7**. Phoenix is declared as `~> 10.0.10` and locked to **10.0.11**. Upgrade to tested releases from the preceding plans and commit both relevant lockfiles; do not invent future version numbers. [Dependency sources][dependencies] [Hex declaration][hex-declaration] [Hex lock][hex-lock]

### Baseline facts that constrain implementation

| Area | Verified current behavior | Consequence |
| --- | --- | --- |
| Composer | Local React portal, completion candidates, image paste/drop, async submission; text drafts in sessionStorage and Files in an in-memory Map | Replace duplicated generic UI only after equivalent behavior passes acceptance |
| Admission | Public Agent prompt/steer/follow-up APIs use synchronous calls; busy `prompt.submit` defaults to follow-up | Connect existing APIs; do not diagnose a nonexistent public cast-only API |
| Receipt | `chat.send` echoes `request_id`; Agent IDs are not returned to the browser | Correlation is not idempotency; return authoritative results |
| Persistence | Admission and pending queues are initially in memory; the user message is persisted later, after hooks | Initial releases must report volatile admission and promise no restart replay |
| Cancellation | Cancelling the active turn may immediately start a queued follow-up | Stop means stop the current turn, not clear or pause the queue |
| Model | Current UI disables selection during an active turn | Preserve the guard when relocating controls |

Sources: [Composer][composer], [LiveView][liveview], [Agent admission][admission], [queue and cancellation][queue-lifecycle], [session persistence][persistence].

## 2. Dependencies and delivery slices

Each slice is a separately reviewable PR or a small dependent PR pair. Initial UI parity must ship independently of durable queue/recovery work.

| Slice | Dependency | Deliverable / gate |
| --- | --- | --- |
| S0: Integration baseline | Master contracts; upstream release candidates | Compatibility fixtures, capability defaults, dependency upgrade |
| S1: Composer parity | React features and Phoenix bridge | Existing text, images, skills, drafts, sync work through shared UI |
| S2: Intent and receipts | Master submission DTO; bridge support | Real send/follow-up/steer routing and truthful volatile receipts |
| S3: Durable admission | S2; reviewed storage/recovery design | Persistent idempotency and reconciliation before replay guarantees |
| S4: Queue controls | S2; authoritative queue contract; S3 for durable recovery | List/update/remove/promote with revisions and race handling |
| S5: Typed references | Semantic document v1; reference provider contract | Scoped discovery, server resolution, materialization, citations |
| S6: Additional controls | Individual backend capability gates | Model toolbar; effort and policy modes only when supported |

S5 may proceed alongside S3 after contract agreement. Do not block S1 on rich references, durable queues, effort, or voice.

## 3. S0–S1: Preserve current behavior and adopt shared features

### Entry points

- `apps/sigma_web/assets/js/hooks/session_chat.js`: retain the Composer/portal wrapper; provide Sigma adapters to the shared composer.
- `apps/sigma_web/assets/js/chat_attachments.js`: keep image validation and base64 encoding as application policy.
- `apps/sigma_web/assets/js/skill_completion.js`: retain Sigma candidate identity, filtering, and insertion semantics until the shared provider adapter covers them.
- `apps/sigma_web/lib/sigma_web/live/session_live.ex`: retain `initialize_chat`, `chat_runtime`, `chat_admission`, `chat.sync`, snapshot/delta handling, and session scope checks.
- `apps/sigma_web/package.json`, root `package-lock.json`, `apps/sigma_web/mix.exs`, and `mix.lock`: update only the dependencies required by the upstream releases.

### Tasks

1. Record contract fixtures for text, image-only, text-plus-image, local skill, remote skill, rejected command, disconnected submission, and restored draft. Keep host capability flags off until the corresponding server path exists.
2. Replace local completion rendering and repeated paste/drop mechanics with shared React features. Keep Sigma's image encoder, error translations, `/skill` provider, remote search cancellation, and server-side validators.
3. Preserve the current image policy: PNG/JPEG/WebP/single-frame GIF, at most four images, 5 MiB each, 10 MiB total; slash-command/image combinations remain rejected. The base64 transport continues in this slice. [Image policy][images]
4. Preserve `/init`, `/reload-tools`, local and configured remote `/skill` resolution, arguments, disabled/ambiguous skill errors, and unknown-command rejection. Do not turn unrecognized slash commands into ordinary prompts or execute a skill through two admission paths. [Commands][commands]
5. Keep existing sessionStorage draft keys. Migrate existing strings to a one-text-node `ComposerDocument v1` when enabling semantic storage, using a versioned envelope and retaining unreadable data for recovery. Browser Files remain nonpersistent; do not imply that a reload restores attachments.
6. Preserve async accepted-draft clearing with the shared revision guard. Rejection and unknown outcome retain the submitted document and attachment handles; a late receipt must not clear a newer draft or another session.
7. Remove duplicate generic UI only after the replacement passes the existing feature checks. Sigma-specific validation and application adapters remain local.

### Acceptance

Text/image submissions, keyboard and IME behavior, slash suggestions, skill arguments, image previews/removal, draft restoration, session switching, and reconnect synchronization match the current working path. No duplicate React root, event listener, portal, or submit occurs during LiveView remounts. The legacy path remains selectable until the parity gate passes.

## 4. S2: Explicit intent and truthful submission receipts

Extend the existing bridge event rather than introducing a parallel socket. Add a pure decoder/validator at the LiveView boundary; a proposed location is `apps/sigma_web/lib/sigma_web/composer_submission.ex`. Keep the master DTO authoritative. Resolve its opaque application-context identity to the authorized repository/workdir and pair it with the conversation/session ID. Use that complete scope for drafts, receipts, lookups, deduplication, and queue mutations; a raw session ID or client-supplied path alone is insufficient.

### Routing

| Composer intent | PublicRuntime command | Required behavior |
| --- | --- | --- |
| `send` | `prompt.submit` | Preserve auto behavior: immediate when idle, follow-up when busy |
| `follow_up` | `prompt.follow_up` | Request follow-up semantics; idle admission can still start immediately |
| `steer` | `prompt.steer` | Require `targetTurnId`; atomically reject a stale/inactive target by default |

Modify `SessionLive`'s `chat.send`, `submit_prompt`, `protocol_admission`, and `prompt_admission` instead of discarding the existing admission info. `PublicRuntime.admit_prompt`, `prompt_opts`, and `Sigma.Agent.new_prompt_item` must retain the immutable **clientSubmissionId** from the logical submission. Carry it through the Envelope payload, runtime options/item, domain events, and receipt. Keep Phoenix `request_id` as physical transport correlation; generating a new physical request must not create a new logical ID. [Protocol path][protocol]

Expose the active turn identity in the runtime projection and propagate `targetTurnId` unchanged for steering. Validate it inside the same Agent mailbox operation that admits the item, not only in LiveView. The existing idle-steer branch can start a new turn: close that race for this contract. A different fallback requires an explicitly advertised policy and truthful actual delivery; never silently start an unrelated turn.

For `operation: prompt`, return the master receipt with `outcome: accepted | rejected | unknown`; an accepted prompt includes actual `delivery: immediate | follow_up | steer` and `persistence: volatile | durable`. Derive delivery from Agent's real `accepted`, `queued_as_follow_up`, or `queued_as_steering` result, not the requested intent. Include real `messageId` and `turnId`; omit `queueItemId` until the backend owns one.

Distinguish command actions from prompt submission. `/reload-tools` returns `operation: command` with its actual action result, without fabricated turn/queue IDs or a durable-prompt claim. Preserve each command's execution and active-run restrictions. Prompt-expanding commands still use prompt admission; do not route every slash command through `prompt.submit`. An empty no-op must not masquerade as a successfully created user message.

Add scope-keyed in-process reservation/result deduplication in S2 for both operation kinds, before dispatch or command effects. The same ID and normalized logical payload returns the original receipt, or its unresolved/pending status; a different payload conflicts. A repeated command must not run again simply to reconstruct its result. Normalize before skill expansion or resource preparation so a retry cannot change the first attempt's resolved content.

Preserve the existing command-expansion boundary and prepared-resource lifecycle when routing intents. Validate scope, content, limits, and supported document version on the server. Unknown capabilities or malformed data return rejection without submitting partial content.

During S2, prompt receipts explicitly report **volatile** admission, and deduplication is limited to the live session owner. Retain unknown submissions; never automatically replay on timeout, disconnect, or remount. A missing in-memory result after restart cannot authorize resending. S3 adds durable lookup/reconciliation; an unresolved attempt stays recoverable meanwhile. A genuinely edited submission receives a new logical ID.

Also correct `chat.stop`/`cancel_turn` to propagate actual cancellation results and errors. Preserve current-turn Stop semantics and the existing cancellation lifecycle; do not silently clear follow-ups.

### Acceptance

Idle/busy transitions, double clicks, Chinese/Japanese composition, delayed replies, and scope-switch races produce correct receipts without clearing unrelated drafts. Identical session IDs in different repositories remain isolated. Same-ID requests deduplicate within the live owner; conflicting payloads reject. A busy-racing `send` reports follow-up, while stale-target steering rejects without creating a turn. Valid steering reaches Backplane. This slice promises no deduplication across owner restart.

## 5. S3: Durable admission and idempotency

Treat this as a backend correctness slice, with a reviewed storage change before enabling recovery guarantees. Existing admission returns before the ordinary user-message hook and append. Existing `prompt_admitted` events are not durable inbox entries. Reusing that event name or echoing an ID cannot close the gap. [Persistence path][persistence] [Journal encoding][journal-encoding]

### Tasks

1. Upgrade S2 reservations to records keyed by resolved repository/conversation scope and `clientSubmissionId`. Fingerprint operation, logical document, attachment identity/content, intent, `targetTurnId`, and relevant options. Identical retries return the recorded result; different payloads conflict. Retain command-action results separately from prompt admission identities.
2. Integrate persistent admission with the existing serialized Session writer. A proposed `Sigma.Session.PromptInbox` owns encoding/replay rules; avoid a second independently authoritative queue. Version new journal records and preserve replay of existing sessions.
3. Commit prompt admission and recoverable payload before making work eligible to run and before a durable receipt. For a command, persist reservation before effects and its result afterward; a crash between effect and result remains interrupted/unknown. Do not persist File objects, object URLs, PIDs, closures, or release functions. Keep resource/digest metadata for revalidation or interruption.
4. Make the boundary between durable admission, user-message commit, hook rejection, consumption, and interruption explicit. Preserve current hook semantics. A later block/failure must remain observable and recoverable, not disappear after the editor clears.
5. Add a scoped lookup/reconciliation command by logical ID, available through the existing bridge. Return known result, pending/interrupted state, or explicit `not_found`. `not_found` is not proof of terminal rejection.
6. Reconcile on reconnect before permitting retry. A logical retry retains its ID; do not replay automatically. Define restart behavior for each state and prevent duplicate logical admissions/messages. Admission deduplication does not guarantee exactly-once model calls, tool effects, or command side effects; interrupted execution requires explicit reconciliation.

Use `SkillInvocationService` and `SkillInvocationStore` as local design references for fingerprinted reservation and interrupted recovery, not as proof that normal chat is already idempotent. The current chat `/skill` expansion bypasses that dedicated invocation service. [Skill idempotency][skill-idempotency]

### Acceptance

Inject failure before/after reserve, before/after user-message append, and after acceptance but before the browser reply. Restart the session process at those boundaries. Same-key retries reconcile to the original IDs; conflicting keys fail; committed messages are not duplicated; interrupted work is visible. Keep automatic replay disabled unless a later separately accepted policy establishes its safety.

## 6. S4: Authoritative queue projection and controls

Extend existing `PromptQueue`, Agent mailbox operations, `status_snapshot`, `PublicRuntime`, `ProtocolEventMapper`, and LiveView projection. Reuse the existing FIFO and steering execution. Current queue counts alone cannot support a trustworthy dock, and turn IDs cannot identify individual steering entries sharing a turn. [Queue implementation][queue]

Introduce stable queue item IDs, a monotonic queue revision, and item states such as pending/reserved/consumed. Return the master queue projection on sync/reconnect. Implement list, update, remove, and promote operations with full scope, item identity, expected revision/state, and operation idempotency where delivery is retryable. Promotion also requires `targetTurnId`.

Serialize mutations in the Agent mailbox. Reject edits/removals after reservation or consumption; return a conflict plus a fresh projection. Promotion from follow-up to steering must atomically preserve item identity, check the target active turn, and transfer resource ownership without double execution. Revalidate modified commands, references, and attachments on update.

Specify what happens to unconsumed steering when its target turn ends or is cancelled. Do not silently deliver stale steering to a different turn. Preserve resource cleanup on rejection/removal and the existing persist-before-ack behavior for consumed steering.

Display optimistic pending rows only with explicit reconciliation to authoritative IDs. Keep controls disabled for unknown/reserved entries. A clear-all or pause-queue action, if later desired, is a separate backend operation; Stop continues to mean current-turn cancellation.

### Acceptance

Race update/remove/promote against consumption and cancellation. Verify FIFO, independent steering/follow-up identities, accurate revisions, disconnected mutation outcomes, prepared-resource cleanup, and fresh queue snapshots after reconnect. S4 may expose a volatile dock before S3, but durable recovery stays disabled.

## 7. S5: Typed references and materialization

Consume the master `ComposerDocument v1`: ordered text/reference/quote content and optional command identity. A reference occurrence includes nodeId/providerId/refId/label/plainText; the label is presentation, never filesystem authority.

Add Sigma provider boundaries for repository files/folders, allowed sessions/messages, and quoted ranges. Candidate queries must be scoped to the current authorized repository/session, bounded, cancellable, and revision-aware. Define lookup/open behavior separately from insertion. Do not expose arbitrary filesystem traversal through a generic component API.

Implement server resolution/materialization before admission: revalidate IDs, scope, existence, allowed paths, session access, and source revision; derive bounded model input and persist provenance. Reuse `PathUtils.safe_resolve` and existing resource-grant policy where applicable. Agent read/find tools alone do not implement input references. [Path resolution][paths]

Persist canonical semantic documents and materialization metadata alongside the compatible model-facing content. Explicitly handle missing files, changed sources, deleted messages, unsupported node versions, and oversized folders. Never silently flatten a structured command/reference into text when its semantics cannot be resolved.

### Acceptance

Round-trip copy/paste, undo, draft migration, duplicate occurrences, quotes, and server rendering without loss of semantic identity. Reject forged/out-of-scope references and stale revisions according to provider policy. Verify token/content bounds and that the model receives the resolved content. A decorative chip alone does not satisfy this slice.

## 8. S6: Model and conditional controls

Move or connect the existing model selector through a Sigma adapter, preserving configured-model validation, persisted selection, and the active-run guard. Enforce the guard server-side as well as in the disabled UI; a stale browser event must not bypass it. Use `Runtime.change_model`, not an unacknowledged optimistic update.

Keep effort capability **off** initially. Anthropic implements `thinking_budget`, while OpenAI Responses advertises `reasoning_effort` without mapping it into the current request body. Enable effort only after model-specific choices, validation, persistence/replay, request mapping, and active-run behavior are verified end to end. [Anthropic adapter][anthropic-effort] [Responses adapter][effort]

Plan mode and permission presets require explicit Sigma policy contracts and enforcement through the existing permission system. Add no cosmetic switch that merely changes prompt text while implying tool restrictions. Voice/transcription is deferred to a separate optional adapter and is outside these slices.

## 9. Verification, rollout, and fallback

Extend tests at the behavior boundaries changed by each slice:

- Web: `apps/sigma_web/test/sigma_web/live/session_live_test.exs`, `image_attachments_test.exs`, and asset `chat_attachments_test.js` / `skill_completion_test.js`; add Composer integration coverage for bridge receipts, remounts, and draft ownership.
- Runtime: `active_turn_control_test.exs`, `prompt_queue_test.exs`, `public_runtime_test.exs`, and `protocol_event_mapper_test.exs` under `apps/sigma_agent/test/sigma_agent/`.
- Storage/commands: `writer_test.exs`, `slash_commands_test.exs`, and `skill_invocation_store_test.exs` under `apps/sigma_session/test/sigma_session/`; add focused admission-journal recovery cases.
- Provider controls: affected tests under `apps/sigma_ai/test/sigma_ai/providers/`, including captured outgoing request assertions before enabling effort.

Run targeted suites for each slice, then the repository gates appropriate to release: `mix format --check-formatted`, `mix compile --warnings-as-errors`, `mix test`, and `mix assets.build`. Verify the actual Sigma page with streaming, IME, keyboard-only use, mobile input, reconnect, and session switching. Plan preparation itself runs no implementation tests.

Release behind explicit composer capabilities, independently gating typed references, queue mutations, durable recovery, and effort. Keep the legacy Composer available through S1 acceptance. After semantic documents exist, rollback must retain/export them or disable unsupported editing; do not downgrade them destructively into strings. Storage changes must remain readable during rollback, and older clients must not trigger unsupported actions.

Completion means the supported features work through the complete Core → React → Phoenix → Sigma path, with truthful capability and delivery semantics. Remaining disabled capabilities and recovery limitations belong in the release notes.

## Source index

All implementation links below are pinned to the stated Sigma baseline.

[instructions]: https://github.com/gsmlg-opt/sigma/blob/291ec1175c97014621c908eae9d4acad24dc7d55/AGENTS.md
[dependencies]: https://github.com/gsmlg-opt/sigma/blob/291ec1175c97014621c908eae9d4acad24dc7d55/apps/sigma_web/package.json
[hex-declaration]: https://github.com/gsmlg-opt/sigma/blob/291ec1175c97014621c908eae9d4acad24dc7d55/apps/sigma_web/mix.exs#L31-L42
[hex-lock]: https://github.com/gsmlg-opt/sigma/blob/291ec1175c97014621c908eae9d4acad24dc7d55/mix.lock#L62
[composer]: https://github.com/gsmlg-opt/sigma/blob/291ec1175c97014621c908eae9d4acad24dc7d55/apps/sigma_web/assets/js/hooks/session_chat.js#L27-L146
[liveview]: https://github.com/gsmlg-opt/sigma/blob/291ec1175c97014621c908eae9d4acad24dc7d55/apps/sigma_web/lib/sigma_web/live/session_live.ex#L611-L722
[admission]: https://github.com/gsmlg-opt/sigma/blob/291ec1175c97014621c908eae9d4acad24dc7d55/apps/sigma_agent/lib/sigma_agent.ex#L995-L1125
[queue-lifecycle]: https://github.com/gsmlg-opt/sigma/blob/291ec1175c97014621c908eae9d4acad24dc7d55/apps/sigma_agent/lib/sigma_agent.ex#L1139-L1195
[persistence]: https://github.com/gsmlg-opt/sigma/blob/291ec1175c97014621c908eae9d4acad24dc7d55/apps/sigma_agent/lib/sigma_agent.ex#L1306-L1378
[journal-encoding]: https://github.com/gsmlg-opt/sigma/blob/291ec1175c97014621c908eae9d4acad24dc7d55/apps/sigma_session/lib/sigma_session/entry_encoder.ex#L28-L134
[images]: https://github.com/gsmlg-opt/sigma/blob/291ec1175c97014621c908eae9d4acad24dc7d55/apps/sigma_web/lib/sigma_web/image_attachments.ex#L4-L99
[commands]: https://github.com/gsmlg-opt/sigma/blob/291ec1175c97014621c908eae9d4acad24dc7d55/apps/sigma_session/lib/sigma_session/slash_commands.ex#L213-L277
[protocol]: https://github.com/gsmlg-opt/sigma/blob/291ec1175c97014621c908eae9d4acad24dc7d55/apps/sigma_agent/lib/sigma_agent/public_runtime.ex#L459-L594
[skill-idempotency]: https://github.com/gsmlg-opt/sigma/blob/291ec1175c97014621c908eae9d4acad24dc7d55/apps/sigma_agent/lib/sigma_agent/skill_invocation_service.ex#L15-L40
[queue]: https://github.com/gsmlg-opt/sigma/blob/291ec1175c97014621c908eae9d4acad24dc7d55/apps/sigma_agent/lib/sigma_agent/prompt_queue.ex
[paths]: https://github.com/gsmlg-opt/sigma/blob/291ec1175c97014621c908eae9d4acad24dc7d55/apps/sigma_coding/lib/sigma_coding/utils/path_utils.ex#L18-L35
[effort]: https://github.com/gsmlg-opt/sigma/blob/291ec1175c97014621c908eae9d4acad24dc7d55/apps/sigma_ai/lib/sigma_ai/providers/openai_responses.ex#L12-L56
[anthropic-effort]: https://github.com/gsmlg-opt/sigma/blob/291ec1175c97014621c908eae9d4acad24dc7d55/apps/sigma_ai/lib/sigma_ai/providers/anthropic.ex#L49-L61
