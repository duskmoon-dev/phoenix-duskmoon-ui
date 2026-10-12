import { describe, expect, test } from "bun:test";
import { initialState, reduceChat } from "../../assets/js/react_chat/state.js";

describe("React chat stream state", () => {
	test("accepts ordered deltas and ignores duplicates", () => {
		let state = initialState("c1", [
			{ id: "m1", role: "assistant", status: "streaming", content: "" },
		]);
		state = reduceChat(state, {
			type: "chat.delta",
			conversation_id: "c1",
			message_id: "m1",
			sequence: 1,
			text: "Hel",
		});
		state = reduceChat(state, {
			type: "chat.delta",
			conversation_id: "c1",
			message_id: "m1",
			sequence: 1,
			text: "bad",
		});
		state = reduceChat(state, {
			type: "chat.delta",
			conversation_id: "c1",
			message_id: "m1",
			sequence: 2,
			text: "lo",
		});
		expect(state.messages[0].content).toBe("Hello");
		expect(state.needsSync).toBe(false);
	});

	test("requests synchronization when a sequence gap is detected", () => {
		const state = reduceChat(
			initialState("c1", [
				{ id: "m1", role: "assistant", status: "streaming", content: "" },
			]),
			{
				type: "chat.delta",
				conversation_id: "c1",
				message_id: "m1",
				sequence: 2,
				text: "lost",
			},
		);
		expect(state.needsSync).toBe(true);
		expect(state.messages[0].content).toBe("");
	});

	test("ignores events for another conversation", () => {
		const state = initialState("c1", []);
		expect(
			reduceChat(state, {
				type: "chat.snapshot",
				conversation_id: "c2",
				messages: [{ id: "x" }],
			}),
		).toEqual(state);
	});
});

test("preserves application fields through streaming, late message replacements and sync", () => {
	const original = {
		id: "m1",
		role: "assistant",
		status: "streaming",
		content: "",
		metadata: { reasoning: "Check context" },
		attachments: [{ url: "/image" }],
	};
	let state = initialState("c1", [original], {
		metadata: { session: "s1" },
		runtime: { active: true, phase: "provider_streaming" },
		admission: { allowWhileStreaming: true },
	});
	state = reduceChat(state, {
		type: "chat.delta",
		conversation_id: "c1",
		message_id: "m1",
		sequence: 1,
		text: "Answer",
	});
	expect(state.messages[0].metadata).toEqual(original.metadata);
	expect(state.messages[0].attachments).toEqual(original.attachments);
	expect(state.metadata.session).toBe("s1");
	state = reduceChat(state, {
		type: "chat.complete",
		conversation_id: "c1",
		message_id: "m1",
		sequence: 2,
		runtime: { active: true, phase: "waiting_for_approval" },
	});
	expect(state.messages[0].status).toBe("complete");
	expect(state.runtime.active).toBe(true);
	const replacement = {
		...state.messages[0],
		metadata: {
			...original.metadata,
			usage: { tokens: 123 },
			summary: "Finished turn",
		},
	};
	state = reduceChat(state, {
		type: "chat.message",
		conversation_id: "c1",
		message_id: "m1",
		sequence: 3,
		message: replacement,
		runtime: { active: false, phase: "complete" },
	});
	expect(state.messages[0]).toEqual(replacement);
	const duplicate = reduceChat(state, {
		type: "chat.message",
		conversation_id: "c1",
		message_id: "m1",
		sequence: 3,
		message: original,
		runtime: { active: true },
	});
	expect(duplicate).toBe(state);
	state = reduceChat(state, {
		type: "chat.delta",
		conversation_id: "c1",
		message_id: "m1",
		sequence: 5,
		text: "lost",
		runtime: { active: true },
	});
	expect(state.needsSync).toBe(true);
	expect(state.runtime.active).toBe(false);
	state = reduceChat(state, {
		type: "chat.snapshot",
		conversation_id: "c1",
		messages: [replacement],
		sequences: { m1: 5 },
		metadata: { session: "s1" },
		runtime: { active: true, phase: "tool_execution" },
		admission: { canSubmit: true, allowWhileStreaming: true },
	});
	expect(state.needsSync).toBe(false);
	expect(state.sequences).toEqual({ m1: 5 });
	expect(state.runtime.phase).toBe("tool_execution");
	expect(state.admission.allowWhileStreaming).toBe(true);
	expect(state.messages[0].metadata.usage.tokens).toBe(123);
});
