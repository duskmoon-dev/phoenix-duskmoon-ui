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
