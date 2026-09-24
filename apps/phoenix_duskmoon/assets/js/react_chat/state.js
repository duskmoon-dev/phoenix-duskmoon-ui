export function initialState(conversationId, messages = []) {
	return {
		conversationId,
		messages,
		sequences: {},
		error: null,
		needsSync: false,
	};
}

export function reduceChat(state, event) {
	if (event?.conversation_id !== state.conversationId) return state;
	if (["chat.snapshot", "chat.reset"].includes(event.type)) {
		return {
			...initialState(state.conversationId, event.messages || []),
			sequences: event.sequences || {},
		};
	}
	if (
		!event.message_id ||
		!Number.isSafeInteger(event.sequence) ||
		event.sequence < 1
	)
		return state;
	const last = state.sequences[event.message_id] || 0;
	if (event.sequence <= last) return state;
	if (event.sequence !== last + 1) return { ...state, needsSync: true };
	if (state.needsSync) return state;
	const index = state.messages.findIndex(
		(message) => message.id === event.message_id,
	);
	let messages = state.messages;
	if (event.type === "chat.message") {
		if (!event.message || event.message.id !== event.message_id) return state;
		messages =
			index < 0
				? [...messages, event.message]
				: messages.map((m, i) => (i === index ? event.message : m));
	} else {
		if (index < 0) return { ...state, needsSync: true };
		const message = messages[index];
		let next;
		switch (event.type) {
			case "chat.delta":
				if (message.status !== "streaming" || typeof event.text !== "string")
					return state;
				next = { ...message, content: (message.content || "") + event.text };
				break;
			case "chat.tool":
				if (!event.tool?.id) return state;
				next = {
					...message,
					tools: [
						...(message.tools || []).filter(
							(tool) => tool.id !== event.tool.id,
						),
						event.tool,
					],
				};
				break;
			case "chat.complete":
				next = {
					...message,
					status: event.status === "cancelled" ? "cancelled" : "complete",
				};
				break;
			case "chat.error":
				next = {
					...message,
					status: "error",
					error: event.message || "Generation failed",
				};
				break;
			default:
				return state;
		}
		messages = messages.map((m, i) => (i === index ? next : m));
	}
	return {
		...state,
		messages,
		sequences: { ...state.sequences, [event.message_id]: event.sequence },
	};
}
