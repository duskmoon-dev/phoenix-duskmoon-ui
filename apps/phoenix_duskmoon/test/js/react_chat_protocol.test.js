import { describe, expect, mock, test } from "bun:test";
import {
	createComposerRecoveryOwner,
	createComposerSessionController,
} from "@duskmoon-dev/components/chat";
import fixture from "../fixtures/react_chat_contracts.v1.json";
import shippedFixture from "@duskmoon-dev/components/chat/contracts.v1.json";
mock.module("react-dom/client", () => ({
	createRoot: () => ({
		render(node) {
			this.node = node;
		},
		unmount: mock(() => {}),
	}),
}));
globalThis.cancelAnimationFrame ??= () => {};
const { createDuskmoonReactChat, ChatTransportError } =
	await import("phoenix_duskmoon/react-chat");

function mount(
	options = {},
	config = {},
	owner = createComposerRecoveryOwner(),
) {
	const events = [],
		handlers = new Map();
	const application = {
		conversationId: fixture.scope.conversationId,
		scope: fixture.scope,
		protocolVersion: 1,
		messages: [],
		event: "chat:event",
		composer: {
			revision: 8,
			capabilities: fixture.capabilities,
			providers: [],
			options: {},
			queue: fixture.queue.initial,
		},
		actions: {
			send: "chat.send",
			sync: "chat.sync",
			reconcile: "chat.reconcile",
			stop: "chat.stop",
			queue_remove: "queue.remove",
		},
		...config,
	};
	const hook = Object.assign(
		Object.create(
			createDuskmoonReactChat({
				adapter: () => ({ recovery: owner, reconcileOnSync: true }),
				...options,
			}),
		),
		{
			el: { id: "chat", dataset: { chat: JSON.stringify(application) } },
			handleEvent(event, callback) {
				handlers.set(event, callback);
				return event;
			},
			removeHandleEvent: mock((event) => handlers.delete(event)),
			pushEvent(event, payload, reply) {
				events.push({ event, payload, reply });
			},
		},
	);
	hook.mounted();
	hook.scheduleRender = () => hook.renderChat();
	return {
		hook,
		events,
		owner,
		application,
		handlers,
		emit: (event) =>
			handlers.get("chat:event")({
				id: "chat",
				conversation_id: application.conversationId,
				scope: hook.state.scope,
				protocolVersion: 1,
				instanceGeneration: hook.state.instanceGeneration,
				...event,
			}),
	};
}
const snapshot = (overrides = {}) => ({
	...fixture.submissions.send,
	...overrides,
});
function reply(event, overrides = {}) {
	event.reply({
		request_id: event.payload.request_id,
		instanceGeneration: event.payload.instanceGeneration,
		receipt: {
			protocolVersion: 1,
			clientSubmissionId: event.payload.clientSubmissionId,
			scope: event.payload.scope,
			operation: event.payload.operation,
			outcome: "accepted",
			delivery: "immediate",
			persistence: "volatile",
			...overrides,
		},
	});
}
const flush = () => new Promise((resolve) => setTimeout(resolve, 0));

