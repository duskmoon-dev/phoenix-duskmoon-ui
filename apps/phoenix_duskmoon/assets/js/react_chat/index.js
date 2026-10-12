import React from "react";
import { createRoot } from "react-dom/client";
import { ReactChat } from "./chat.js";
import { initialState, reduceChat } from "./state.js";

export { ReactChat, useChatSubmission } from "./chat.js";
export { initialState, reduceChat } from "./state.js";

export function createDuskmoonReactChat(options = {}) {
	return {
		mounted() {
			this.config = JSON.parse(this.el.dataset.chat);
			this.state = initialState(
				this.config.conversationId,
				this.config.messages,
				this.config,
			);
			this.root = createRoot(this.el);
			this.connected = true;
			this.requests = new Set();
			this.bridge = {
				send: (action, payload) => this.sendChat(action, payload),
			};
			this.eventRef = this.handleEvent(this.config.event, (event) => {
				if (event.id !== this.el.id) return;
				const previous = this.state;
				this.state = reduceChat(this.state, event);
				if (previous === this.state) return;
				if (this.state.needsSync && !previous.needsSync) this.requestSync();
				this.scheduleRender();
			});
			this.renderChat();
		},
		sendChat(action, payload) {
			if (!this.connected || this.dead)
				return Promise.reject(new Error("Chat is disconnected"));
			if (action === "send" && this.state.needsSync)
				return Promise.reject(new Error("Chat is synchronizing"));
			return new Promise((resolve, reject) => {
				const finish = (error, reply) => {
					if (!this.requests.delete(request)) return;
					clearTimeout(request.timer);
					error ? reject(error) : resolve(reply);
				};
				const request = {
					cancel: () =>
						finish(
							new Error("Chat disconnected; check status before retrying"),
						),
				};
				this.requests.add(request);
				request.timer = setTimeout(
					() =>
						finish(
							new Error("Chat request timed out; check status before retrying"),
						),
					15000,
				);
				const body = {
					...payload,
					id: this.el.id,
					conversation_id: this.state.conversationId,
				};
				const reply = (response) => {
					const error =
						response?.status === "ok"
							? null
							: new Error(response?.message || "Chat request rejected");
					if (error) error.response = response;
					finish(error, response);
				};
				try {
					const event = this.config.actions[action];
					if (this.config.target || this.el.dataset.target)
						this.pushEventTo(
							this.config.target || this.el.dataset.target,
							event,
							body,
							reply,
						);
					else this.pushEvent(event, body, reply);
				} catch (error) {
					finish(error);
				}
			});
		},
		requestSync() {
			this.sendChat("sync", { sequences: this.state.sequences }).catch(
				() => {},
			);
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
				}),
			);
		},
		disconnected() {
			this.connected = false;
			this.requests.forEach((request) => request.cancel());
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
