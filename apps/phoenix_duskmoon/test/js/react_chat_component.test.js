import { describe, expect, test } from "bun:test";
import React from "react";
import { renderToStaticMarkup } from "react-dom/server";
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
	test("renders streaming Markdown and tool input through the published chat parts", () => {
		const html = render([
			{
				id: "answer",
				role: "assistant",
				status: "streaming",
				content: "**Searching**",
				tools: [{ id: "search", name: "Search", status: "running", input: { query: "Moon" } }],
			},
		]);

		expect(html).toContain('role="article"');
		expect(html).toContain('data-message-id="answer"');
		expect(html).toContain("chat-bubble-streaming");
		expect(html).toContain('class="chat-bubble-content chat-bubble-streaming" aria-hidden="true"');
		expect(html).toContain("<strong>Searching</strong>");
		expect(html).toContain("chat-tool-running");
		expect(html).toContain("chat-tool-call");
		expect(html).toMatch(/class="chat-bubble[^\"]*"><details class="chat-tool chat-tool-running">/);
		expect(html).toContain('</details><div class="markdown-body chat-bubble-content">');
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
					tools: [{ id: "search", name: "Search", status: "success", result: { count: 3 } }],
					actions: [{ id: "inspect", label: "Inspect" }],
				},
			],
			false,
		);

		expect(html).toContain("chat-end");
		expect(html).toContain("chat-tool-success");
		expect(html).toContain("chat-tool-result");
		expect(html).toMatch(/class="chat-bubble[^\"]*"><details class="chat-tool chat-tool-success">/);
		expect(html).toContain('</details><div class="markdown-body chat-bubble-content">');
		expect(html).toContain("chat-footer");
		expect(html).toContain("chat-actions");
		expect(html).toContain('role="alert">Generation failed');
		expect(html).toMatch(/<button[^>]*><span[^>]*>Retry<\/span><\/button>/);
		expect(html).toMatch(/<button[^>]*><span[^>]*>Inspect<\/span><\/button>/);
		expect(html).toMatch(/<button[^>]*disabled=""[^>]*><span[^>]*>Send<\/span><\/button>/);
		expect(html).toContain("Disconnected. Draft preserved.");
		expect(html).not.toContain('class="chat-bubble-content chat-bubble-streaming"');
	});

	test("pairs panel-local reply markers with the latest 24 assistant messages", () => {
		const messages = Array.from({ length: 26 }, (_, index) => [
			{ id: `user-${index}`, role: "user", content: "Question" },
			{ id: `assistant-${index}`, role: "assistant", content: "Answer" },
		]).flat();
		const html = render(messages);
		const markers = [...html.matchAll(/data-chat-target="([^"]+)" data-chat-tl="(\d+)"/g)];

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
			state: initialState("conversation", [{ id: "answer", role: "assistant", content: "Hello" }]),
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
		const targets = [...html.matchAll(/data-chat-target="([^"]+)"/g)].map(([, target]) => target);

		expect(targets).toHaveLength(2);
		expect(new Set(targets).size).toBe(2);
	});
});
