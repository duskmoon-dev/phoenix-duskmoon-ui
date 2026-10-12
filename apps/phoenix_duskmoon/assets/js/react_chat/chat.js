import React, { memo, useEffect, useId, useRef, useState } from "react";
import { Markdown } from "@duskmoon-dev/components/markdown";
import { Input } from "@duskmoon-dev/components/input";
import { Button } from "@duskmoon-dev/components/button";
import { Chat } from "@duskmoon-dev/components/chat";
const h = React.createElement;
const defaultOptions = {};

const Message = memo(function Message(props) {
	const {
		message,
		bridge,
		targetId,
		timeline,
		options,
		connected,
		synchronizing,
	} = props;
	const [notice, setNotice] = useState("");
	return h(
		Chat,
		{
			id: targetId,
			role: "article",
			placement: message.role === "user" ? "end" : "start",
			timeline,
			"data-message-id": message.id,
		},
		options.renderHeader
			? h(options.renderHeader, props)
			: h(Chat.Header, null, message.author || message.role),
		h(
			Chat.Bubble,
			{ streaming: message.status === "streaming" },
			...(message.tools || []).map((tool) =>
				h(
					Chat.Tool,
					{ key: tool.id, status: tool.status || "running" },
					h(
						Chat.ToolHeader,
						null,
						`${tool.name || tool.id}: ${tool.status || "running"}`,
					),
					h(
						tool.result == null ? Chat.ToolCall : Chat.ToolResult,
						null,
						h(
							"pre",
							null,
							JSON.stringify(tool.result ?? tool.input ?? {}, null, 2),
						),
					),
				),
			),
			h(Markdown, {
				className: "chat-bubble-content",
				markdown: message.content || "",
			}),
		),
		message.status === "streaming" &&
			h(
				Chat.Status,
				{ role: "status" },
				h(Chat.StatusItem, null, "Generating…"),
			),
		message.error && h("p", { role: "alert" }, message.error),
		options.renderFooter
			? h(options.renderFooter, props)
			: h(
					Chat.Footer,
					null,
					h(
						Chat.Actions,
						null,
						h(
							Button,
							{
								type: "button",
								appearance: "ghost",
								onClick: async () => {
									try {
										await navigator.clipboard.writeText(message.content || "");
										setNotice("Copied");
									} catch {
										setNotice("Copy failed");
									}
								},
							},
							"Copy",
						),
						["error", "cancelled"].includes(message.status) &&
							h(
								Button,
								{
									type: "button",
									appearance: "ghost",
									disabled: !connected || synchronizing,
									onClick: () =>
										bridge
											.send("retry", { message_id: message.id })
											.catch((error) => setNotice(error.message)),
								},
								"Retry",
							),
						...(message.actions || []).map((action) =>
							h(
								Button,
								{
									key: action.id,
									disabled:
										action.disabled ||
										action.eligible === false ||
										!connected ||
										synchronizing,
									type: "button",
									appearance: "ghost",
									onClick: () =>
										bridge
											.send("action", {
												message_id: message.id,
												action: action.id,
											})
											.catch((error) => setNotice(error.message)),
								},
								action.label,
							),
						),
					),
				),
		h("span", { role: "status" }, notice),
	);
});

// A composer owns its draft/attachments. This helper only owns admission and UI requests.
export function useChatSubmission({ bridge, canSubmit }) {
	const [busy, setBusy] = useState(false);
	const [notice, setNotice] = useState("");
	const pending = useRef(false);
	const alive = useRef(true);
	useEffect(() => {
		alive.current = true;
		return () => {
			alive.current = false;
		};
	}, []);
	async function submit(payload) {
		if (!canSubmit || pending.current)
			throw new Error("Chat is not accepting messages");
		pending.current = true;
		setBusy(true);
		setNotice("");
		try {
			return await bridge.send("send", {
				request_id: crypto.randomUUID(),
				...payload,
			});
		} catch (error) {
			if (alive.current) setNotice(error.message);
			throw error;
		} finally {
			pending.current = false;
			if (alive.current) setBusy(false);
		}
	}
	return { submit, busy, notice };
}

