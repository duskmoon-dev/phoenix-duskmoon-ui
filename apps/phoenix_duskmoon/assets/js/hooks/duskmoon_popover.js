export function syncPopoverState(element) {
	const controlledOpen = element.dataset.open;

	if (controlledOpen !== "true" && controlledOpen !== "false") return;
	if (!("showPopover" in element) || !("hidePopover" in element)) return;

	const open = element.matches(":popover-open");

	if (controlledOpen === "true" && !open) element.showPopover();
	if (controlledOpen === "false" && open) element.hidePopover();
}

export const DuskmoonPopover = {
	mounted() {
		syncPopoverState(this.el);
	},

	updated() {
		syncPopoverState(this.el);
	},
};