describe("v1 composer transport and application recovery", () => {
	test("uses the published Unicode/repeated-reference/command contract without flattening", async () => {
		expect(fixture).toEqual(shippedFixture);
		const { hook, events, owner } = mount();
		const value = snapshot();
		const sent = hook.bridge.submit(value);
		expect(owner.getSnapshot()[0].snapshot).toEqual(value);
		expect(events[0].payload.document).toEqual(value.document);
		expect(events[0].payload.options).toEqual(value.options);
		expect(events[0].payload.text).toBeUndefined();
		reply(events[0], {
			delivery: "follow_up",
			queueItemId: "actual-queue",
			queueRevision: 9,
		});
		const receipt = await sent;
		expect(receipt.delivery).toBe("follow_up");
		expect(receipt.persistence).toBe("volatile");
		expect(receipt.turnId).toBeUndefined();
		expect(owner.getSnapshot()[0].status).toBe("accepted");
		const command = hook.bridge.submit(fixture.submissions.command);
		const commandReceipt = fixture.receipts.find(
			(r) => r.clientSubmissionId === "command-accepted",
		);
		events[1].reply({
			request_id: events[1].payload.request_id,
			instanceGeneration: hook.state.instanceGeneration,
			receipt: commandReceipt,
		});
		expect(await command).toEqual(commandReceipt);
		expect((await command).turnId).toBeUndefined();
		hook.destroyed();
	});

	test("guards double dispatch synchronously and explicit retry retains the logical identity", async () => {
		const owner = createComposerRecoveryOwner();
		const { hook, events } = mount(
			{
				adapter: () => ({ recovery: owner, authorizeRetry: async () => true }),
			},
			{},
			owner,
		);
		const first = hook.bridge.submit(snapshot());
		await expect(hook.bridge.submit(snapshot())).rejects.toThrow(
			"not accepting",
		);
		expect(events).toHaveLength(1);
		hook.disconnected();
		const uncertain = await first;
		expect(uncertain.outcome).toBe("unknown");
		expect(uncertain.error.details.request_id).toBe(
			events[0].payload.request_id,
		);
		expect(owner.getSnapshot()[0].snapshot).toEqual(snapshot());
		hook.connected = true;
		const retry = hook.bridge.submit(snapshot());
		await flush();
		expect(events).toHaveLength(2);
		expect(events[1].payload.clientSubmissionId).toBe(
			events[0].payload.clientSubmissionId,
		);
		expect(events[1].payload.request_id).not.toBe(events[0].payload.request_id);
		reply(events[1]);
		expect((await retry).outcome).toBe("accepted");
		hook.destroyed();
	});

	test("timeout becomes unknown and a late receipt only resolves the retained attempt", async () => {
		const { hook, events, owner } = mount({ requestTimeoutMs: 2 });
		const result = await hook.bridge.submit(snapshot());
		expect(result.outcome).toBe("unknown");
		expect(events).toHaveLength(1);
		expect(hook.requests.size).toBe(0);
		expect(owner.getSnapshot()[0].status).toBe("unknown");
		reply(events[0], { persistence: "durable", turnId: "real-turn" });
		expect(owner.getSnapshot()[0].receipt.turnId).toBe("real-turn");
		expect(result.outcome).toBe("unknown");
		hook.destroyed();
	});

	test("disconnect cleanup cannot overwrite a definitive receipt delivered before its microtask", async () => {
		const { hook, events, owner } = mount();
		const pending = hook.bridge.submit(snapshot());
		hook.disconnected();
		reply(events[0], { persistence: "durable", turnId: "confirmed-turn" });
		expect((await pending).outcome).toBe("unknown");
		expect(owner.getSnapshot()[0].status).toBe("accepted");
		expect(owner.getSnapshot()[0].receipt.turnId).toBe("confirmed-turn");
		hook.destroyed();
	});

	test("malformed and mismatched replies never invent acceptance", async () => {
		for (const response of [
			{ status: "ok" },
			{ receipt: fixture.receipts[0] },
			{ wrong: true },
		]) {
			const { hook, events, owner } = mount();
			const sent = hook.bridge.submit(snapshot());
			events[0].reply(response);
			expect((await sent).outcome).toBe("unknown");
			expect(owner.getSnapshot()[0].status).toBe("unknown");
			hook.destroyed();
		}
	});

	test("unsupported versions, capabilities, scopes, unmapped actions and raw binary never dispatch", async () => {
		const { hook, events, owner } = mount();
		await expect(hook.bridge.send("missing", {})).rejects.toThrow(
			"not configured",
		);
		for (const value of [
			snapshot({ protocolVersion: 2 }),
			snapshot({
				scope: { ...fixture.scope, contextKey: "another-repository" },
			}),
			snapshot({ document: { schemaVersion: 2, content: [] } }),
			snapshot({ attachments: [new Blob(["raw"])] }),
		])
			await expect(hook.bridge.submit(value)).rejects.toThrow();
		hook.state.composer.capabilities = {
			...fixture.capabilities,
			commands: false,
		};
		await expect(
			hook.bridge.submit(fixture.submissions.command),
		).rejects.toThrow("Unsupported");
		expect(events).toHaveLength(0);
		expect(owner.getSnapshot()).toHaveLength(0);
		hook.destroyed();
	});

	test("context switch in the same conversation invalidates old bridge callbacks and preserves recovery", async () => {
		const { hook, events, owner, application } = mount();
		const oldBridge = hook.bridge,
			oldGeneration = hook.state.instanceGeneration;
		const sent = oldBridge.submit(snapshot());
		const scope = { ...fixture.scope, contextKey: "repo:beta" };
		hook.switchContext({
			...application,
			scope,
			composer: {
				...application.composer,
				queue: { ...fixture.queue.initial, scope },
			},
		});
		expect((await sent).outcome).toBe("unknown");
		await expect(oldBridge.submit(snapshot())).rejects.toThrow(
			"context has changed",
		);
		reply(events[0]);
		expect(owner.getSnapshot()[0].status).toBe("accepted");
		expect(hook.state.scope).toEqual(scope);
		expect(hook.state.instanceGeneration).not.toBe(oldGeneration);
		hook.destroyed();
	});

	test("reconnect reconciles receipts and leaves omitted attempts unknown without replay", async () => {
		const { hook, events, emit, owner } = mount();
		const sent = hook.bridge.submit(snapshot());
		hook.disconnected();
		await sent;
		hook.reconnected();
		expect(events[1].payload.unresolvedSubmissionIds).toEqual([
			snapshot().clientSubmissionId,
		]);
		expect(events[1].event).toBe("chat.sync");
		events[1].reply({ status: "ok" });
		emit({
			type: "chat.snapshot",
			messages: [],
			sequences: {},
			composer: hook.state.composer,
			receipts: [],
		});
		expect(hook.state.needsSync).toBe(false);
		expect(owner.getSnapshot()[0].status).toBe("unknown");
		const lookup = hook.bridge.reconcile(snapshot());
		reply(events[2], { operation: "prompt" });
		expect((await lookup).outcome).toBe("accepted");
		expect(events.filter((e) => e.event === "chat.send")).toHaveLength(1);
		hook.destroyed();
	});

	test("unmount and transport capacity preserve snapshots and release client work without Stop", async () => {
		const { hook, events, owner, handlers } = mount({ maxPendingRequests: 1 });
		const sent = hook.bridge.submit(snapshot());
		await expect(hook.bridge.send("stop", {})).rejects.toThrow("capacity");
		hook.destroyed();
		expect((await sent).outcome).toBe("unknown");
		expect(owner.getSnapshot()[0].snapshot).toEqual(snapshot());
		expect(hook.requests.size).toBe(0);
		expect(handlers.size).toBe(0);
		expect(events.map((e) => e.event)).toEqual(["chat.send"]);
		reply(events[0]);
		expect(owner.getSnapshot()[0].status).toBe("accepted");
	});

	test("failed application handoff stops dispatch and remains inspectable", async () => {
		const { hook, events } = mount({
			adapter: () => ({
				recovery: {
					getSnapshot: () => [],
					retain() {
						throw new Error("Storage unavailable");
					},
				},
			}),
		});
		await expect(hook.bridge.submit(snapshot())).rejects.toThrow(
			"Storage unavailable",
		);
		expect(events).toHaveLength(0);
		expect(hook.bridge.getRecoveryFailures()[0].attempt.snapshot).toEqual(
			snapshot(),
		);
		hook.destroyed();
	});

	test("queue mutations forward authoritative identity and revisions without optimistic Stop or removal", async () => {
		const { hook, events } = mount();
		const mutation = {
			requestId: "queue-request",
			scope: fixture.scope,
			itemId: "queue-1",
			expectedRevision: 8,
			operation: "remove",
		};
		const sent = hook.bridge.mutateQueue(mutation);
		expect(events[0].payload.scope).toEqual(fixture.scope);
		expect(hook.state.composer.queue.items).toHaveLength(1);
		events[0].reply({
			request_id: events[0].payload.request_id,
			instanceGeneration: hook.state.instanceGeneration,
			result: {
				requestId: mutation.requestId,
				outcome: "accepted",
				projection: fixture.queue.authoritative,
			},
		});
		expect((await sent).outcome).toBe("accepted");
		expect(hook.state.composer.queue.items).toHaveLength(0);
		await expect(hook.bridge.mutateQueue(mutation)).rejects.toThrow();
		hook.destroyed();
	});

	test("the upstream controller can pre-retain its first attempt before calling the same recovery owner", async () => {
		const { hook, events, owner } = mount();
		const controller = createComposerSessionController(
			{
				scope: fixture.scope,
				draftKey: "draft",
				document: fixture.documents.mixed,
				revision: 1,
				instanceGeneration: 1,
				runtime: { status: "idle" },
				host: {
					capabilities: fixture.capabilities,
					recovery: owner,
					submit: hook.bridge.submit,
				},
			},
			{ instanceId: "upstream-controller" },
		);
		const sent = controller.submit();
		expect(events).toHaveLength(1);
		reply(events[0]);
		expect((await sent).outcome).toBe("accepted");
		controller.dispose();
		hook.destroyed();
	});

	test("legacy binary is rejected but the host's already encoded bounded inline adapter stays compatible", async () => {
		const { hook, events } = mount();
		await expect(
			hook.bridge.send("send", {
				text: "image",
				attachments: [new File(["bytes"], "a.png")],
			}),
		).rejects.toThrow("File/Blob");
		const sent = hook.bridge.send("send", {
			text: "image",
			attachments: [{ data: "data:image/png;base64,YQ==" }],
		});
		events[0].reply({ status: "ok", admission: "immediate" });
		expect((await sent).admission).toBe("immediate");
		const pending = hook.bridge.send("stop", {}).catch((error) => error);
		hook.disconnected();
		expect(await pending).toBeInstanceOf(ChatTransportError);
		hook.destroyed();
	});
	test("receipt lookup survives a capability rollback and stale projection snapshots still reconcile", async () => {
		const { hook, events, owner, emit } = mount();
		const sent = hook.bridge.submit(snapshot());
		hook.disconnected();
		await sent;
		hook.connected = true;
		hook.state = {
			...hook.state,
			composer: {
				...hook.state.composer,
				revision: 20,
				capabilities: {
					...fixture.capabilities,
					intents: [],
					attachments: false,
				},
			},
		};
		const lookup = hook.bridge.reconcile(snapshot());
		expect(events[1].payload.operation).toBe("prompt");
		reply(events[1], { operation: "prompt" });
		expect((await lookup).outcome).toBe("accepted");
		const next = snapshot({ clientSubmissionId: "other-attempt" });
		owner.retain({
			snapshot: next,
			instanceId: "other",
			instanceGeneration: 1,
			createdAt: 0,
			status: "unknown",
			receipt: {
				...fixture.receipts[2],
				clientSubmissionId: next.clientSubmissionId,
			},
		});
		emit({
			type: "chat.snapshot",
			messages: [],
			composer: { ...hook.state.composer, revision: 10 },
			receipts: [
				{
					protocolVersion: 1,
					scope: fixture.scope,
					clientSubmissionId: next.clientSubmissionId,
					operation: "prompt",
					outcome: "accepted",
					delivery: "immediate",
					persistence: "volatile",
				},
			],
		});
		expect(hook.state.composer.revision).toBe(20);
		expect(
			owner
				.getSnapshot()
				.find((a) => a.snapshot.clientSubmissionId === next.clientSubmissionId)
				.status,
		).toBe("accepted");
		hook.destroyed();
	});

	test("cancellation releases transport and preserves uncertainty without stopping the server", async () => {
		const { hook, events, owner } = mount();
		const cancelled = new AbortController();
		cancelled.abort();
		await expect(
			hook.bridge.submit(snapshot(), cancelled.signal),
		).rejects.toThrow("before dispatch");
		expect(events).toHaveLength(0);
		const controller = new AbortController();
		const pending = hook.bridge.submit(snapshot(), controller.signal);
		controller.abort();
		expect((await pending).outcome).toBe("unknown");
		expect(hook.requests.size).toBe(0);
		expect(owner.getSnapshot()[0].snapshot).toEqual(snapshot());
		expect(events.map((e) => e.event)).toEqual(["chat.send"]);
		hook.destroyed();
	});

	test("retry compares normalized JSON and cannot overlap an asynchronous authorization", async () => {
		const owner = createComposerRecoveryOwner();
		let authorize;
		const { hook, events } = mount(
			{
				adapter: () => ({
					recovery: owner,
					authorizeRetry: () =>
						new Promise((resolve) => {
							authorize = resolve;
						}),
				}),
			},
			{},
			owner,
		);
		const first = hook.bridge.submit(snapshot());
		hook.disconnected();
		await first;
		hook.connected = true;
		const reordered = Object.fromEntries(Object.entries(snapshot()).reverse());
		const retry = hook.bridge.submit(reordered);
		await expect(hook.bridge.submit(reordered)).rejects.toThrow(
			"not accepting",
		);
		authorize(true);
		await flush();
		reply(events[1]);
		expect((await retry).outcome).toBe("accepted");
		hook.destroyed();
	});

	test("text-only queue edits and malformed authoritative replies cannot replace confirmed items", async () => {
		const { hook, events } = mount();
		const mutation = {
			requestId: "edit-request",
			scope: fixture.scope,
			itemId: "queue-1",
			expectedRevision: 8,
			operation: "edit",
			document: fixture.documents.mixed,
		};
		await expect(hook.bridge.mutateQueue(mutation)).rejects.toThrow(
			"text documents only",
		);
		expect(events).toHaveLength(0);
		const sent = hook.bridge
			.mutateQueue({ ...mutation, operation: "remove" })
			.catch((error) => error);
		events[0].reply({
			request_id: events[0].payload.request_id,
			instanceGeneration: hook.state.instanceGeneration,
			result: {
				requestId: mutation.requestId,
				outcome: "accepted",
				projection: {
					...fixture.queue.authoritative,
					items: [{ id: "same" }, { id: "same" }],
				},
			},
		});
		expect(await sent).toBeInstanceOf(ChatTransportError);
		expect(hook.state.composer.queue.items).toEqual(
			fixture.queue.initial.items,
		);
		hook.destroyed();
	});
	test("a second reconnect replaces a cancelled sync without stale promise cleanup", async () => {
		const { hook, events, emit } = mount();
		hook.disconnected();
		hook.reconnected();
		hook.requestSync();
		expect(events).toHaveLength(1);
		hook.disconnected();
		hook.reconnected();
		expect(events).toHaveLength(2);
		await flush();
		hook.requestSync();
		expect(events).toHaveLength(2);
		events[1].reply({ status: "ok" });
		emit({
			type: "chat.snapshot",
			messages: [],
			sequences: {},
			composer: hook.state.composer,
		});
		await flush();
		expect(hook.state.needsSync).toBe(false);
		expect(hook.state.error).toBeNull();
		hook.destroyed();
	});
});
