import React from "react";
import { createRoot } from "react-dom/client";
import {
	snapshotComposerDocument,
	snapshotComposerReceipt,
} from "@duskmoon-dev/components/chat";
import { ReactChat } from "./chat.js";
import {
	initialState,
	reduceChat,
	sameChatScope,
	validChatQueue,
} from "./state.js";
import {
	assertChatJSON,
	ChatTransportError,
	correlatedReceipt,
	requestId,
	structuredSnapshot,
	submissionSnapshot,
	unknownReceipt,
	chatJSONKey,
} from "./protocol.js";

export { ReactChat, useChatSubmission } from "./chat.js";
export { initialState, reduceChat } from "./state.js";
export { ChatTransportError } from "./protocol.js";

let nextGeneration = 0;

export function createDuskmoonReactChat(options = {}) {
	return {
		mounted() {
			this.connected = true;
			this.requests = new Set();
			this.recoveryFailures = new Map();
			this.bindContext(JSON.parse(this.el.dataset.chat));
			this.root = createRoot(this.el);
			this.eventRef = this.handleEvent(this.config.event, (event) => {
				if (event.id !== this.el.id) return;
				if (
					["chat.snapshot", "chat.reset"].includes(event.type) &&
					event.conversation_id === this.state.conversationId &&
					event.protocolVersion === 1 &&
					sameChatScope(event.scope, this.state.scope) &&
					event.instanceGeneration === this.state.instanceGeneration
				)
					this.reconcileReceipts(event.receipts);
				const previous = this.state;
				this.state = reduceChat(this.state, event);
				if (previous === this.state) return;
				if (this.state.needsSync && !previous.needsSync) this.requestSync();
				this.scheduleRender();
			});
			this.renderChat();
		},
		bindContext(config) {
			if (config.protocolVersion != null && config.protocolVersion !== 1)
				throw new TypeError("Unsupported chat protocol version");
			const generation = ++nextGeneration;
			if (
				config.protocolVersion === 1 &&
				(!config.scope?.contextKey ||
					config.scope.conversationId !== config.conversationId)
			)
				throw new TypeError(
					"Structured chat requires an application context key and matching conversation",
				);
			this.config = config;
			this.state = initialState(config.conversationId, config.messages, {
				...config,
				instanceGeneration: generation,
			});
			this.adapter =
				options.adapter?.({
					scope: this.state.scope,
					instanceGeneration: generation,
					config,
					element: this.el,
				}) || {};
			this.submissionPending = false;
			this.syncPending = null;
			const current = () => {
				if (this.dead || generation !== this.state.instanceGeneration)
					throw new Error("Chat context has changed");
			};
			this.bridge = {
				send: (action, payload) => {
					try {
						current();
						return this.sendChat(action, payload);
					} catch (error) {
						return Promise.reject(error);
					}
				},
				submit: async (snapshot, signal) => {
					current();
					return this.submitStructured(snapshot, signal);
				},
				reconcile: async (snapshot, signal) => {
					current();
					return this.reconcileSubmission(snapshot, signal);
				},
				mutateQueue: async (mutation, signal) => {
					current();
					return this.mutateQueue(mutation, signal);
				},
				getRecoveryFailures: () => [...this.recoveryFailures.values()],
			};
		},
		// Explicit host operation. Mutating data-chat alone never changes ownership.
		switchContext(config) {
			if (config.event !== this.config.event)
				throw new TypeError("Remount the hook to change its event channel");
			this.requests.forEach((request) => request.cancel());
			this.bindContext(config);
			this.renderChat();
		},
		checkAction(action) {
			if (
				typeof this.config.actions?.[action] !== "string" ||
				!this.config.actions[action].trim()
			)
				throw new TypeError(`Chat action is not configured: ${action}`);
			if (!this.connected || this.dead) throw new Error("Chat is disconnected");
			if (action === "send" && this.state.needsSync)
				throw new Error("Chat is synchronizing");
			if (this.requests.size >= (options.maxPendingRequests ?? 64))
				throw new Error(
					"Chat transport capacity reached; reconcile pending requests",
				);
		},
		sendChat(action, payload = {}) {
			if (
				action === "send" &&
				(payload.protocolVersion !== undefined ||
					payload.document !== undefined)
			)
				return this.submitStructured(payload);
			return this.transport(action, payload);
		},
		transport(action, payload, structured) {
			try {
				this.checkAction(action);
				assertChatJSON(payload);
			} catch (error) {
				return Promise.reject(error);
			}
			const generation = this.state.instanceGeneration;
			const scope = this.state.scope;
			const correlation = {
				request_id: payload.request_id ?? requestId(),
				instanceGeneration: generation,
				scope,
				clientSubmissionId: structured?.snapshot?.clientSubmissionId,
			};
			if (
				typeof correlation.request_id !== "string" ||
				!correlation.request_id ||
				[...this.requests].some((r) => r.id === correlation.request_id)
			)
				return Promise.reject(
					new TypeError("Chat request_id must be unique while pending"),
				);
			const body = {
				...payload,
				request_id: correlation.request_id,
				id: this.el.id,
				conversation_id: this.state.conversationId,
				...(this.state.protocolVersion === 1
					? { protocolVersion: 1, scope, instanceGeneration: generation }
					: {}),
			};
			return new Promise((resolve, reject) => {
				const uncertain = (message, cause) =>
					new ChatTransportError(
						message,
						{ ...correlation, dispatched: true },
						cause,
					);
				const finish = (error, reply) => {
					if (!this.requests.delete(request)) return;
					clearTimeout(request.timer);
					structured?.signal?.removeEventListener("abort", request.cancel);
					error ? reject(error) : resolve(reply);
				};
				const request = {
					id: correlation.request_id,
					cancel: () =>
						finish(
							uncertain("Chat disconnected; check status before retrying"),
						),
				};
				if (structured?.signal?.aborted) {
					reject(new Error("Chat request aborted before dispatch"));
					return;
				}
				this.requests.add(request);
				structured?.signal?.addEventListener("abort", request.cancel, {
					once: true,
				});
				request.timer = setTimeout(
					() =>
						finish(
							uncertain("Chat request timed out; check status before retrying"),
						),
					options.requestTimeoutMs ?? 15000,
				);
				const reply = (response) => {
					try {
						if (structured) {
							const receipt = structured.validate(response, correlation);
							structured.onReceipt?.(receipt);
							// A late receipt resolves its original recovery record only.
							if (generation !== this.state.instanceGeneration || this.dead) {
								finish(uncertain("Chat context has changed"));
								return;
							}
							finish(null, receipt);
						} else if (response?.status === "ok") finish(null, response);
						else if (response?.status === "error") {
							const error = new Error(
								response.message || "Chat request rejected",
							);
							error.response = response;
							finish(error);
						} else
							finish(uncertain("Missing or malformed chat acknowledgement"));
					} catch (error) {
						finish(
							uncertain(
								"Invalid chat acknowledgement; check status before retrying",
								error,
							),
						);
					}
				};
				try {
					const event = this.config.actions[action];
					const target = this.config.target || this.el.dataset.target;
					if (target) this.pushEventTo(target, event, body, reply);
					else this.pushEvent(event, body, reply);
				} catch (error) {
					finish(uncertain("Chat dispatch outcome is unknown", error));
				}
			});
		},
		retain(adapter, attempt) {
			try {
				adapter.recovery.retain(attempt);
				this.recoveryFailures.delete(attempt.snapshot.clientSubmissionId);
			} catch (error) {
				this.recoveryFailures.set(attempt.snapshot.clientSubmissionId, {
					attempt,
					error,
				});
				throw error;
			}
		},
		async submitStructured(payload, signal) {
			if (signal?.aborted)
				throw new Error("Chat request aborted before dispatch");
			this.checkAction("send");
			if (this.submissionPending)
				throw new Error("Chat is not accepting messages");
			const snapshot = structuredSnapshot(payload, this.state);
			const adapter = this.adapter;
			if (!adapter.recovery?.retain || !adapter.recovery?.getSnapshot)
				throw new TypeError(
					"Structured submissions require an application recovery owner",
				);
			const generation = this.state.instanceGeneration;
			const previous = adapter.recovery
				.getSnapshot()
				.find(
					(a) => a.snapshot.clientSubmissionId === snapshot.clientSubmissionId,
				);
			if (previous && chatJSONKey(previous.snapshot) !== chatJSONKey(snapshot))
				throw new TypeError(
					"A logical submission ID cannot change its payload",
				);
			if (previous?.status === "accepted" || previous?.status === "rejected")
				return previous.receipt;
			const physicalId = payload.request_id ?? requestId();
			const attempt = {
				snapshot,
				instanceId: this.el.id,
				instanceGeneration: generation,
				createdAt: previous?.createdAt ?? Date.now(),
				status: "pending",
				requestIds: [...(previous?.requestIds || []), physicalId],
			};
			this.submissionPending = true;
			try {
				// The upstream controller may already have retained this first attempt.
				if (
					previous &&
					(previous.status === "unknown" || previous.requestIds?.length) &&
					(await adapter.authorizeRetry?.(previous)) !== true
				)
					throw new Error(
						"Explicit application authorization is required to retry an unresolved submission",
					);
				// Handoff is synchronous and must succeed before dispatch becomes possible.
				this.retain(adapter, attempt);
				if (generation !== this.state.instanceGeneration || this.dead)
					throw new Error("Chat context has changed");
				return await this.transport(
					"send",
					{ ...snapshot, request_id: physicalId },
					{
						snapshot,
						signal,
						validate: (response, correlation) =>
							correlatedReceipt(response, snapshot, correlation),
						onReceipt: (receipt) =>
							this.retain(adapter, {
								...attempt,
								status: receipt.outcome,
								receipt,
							}),
					},
				);
			} catch (error) {
				if (!(error instanceof ChatTransportError)) throw error;
				const receipt = unknownReceipt(snapshot, error);
				this.retain(adapter, { ...attempt, status: "unknown", receipt });
				return receipt;
			} finally {
				if (generation === this.state.instanceGeneration)
					this.submissionPending = false;
			}
		},
		async reconcileSubmission(payload, signal) {
			const snapshot = submissionSnapshot(payload, this.state);
			const adapter = this.adapter;
			const attempt = adapter.recovery
				?.getSnapshot()
				.find(
					(a) => a.snapshot.clientSubmissionId === snapshot.clientSubmissionId,
				);
			if (!attempt || chatJSONKey(attempt.snapshot) !== chatJSONKey(snapshot))
				throw new Error("No matching scoped recovery record for submission");
			try {
				return await this.transport(
					"reconcile",
					{
						clientSubmissionId: snapshot.clientSubmissionId,
						operation: snapshot.operation,
					},
					{
						snapshot,
						signal,
						validate: (response, correlation) =>
							correlatedReceipt(response, snapshot, correlation),
						onReceipt: (receipt) =>
							this.retain(adapter, {
								...attempt,
								status: receipt.outcome,
								receipt,
							}),
					},
				);
			} catch (error) {
				if (!(error instanceof ChatTransportError)) throw error;
				const receipt = unknownReceipt(snapshot, error);
				this.retain(adapter, { ...attempt, status: "unknown", receipt });
				return receipt;
			}
		},
		async mutateQueue(mutation, signal) {
			assertChatJSON(mutation);
			if (
				!["edit", "remove", "promote"].includes(mutation.operation) ||
				!mutation.requestId
			)
				throw new TypeError("Unsupported queue operation");
			const { composer, scope } = this.state;
			const item = composer?.queue?.items.find(
				(item) => item.id === mutation.itemId,
			);
			const capability = composer?.capabilities?.queue?.[mutation.operation];
			const itemCapability = item?.capabilities?.[mutation.operation];
			if (
				!sameChatScope(mutation.scope, scope) ||
				!item ||
				!capability ||
				capability === "none" ||
				!itemCapability ||
				itemCapability === "none"
			)
				throw new TypeError("Unsupported queue operation or item");
			if (mutation.expectedRevision !== composer.queue.revision)
				throw new TypeError("Queue revision has changed");
			if (mutation.operation === "promote" && !mutation.targetTurnId)
				throw new TypeError("Promotion requires a target turn");
			if (mutation.operation === "edit")
				snapshotComposerDocument(mutation.document);
			if (
				mutation.operation === "edit" &&
				(!mutation.document ||
					([capability, itemCapability].includes("text") &&
						(mutation.document.command ||
							mutation.document.content?.some((node) => node.type !== "text"))))
			)
				throw new TypeError("Queue editing supports text documents only");
			const generation = this.state.instanceGeneration;
			return this.transport(`queue_${mutation.operation}`, mutation, {
				signal,
				validate: (response, correlation) => {
					const result = response?.result;
					assertChatJSON(result);
					if (
						response?.request_id !== correlation.request_id ||
						response?.instanceGeneration !== generation ||
						result?.requestId !== mutation.requestId ||
						!["accepted", "rejected"].includes(result.outcome) ||
						!validChatQueue(result.projection, scope) ||
						(result.outcome === "rejected" && !result.error?.code)
					)
						throw new TypeError("Queue response correlation mismatch");
					return result;
				},
				onReceipt: (result) => {
					if (this.dead || generation !== this.state.instanceGeneration) return;
					const projection = result.projection;
					if (
						Number.isSafeInteger(projection.revision) &&
						projection.revision > this.state.composer.queue.revision &&
						Array.isArray(projection.items)
					) {
						this.state = {
							...this.state,
							composer: { ...this.state.composer, queue: projection },
						};
						this.scheduleRender();
					}
				},
			});
		},
		reconcileReceipts(receipts = []) {
			if (!this.adapter.reconcileOnSync || !this.adapter.recovery) return;
			if (!Array.isArray(receipts)) receipts = [];
			for (const attempt of this.adapter.recovery.getSnapshot()) {
				if (
					!sameChatScope(attempt.snapshot.scope, this.state.scope) ||
					!["pending", "unknown"].includes(attempt.status)
				)
					continue;
				const input = receipts.find(
					(r) => r.clientSubmissionId === attempt.snapshot.clientSubmissionId,
				);
				let receipt;
				try {
					receipt = input
						? snapshotComposerReceipt(input, attempt.snapshot)
						: unknownReceipt(
								attempt.snapshot,
								new Error("No authoritative receipt in snapshot"),
							);
				} catch (error) {
					receipt = unknownReceipt(attempt.snapshot, error);
				}
				this.retain(this.adapter, {
					...attempt,
					status: receipt.outcome,
					receipt,
				});
			}
		},
		requestSync() {
			if (this.syncPending) return this.syncPending;
			const generation = this.state.instanceGeneration;
			const payload = { sequences: this.state.sequences };
			if (this.adapter.reconcileOnSync && this.adapter.recovery)
				payload.unresolvedSubmissionIds = this.adapter.recovery
					.getSnapshot()
					.filter(
						(a) =>
							sameChatScope(a.snapshot.scope, this.state.scope) &&
							["pending", "unknown"].includes(a.status),
					)
					.map((a) => a.snapshot.clientSubmissionId);
			const pending = this.sendChat("sync", payload)
				.catch((error) => {
					if (
						!this.dead &&
						generation === this.state.instanceGeneration &&
						this.syncPending === pending
					) {
						this.state = { ...this.state, error: error.message };
						this.scheduleRender();
					}
				})
				.finally(() => {
					if (this.syncPending === pending) this.syncPending = null;
				});
			this.syncPending = pending;
			return pending;
		},
		scheduleRender() {
			if (!this.frame)
				this.frame = requestAnimationFrame(() => {
					this.frame = null;
					if (!this.dead) this.renderChat();
				});
		},
		renderChat() {
			this.root.render(
				React.createElement(ReactChat, {
					state: this.state,
					bridge: this.bridge,
					connected: this.connected,
					label: this.config.label,
					options,
					adapter: this.adapter,
				}),
			);
		},
		disconnected() {
			this.connected = false;
			this.requests.forEach((request) => request.cancel());
			this.syncPending = null;
			this.renderChat();
		},
		reconnected() {
			this.connected = true;
			this.state = { ...this.state, needsSync: true };
			this.renderChat();
			this.requestSync();
		},
		destroyed() {
			this.dead = true;
			cancelAnimationFrame(this.frame);
			this.removeHandleEvent(this.eventRef);
			this.requests.forEach((request) => request.cancel());
			this.root.unmount();
		},
	};
}

export const DuskmoonReactChat = createDuskmoonReactChat();
