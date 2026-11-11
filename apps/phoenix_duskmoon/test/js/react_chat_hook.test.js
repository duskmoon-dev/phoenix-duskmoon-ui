import { describe, expect, mock, test } from "bun:test";
import React from "react";
import { renderToStaticMarkup } from "react-dom/server";
mock.module("react-dom/client", () => ({
	createRoot: () => ({
		render(node) {
			this.node = node;
		},
		unmount: mock(() => {}),
	}),
}));
globalThis.cancelAnimationFrame ??= () => {};
const { createDuskmoonReactChat, DuskmoonReactChat, ReactChat, initialState } =
	await import("phoenix_duskmoon/react-chat");

function mount(options = {}, application = {}) {
	const events = [],
		handlers = new Map();
	const hook = Object.assign(Object.create(createDuskmoonReactChat(options)), {
		el: {
			id: "chat",
			dataset: {
				target: "#component",
				chat: JSON.stringify({
					conversationId: "c1",
					messages: [
						{
							id: "m1",
							role: "assistant",
							content: "Answer",
							status: "streaming",
						},
					],
					event: "chat:event",
					actions: {
						send: "chat.send",
						stop: "chat.stop",
						sync: "chat.sync",
						action: "chat.action",
					},
					...application,
				}),
			},
		},
		handleEvent(event, callback) {
			handlers.set(event, callback);
			return event;
		},
		removeHandleEvent: mock((event) => handlers.delete(event)),
		pushEventTo(target, event, payload, reply) {
			events.push({ target, event, payload, reply });
		},
	});
	hook.mounted();
	return { hook, events, handlers };
}

// Drive transport deadlines and backoff without wall-clock sleeps.
async function withSyncClock(run) {
	const originalSet = globalThis.setTimeout;
	const originalClear = globalThis.clearTimeout;
	const timers = new Map();
	let now = 0,
		nextId = 0;
	const settle = async () => {
		for (let index = 0; index < 8; index++) await Promise.resolve();
	};
	globalThis.setTimeout = (callback, delay) => {
		const id = ++nextId;
		timers.set(id, { callback, at: now + delay });
		return id;
	};
	globalThis.clearTimeout = (id) => timers.delete(id);
	try {
		await run({
			settle,
			timers,
			async advance(ms) {
				const end = now + ms;
				await settle();
				while (true) {
					const next = [...timers].sort((a, b) => a[1].at - b[1].at)[0];
					if (!next || next[1].at > end) break;
					now = next[1].at;
					timers.delete(next[0]);
					next[1].callback();
					await settle();
				}
				now = end;
			},
		});
	} finally {
		globalThis.setTimeout = originalSet;
		globalThis.clearTimeout = originalClear;
	}
}

function syncingChat() {
	const context = mount();
	context.hook.scheduleRender = () => context.hook.renderChat();
	context.emit = (event) =>
		context.handlers.get("chat:event")({
			id: "chat",
			conversation_id: "c1",
			...event,
		});
	context.snapshot = () =>
		context.emit({
			type: "chat.snapshot",
			messages: [],
			sequences: {},
		});
	// A delta for an unknown message freezes reduction and requests a snapshot.
	context.emit({
		type: "chat.delta",
		message_id: "missing",
		sequence: 1,
		delta: "Lost",
	});
	return context;
}

