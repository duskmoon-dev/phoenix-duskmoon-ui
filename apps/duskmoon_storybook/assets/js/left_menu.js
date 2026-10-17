/** Host adapter example: persistence belongs in the page's LiveView handler. */
export const DuskmoonLeftMenuHostDemo = {
	mounted() {
		this.menuWindow = this.el.ownerDocument.defaultView;
		this.onMenuCollapse = ({ detail }) => {
			if (
				detail?.id !== "left-menu-demo-sidebar" ||
				typeof detail.collapsed !== "boolean"
			)
				return;
			this.pushEvent("sidebar_collapse", detail);
		};
		this.menuWindow.addEventListener(
			"storybook:left-menu:collapse",
			this.onMenuCollapse,
		);
	},
	destroyed() {
		this.menuWindow.removeEventListener(
			"storybook:left-menu:collapse",
			this.onMenuCollapse,
		);
	},
};
