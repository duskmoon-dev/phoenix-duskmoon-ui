import { describe, expect, mock, test } from "bun:test";

import {
	copyTextToClipboard,
	installClipboardBehavior,
} from "../../assets/js/phoenix_duskmoon.js";

function copyControl(value) {
	const label = { textContent: "Copy" };
	const status = {
		textContent: "",
		matches: (selector) => selector === "[data-copy-status]",
	};
	const button = {
		dataset: { copyValue: value },
		disabled: false,
		getAttribute: () => null,
		nextElementSibling: status,
		querySelector: (selector) =>
			selector === "[data-copy-label]" ? label : null,
	};
	const target = {
		closest: (selector) => (selector === "[data-copy-value]" ? button : null),
	};

	return { button, label, status, target };
}

function delegatedRoot() {
	const listeners = new Map();

	return {
		addEventListener: mock((event, listener) => listeners.set(event, listener)),
		listeners,
	};
}

const noReset = () => undefined;

describe("delegated clipboard behavior", () => {
	test("copies the exact value and announces success", async () => {
		const root = delegatedRoot();
		const control = copyControl(
			"git clone https://example.test/acme/demo.git\n",
		);
		const copy = mock(async () => undefined);

		installClipboardBehavior(root, { copy, scheduleReset: noReset });
		await root.listeners.get("click")({ target: control.target });

		expect(copy).toHaveBeenCalledWith(
			"git clone https://example.test/acme/demo.git\n",
		);
		expect(control.label.textContent).toBe("Copied");
		expect(control.status.textContent).toBe("Copied");
		expect(control.button.dataset.copyState).toBe("success");
	});

	test("announces clipboard failures without moving focus", async () => {
		const root = delegatedRoot();
		const control = copyControl("blob contents");
		const copy = mock(async () => {
			throw new Error("permission denied");
		});

		installClipboardBehavior(root, { copy, scheduleReset: noReset });
		await root.listeners.get("click")({ target: control.target });

		expect(control.label.textContent).toBe("Copy failed");
		expect(control.status.textContent).toBe("Copy failed");
		expect(control.button.dataset.copyState).toBe("error");
	});

	test("uses the legacy copy command only when the Clipboard API is unavailable", async () => {
		const activeElement = { focus: mock(() => undefined) };
		const textArea = {
			focus: mock(() => undefined),
			select: mock(() => undefined),
			setAttribute: mock(() => undefined),
			style: {},
			value: "",
		};
		const body = {
			appendChild: mock(() => undefined),
			removeChild: mock(() => undefined),
		};
		const document = {
			activeElement,
			body,
			createElement: mock(() => textArea),
			execCommand: mock(() => true),
		};

		await copyTextToClipboard("fallback value", { document, navigator: {} });

		expect(textArea.value).toBe("fallback value");
		expect(document.execCommand).toHaveBeenCalledWith("copy");
		expect(body.removeChild).toHaveBeenCalledWith(textArea);
		expect(activeElement.focus).toHaveBeenCalledTimes(1);
	});

	test("does not use the legacy command when the Clipboard API rejects", async () => {
		const writeText = mock(async () => {
			throw new Error("permission denied");
		});
		const document = { execCommand: mock(() => true) };

		await expect(
			copyTextToClipboard("protected value", {
				document,
				navigator: { clipboard: { writeText } },
			}),
		).rejects.toThrow("permission denied");

		expect(writeText).toHaveBeenCalledWith("protected value");
		expect(document.execCommand).not.toHaveBeenCalled();
	});
});
