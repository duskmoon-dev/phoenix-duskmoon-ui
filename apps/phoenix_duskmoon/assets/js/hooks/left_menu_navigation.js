/** Synchronizes the page's active item with its sticky dm_left_menu child. */
export const DuskmoonLeftMenuNavigation = {
	mounted() {
		this.navigationDestroyed = false;
		this.lastNavigation = null;
		this.navigationRequest = null;
		this.syncActiveNav();
	},
	updated() {
		this.syncActiveNav();
	},
	reconnected() {
		this.lastNavigation = null;
		this.navigationRequest = null;
		this.syncActiveNav();
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
	},
};
