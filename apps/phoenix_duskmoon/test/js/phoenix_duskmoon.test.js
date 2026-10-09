import { describe, expect, mock, test } from "bun:test";

import { installDialogBehavior } from "../../assets/js/phoenix_duskmoon.js";
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
		return {
			dataset: { open: controlledOpen },
			hidePopover: mock(() => undefined),
			matches: mock(() => open),
			showPopover: mock(() => undefined),
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

		expect(element.showPopover).toHaveBeenCalledTimes(2);
	});
});
