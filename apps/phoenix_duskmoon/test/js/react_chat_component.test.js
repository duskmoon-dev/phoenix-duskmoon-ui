import { describe, expect, test } from "bun:test";
import React from "react";
import { renderToStaticMarkup } from "react-dom/server";
import { Chat, ComposerSettings } from "@duskmoon-dev/components/chat";
import { ReactChat } from "../../assets/js/react_chat/chat.js";
import { initialState } from "../../assets/js/react_chat/state.js";

function render(messages, connected = true) {
	return renderToStaticMarkup(
		React.createElement(ReactChat, {
			state: initialState("conversation", messages),
			bridge: { send: () => Promise.resolve({ status: "ok" }) },
			connected,
			label: "Conversation",
		}),
	);
}

describe("React chat upstream composition", () => {
	test("custom composers and messages use upstream context, menu settings and requests", () => {
		const h = React.createElement;
		function Composer() {
			return h(
				Chat.Composer,
				{
					value: "",
					onValueChange: () => {},
					onSubmit: async () => false,
					context: h(
						Chat.ComposerContext,
						null,
						h(Chat.ComposerContextItem, null, "Repository: application"),
						h(
							Chat.ComposerContextEnd,
							null,
							h(Chat.ComposerConnection, { state: "connected" }),
						),
					),
				},
				h(ComposerSettings, {
					variant: "menu",
					scopeKey: "application",
					revision: 1,
					settings: [
						{
							id: "model",
							label: "Model",
							value: "small",
							choices: [{ value: "small", label: "Small" }],
						},
					],
					onRequest: async () => {
						throw new Error("No SSR requests");
					},
					onAcknowledged: () => {},
				}),
			);
		}
		function Message({ targetId, timeline }) {
			return h(
				Chat.Agent,
				{ id: targetId, timeline },
				h(
					Chat.Request,
					{
						title: "Allow file read?",
						state: "pending",
						pending: true,
						actions: [{ id: "approve", label: "Approve", onSelect: () => {} }],
					},
					"Application authorization required",
				),
			);
		}
		const html = renderToStaticMarkup(
			h(ReactChat, {
				state: initialState("conversation", [
					{ id: "request", role: "assistant" },
				]),
				bridge: { send: async () => ({ status: "ok" }) },
				connected: true,
				options: { Composer, renderMessage: Message },
			}),
		);
		expect(html).toContain("chat-composer-context");
		expect(html).toContain("Repository: application");
		expect(html).toContain("Connected");
		expect(html).toContain('aria-label="Model: Small"');
		expect(html).toContain('popover="auto" role="group" aria-label="Model"');
		expect(html).toContain("Allow file read?");
		expect(html).toContain("Application authorization required");
		expect(html).toMatch(/<button[^>]*disabled[^>]*>Approve<\/button>/);
	});

	test("renders streaming Markdown and tool input through the published chat parts", () => {
		const html = render([
			{
				id: "answer",
				role: "assistant",
				status: "streaming",
				content: "**Searching**",
				tools: [
					{
						id: "search",
						name: "Search",
						status: "running",
						input: { query: "Moon" },
					},
				],
			},
		]);

		expect(html).toContain('role="article"');
		expect(html).toContain('data-message-id="answer"');
		expect(html).toContain('class="chat chat-start chat-agent"');
		expect(html).toContain('class="chat-content chat-streaming"');
		expect(html).not.toContain('class="chat-bubble');
		expect(html).toContain("<strong>Searching</strong>");
		expect(html).toContain("chat-tool-running");
		expect(html).toContain("chat-tool-call");
		expect(html).toMatch(
			/class="chat-content chat-streaming"><details class="chat-tool chat-tool-running">/,
		);
		expect(html).toContain('</details><div class="markdown-body">');
		expect(html).toContain("Moon");
		expect(html).toContain('role="status" class="chat-status"');
		expect(html).toContain('class="chat-status-item">Generating…');
		expect(html).toMatch(/<button[^>]*><span[^>]*>Stop<\/span><\/button>/);
	});

	test("retains user placement, tool results, error actions, and disconnected state", () => {
		const html = render(
			[
				{ id: "question", role: "user", content: "Hello", status: "complete" },
				{
					id: "answer",
					role: "assistant",
					status: "error",
					content: "Partial reply",
					error: "Generation failed",
					tools: [
						{
							id: "search",
							name: "Search",
							status: "success",
							result: { count: 3 },
						},
					],
					actions: [{ id: "inspect", label: "Inspect" }],
				},
			],
			false,
		);

		expect(html).toContain("chat-end");
		expect(html.match(/class="chat-bubble(?:\s|")/g)).toHaveLength(1);
		expect(html).toContain('class="chat chat-start chat-agent"');
		expect(html).toContain("chat-tool-success");
		expect(html).toContain("chat-tool-result");
		expect(html).toMatch(
			/class="chat-content"><details class="chat-tool chat-tool-success">/,
		);
		expect(html).toContain('</details><div class="markdown-body">');
		expect(html).toContain("chat-footer");
		expect(html).toContain("chat-actions");
		expect(html).toContain('role="alert">Generation failed');
		expect(html).toMatch(/<button[^>]*><span[^>]*>Retry<\/span><\/button>/);
		expect(html).toMatch(/<button[^>]*><span[^>]*>Inspect<\/span><\/button>/);
		expect(html).toMatch(
			/<button[^>]*disabled=""[^>]*><span[^>]*>Send<\/span><\/button>/,
		);
		expect(html).toContain("Disconnected. Draft preserved.");
		expect(html).not.toContain('class="chat-content chat-streaming"');
	});

	test("pairs panel-local reply markers with the latest 24 assistant messages", () => {
		const messages = Array.from({ length: 26 }, (_, index) => [
			{ id: `user-${index}`, role: "user", content: "Question" },
			{ id: `assistant-${index}`, role: "assistant", content: "Answer" },
		]).flat();
		const html = render(messages);
		const markers = [
			...html.matchAll(/data-chat-target="([^"]+)" data-chat-tl="(\d+)"/g),
		];

		expect(markers).toHaveLength(24);
		expect(markers.map(([, , timeline]) => Number(timeline))).toEqual(
			Array.from({ length: 24 }, (_, index) => index + 1),
		);
		markers.forEach(([, target]) => {
			expect(html).toContain(`id="${target}"`);
			expect(target).toContain("-message-assistant-");
		});
		expect(markers[0][1]).toEndWith("-message-assistant-2");
		expect(markers[23][1]).toEndWith("-message-assistant-25");
		expect(html).toContain("chat-scroll-body");
		expect(html).toContain("chat-scroll-track");
		expect(html).toContain('data-message-id="assistant-0"');
		expect(html).toContain('data-message-id="assistant-1"');
	});

	test("keeps navigation targets unique when two conversations share message IDs", () => {
		const props = {
			state: initialState("conversation", [
				{ id: "answer", role: "assistant", content: "Hello" },
			]),
			bridge: { send: () => Promise.resolve({ status: "ok" }) },
			connected: true,
			label: "Conversation",
		};
		const html = renderToStaticMarkup(
			React.createElement(
				React.Fragment,
				null,
				React.createElement(ReactChat, props),
				React.createElement(ReactChat, props),
			),
		);
		const targets = [...html.matchAll(/data-chat-target="([^"]+)"/g)].map(
			([, target]) => target,
		);

		expect(targets).toHaveLength(2);
		expect(new Set(targets).size).toBe(2);
	});
});
