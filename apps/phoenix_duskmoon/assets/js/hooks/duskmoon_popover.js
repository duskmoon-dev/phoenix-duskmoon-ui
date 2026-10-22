export function syncPopoverState(element) {
	const controlledOpen = element.dataset.open;

	if (controlledOpen !== "true" && controlledOpen !== "false") return;
	if (!("showPopover" in element) || !("hidePopover" in element)) return;

	const open = element.matches(":popover-open");

	if (controlledOpen === "true" && !open) element.showPopover();
	if (controlledOpen === "false" && open) element.hidePopover();
}

// Dropdown hooks live on the wrapper so patches to either the trigger or panel
// resynchronize state. Existing popover hooks still mount directly on the panel.
function hookPopover(element) {
	return element.dataset.popoverId
		? element.ownerDocument.getElementById(element.dataset.popoverId)
		: element;
}

function syncExpandedState(element, popover) {
	if (element === popover || !("showPopover" in popover)) return;

	const expanded = String(popover.matches(":popover-open"));

	for (const trigger of element.querySelectorAll("[aria-controls]")) {
		if (trigger.getAttribute("aria-controls") === popover.id) {
			trigger.setAttribute("aria-expanded", expanded);
		}
	}
}

function syncHookState(hook) {
	const popover = hookPopover(hook.el);

	if (hook._popover !== popover) {
		hook._popover?.removeEventListener("toggle", hook._onPopoverToggle);
		hook._popover = popover;
		popover?.addEventListener("toggle", hook._onPopoverToggle);
	}

	if (!popover) return;

	syncPopoverState(popover);
	syncExpandedState(hook.el, popover);
}

export const DuskmoonPopover = {
	mounted() {
		this._onPopoverToggle = () => {
			if (this._popover) syncExpandedState(this.el, this._popover);
		};
		syncHookState(this);
	},

	updated() {
		syncHookState(this);
	},

	destroyed() {
		this._popover?.removeEventListener("toggle", this._onPopoverToggle);
		this._popover = null;
	},
};
