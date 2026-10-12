import React, { useState } from "react";
import { Chat } from "@duskmoon-dev/components/chat";
import { Markdown } from "@duskmoon-dev/components/markdown";
import { Button } from "@duskmoon-dev/components/button";
import {
	createDuskmoonReactChat,
	useChatSubmission,
} from "phoenix_duskmoon/react-chat";

const h = React.createElement;
const drafts = new Map();

function Composer(props) {
	const id = props.state.conversationId;
	const [draft, setDraft] = useState(
		() => drafts.get(id) || { value: "", files: [] },
	);
	const [ack, setAck] = useState("");
	const [error, setError] = useState();
	const { submit, busy, notice } = useChatSubmission(props);
	function update(next) {
		drafts.set(id, next);
		setDraft(next);
	}
	return h(
		React.Fragment,
		null,
		h(Chat.Composer, {
			value: draft.value,
			attachments: draft.files,
			onValueChange: (value) => update({ ...draft, value }),
			onAttachmentsChange: (files) => update({ ...draft, files }),
			generating: props.active,
			canSubmit: props.canSubmit,
			busy,
			error: error || notice || undefined,
			textareaProps: { "aria-label": "Demo message" },
			onSubmit: async ({ value, files }) => {
				setError(undefined);
				setAck("");
				// File bytes need an application upload path; the demo only admits text.
				if (files.length) {
					setError("Upload attachments in your application before sending.");
					return false;
				}
				try {
					const reply = await submit({ text: value });
					setAck(`Admitted as ${reply.admission || "message"}`);
					return true;
				} catch {
					return false;
				}
			},
			onStop: () =>
				props.bridge.send("stop", {}).catch((error) => setError(error.message)),
			completion: {
				items: draft.value.startsWith("/")
					? [{ id: "explain", label: "/explain" }]
					: [],
				onSelect: () =>
					update({ ...draft, value: "Explain the streaming lifecycle" }),
			},
		}),
		ack && h("p", { role: "status" }, ack),
	);
}

function Footer({ message, bridge, connected, synchronizing }) {
	const [notice, setNotice] = useState("");
	return h(
		Chat.Footer,
		null,
		message.metadata?.usage &&
			h(
				"span",
				null,
				`${message.metadata.usage.tokens} tokens · ${message.metadata.usage.duration_ms} ms`,
			),
		message.metadata?.summary && h("p", null, message.metadata.summary),
		h(
			Chat.Actions,
			null,
			...(message.actions || []).map((action) =>
				h(
					Button,
					{
						key: action.id,
						type: "button",
						appearance: "ghost",
						disabled:
							!connected ||
							synchronizing ||
							action.disabled ||
							action.eligible === false,
						onClick: async () => {
							if (action.confirm && !window.confirm(action.confirm)) return;
							try {
								await bridge.send("action", {
									message_id: message.id,
									action: action.id,
								});
							} catch (error) {
								setNotice(error.message);
							}
						},
					},
					action.label,
				),
			),
		),
		notice && h("p", { role: "alert" }, notice),
	);
}

function Message(props) {
	const { message, targetId, timeline } = props;
	return h(
		Chat,
		{
			id: targetId,
			timeline,
			role: "article",
			placement: message.role === "user" ? "end" : "start",
			"data-message-id": message.id,
		},
		h(Chat.Header, null, message.author || message.role),
		message.metadata?.reasoning &&
			h(Chat.Reasoning, null, message.metadata.reasoning),
		h(
			Chat.Bubble,
			{ streaming: message.status === "streaming" },
			...(message.attachments || []).map((image) =>
				h("img", {
					key: image.url,
					src: image.url,
					alt: image.name || "Attachment",
					width: 96,
				}),
			),
			...(message.tools || []).map((tool) =>
				h(
					Chat.Tool,
					{ key: tool.id, status: tool.status },
					h(Chat.ToolHeader, null, tool.name),
					h(
						tool.result == null ? Chat.ToolCall : Chat.ToolResult,
						null,
						h("pre", null, JSON.stringify(tool.result ?? tool.input)),
					),
				),
			),
			h(Markdown, {
				markdown: message.content || "",
				className: "chat-bubble-content",
			}),
		),
		h(Footer, props),
	);
}

export const DuskmoonComposedChat = createDuskmoonReactChat({
	Composer,
	renderMessage: Message,
	renderFooter: Footer,
	renderStatus: ({ runtime }) =>
		runtime.active &&
		h(
			Chat.Status,
			{ role: "status" },
			h(Chat.StatusItem, null, runtime.phase || "Generating"),
		),
});