describe("sync recovery", () => {
	test("rejected and timed-out syncs retry with capped backoff and stop after a snapshot", async () => {
		await withSyncClock(async ({ advance, settle, timers }) => {
			const { hook, events, snapshot } = syncingChat();
			try {
				expect(hook.state.needsSync).toBe(true);
				expect(events).toHaveLength(1);
				events[0].reply({ status: "error", message: "Try later" });
				await settle();
				expect(hook.state.error).toBe("Try later");
				await advance(999);
				expect(events).toHaveLength(1);
				await advance(1);
				expect(events).toHaveLength(2);
				hook.requestSync();
				expect(events).toHaveLength(2);
				await advance(15000);
				expect(hook.state.error).toContain("timed out");
				await advance(1999);
				expect(events).toHaveLength(2);
				await advance(1);
				expect(events).toHaveLength(3);
				for (const delay of [4000, 8000, 16000, 30000, 30000]) {
					events.at(-1).reply({ status: "error" });
					await settle();
					const count = events.length;
					await advance(delay - 1);
					expect(events).toHaveLength(count);
					await advance(1);
					expect(events).toHaveLength(count + 1);
				}
				// An acknowledgement alone does not establish transcript recovery.
				events.at(-1).reply({ status: "ok" });
				await settle();
				const acknowledged = events.length;
				await advance(30000);
				expect(events).toHaveLength(acknowledged + 1);
				expect(
					new Set(events.map(({ payload }) => payload.request_id)).size,
				).toBe(events.length);
				snapshot();
				events.at(-1).reply({ status: "ok" });
				expect(hook.state.needsSync).toBe(false);
				expect(hook.state.error).toBeNull();
				const count = events.length;
				await advance(60000);
				expect(events).toHaveLength(count);
				expect(timers.size).toBe(0);
				expect(events.every(({ event }) => event === "chat.sync")).toBe(true);
			} finally {
				hook.destroyed();
			}
		});
	});

	test("disconnect, context switch and unmount cancel queued retries", async () => {
		for (const lifecycle of ["disconnected", "switchContext", "destroyed"]) {
			await withSyncClock(async ({ advance, settle, timers }) => {
				const { hook, events } = syncingChat();
				try {
					events[0].reply({ status: "error" });
					await settle();
					if (lifecycle === "switchContext")
						hook.switchContext({ ...hook.config, conversationId: "c2" });
					else hook[lifecycle]();
					await advance(60000);
					expect(events).toHaveLength(1);
					expect(timers.size).toBe(0);
					if (lifecycle === "disconnected") {
						hook.reconnected();
						expect(events).toHaveLength(2);
						events[1].reply({ status: "error" });
						await settle();
						await advance(1000);
						expect(events).toHaveLength(3);
					}
				} finally {
					if (!hook.dead) hook.destroyed();
				}
			});
		}
	});

	test("one mount's cleanup cannot cancel another mount's recovery", async () => {
		await withSyncClock(async ({ advance, settle }) => {
			const first = syncingChat(),
				second = syncingChat();
			try {
				first.events[0].reply({ status: "error" });
				second.events[0].reply({ status: "error" });
				await settle();
				first.hook.destroyed();
				await advance(1000);
				expect(first.events).toHaveLength(1);
				expect(second.events).toHaveLength(2);
			} finally {
				if (!first.hook.dead) first.hook.destroyed();
				second.hook.destroyed();
			}
		});
	});

	test("a late failure after a snapshot neither restores its error nor retries", async () => {
		await withSyncClock(async ({ advance, timers }) => {
			const { hook, events, snapshot } = syncingChat();
			try {
				snapshot();
				events[0].reply({ status: "error", message: "Stale failure" });
				await advance(60000);
				expect(hook.state.error).toBeNull();
				expect(events).toHaveLength(1);
				expect(timers.size).toBe(0);
			} finally {
				hook.destroyed();
			}
		});
	});
});