function DefaultComposer(props) {
	const { bridge, connected, active, canSubmit } = props;
	const [draft, setDraft] = useState("");
	const { submit, busy, notice } = useChatSubmission(props);
	const [stopNotice, setStopNotice] = useState("");
	async function onSubmit(event) {
		event.preventDefault();
		if (!draft.trim() || busy || !canSubmit) return;
		const text = draft;
		try {
			await submit({ text });
			setDraft((current) => (current === text ? "" : current));
		} catch {
			/* The helper preserves the draft and renders the rejection. */
		}
	}
	return h(
		React.Fragment,
		null,
		(notice || stopNotice) && h("p", { role: "alert" }, notice || stopNotice),
		h(
			"form",
			{ className: "flex gap-2", onSubmit },
			h(Input, {
				value: draft,
				onChange: (event) => setDraft(event.target.value),
				"aria-label": "Message",
				placeholder: "Write a message",
			}),
			h(
				Button,
				{ type: "submit", disabled: busy || !canSubmit || !draft.trim() },
				"Send",
			),
			active &&
				h(
					Button,
					{
						type: "button",
						disabled: !connected,
						onClick: () =>
							bridge
								.send("stop", {})
								.catch((error) => setStopNotice(error.message)),
					},
					"Stop",
				),
		),
	);
}

export function ReactChat({
	state,
	bridge,
	connected,
	label,
	options = defaultOptions,
}) {
	const transcriptId = useId();
	const scroll = useRef(null);
	const follow = useRef(true);
	useEffect(() => {
		if (follow.current && scroll.current)
			scroll.current.scrollTop = scroll.current.scrollHeight;
	}, [state.messages]);
	const streaming = state.messages.some(
		(message) => message.status === "streaming",
	);
	const active = state.runtime.active ?? streaming;
	const canSubmit =
		connected &&
		!state.needsSync &&
		state.admission.canSubmit !== false &&
		(!active || state.admission.allowWhileStreaming === true);
	const context = {
		state,
		bridge,
		connected,
		synchronizing: state.needsSync,
		metadata: state.metadata,
		runtime: state.runtime,
		admission: state.admission,
		streaming,
		active,
		canSubmit,
	};
	const replies = state.messages
		.filter((message) => message.role === "assistant")
		.slice(-24);
	const timelines = new Map(
		replies.map((message, index) => [message.id, index + 1]),
	);
	const targetId = (message) =>
		`${transcriptId}-message-${encodeURIComponent(message.id)}`;
	return h(
		"section",
		{ className: "flex flex-col gap-3 h-full", "aria-label": label },
		h(
			Chat.Scroll,
			{
				ref: scroll,
				className: "flex-1 min-h-0",
				"data-chat-messages": true,
				onScroll: () => {
					const el = scroll.current;
					follow.current =
						el.scrollHeight - el.scrollTop - el.clientHeight < 48;
				},
			},
			h(
				Chat.ScrollTrack,
				{ role: "navigation", "aria-label": "Assistant replies" },
				replies.map((message) =>
					h(Chat.ScrollIndicator, {
						key: message.id,
						targetId: targetId(message),
						timeline: timelines.get(message.id),
						onClick: () => {
							follow.current = false;
						},
					}),
				),
			),
			h(
				Chat.ScrollBody,
				{ className: "gap-3" },
				state.messages.map((message) =>
					h(options.renderMessage || Message, {
						...(options.renderMessage ||
						options.renderHeader ||
						options.renderFooter
							? context
							: { connected, synchronizing: state.needsSync }),
						options,
						key: message.id,
						message,
						bridge,
						targetId: targetId(message),
						timeline: timelines.get(message.id),
					}),
				),
			),
		),
		h(
			Button,
			{
				type: "button",
				appearance: "ghost",
				onClick: () => {
					follow.current = true;
					scroll.current.scrollTop = scroll.current.scrollHeight;
				},
			},
			"Jump to latest",
		),
		(!connected || state.needsSync) &&
			h(
				"p",
				{ role: "status" },
				connected
					? "Synchronizing conversation…"
					: "Disconnected. Draft preserved.",
			),
		options.renderStatus && h(options.renderStatus, context),
		h(options.Composer || DefaultComposer, {
			...context,
			key: state.conversationId,
		}),
	);
}
