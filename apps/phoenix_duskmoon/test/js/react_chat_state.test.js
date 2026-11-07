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

const structuredScope = { conversationId: "c1", contextKey: "repo:alpha" };
const queue = (revision, items = []) => ({
	protocolVersion: 1,
	scope: structuredScope,
	revision,
	items: items.map((id) => ({
		id,
		document: { schemaVersion: 1, content: [] },
	})),
});
const composer = (revision, queueRevision = revision, items = []) => ({
	revision,
	capabilities: { protocolVersion: 1, intents: ["send"] },
	providers: [{ providerId: "files", label: "Files" }],
	options: { model: "fixture" },
	queue: queue(queueRevision, items),
});
const structuredEvent = (fields = {}) => ({
	conversation_id: "c1",
	protocolVersion: 1,
	scope: structuredScope,
	instanceGeneration: 1,
	...fields,
});
const structuredState = () =>
	initialState(
		"c1",
		[{ id: "m1", role: "assistant", status: "streaming", content: "Hello" }],
		{
			protocolVersion: 1,
			scope: structuredScope,
			instanceGeneration: 1,
			composer: composer(2, 4, ["q1"]),
			runtime: { active: true, phase: "cancelling" },
			admission: { allowWhileStreaming: true },
		},
	);

describe("revisioned composer projection", () => {
	test("replaces queue and capabilities independently of the transcript sequence", () => {
		const state = structuredState();
		const projection = composer(7, 5, ["q2"]);
		projection.capabilities = {
			protocolVersion: 1,
			intents: ["send", "follow_up"],
		};
		const next = reduceChat(
			state,
			structuredEvent({
				type: "chat.composer-state",
				composer: projection,
				runtime: { active: false, phase: "idle" },
				admission: { canSubmit: true },
			}),
		);
		expect(next.composer).toEqual(projection);
		expect(next.messages).toBe(state.messages);
		expect(next.sequences).toBe(state.sequences);
		expect(next.runtime).toEqual({ active: false, phase: "idle" });
		expect(next.admission).toEqual({ canSubmit: true });
		expect(next.needsSync).toBe(false);
	});

	test("duplicate and late projections cannot revive removed queue items", () => {
		const removed = reduceChat(
			structuredState(),
			structuredEvent({
				type: "chat.composer-state",
				composer: composer(3, 5),
			}),
		);
		for (const revision of [2, 3]) {
			expect(
				reduceChat(
					removed,
					structuredEvent({
						type: "chat.composer-state",
						composer: composer(revision, 4, ["q1"]),
						runtime: { active: true },
					}),
				),
			).toBe(removed);
		}
		expect(removed.composer.queue.items).toEqual([]);
	});

	test("late snapshots are ignored without triggering another synchronization", () => {
		const state = structuredState();
		const next = reduceChat(
			state,
			structuredEvent({
				type: "chat.snapshot",
				composer: composer(1, 3, ["old"]),
				messages: [],
			}),
		);
		expect(next).toBe(state);
	});

	test("snapshot message sequences cannot regress while composer revisions stay equal or advance", () => {
		const state = { ...structuredState(), sequences: { m1: 2 } };
		for (const revision of [2, 3]) {
			for (const sequences of [{ m1: 1 }, {}]) {
				const next = reduceChat(
					state,
					structuredEvent({
						type: "chat.snapshot",
						composer: composer(revision, 4),
						messages: [{ id: "m1", content: "Stale transcript" }],
						sequences,
					}),
				);
				expect(next).toBe(state);
			}
		}
		const synchronizing = { ...state, needsSync: true };
		expect(
			reduceChat(
				synchronizing,
				structuredEvent({
					type: "chat.snapshot",
					composer: composer(2, 4),
					messages: [{ id: "m1", content: "Stale transcript" }],
					sequences: { m1: 1 },
				}),
			),
		).toBe(synchronizing);
		const next = reduceChat(
			synchronizing,
			structuredEvent({
				type: "chat.snapshot",
				composer: composer(2, 4),
				messages: [{ id: "m1", content: "Authoritative transcript" }],
				sequences: { m1: 3 },
			}),
		);
		expect(next.needsSync).toBe(false);
		expect(next.sequences).toEqual({ m1: 3 });
		expect(next.messages[0].content).toBe("Authoritative transcript");
	});

	test("sequence reset requires a new explicit reset revision", () => {
		const state = { ...structuredState(), sequences: { m1: 2 } };
		expect(
			reduceChat(
				state,
				structuredEvent({
					type: "chat.reset",
					composer: composer(2, 4),
					messages: [],
					sequences: {},
				}),
			),
		).toBe(state);
		const reset = reduceChat(
			state,
			structuredEvent({
				type: "chat.reset",
				composer: composer(3, 4),
				messages: [],
				sequences: {},
			}),
		);
		expect(reset.messages).toEqual([]);
		expect(reset.sequences).toEqual({});
		expect(reset.composer.revision).toBe(3);
	});

	test("malformed snapshot sequence counters cannot poison stream ordering", () => {
		const state = structuredState();
		for (const sequences of [{ m1: -1 }, { m1: 1.5 }, { m1: "2" }, []]) {
			const next = reduceChat(
				state,
				structuredEvent({
					type: "chat.snapshot",
					composer: composer(3, 5),
					messages: [],
					sequences,
				}),
			);
			expect(next.needsSync).toBe(true);
			expect(next.messages).toBe(state.messages);
			expect(next.composer).toBe(state.composer);
		}
	});

	test("ordered projection gaps freeze reduction until one authoritative snapshot", () => {
		const original = structuredState();
		let state = reduceChat(
			original,
			structuredEvent({
				type: "chat.composer-state",
				previousRevision: 3,
				composer: composer(4, 5),
			}),
		);
		expect(state.needsSync).toBe(true);
		expect(state.composer).toBe(original.composer);
		const frozen = state;
		state = reduceChat(
			state,
			structuredEvent({
				type: "chat.composer-state",
				previousRevision: 2,
				composer: composer(3, 5),
			}),
		);
		expect(state).toBe(frozen);
		state = reduceChat(
			state,
			structuredEvent({
				type: "chat.snapshot",
				composer: composer(4, 6),
				messages: [{ id: "restored", content: "Snapshot" }],
				sequences: { restored: 9 },
				runtime: { active: true, phase: "running" },
				admission: { canSubmit: true },
			}),
		);
		expect(state.needsSync).toBe(false);
		expect(state.composer.revision).toBe(4);
		expect(state.composer.queue.revision).toBe(6);
		expect(state.messages).toEqual([{ id: "restored", content: "Snapshot" }]);
		expect(state.sequences).toEqual({ restored: 9 });
	});

	test("ordered updates accept matching previousRevision and reject malformed revisions", () => {
		const original = structuredState();
		const next = reduceChat(
			original,
			structuredEvent({
				type: "chat.composer-state",
				previousRevision: 2,
				composer: composer(3, 5),
			}),
		);
		expect(next.composer.revision).toBe(3);
		for (const revision of [-1, 1.5, "3", Number.MAX_SAFE_INTEGER + 1]) {
			const invalid = reduceChat(
				original,
				structuredEvent({
					type: "chat.composer-state",
					composer: composer(revision),
				}),
			);
			expect(invalid.needsSync).toBe(true);
			expect(invalid.composer).toBe(original.composer);
		}
		for (const previousRevision of [null, -1, 2.5, "2"]) {
			const invalid = reduceChat(
				original,
				structuredEvent({
					type: "chat.composer-state",
					previousRevision,
					composer: composer(3, 5),
				}),
			);
			expect(invalid.needsSync).toBe(true);
			expect(invalid.composer).toBe(original.composer);
		}
	});

	test("scopes and mount generations fence every event, including context changes in one conversation", () => {
		const state = structuredState();
		for (const override of [
			{ scope: { ...structuredScope, contextKey: "repo:beta" } },
			{ scope: { ...structuredScope, conversationId: "c2" } },
			{ instanceGeneration: 2 },
			{ instanceGeneration: undefined },
			{ protocolVersion: 2 },
			{ scope: undefined },
		]) {
			for (const payload of [
				{ type: "chat.composer-state", composer: composer(3, 5) },
				{ type: "chat.snapshot", composer: composer(3, 5), messages: [] },
				{ type: "chat.delta", message_id: "m1", sequence: 1, text: " unsafe" },
			]) {
				expect(
					reduceChat(state, structuredEvent({ ...payload, ...override })),
				).toBe(state);
			}
		}
	});

	test("queue regression and malformed queue membership request sync without changing confirmed state", () => {
		const state = structuredState();
		for (const projection of [
			composer(3, 3, ["removed"]),
			{ ...composer(3), queue: undefined },
			{ ...composer(3), queue: { ...queue(5), revision: "5" } },
			{
				...composer(3),
				queue: {
					...queue(5),
					scope: { ...structuredScope, contextKey: "elsewhere" },
				},
			},
			composer(3, 5, ["q1", "q1"]),
		]) {
			const next = reduceChat(
				state,
				structuredEvent({ type: "chat.composer-state", composer: projection }),
			);
			expect(next.needsSync).toBe(true);
			expect(next.composer).toBe(state.composer);
		}
	});

	test("snapshots are atomic, cannot regress projections, and require the structured projection", () => {
		const state = { ...structuredState(), needsSync: true };
		for (const projection of [
			undefined,
			null,
			composer(1, 5),
			composer(3, 3),
		]) {
			const next = reduceChat(
				state,
				structuredEvent({
					type: "chat.snapshot",
					composer: projection,
					messages: [{ id: "stale" }],
					runtime: { active: false },
				}),
			);
			expect(next.messages).toBe(state.messages);
			expect(next.composer).toBe(state.composer);
			expect(next.runtime).toBe(state.runtime);
			expect(next.needsSync).toBe(true);
		}
		const restored = reduceChat(
			state,
			structuredEvent({
				type: "chat.snapshot",
				composer: composer(2, 4, ["bad-same-revision"]),
				messages: [{ id: "restored" }],
				sequences: { restored: 3 },
				runtime: { active: false },
				admission: { canSubmit: false },
			}),
		);
		expect(restored.needsSync).toBe(false);
		expect(restored.messages).toEqual([{ id: "restored" }]);
		expect(restored.composer).toBe(state.composer);
		expect(restored.runtime).toBe(state.runtime);
		expect(restored.admission).toBe(state.admission);
	});

	test("an unchanged queue revision cannot revive or replace confirmed membership", () => {
		const state = structuredState();
		const next = reduceChat(
			state,
			structuredEvent({
				type: "chat.composer-state",
				composer: composer(3, 4, ["bad-same-revision"]),
			}),
		);
		expect(next.composer.revision).toBe(3);
		expect(next.composer.queue).toBe(state.composer.queue);
	});

	test("stream messages retain metadata but cannot overwrite structured application projection", () => {
		const state = structuredState();
		const next = reduceChat(
			state,
			structuredEvent({
				type: "chat.complete",
				message_id: "m1",
				sequence: 1,
				runtime: { active: false },
				admission: { canSubmit: false },
				composer: composer(50, 50),
				metadata: { usage: 12 },
			}),
		);
		expect(next.messages[0].status).toBe("complete");
		expect(next.metadata).toEqual({ usage: 12 });
		expect(next.runtime).toBe(state.runtime);
		expect(next.admission).toBe(state.admission);
		expect(next.composer).toBe(state.composer);
	});

	test("an initial empty projection accepts revision zero and Stop never changes runtime", () => {
		const initial = initialState("c1", [], {
			protocolVersion: 1,
			scope: structuredScope,
			instanceGeneration: 1,
			runtime: { active: true, phase: "running" },
		});
		expect(initial.composer).toBeNull();
		const next = reduceChat(
			initial,
			structuredEvent({
				type: "chat.composer-state",
				composer: composer(0, 0),
			}),
		);
		expect(next.composer.revision).toBe(0);
		expect(next.runtime).toBe(initial.runtime);
		expect(
			reduceChat(
				next,
				structuredEvent({
					type: "chat.stop",
					runtime: { active: false },
				}),
			),
		).toBe(next);
	});

	test("legacy mounts never opt into a structured protocol through a server event", () => {
		const state = initialState("c1");
		const projected = reduceChat(
			state,
			structuredEvent({
				type: "chat.composer-state",
				composer: composer(1),
			}),
		);
		expect(projected).toBe(state);
		const snapshot = reduceChat(
			state,
			structuredEvent({
				type: "chat.snapshot",
				composer: composer(1),
				messages: [{ id: "legacy" }],
			}),
		);
		expect(snapshot.protocolVersion).toBe(state.protocolVersion);
		expect(snapshot.messages).toEqual([{ id: "legacy" }]);
	});
});
