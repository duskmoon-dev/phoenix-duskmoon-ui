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
`@duskmoon-dev/components/chat` parts for bubbles, tools, statuses, and actions,
with Markdown inside `.chat-bubble-content`. The default composer preserves its
text on rejection/disconnect and disallows sending during an active turn unless
admission explicitly permits it. **Jump to latest** resumes automatic scrolling;
reply markers cover the latest 24 assistant messages while all messages remain
visible.

The mount has `phx-update="ignore"`. Push events rather than updating `@messages`
per token. HEEX children are not a composition API: `inner_block` is no longer
declared. Put server-rendered controls outside the mount, or use the public React
composition API below. `target` routes the bridge to a LiveComponent if needed.

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
  return h(Chat, { id: targetId, timeline, role: "article", placement: message.role === "user" ? "end" : "start" },
    h(Chat.Header, null, message.author || message.role),
    message.metadata?.reasoning && h(Chat.Reasoning, null, message.metadata.reasoning),
    h(Chat.Bubble, { streaming: message.status === "streaming" },
      h(Markdown, { markdown: message.content || "", className: "chat-bubble-content" })),
    h(Footer, props),
  );
}
const ApplicationChat = createDuskmoonReactChat({
  Composer, renderMessage: Message, renderFooter: Footer,
  renderStatus: ({ runtime }) => runtime.active && h(Chat.Status, null, runtime.phase),
});
// Add ApplicationChat to your LiveSocket hooks.
```

Select it with `hook="ApplicationChat"` on `dm_react_chat`. The interactive
React Chat demo mounts a consumer composer/message/footer using public exports,
with attachments, completion, usage, reasoning, summaries, and confirmed actions.
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
