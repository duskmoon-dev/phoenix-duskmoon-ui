import React, {
	useEffect,
	useMemo,
	useRef,
	useState,
	useSyncExternalStore,
} from "react";
import { createPortal } from "react-dom";
import {
	Chat,
	ChatSessionComposer,
	ChatAuthoritativeQueue,
	ComposerSettings,
	createComposerRecoveryOwner,
} from "@duskmoon-dev/components/chat";
import { Markdown } from "@duskmoon-dev/components/markdown";
import { Button } from "@duskmoon-dev/components/button";
import {
	createDuskmoonReactChat,
	useChatSubmission,
} from "phoenix_duskmoon/react-chat";

const h = React.createElement;
const drafts = new Map();

function LegacyComposer(props) {
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
			compact: true,
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
	const assistant = message.role === "assistant";
	return h(
		assistant ? Chat.Agent : Chat,
		{
			id: targetId,
			timeline,
			role: "article",
			...(assistant
				? {}
				: { placement: message.role === "user" ? "end" : "start" }),
			"data-message-id": message.id,
		},
		h(Chat.Header, null, message.author || message.role),
		message.metadata?.reasoning &&
			h(
				Chat.Reasoning,
				null,
				h("summary", null, "Reasoning"),
				h("div", null, message.metadata.reasoning),
			),
		h(
			assistant ? Chat.Content : Chat.Bubble,
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
				className: assistant ? undefined : "chat-bubble-content",
			}),
		),
		h(Footer, props),
	);
}

// The fixture application owns these stores, independently of the hook lifecycle.
// Memory retention survives remount/navigation only; reload loses local drafts.
const semanticDrafts = new Map();
let occurrence = 0;
const occurrenceId = () => `fixture-node-${Date.now()}-${++occurrence}`;
const recoveryOwners = new Map();
const scopeKey = (scope) =>
	JSON.stringify([scope?.contextKey, scope?.conversationId]);
function recoveryFor(scope) {
	const key = scopeKey(scope);
	if (!recoveryOwners.has(key))
		recoveryOwners.set(key, createComposerRecoveryOwner());
	return recoveryOwners.get(key);
}

function fixtureProvider(providerId, trigger, candidates) {
	return {
		providerId,
		label: providerId === "files" ? "Fixture files" : "Fixture commands",
		trigger,
		async query(request, signal) {
			// Providers receive cancellation separately from portable JSON.
			await new Promise((resolve, reject) => {
				if (signal.aborted) return reject(new Error("Provider cancelled"));
				const done = () => {
					signal.removeEventListener("abort", abort);
					resolve();
				};
				const timer = setTimeout(done, 80);
				const abort = () => {
					clearTimeout(timer);
					reject(new Error("Provider cancelled"));
				};
				signal.addEventListener("abort", abort, { once: true });
			});
			return {
				request,
				candidates: candidates
					.filter((item) =>
						item.label.toLowerCase().includes(request.query.toLowerCase()),
					)
					.map((item) =>
						item.action.type === "insert"
							? {
									...item,
									action: {
										...item.action,
										content: item.action.content.map((node) =>
											node.type === "reference"
												? { ...node, nodeId: occurrenceId() }
												: node,
										),
									},
								}
							: item,
					),
			};
		},
	};
}
const fixtureProviders = [
	fixtureProvider("files", { text: "@", position: "word" }, [
		{
			id: "fixture-readme",
			label: "README.md",
			group: "Fixture repository",
			action: {
				type: "insert",
				content: [
					{
						type: "reference",
						nodeId: "fixture-provider-reference",
						providerId: "files",
						refId: "README.md",
						label: "README.md",
						plainText: "@README.md",
					},
				],
			},
		},
	]),
	fixtureProvider("commands", { text: "/", position: "leading" }, [
		{
			id: "reload-tools",
			label: "/reload-tools",
			group: "Fixture actions",
			action: {
				type: "insert",
				content: [{ type: "text", text: "/reload-tools" }],
				command: { providerId: "commands", commandId: "reload-tools" },
			},
		},
	]),
];
let richComposerPromise;
function loadRichComposer() {
	return (richComposerPromise ??= import("@duskmoon-dev/components/chat/rich"));
}

