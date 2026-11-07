export function sameChatScope(left, right) {
	return (
		typeof left?.conversationId === "string" &&
		left.conversationId.length > 0 &&
		typeof left.contextKey === "string" &&
		left.contextKey.length > 0 &&
		left.conversationId === right?.conversationId &&
		left.contextKey === right?.contextKey
	);
}

function revision(value) {
	return Number.isSafeInteger(value) && value >= 0;
}

function requestSync(state) {
	return state.needsSync ? state : { ...state, needsSync: true };
}

export function validChatQueue(queue, scope) {
	return (
		queue?.protocolVersion === 1 &&
		sameChatScope(queue.scope, scope) &&
		revision(queue.revision) &&
		Array.isArray(queue.items) &&
		queue.items.every(
			(item) => typeof item?.id === "string" && item.id.length > 0,
		) &&
		new Set(queue.items.map((item) => item.id)).size === queue.items.length
	);
}

function validProjection(composer, state) {
	if (!composer || !revision(composer.revision)) return false;
	const queue = composer.queue;
	if (queue == null) return state.composer?.queue == null;
	return (
		validChatQueue(queue, state.scope) &&
		queue.revision >= (state.composer?.queue?.revision ?? -1)
	);
}

// Each queue revision is immutable, independently of capabilities or runtime.
function nextProjection(composer, state) {
	if (
		state.composer?.queue &&
		composer.queue?.revision === state.composer.queue.revision
	) {
		return { ...composer, queue: state.composer.queue };
	}
	return composer;
}

export function initialState(conversationId, messages = [], application = {}) {
	return {
		conversationId,
		protocolVersion: application.protocolVersion ?? null,
		scope: application.scope ?? null,
		instanceGeneration: application.instanceGeneration ?? null,
		composer: application.composer ?? null,
		messages,
		metadata: application.metadata || {},
		runtime: application.runtime || {},
		admission: application.admission || {},
		sequences: {},
		error: null,
		needsSync: false,
	};
}

export function reduceChat(state, event) {
	if (event?.conversation_id !== state.conversationId) return state;
	const structured = state.protocolVersion === 1;
	if (
		structured &&
		(event.protocolVersion !== 1 ||
			!sameChatScope(state.scope, event.scope) ||
			state.scope.conversationId !== state.conversationId ||
			!revision(state.instanceGeneration) ||
			event.instanceGeneration !== state.instanceGeneration)
	)
		return state;
	if (["chat.snapshot", "chat.reset"].includes(event.type)) {
		if (structured && !revision(event.composer?.revision))
			return requestSync(state);
		const currentRevision = state.composer?.revision ?? -1;
		if (structured && event.composer.revision < currentRevision) return state;
		if (structured && !validProjection(event.composer, state))
			return requestSync(state);
		if (structured) {
			const sequences = event.sequences ?? {};
			if (
				typeof sequences !== "object" ||
				Array.isArray(sequences) ||
				!Object.values(sequences).every(revision)
			)
				return requestSync(state);
			// Transcript sequence counters and composer revisions are independent.
			// Only a new explicit reset may discard known counters.
			if (
				(event.type !== "chat.reset" ||
					event.composer.revision === currentRevision) &&
				Object.entries(state.sequences).some(
					([messageId, sequence]) => (sequences[messageId] ?? 0) < sequence,
				)
			)
				return state;
		}
		const unchanged = structured && event.composer.revision === currentRevision;
		return {
			...initialState(state.conversationId, event.messages || [], {
				...event,
				// Protocol mode and application identity can change only at the hook boundary.
				protocolVersion: state.protocolVersion,
				scope: state.scope,
				instanceGeneration: state.instanceGeneration,
				composer: structured
					? unchanged
						? state.composer
						: nextProjection(event.composer, state)
					: state.composer,
				...(unchanged
					? { runtime: state.runtime, admission: state.admission }
					: {}),
			}),
			sequences: event.sequences || {},
		};
	}
	if (event.type === "chat.composer-state") {
		if (!structured || state.needsSync) return state;
		if (!revision(event.composer?.revision)) return requestSync(state);
		const currentRevision = state.composer?.revision ?? -1;
		if (event.composer.revision <= currentRevision) return state;
		if (
			(event.previousRevision !== undefined &&
				(!revision(event.previousRevision) ||
					event.previousRevision !== currentRevision)) ||
			!validProjection(event.composer, state)
		)
			return requestSync(state);
		return {
			...state,
			composer: nextProjection(event.composer, state),
			metadata: event.metadata ?? state.metadata,
			runtime: event.runtime ?? state.runtime,
			admission: event.admission ?? state.admission,
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
	if (event.sequence !== last + 1) return requestSync(state);
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
		if (index < 0) return requestSync(state);
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
		metadata: event.metadata ?? state.metadata,
		runtime: structured ? state.runtime : (event.runtime ?? state.runtime),
		admission: structured
			? state.admission
			: (event.admission ?? state.admission),
		sequences: { ...state.sequences, [event.message_id]: event.sequence },
	};
}
