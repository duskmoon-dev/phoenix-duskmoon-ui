import { describe, expect, mock, test } from "bun:test";

import {
	handleDialogConfirmClick,
	installDialogBehavior,
} from "../../assets/js/phoenix_duskmoon.js";
import {
	DuskmoonPopover,
	syncPopoverState,
} from "../../assets/js/hooks/duskmoon_popover.js";

function delegatedRoot() {
	const listeners = new Map();

	return {
		addEventListener: mock((event, listener) => listeners.set(event, listener)),
		listeners,
	};
}

describe("delegated dialog behavior", () => {
	function confirmClick(overrides = {}) {
		const dialog = {
			close: mock(() => undefined),
			matches: (selector) => selector.startsWith("dialog["),
			open: true,
		};
		const action = {
			command: "close",
			commandForElement: dialog,
			form: null,
			matches: (selector) => selector.startsWith("[data-dm-confirm-action"),
			type: "button",
			...overrides,
		};
		const event = {
			composedPath: () => [{}, action, dialog],
			preventDefault: mock(() => undefined),
			stopPropagation: mock(() => undefined),
			stopImmediatePropagation: mock(() => undefined),
		};

		return { dialog, event };
	}

	test("leaves the current dialog's native close command to the browser", () => {
		const { dialog, event } = confirmClick();

		handleDialogConfirmClick(event);

		expect(dialog.close).not.toHaveBeenCalled();
		expect(event.preventDefault).not.toHaveBeenCalled();
		expect(event.stopPropagation).not.toHaveBeenCalled();
		expect(event.stopImmediatePropagation).not.toHaveBeenCalled();
	});

	test.each(["submit", "reset"])(
		"closes before a form-associated %s action without canceling it",
		(type) => {
			const { dialog, event } = confirmClick({ type, form: {} });

			handleDialogConfirmClick(event);

			expect(dialog.close).toHaveBeenCalledTimes(1);
			expect(event.preventDefault).not.toHaveBeenCalled();
			expect(event.stopPropagation).not.toHaveBeenCalled();
			expect(event.stopImmediatePropagation).not.toHaveBeenCalled();
		},
	);

	test.each([
		{ command: "show-modal", commandForElement: {} },
		{ command: "--confirm", commandForElement: {} },
		{ command: "close", commandForElement: {} },
		{ command: undefined, commandForElement: undefined },
	])("closes before another action: %j", (overrides) => {
		const { dialog, event } = confirmClick(overrides);

		handleDialogConfirmClick(event);

		expect(dialog.close).toHaveBeenCalledTimes(1);
		expect(event.preventDefault).not.toHaveBeenCalled();
		expect(event.stopPropagation).not.toHaveBeenCalled();
		expect(event.stopImmediatePropagation).not.toHaveBeenCalled();
	});

	test("installs one capturing confirm listener", () => {
		const root = delegatedRoot();

		installDialogBehavior(root);
		installDialogBehavior(root);

		expect(root.addEventListener).toHaveBeenCalledTimes(1);
		expect(root.addEventListener).toHaveBeenCalledWith(
			"click",
			expect.any(Function),
			true,
		);
	});
});

describe("server-controlled native popover state", () => {
	function popoverElement(controlledOpen, open = false) {
		const listeners = new Map();
		return {
			id: "menu",
			dataset: { open: controlledOpen },
			addEventListener: mock((event, listener) =>
				listeners.set(event, listener),
			),
			removeEventListener: mock((event, listener) => {
				if (listeners.get(event) === listener) listeners.delete(event);
			}),
			hidePopover: mock(() => {
				open = false;
			}),
			matches: mock(() => open),
			showPopover: mock(() => {
				open = true;
			}),
			toggle(openState, event = {}) {
				open = openState;
				listeners.get("toggle")?.(event);
			},
		};
	}

	test("opens and closes only explicitly controlled popovers", () => {
		const closed = popoverElement("true");
		syncPopoverState(closed);
		expect(closed.showPopover).toHaveBeenCalledTimes(1);

		const open = popoverElement("false", true);
		syncPopoverState(open);
		expect(open.hidePopover).toHaveBeenCalledTimes(1);

		const browserOwned = popoverElement(undefined);
		syncPopoverState(browserOwned);
		expect(browserOwned.showPopover).not.toHaveBeenCalled();
		expect(browserOwned.hidePopover).not.toHaveBeenCalled();
	});

	test("syncs on mount and LiveView updates", () => {
		const element = popoverElement("true");
		const hook = { el: element };

		DuskmoonPopover.mounted.call(hook);
		DuskmoonPopover.updated.call(hook);

		expect(element.showPopover).toHaveBeenCalledTimes(1);
	});
});

