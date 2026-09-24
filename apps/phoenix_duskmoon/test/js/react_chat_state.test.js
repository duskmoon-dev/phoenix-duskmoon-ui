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
