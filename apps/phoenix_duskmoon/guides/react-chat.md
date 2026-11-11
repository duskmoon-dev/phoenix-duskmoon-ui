# React streaming chat

Use `dm_react_chat` for streaming conversations. React owns the transcript,
draft, Markdown, scrolling, and message actions. LiveView owns authorization,
persistence, admission, and the generation process.

```heex
<.dm_react_chat id="assistant-chat" conversation_id={@conversation_id}
  messages={@messages} runtime={%{active: true, phase: "tool_execution"}}
  admission={%{allowWhileStreaming: true}} class="h-full" />
```

Register `DuskmoonReactChat` from `phoenix_duskmoon/react-chat` in LiveSocket
hooks. Existing callers need no options. The default transcript uses the published
`@duskmoon-dev/components/chat` parts for messages, tools, statuses, and actions.
Assistant replies use `Chat.Agent` and `Chat.Content` without a bubble; user
messages retain `Chat.Bubble` with Markdown inside `.chat-bubble-content`.
The default composer preserves its
text on rejection/disconnect and disallows sending during an active turn unless
admission explicitly permits it. Two floating icon buttons stay at the bottom of
the transcript, above the composer: **Jump to latest** scrolls once without changing
the follow setting; **Stick to bottom** toggles continuous following of new messages,
streaming content, and late content or viewport resizing. Sticking starts enabled.
Scrolling up or choosing a reply marker turns it off so history stays readable;
reaching the bottom manually does not turn it back on. The toggle exposes its state
through `aria-pressed`. Reply markers cover the latest 24 assistant messages while
all messages remain visible. Each conversation starts with its own follow setting.

The mount has `phx-update="ignore"`. Push events rather than updating `@messages`
per token. HEEX children are not a composition API: `inner_block` is no longer
declared. Put server-rendered controls outside the mount, or use the public React
composition API below. `target` routes the bridge to a LiveComponent if needed.

## Required Tailwind sources