function StructuredComposer(props) {
	const { scope, composer, bridge, adapter } = props;
	const key = scopeKey(scope);
	const [value, setValue] = useState(
		() =>
			semanticDrafts.get(key) || {
				document: { schemaVersion: 1, content: [{ type: "text", text: "" }] },
				revision: 0,
				origin: "replace",
				originId: "fixture-initial",
			},
	);
	const [Editor, setEditor] = useState(() => ChatSessionComposer);
	const [rich, setRich] = useState(false);
	const [loading, setLoading] = useState(false);
	const [scenario, setScenario] = useState("volatile");
	const [receipt, setReceipt] = useState();
	const [notice, setNotice] = useState("");
	const editor = useRef(null);
	const alive = useRef(true);
	useEffect(() => {
		alive.current = true;
		return () => {
			alive.current = false;
		};
	}, []);
	const attempts = useSyncExternalStore(
		adapter.recovery.subscribe,
		adapter.recovery.getSnapshot,
		adapter.recovery.getSnapshot,
	);
	const unresolved = attempts.filter(
		(attempt) => attempt.status === "unknown" || attempt.status === "pending",
	);
	const host = useMemo(
		() => ({
			capabilities: composer.capabilities,
			recovery: adapter.recovery,
			commandOperation: adapter.commandOperation,
			submit: async (snapshot, signal) => {
				// Captured by the upstream controller before this optional fixture delay.
				if (snapshot.options.scenario === "pending")
					await new Promise((resolve, reject) => {
						const timer = setTimeout(done, 900);
						function done() {
							signal.removeEventListener("abort", abort);
							resolve();
						}
						function abort() {
							clearTimeout(timer);
							reject(
								new Error("Fixture preparation cancelled before dispatch"),
							);
						}
						if (signal.aborted) abort();
						else signal.addEventListener("abort", abort, { once: true });
					});
				if (signal.aborted)
					throw new Error("Fixture preparation cancelled before dispatch");
				const result = await bridge.submit(snapshot, signal);
				if (alive.current) setReceipt(result);
				return result;
			},
			reconcile: (snapshot, signal) => bridge.reconcile(snapshot, signal),
		}),
		[composer.capabilities, adapter, bridge],
	);
	function update(next) {
		semanticDrafts.set(key, next);
		setValue(next);
	}
	async function enableRich() {
		setLoading(true);
		try {
			const module = await loadRichComposer();
			if (alive.current) {
				setEditor(() => module.RichChatComposer);
				setRich(true);
			}
		} catch (error) {
			if (alive.current) setNotice(error.message);
		} finally {
			if (alive.current) setLoading(false);
		}
	}
	const settings = [
		{
			id: "model",
			label: "Fixture model",
			value: composer.options.model,
			choices: [
				{ value: "fixture-small", label: "Fixture small" },
				{ value: "fixture-large", label: "Fixture large" },
			],
		},
	];
	const content = h(
		React.Fragment,
		null,
		h(
			"p",
			{ className: "text-sm opacity-70" },
			"Fixture storage is memory only. Durable receipts below simulate a committed backend; this demo does not provide production persistence.",
		),
		h(ComposerSettings, {
			scopeKey: key,
			revision: composer.revision,
			settings,
			onRequest: async (request) =>
				(await bridge.send("configure", request)).result,
			onAcknowledged: () => {}, // Server projection events own the controlled value.
		}),
		h(
			"label",
			{ className: "flex gap-2 items-center" },
			"Admission fixture",
			h(
				"select",
				{
					className: "select",
					"aria-label": "Admission fixture",
					value: scenario,
					onChange: (event) => setScenario(event.target.value),
				},
				...[
					["volatile", "Volatile acceptance"],
					["durable", "Durable acceptance fixture"],
					["rejected", "Explicit rejection"],
					["unknown", "Unknown then reconcile"],
					["pending", "Delayed reply: edit while pending"],
				].map(([id, label]) => h("option", { key: id, value: id }, label)),
			),
		),
		h(
			"div",
			{ className: "flex flex-wrap gap-2" },
			!rich &&
				h(
					Button,
					{ type: "button", disabled: loading, onClick: enableRich },
					loading ? "Loading editor…" : "Load rich editor",
				),
			h(
				Button,
				{
					type: "button",
					disabled: !rich,
					onClick: () =>
						editor.current?.insertReference({
							type: "reference",
							nodeId: occurrenceId(),
							providerId: "files",
							refId: "README.md",
							label: "README.md",
							plainText: "@README.md",
						}),
				},
				"Insert reference",
			),
			h(
				Button,
				{
					type: "button",
					disabled: !rich,
					onClick: () =>
						editor.current?.insertQuote({
							type: "quote",
							nodeId: occurrenceId(),
							text: "Preserve the submitted revision.",
							source: {
								providerId: "messages",
								messageId: "fixture-source",
								label: "Fixture source",
							},
						}),
				},
				"Insert quote",
			),
			h(
				Button,
				{
					type: "button",
					onClick: () =>
						editor.current?.claimCommand(
							{ providerId: "commands", commandId: "reload-tools" },
							"/reload-tools",
						),
				},
				"Claim reload command",
			),
		),
		h(Editor, {
			ref: editor,
			compact: true,
			value,
			onDocumentChange: update,
			scope,
			draftKey: "storybook-composer-v1",
			host,
			options: { ...composer.options, scenario },
			providers: props.providers,
			runtime: {
				status: props.connected
					? props.active
						? "running"
						: "idle"
					: "disconnected",
				activeTurnId: props.runtime.activeTurnId,
			},
			canSubmit: props.canSubmit,
			label: "Structured demo message",
			error: notice || undefined,
			attachmentOptions: {
				prepare: async () => {
					throw new Error(
						"This fixture has no upload transport. Remove the file before sending.",
					);
				},
			},
			onStop: () =>
				bridge.send("stop", {}).catch((error) => setNotice(error.message)),
		}),
		receipt &&
			h(
				"p",
				{ role: "status", "data-composer-receipt": true },
				receipt.operation === "command" && receipt.outcome === "accepted"
					? `Command accepted: ${JSON.stringify(receipt.result)}`
					: receipt.outcome === "accepted"
						? `Accepted: ${receipt.delivery}; ${receipt.persistence} admission (execution is separate).`
						: `${receipt.outcome}: ${receipt.error?.message || "No definitive admission evidence"}`,
			),
		unresolved.length > 0 &&
			h(
				"div",
				null,
				h(
					"p",
					{ role: "status" },
					`${unresolved.length} unresolved snapshot(s) retained; no automatic replay.`,
				),
				h(
					Button,
					{
						type: "button",
						disabled: !props.connected,
						onClick: async () => {
							try {
								for (const attempt of unresolved) {
									const result = await bridge.reconcile(attempt.snapshot);
									if (alive.current) setReceipt(result);
								}
							} catch (error) {
								if (alive.current) setNotice(error.message);
							}
						},
					},
					"Reconcile retained attempts",
				),
			),
		h(ChatAuthoritativeQueue, {
			projection: composer.queue,
			capabilities: composer.capabilities.queue,
			targetTurnId: props.runtime.activeTurnId,
			onMutation: (mutation, signal) => bridge.mutateQueue(mutation, signal),
			onProjection: () => {}, // The bridge/server revisioned event owns projection.
		}),
		h(
			"p",
			{ className: "text-xs opacity-60" },
			`Queue revision ${composer.queue.revision}; projection revision ${composer.revision}. File preparation intentionally fails: previews are not uploads.`,
		),
	);
	const target =
		props.metadata.composerPortalId &&
		document.getElementById(props.metadata.composerPortalId);
	return target ? createPortal(content, target) : content;
}

export const DuskmoonComposedChat = createDuskmoonReactChat({
	Composer: (props) =>
		props.composer ? h(StructuredComposer, props) : h(LegacyComposer, props),
	adapter: ({ scope }) => ({
		recovery: recoveryFor(scope),
		providers: fixtureProviders,
		commandOperation: () => "command",
		reconcileOnSync: true,
	}),
	renderMessage: Message,
	renderFooter: Footer,
	renderStatus: ({ runtime }) =>
		h(
			Chat.Status,
			{ role: "status" },
			h(
				Chat.StatusItem,
				null,
				runtime.active ? runtime.phase || "Generating" : "Ready",
			),
		),
});
