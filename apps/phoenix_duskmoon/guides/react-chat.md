# React streaming chat

Use `dm_react_chat` for conversations with streaming responses. React owns the
transcript, draft, markdown rendering, scrolling, and message actions. LiveView
owns authorization, persistence, and the generation process.

The transcript uses the published `@duskmoon-dev/components/chat` composition
for message bubbles, streaming carets, tool disclosures, and action footers.
Each reply keeps its tool disclosures inside a single `Chat.Bubble`, before
the final Markdown in `.chat-bubble-content`, following the upstream LLM layout.
The upstream status and action parts retain the generating notice and existing
Copy, Retry, and custom actions. Reply markers navigate within the transcript
panel using `Chat.ScrollIndicator`; they cover the latest 24 assistant replies,
while all messages remain visible. Navigation preserves manual scroll position
as streaming continues; use **Jump to latest** to resume following new content.

```heex
<.dm_react_chat
  id="assistant-chat"
  conversation_id={@conversation_id}
  messages={@messages}
  class="h-full"
/>
```

Register `DuskmoonReactChat` from `phoenix_duskmoon/react-chat` in the LiveSocket
hooks. The mount uses `phx-update="ignore"`; do not update `@messages` for every
token. Send server events with `push_event(socket, "chat:event", payload)`.

Server events include `chat.snapshot`, `chat.message`, `chat.delta`, `chat.tool`,
`chat.complete`, `chat.error`, and `chat.reset`. Every event must include the
conversation ID, message ID, and a monotonic sequence. The client ignores duplicate
events and requests `chat.sync` after a sequence gap or reconnect.

Client events are `chat.send`, `chat.stop`, `chat.retry`, `chat.action`, and
`chat.sync`. `chat.send` contains the chat ID, conversation ID, text, and a request
ID. The LiveView should reply quickly and let a supervised task stream output.
Batch model tokens for roughly 30–50ms or a bounded chunk size before pushing them;
the React DOM is updated once per received batch.

Keep PubSub topics scoped to the tenant, user, and conversation. Terminate the
generation task and unsubscribe or ignore late events when the hook is destroyed.
`dm_chat` and `dm_chat_input` remain available for existing custom-element usage.
