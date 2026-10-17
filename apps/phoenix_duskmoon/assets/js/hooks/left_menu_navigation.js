/** Synchronizes the page's active item with its sticky dm_left_menu child. */
export const DuskmoonLeftMenuNavigation = {
	mounted() {
		this.navigationDestroyed = false;
		this.lastNavigation = null;
		this.navigationRequest = null;
		this.lastCollapse = null;
		this.syncActiveNav();
		this.syncCollapse();
	},
	updated() {
		this.syncActiveNav();
		this.syncCollapse();
	},
	reconnected() {
		this.lastNavigation = null;
		this.navigationRequest = null;
		this.lastCollapse = null;
		this.syncActiveNav();
		this.syncCollapse();
	},
	syncCollapse() {
		if (this.navigationDestroyed) return;
		const { sidebarId, collapseState } = this.el.dataset;
		const target = sidebarId
			? this.el.ownerDocument.getElementById(sidebarId)
			: null;
		if (!target || (collapseState !== "true" && collapseState !== "false")) {
			this.lastCollapse = null;
			return;
		}
		if (
			this.lastCollapse?.target === target &&
			this.lastCollapse.collapseState === collapseState
		)
			return;
		this.lastCollapse = { target, collapseState };
		target.dispatchEvent(
			new target.ownerDocument.defaultView.CustomEvent(
				"duskmoon:left-menu:set-collapsed",
				{
					detail: { collapsed: collapseState === "true" },
				},
			),
		);
	},
	syncActiveNav() {
		if (this.navigationDestroyed) return;
		const { sidebarId, activeNav } = this.el.dataset;
		const target = sidebarId
			? this.el.ownerDocument.getElementById(sidebarId)
			: null;
		if (!target || typeof activeNav !== "string") {
			this.lastNavigation = null;
			this.navigationRequest = null;
			return;
		}
		if (
			this.lastNavigation?.sidebarId === sidebarId &&
			this.lastNavigation.target === target &&
			this.lastNavigation.activeNav === activeNav
		)
			return;
		this.lastNavigation = { sidebarId, target, activeNav };
		const request = {};
		this.navigationRequest = request;
		const failed = () => {
			if (!this.navigationDestroyed && this.navigationRequest === request) {
				this.lastNavigation = null;
				this.navigationRequest = null;
			}
		};
		try {
			Promise.resolve(
				this.pushEventTo(target, "set_active_nav", { active_nav: activeNav }),
			)
				.then((results) => {
					if (
						!Array.isArray(results) ||
						!results.length ||
						results.some(
							(result) =>
								result?.status !== "fulfilled" ||
								result.value?.reply?.status !== "ok",
						)
					)
						failed();
				})
				.catch(failed);
		} catch {
			failed();
		}
	},
	destroyed() {
		this.navigationDestroyed = true;
		this.lastNavigation = null;
		this.navigationRequest = null;
		this.lastCollapse = null;
	},
};
