import React, { memo, useEffect, useRef, useState } from "react";
import { Markdown } from "@duskmoon-dev/components/markdown";
import { Input } from "@duskmoon-dev/components/input";
import { Button } from "@duskmoon-dev/components/button";
const h = React.createElement;

const Message = memo(function Message({ message, bridge }) {
	const [notice, setNotice] = useState("");
	return h(
		"article",
		{
			className: message.role === "user" ? "chat chat-end" : "chat chat-start",
			"data-message-id": message.id,
		},
		h("div", { className: "chat-header" }, message.author || message.role),
		h(
			"div",
			{ className: "chat-bubble" },
			h(Markdown, { markdown: message.content || "" }),
		),
		...(message.tools || []).map((tool) =>
			h(
				"details",
				{ key: tool.id },
				h(
					"summary",
					null,
					`${tool.name || tool.id}: ${tool.status || "running"}`,
				),
				h(
					"pre",
					null,
					JSON.stringify(tool.result ?? tool.input ?? {}, null, 2),
				),
			),
		),
		message.status === "streaming" &&
			h("span", { role: "status" }, "Generating…"),
		message.error && h("p", { role: "alert" }, message.error),
		h(
			"div",
			{ className: "flex gap-2" },
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
						type: "button",
						appearance: "ghost",
						onClick: () =>
							bridge
								.send("action", { message_id: message.id, action: action.id })
								.catch((error) => setNotice(error.message)),
					},
					action.label,
				),
			),
		),
		h("span", { role: "status" }, notice),
	);
});

export function ReactChat({ state, bridge, connected, label }) {
	const [draft, setDraft] = useState("");
	const [busy, setBusy] = useState(false);
	const [notice, setNotice] = useState("");
	const pending = useRef(false);
	const alive = useRef(true);
	const scroll = useRef(null);
	const follow = useRef(true);
	useEffect(
		() => () => {
			alive.current = false;
		},
		[],
	);
	useEffect(() => {
		if (follow.current && scroll.current)
			scroll.current.scrollTop = scroll.current.scrollHeight;
	}, [state.messages]);
	const streaming = state.messages.some(
		(message) => message.status === "streaming",
	);
	async function submit(event) {
		event.preventDefault();
		if (
			!draft.trim() ||
			pending.current ||
			streaming ||
			!connected ||
			state.needsSync
		)
			return;
		const text = draft;
		pending.current = true;
		setBusy(true);
		setNotice("");
		try {
			await bridge.send("send", { text, request_id: crypto.randomUUID() });
			if (alive.current)
				setDraft((current) => (current === text ? "" : current));
		} catch (error) {
			if (alive.current) setNotice(error.message);
		} finally {
			pending.current = false;
			if (alive.current) setBusy(false);
		}
	}
	return h(
		"section",
		{ className: "flex flex-col gap-3 h-full", "aria-label": label },
		h(
			"div",
			{
				ref: scroll,
				className: "flex flex-col gap-3 overflow-auto flex-1 min-h-0",
				"data-chat-messages": true,
				onScroll: () => {
					const el = scroll.current;
					follow.current =
						el.scrollHeight - el.scrollTop - el.clientHeight < 48;
				},
			},
			state.messages.map((message) =>
				h(Message, { key: message.id, message, bridge }),
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
		notice && h("p", { role: "alert" }, notice),
		h(
			"form",
			{ className: "flex gap-2", onSubmit: submit },
			h(Input, {
				value: draft,
				onChange: (event) => setDraft(event.target.value),
				"aria-label": "Message",
				placeholder: "Write a message",
			}),
			h(
				Button,
				{
					type: "submit",
					disabled:
						busy || streaming || !connected || state.needsSync || !draft.trim(),
				},
				"Send",
			),
			streaming &&
				h(
					Button,
					{
						type: "button",
						disabled: !connected,
						onClick: () =>
							bridge
								.send("stop", {})
								.catch((error) => setNotice(error.message)),
					},
					"Stop",
				),
		),
	);
}