describe("public React chat composition bridge", () => {
	test("mounts factory options and restores custom application state without copying the hook", () => {
		const Composer = ({ canSubmit, runtime, metadata }) =>
			React.createElement(
				"output",
				null,
				`${canSubmit}:${runtime.phase}:${metadata.session}`,
			);
		const Footer = ({ message }) =>
			React.createElement("footer", null, message.content);
		const { hook } = mount(
			{ Composer, renderFooter: Footer },
			{
				metadata: { session: "s1" },
				runtime: { active: true, phase: "tool_execution" },
				admission: { allowWhileStreaming: true },
			},
		);
		expect(renderToStaticMarkup(hook.root.node)).toContain(
			"true:tool_execution:s1",
		);
		expect(renderToStaticMarkup(hook.root.node)).toContain(
			"<footer>Answer</footer>",
		);
		expect(DuskmoonReactChat.mounted).toBeFunction();
		hook.destroyed();
	});

	test("preserves payloads and full admission acknowledgments, with rejection metadata", async () => {
		const { hook, events } = mount();
		const submission = hook.bridge.send("send", {
			text: "Steer",
			attachments: [{ upload_id: "image-1" }],
			request_id: "r1",
		});
		expect(events[0].target).toBe("#component");
		expect(events[0].payload).toEqual({
			id: "chat",
			conversation_id: "c1",
			text: "Steer",
			attachments: [{ upload_id: "image-1" }],
			request_id: "r1",
		});
		events[0].reply({
			status: "ok",
			admission: "steering",
			runtime_request_id: "runtime-1",
		});
		expect(await submission).toEqual({
			status: "ok",
			admission: "steering",
			runtime_request_id: "runtime-1",
		});
		const rejected = hook.bridge
			.send("send", { text: "Keep draft" })
			.catch((error) => error);
		events[1].reply({
			status: "error",
			message: "Not admitted",
			admission: "blocked",
		});
		const error = await rejected;
		expect(error.message).toBe("Not admitted");
		expect(error.response.admission).toBe("blocked");
		hook.destroyed();
	});

	test("reconnect blocks sends until snapshot and destruction cancels only UI work", async () => {
		const { hook, events, handlers } = mount();
		const pending = hook.bridge
			.send("send", { text: "Draft" })
			.catch((error) => error);
		hook.disconnected();
		expect((await pending).message).toContain("disconnected");
		await expect(hook.bridge.send("send", { text: "Draft" })).rejects.toThrow(
			"disconnected",
		);
		hook.reconnected();
		expect(events.at(-1).event).toBe("chat.sync");
		await expect(hook.bridge.send("send", { text: "Draft" })).rejects.toThrow(
			"synchronizing",
		);
		// Avoid real browser frame scheduling in this lifecycle unit test.
		hook.scheduleRender = () => hook.renderChat();
		handlers.get("chat:event")({
			id: "chat",
			type: "chat.snapshot",
			conversation_id: "c1",
			messages: [],
			sequences: {},
			runtime: { active: true, phase: "waiting_for_approval" },
			admission: { allowWhileStreaming: true },
		});
		expect(hook.state.needsSync).toBe(false);
		const request = hook.bridge
			.send("send", { text: "Draft" })
			.catch((error) => error);
		hook.destroyed();
		expect((await request).message).toContain("disconnected");
		expect(hook.root.unmount).toHaveBeenCalledTimes(1);
		expect(handlers.size).toBe(0);
		expect(hook.requests.size).toBe(0);
		expect(events.some((event) => event.event === "chat.stop")).toBe(false);
	});

	test("active runtime keeps Stop after text completion and custom admission permits steering", () => {
		const state = initialState(
			"c1",
			[{ id: "m1", role: "assistant", content: "Done", status: "complete" }],
			{
				runtime: { active: true, phase: "waiting_for_approval" },
				admission: { allowWhileStreaming: true },
			},
		);
		let context;
		const html = renderToStaticMarkup(
			React.createElement(ReactChat, {
				state,
				bridge: { send() {} },
				connected: true,
				options: {
					renderStatus: (props) => {
						context = props;
						return React.createElement("output", null, props.runtime.phase);
					},
				},
			}),
		);
		expect(html).toContain("waiting_for_approval");
		expect(html).toMatch(/<button[^>]*><span[^>]*>Stop<\/span><\/button>/);
		expect(context.canSubmit).toBe(true);
		expect(context.streaming).toBe(false);
		expect(context.active).toBe(true);
		state.needsSync = true;
		renderToStaticMarkup(
			React.createElement(ReactChat, {
				state,
				bridge: {},
				connected: true,
				options: {
					Composer: (props) => {
						context = props;
						return null;
					},
				},
			}),
		);
		expect(context.canSubmit).toBe(false);
	});
});