React Chat uses Tailwind utilities as well as upstream component styles.
Follow the [Getting Started CSS and Bundler source setup](getting-started.md#4-configure-css),
including `deps/phoenix_duskmoon/assets/js` and `deps/phoenix_duskmoon/lib`.
Tailwind v4 skips gitignored dependencies during automatic detection.

With DuskmoonBundler 10.1.3, add the dependency entries to the existing profile's
`tailwind.sources`; CSS `@source` alone is insufficient
([upstream issue #23](https://github.com/duskmoon-dev/duskmoon-bundler/issues/23)).
Keep them until the published upstream fix is adopted and verified. Without the
JavaScript source, utilities such as `bottom-3`, `end-3` and `pb-16` are missing,
and the transcript controls can overlap the composer. The getting-started guide
covers both normal and umbrella path conventions.

## Public composition

```javascript
import React, { useState } from "react";
import { Chat } from "@duskmoon-dev/components/chat";
import { Markdown } from "@duskmoon-dev/components/markdown";
import { createDuskmoonReactChat, useChatSubmission } from "phoenix_duskmoon/react-chat";

const h = React.createElement;
function Composer(props) {
  const [value, setValue] = useState("");
  const [files, setFiles] = useState([]);
  const { submit, busy, notice } = useChatSubmission(props);
  return h(Chat.Composer, {
    value, onValueChange: setValue,
    attachments: files, onAttachmentsChange: setFiles,
    generating: props.active, canSubmit: props.canSubmit, busy, error: notice || undefined,
    onStop: () => props.bridge.send("stop", {}),
    onSubmit: async ({ value, files }) => {
      try {
        // Upload File bytes through your application before sending JSON references.
        const attachments = await uploadFiles(files);
        const reply = await submit({ text: value, attachments });
        // reply retains application metadata, for example reply.admission/request_id.
        showAdmission(reply.admission);
        return true;
      } catch (error) {
        // error.response retains a server rejection, if one was received.
        return false;
      }
    },
  });
}
function Footer({ message, bridge, connected, synchronizing }) {
  return h(Chat.Footer, null,
    message.metadata?.summary,
    h(Chat.Actions, null, (message.actions || []).map((action) => h("button", {
      key: action.id, type: "button",
      disabled: !connected || synchronizing || action.disabled || action.eligible === false,
      onClick: async () => {
        if (action.confirm && !await confirmAction(action)) return;
        await bridge.send("action", { message_id: message.id, action: action.id });
      },
    }, action.label))),
  );
}
function Message(props) {
  const { message, targetId, timeline } = props;
  const assistant = message.role === "assistant";
  return h(assistant ? Chat.Agent : Chat, {
    id: targetId, timeline, role: "article",
    ...(assistant ? {} : { placement: message.role === "user" ? "end" : "start" }),
  },
    h(Chat.Header, null, message.author || message.role),
    message.metadata?.reasoning && h(
      Chat.Reasoning, null,
      h("summary", null, "Reasoning"),
      h("div", null, message.metadata.reasoning),
    ),
    h(assistant ? Chat.Content : Chat.Bubble, { streaming: message.status === "streaming" },
      h(Markdown, {
        markdown: message.content || "",
        className: assistant ? undefined : "chat-bubble-content",
      })),
    h(Footer, props),
  );
}
const ApplicationChat = createDuskmoonReactChat({
  Composer, renderMessage: Message, renderFooter: Footer,
  renderStatus: ({ runtime }) => h(
    Chat.Status, null, runtime.active ? runtime.phase || "Generating" : "Ready",
  ),
});
// Add ApplicationChat to your LiveSocket hooks.
```

Select it with `hook="ApplicationChat"` on `dm_react_chat`. The interactive
React Chat demo mounts a consumer composer/message/footer using public exports,
with attachments, completion, usage, reasoning, summaries, and confirmed actions.
In its Conversation playground, **Keep generate** (below **Seed 12-message transcript**)
repeatedly adds a simulated prompt and streamed reply without interrupting an active
reply. Click it again, use Stop, or seed/reset the conversation to stop generation.
These are local test messages; no model is invoked.
`Chat.Composer` is available in upstream Components 0.5.0. Consumers can also supply
any React composer; there is no required upstream composer dependency in the hook
contract. The public module also exports `ReactChat`, `initialState`, and
`reduceChat` for consumers testing their event adapters.

Factory options are React component types: `Composer`, `renderMessage`,
`renderHeader`, `renderFooter`, and `renderStatus`. Header/footer replace parts
of the default message; a full `renderMessage` owns all of its message parts.
A custom message must apply `targetId` to its root and `timeline` to `Chat` to
retain reply navigation. React keeps message identity by `message.id`.

Every component receives `state`, `bridge`, `connected`, `synchronizing`,
`metadata`, `runtime`, `admission`, `streaming`, `active`, and `canSubmit`.
Message/header/footer components additionally receive `message`, `targetId`,
`timeline`, and `options`. All arbitrary message fields survive the reducer,
including reasoning blocks, image references, usage metrics, action eligibility,
and turn summaries. The application chooses where summaries appear, and owns
Retry, Resend, Continue, Fork eligibility and confirmation. The bridge preserves
custom action identifiers; it does not translate them to Retry.

`runtime.active` defines whether the whole turn is running. If absent, `active`
falls back to any streaming message. An active tool/approval phase can therefore
show Stop after text completes. `admission.canSubmit: false` disables submission;
`admission.allowWhileStreaming: true` allows steering/follow-up during active
turns. Disconnection and synchronization always make `canSubmit` false. These
client gates improve UX; the backend must still authorize/admit each request.

`useChatSubmission(props)` returns `{submit, busy, notice}`. `submit(payload)`
adds a request ID, guards concurrent/synchronizing/disconnected submissions, and
resolves with the complete successful acknowledgment. It never clears drafts or
attachments. `Chat.Composer` clears only unchanged admitted input when its
`onSubmit` resolves positively; return false or throw to preserve it. For another
composer, clear only after successful `submit`, preserving edits made while the
request was pending. For conversation-scoped restoration across navigation, own
the draft store in the application and initialize it with `state.conversationId`.
Do not persist File bytes as JSON; retain File objects in an application store or
persist uploaded attachment references. Disconnect/recovery does not remount the
composer. No request is automatically resent after disconnect or timeout; use
request IDs and backend idempotency to reconcile uncertain admission.

## Events, application state, and recovery

Server events are `chat.snapshot`, `chat.reset`, `chat.message`, `chat.delta`,
`chat.tool`, `chat.complete`, and `chat.error`. Every payload includes mount `id`
and `conversation_id`. Ordered message events additionally require `message_id`
and a per-message positive monotonic `sequence`; duplicates are ignored. A gap
halts reduction and requests `chat.sync`. Snapshot/reset events replace messages,
sequences, and application state without message-level sequence requirements.

Pass `metadata`, `runtime`, and `admission` maps as initial HEEX attrs. These fields
can also accompany any accepted message event, replacing the corresponding map.
Omitted fields preserve state. To update late usage or runtime without adding an
event type, replace the complete message with `chat.message` at its next sequence:

```elixir
push_event(socket, "chat:event", %{
  id: "assistant-chat", conversation_id: conversation_id,
  type: "chat.message", message_id: message.id, sequence: next_sequence,
  message: Map.put(message, :metadata, %{usage: usage, summary: summary}),
  runtime: %{active: true, phase: "waiting_for_approval"},
  admission: %{allowWhileStreaming: true}
})
```

Keep a canonical server snapshot including messages (and all application fields),
per-message `sequences`, `metadata`, `runtime`, and `admission`. On `chat.sync`,
push `chat.snapshot` with that state and reply `%{status: "ok"}`. Reconnect uses
this same recovery path. Snapshot/reset omission resets application maps to empty
maps. A message replacement must contain the whole message, including content,
tools and application fields you want retained.

Client bridge actions are `send`, `stop`, `retry`, `action`, `sync`, mapped to
`chat.send`, `chat.stop`, `chat.retry`, `chat.action`, and `chat.sync`. Payloads
always include chat `id` and `conversation_id`; arbitrary submission/action JSON
fields are preserved. Success remains **`status: "ok"`**. Map your application's
admission result in its LiveView adapter, keeping your runtime protocol unchanged:

```elixir
case Sessions.admit(scope, conversation_id, params) do
  {:ok, admission} -> {:reply, %{status: "ok", admission: admission.kind}, socket}
  {:error, reason} -> {:reply, %{status: "error", message: reason}, socket}
end
```

A rejection produces an Error with the original reply at `error.response`.
Reply quickly, letting the supervised server runtime stream output. Batch tokens
for roughly 30–50ms or a bounded chunk size; the hook schedules React rendering
once per animation frame. Keep PubSub topics scoped to tenant/user/conversation.

Destroying the UI removes the event handler, cancels its animation frame, rejects
pending **UI requests**, and unmounts React. It sends no Stop command and must not
cancel a persistent server-owned agent. Leaving a view may unsubscribe its UI
subscription while the session continues. Only an explicit, authorized `chat.stop`
should stop server generation. `dm_chat` and `dm_chat_input` remain available for
existing custom-element callers.

## Structured composer protocol v1

Structured JSON is opt-in. Legacy `{text}` callers and `status: "ok"` responses
continue to use the existing path. A legacy acknowledgement cannot establish a
versioned admission receipt.

```heex
<.dm_react_chat id="assistant-chat" conversation_id={@conversation_id}
  hook="ApplicationChat" protocol_version={1} context_key={@opaque_context_key}
  composer={@composer_projection} runtime={@runtime} admission={@admission}
  actions={%{reconcile: "composer.lookup", queue_remove: "composer.queue.remove"}} />
```

`context_key` covers the application's repository/context identity as well as its
conversation. It is opaque to Phoenix and is not an authorization credential.
`composer` contains an independent, nonnegative `revision`, v1 `capabilities`,
serializable provider descriptors, controlled `options`, and optional `queue`.
Use the types and fixture exported by Components 0.6.2 at
`@duskmoon-dev/components/chat` and `/chat/contracts.v1.json`. Core/CSS Art 1.21.2
supply the composer classes. Elements/Art Elements remain 1.10.2; Art Components
is not needed for this integration. React and React DOM remain 19.3.1.

Pass `compact: true` to `Chat.Composer`, `ChatSessionComposer`, or
`RichChatComposer` to use the compact Add menu, one send/stop action and image
thumbnail strip. The Storybook composers enable this upstream presentation mode;
controlled drafts, upload preparation and admission remain application-owned.
React Components 0.6.2 requires Core 1.21.1 or newer for these styles.

Components 0.6.2 supports default plain and rich structured submissions on LAN HTTP.
Its submission ID generator uses secure random bytes when `crypto.randomUUID()`
is unavailable, preserving the same logical identity and admission contract.

```javascript
import { ChatSessionComposer, createComposerRecoveryOwner } from "@duskmoon-dev/components/chat";
const recovery = createComposerRecoveryOwner(); // application lifetime, outside the hook
const ApplicationChat = createDuskmoonReactChat({
  adapter: ({ scope }) => ({
    recovery, providers: applicationProviders(scope), reconcileOnSync: true,
    authorizeRetry: async (attempt) => authorizeExplicitRetry(attempt),
  }),
  Composer: (props) => h(ChatSessionComposer, {
    value: useApplicationDraft(props.scope), // controlled ComposerDocumentUpdate
    onDocumentChange: updateApplicationDraft,
    scope: props.scope, draftKey: "main", providers: props.providers,
    canSubmit: props.canSubmit,
    runtime: { status: props.connected ? (props.active ? "running" : "idle") : "disconnected",
      activeTurnId: props.runtime.activeTurnId },
    options: props.composer.options,
    host: { capabilities: props.composer.capabilities, recovery: props.adapter.recovery,
      submit: props.bridge.submit, reconcile: props.bridge.reconcile,
      commandOperation: applicationCommandOperation },
    onStop: () => props.bridge.send("stop", {}),
  }),
});
```

The application chooses command operations from its descriptor/catalog. A leading
slash does not determine whether submission is a prompt or an action. Provider
callbacks stay in the factory adapter; do not serialize functions or application
URLs in HEEX. Upstream React binds provider cancellation, document revision and
scope. Each mount gets its own adapter invocation and generation.

`bridge.submit(snapshot)` accepts the portable v1 submission: stable
`clientSubmissionId`, `scope`, `draftKey`, `draftRevision`, `operation`, semantic
`document`, sendable attachment references and `options`; prompts also carry
`intent` and steering requires `targetTurnId`. It returns the complete explicit
receipt, including backend rejection details or command results. `useChatSubmission`
also recognizes this payload and delegates to `bridge.submit`, keeping its
`{submit, busy, notice}` API. A resolved promise alone is not acceptance: inspect
`receipt.outcome`, or let `ChatSessionComposer` handle the receipt. The hook never
sets draft values, clears attachments, or calls an editor reset.

The three revisions/identities have different roles:

- `clientSubmissionId` identifies one immutable logical attempt. Explicit retry
  uses the same snapshot and ID; edits create another ID. A recovery owner rejects
  reuse with different JSON. Retry requires the host's `authorizeRetry` callback.
- `request_id` identifies a physical request, generated with cryptographic browser
  APIs (including HTTP LAN origins). A retry gets a new physical ID. It is not
  durable idempotency. A caller may supply a nonempty ID unique among pending requests.
- `draftRevision` belongs to React and determines whether accepted input may clear.
  `composer.revision`, queue revision, and transcript message sequences order
  independent server projections; they cannot substitute for the draft revision.

Replies echo physical correlation and return a receipt:

```elixir
{:reply, %{
  request_id: params["request_id"], instanceGeneration: params["instanceGeneration"],
  receipt: %{
    protocolVersion: 1, clientSubmissionId: params["clientSubmissionId"],
    scope: params["scope"], operation: "prompt", outcome: "accepted",
    delivery: "follow_up", persistence: "volatile", queueItemId: actual_queue_id
  }
}, socket}
```

Only include actual backend IDs. Accepted prompts require actual `delivery`
(`immediate`, `follow_up`, `steer`) and `persistence` (`volatile`, `durable`). An
accepted command returns `operation: "command", result: ...` with no prompt,
turn, delivery or persistence fields. Rejected and unknown receipts require an
`error` with `code`, `message` and optional JSON `details`. Backend authorization,
reference materialization, model/option validation, idempotency and command
semantics remain application responsibilities.

Missing/malformed responses, timeout and disconnect after possible transmission
produce `ChatTransportError` (`code: "uncertain_transport"`, `outcome: "unknown"`)
on the low-level bridge. It includes correlation metadata. Structured submission
normalizes that error into an unknown receipt, retaining the snapshot. It never
returns legacy `false` or fabricates rejection. Before-dispatch failures such as
unsupported versions/capabilities, missing action mappings, capacity or failed
recovery handoff reject locally without sending. Unconfigured actions never push
an undefined event name. Backend rejection is explicit; an empty queue or
`not_found` lookup does not establish rejection or completion.

## Projection, recovery and scope lifecycle

A structured event carries the usual mount ID/conversation plus `protocolVersion`,
`scope`, and `instanceGeneration` echoed from the bridge request. Mismatched
mounts/scopes/generations are ignored. `chat.composer-state` replaces a complete
projection without adding a transcript message:

```elixir
push_event(socket, "chat:event", %{
  id: params["id"], conversation_id: params["conversation_id"],
  protocolVersion: 1, scope: params["scope"], instanceGeneration: params["instanceGeneration"],
  type: "chat.composer-state", composer: next_projection,
  runtime: %{active: true, phase: "cancelling"}, admission: %{allowWhileStreaming: true}
})
```

A full projection can skip revisions; optional `previousRevision` requires ordered
contiguous application updates. Stale/duplicate revisions are ignored. Gaps or
invalid queue revisions freeze updates and request one bounded synchronization.
In structured mode runtime/admission changes accompany the composer projection
or snapshot, not message deltas. Stop is always an explicit request; the UI keeps
the confirmed active/cancelling state until the application's projection changes.

`chat.snapshot` atomically restores messages, sequences, metadata and projection.
It cannot regress a projection or known transcript sequence. Keep sequence
counters for removed messages as tombstones; an intentional counter reset uses
`chat.reset` with a strictly higher composer revision. Equal composer-revision
snapshots may recover transcript state but cannot overwrite composer/runtime or
queue state. Confirmed queue membership/order is immutable within a queue revision.

With `adapter.reconcileOnSync: true`, reconnect sync includes scoped
`unresolvedSubmissionIds`. Put authoritative `receipts` in the snapshot. Omitted
or invalid receipts remain unknown; no prompt is replayed. `bridge.reconcile`
performs a separately configured status lookup even after dispatch capabilities
have been disabled. A definitive late receipt can update its original recovery
record but cannot change the current scope or clear newer input.

An application `ComposerRecoveryOwner` must outlive the hook, accept each
immutable attempt before transmission, and retain pending/unknown records. The
bridge bounds active correlation records (64 by default; `maxPendingRequests`
configures it), releases timers/listeners, and hands uncertainty back to that
owner. Failed handoffs prevent dispatch; `bridge.getRecoveryFailures()` exposes
failed records for explicit recovery/export. Never discard that owner or silently
evict unresolved snapshots during navigation or rollout rollback. The default
in-memory owner survives only while its application store remains alive. For
reload recovery, persist versioned JSON using the host's storage policy and restore
it into the owner. This does not make volatile server admission durable. Local
files lost on reload require reselection; uploaded references can be retained.

For a repository/context switch, explicitly remount with the application's draft
and recovery stores, or call the hook instance's `switchContext(config)` with the
new scope and initial snapshot. It invalidates the generation and replaces only
the Composer inside the existing root, even when `conversationId` is unchanged.
Changing `data-chat` by a LiveView patch alone does not switch the context. Mounts
and any portal targets must have unique IDs and `phx-update="ignore"`. A portal
belongs to that existing React root. Do not add a second root or an outer submit
handler. Cleanup removes UI work and portals; it never sends Stop or cancels a
server-owned run.

`bridge.mutateQueue(mutation, signal)` forwards portable queue mutations through
explicit `queue_edit`, `queue_remove`, `queue_promote` action mappings. Include
`requestId`, scope, `itemId`, `expectedRevision` and the operation; promotion also
requires a target turn. Both projection and per-item capabilities gate dispatch;
text-only edit support rejects atomic nodes/commands. A correlated reply uses
`{request_id, instanceGeneration, result: {requestId, outcome, projection, error?}}`.
The projection is authoritative even after a revision conflict. The application
owns atomic scheduling and persistence; React renders confirmed rows.

## Optional editor and upload boundary

Inject `RichChatComposer` from a separately loaded
`@duskmoon-dev/components/chat/rich` import into your existing Composer. Keep the
factory's Composer type stable while the optional child loads; retain the
controlled semantic draft and scope store. Install compatible optional peers
`lexical`, `@lexical/history`, and `@lexical/plain-text` at 0.53.0 only for rich
consumers. Ordinary/root/shared-hook imports load no Lexical runtime. The Phoenix
`./react-chat` entry and source assets ship in both Hex and npm distributions;
DuskmoonBundler resolves them directly from the Hex dependency, so no second npm
`phoenix_duskmoon` install is needed.

Raw File/Blob handles, object URLs, DOM/editor state and callbacks never enter
semantic documents or generic bridge JSON. Resolve/preprocess/upload through the
application adapter, then submit stable attachment entry IDs with approved
references/receipts. Failed or cancelled preparation must not dispatch incomplete
content. Sigma's existing validated, size-bounded inline-image encoding may remain
an explicit legacy adapter using JSON strings; the generic bridge does not encode
or validate image bytes or advertise an upload transport.

The interactive Storybook includes a legacy mount and structured portal mount,
fixture reference/command providers, model selection, queue operations, rejected
and unknown admission, lookup/reconnect, and volatile/durable receipt scenarios.
The fixture retains server state across socket reconnects for the same LiveView
root in a supervised memory cache, capped at 128 sessions and 30 idle minutes.
Reload creates a new root; expiry, eviction, or application restart loses that
state. Durable acceptance there is a labeled simulation, not proof of crash
recovery. Durable recovery and Sigma adoption need Sigma's persistence/idempotency
gates and a separately authorized release.