// Native visibility belongs to the browser. This harness delivers the same toggle
// notification for command activation, Escape/light dismiss and show/hidePopover.
describe("native dropdown expanded state", () => {
	function dropdown(open = false) {
		const listeners = new Map();
		let panel;
		const trigger = () => ({
			attributes: { "aria-controls": "menu" },
			getAttribute(name) {
				return this.attributes[name] ?? null;
			},
			setAttribute(name, value) {
				this.attributes[name] = value;
			},
		});
		function popover() {
			let visible = open;
			return {
				id: "menu",
				dataset: {},
				addEventListener: mock((name, listener) =>
					listeners.set(name, listener),
				),
				removeEventListener: mock((name, listener) => {
					if (listeners.get(name) === listener) listeners.delete(name);
				}),
				matches: (selector) => selector === ":popover-open" && visible,
				showPopover: mock(() => {
					visible = true;
				}),
				hidePopover: mock(() => {
					visible = false;
				}),
				toggle(value, event = {}) {
					visible = value;
					listeners.get("toggle")?.(event);
				},
			};
		}
		panel = popover();
		const wrapper = {
			dataset: { popoverId: "menu" },
			ownerDocument: { getElementById: (id) => (id === "menu" ? panel : null) },
			triggers: [trigger()],
			querySelectorAll: () => wrapper.triggers,
		};
		const hook = { el: wrapper };
		return {
			hook,
			panel,
			wrapper,
			trigger,
			replacePanel: () => {
				panel = popover();
				return panel;
			},
			removePanel: () => {
				panel = null;
			},
		};
	}

	test.each([false, true])(
		"initializes explicit state from the mounted native panel: %s",
		(open) => {
			const { hook, wrapper } = dropdown(open);
			expect(wrapper.triggers[0].getAttribute("aria-expanded")).toBeNull();

			DuskmoonPopover.mounted.call(hook);

			expect(wrapper.triggers[0].getAttribute("aria-expanded")).toBe(
				String(open),
			);
		},
	);

	test("follows native visibility without canceling events or issuing duplicate commands", () => {
		const { hook, panel, wrapper } = dropdown();
		DuskmoonPopover.mounted.call(hook);
		const event = { preventDefault: mock(), stopPropagation: mock() };

		for (const open of [true, false, true, false]) {
			panel.toggle(open, event);
			expect(wrapper.triggers[0].getAttribute("aria-expanded")).toBe(
				String(open),
			);
		}

		expect(panel.showPopover).not.toHaveBeenCalled();
		expect(panel.hidePopover).not.toHaveBeenCalled();
		expect(event.preventDefault).not.toHaveBeenCalled();
		expect(event.stopPropagation).not.toHaveBeenCalled();
	});

	test("reads current native state instead of a stale queued toggle event", () => {
		const { hook, panel, wrapper } = dropdown();
		DuskmoonPopover.mounted.call(hook);
		panel.toggle(false, { newState: "open" });
		expect(wrapper.triggers[0].getAttribute("aria-expanded")).toBe("false");
	});

	test("resynchronizes replaced sibling triggers during a LiveView patch", () => {
		const { hook, panel, wrapper, trigger } = dropdown();
		DuskmoonPopover.mounted.call(hook);
		panel.toggle(true);
		wrapper.triggers = [trigger(), trigger()];
		const unrelated = trigger();
		unrelated.attributes["aria-controls"] = "another-menu";
		wrapper.triggers.push(unrelated);

		DuskmoonPopover.updated.call(hook);

		expect(wrapper.triggers[0].getAttribute("aria-expanded")).toBe("true");
		expect(wrapper.triggers[1].getAttribute("aria-expanded")).toBe("true");
		expect(unrelated.getAttribute("aria-expanded")).toBeNull();
		expect(panel.addEventListener).toHaveBeenCalledTimes(1);
	});

	test("rebinds to a patched panel and applies server-controlled state before ARIA", () => {
		const { hook, panel, wrapper, replacePanel } = dropdown();
		DuskmoonPopover.mounted.call(hook);
		const replacement = replacePanel();
		replacement.dataset.open = "true";

		DuskmoonPopover.updated.call(hook);

		expect(panel.removeEventListener).toHaveBeenCalledTimes(1);
		expect(replacement.addEventListener).toHaveBeenCalledTimes(1);
		expect(replacement.showPopover).toHaveBeenCalledTimes(1);
		expect(wrapper.triggers[0].getAttribute("aria-expanded")).toBe("true");
		replacement.dataset.open = "false";
		DuskmoonPopover.updated.call(hook);
		expect(wrapper.triggers[0].getAttribute("aria-expanded")).toBe("false");
	});

	test("handles a temporarily absent panel and removes listeners on destroy", () => {
		const { hook, panel, removePanel, replacePanel } = dropdown();
		DuskmoonPopover.mounted.call(hook);
		removePanel();
		DuskmoonPopover.updated.call(hook);
		expect(panel.removeEventListener).toHaveBeenCalledTimes(1);

		const replacement = replacePanel();
		DuskmoonPopover.updated.call(hook);
		DuskmoonPopover.destroyed.call(hook);
		expect(replacement.removeEventListener).toHaveBeenCalledTimes(1);
		expect(hook._popover).toBeNull();
	});
});
