import {
	ComposerUncertainTransportError,
	snapshotComposerReceipt,
	snapshotComposerSubmission,
} from "@duskmoon-dev/components/chat";

export function requestId() {
	if (typeof crypto.randomUUID === "function") return crypto.randomUUID();
	const bytes = crypto.getRandomValues(new Uint8Array(16));
	bytes[6] = (bytes[6] & 0x0f) | 0x40;
	bytes[8] = (bytes[8] & 0x3f) | 0x80;
	const hex = Array.from(bytes, (byte) => byte.toString(16).padStart(2, "0"));
	return [
		hex.slice(0, 4),
		hex.slice(4, 6),
		hex.slice(6, 8),
		hex.slice(8, 10),
		hex.slice(10),
	]
		.map((part) => part.join(""))
		.join("-");
}

// Compatible with the upstream session controller's uncertain-transport boundary.
export class ChatTransportError extends ComposerUncertainTransportError {
	constructor(message, correlation, cause) {
		super(message, { cause });
		this.name = "ChatTransportError";
		this.outcome = "unknown";
		Object.assign(this, correlation);
	}
}

export function unknownReceipt(snapshot, error) {
	return Object.freeze({
		protocolVersion: 1,
		clientSubmissionId: snapshot.clientSubmissionId,
		scope: snapshot.scope,
		operation: snapshot.operation,
		outcome: "unknown",
		error: {
			code: error.code || "uncertain_transport",
			message: error.message,
			...(error.request_id
				? {
						details: {
							request_id: error.request_id,
							instanceGeneration: error.instanceGeneration,
						},
					}
				: {}),
		},
	});
}

// Reject binary handles before any JSON serialization, including the legacy path.
export function assertChatJSON(value, ancestors = new Set()) {
	if (value == null || ["string", "boolean"].includes(typeof value)) return;
	if (typeof value === "number" && Number.isFinite(value)) return;
	if (typeof value !== "object" || ancestors.has(value))
		throw new TypeError("Chat payload must contain portable JSON only");
	if (
		!Array.isArray(value) &&
		Object.getPrototypeOf(value) !== Object.prototype &&
		Object.getPrototypeOf(value) !== null
	)
		throw new TypeError(
			"Upload File/Blob objects through an application adapter before submitting JSON",
		);
	ancestors.add(value);
	for (const item of Object.values(value)) assertChatJSON(item, ancestors);
	ancestors.delete(value);
}

export function submissionSnapshot(payload, state) {
	if (state.protocolVersion !== 1)
		throw new TypeError("Structured composer protocol is not enabled");
	const { request_id, ...submission } = payload;
	assertChatJSON(submission);
	const snapshot = snapshotComposerSubmission(submission);
	if (
		snapshot.scope.contextKey !== state.scope.contextKey ||
		snapshot.scope.conversationId !== state.scope.conversationId
	)
		throw new TypeError("Submission scope does not match this chat instance");
	return snapshot;
}

export function structuredSnapshot(payload, state) {
	const snapshot = submissionSnapshot(payload, state);
	const caps = state.composer?.capabilities;
	if (
		caps?.protocolVersion !== 1 ||
		!caps.documentVersions?.includes(snapshot.document.schemaVersion)
	)
		throw new TypeError("Unsupported composer document version");
	if (
		snapshot.operation === "command"
			? caps.commands !== true
			: !caps.intents?.includes(snapshot.intent)
	)
		throw new TypeError("Unsupported composer operation or intent");
	if (snapshot.attachments.length && caps.attachments !== true)
		throw new TypeError("Attachments are not supported by this application");
	return snapshot;
}

export function chatJSONKey(value) {
	if (Array.isArray(value)) return `[${value.map(chatJSONKey).join(",")}]`;
	if (value && typeof value === "object")
		return `{${Object.keys(value)
			.sort()
			.map((key) => `${JSON.stringify(key)}:${chatJSONKey(value[key])}`)
			.join(",")}}`;
	return JSON.stringify(value);
}

export function correlatedReceipt(response, snapshot, correlation) {
	if (
		response?.request_id !== correlation.request_id ||
		response?.instanceGeneration !== correlation.instanceGeneration
	)
		throw new TypeError("Chat response correlation mismatch");
	return snapshotComposerReceipt(response.receipt, snapshot);
}
