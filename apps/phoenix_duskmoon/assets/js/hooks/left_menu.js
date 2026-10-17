const navigationKinds = new Set(["redirect", "patch", "initial"]);

/** Collapse integration, group state, and scroll restoration for dm_left_menu. */
export const DuskmoonLeftMenu = {
	mounted() {
		this.menuWindow = this.el.ownerDocument.defaultView;
		this.collapsed = this.el.dataset.collapsed === "true";
		this.lastServerCollapsed = this.el.dataset.serverCollapsed;
		this.groupStates = new Map();
		this.navigationScrollTop = null;
		this.scrollTop = this.menuScroller().scrollTop;
		this.captureGroups();

		try {
			const stored =
				this.lastServerCollapsed === undefined && this.el.dataset.storageKey
					? this.menuWindow.localStorage.getItem(this.el.dataset.storageKey)
					: null;
			if (stored === "true" || stored === "false") {
				this.collapsed = stored === "true";
			}
		} catch {
			// Storage can be disabled; in-page toggling remains available.
		}

		this.handleMenuClick = (event) => {
			const toggle = event.target.closest?.("[data-left-menu-toggle]");
			if (!toggle || !this.el.contains(toggle)) return;
			this.setMenuCollapsed(!this.collapsed);
			try {
				if (
					this.el.dataset.serverCollapsed === undefined &&
					this.el.dataset.storageKey
				) {
					this.menuWindow.localStorage.setItem(
						this.el.dataset.storageKey,
						String(this.collapsed),
					);
				}
			} catch {
				// Persistence is optional.
			}
			if (this.el.dataset.collapseEvent) {
				this.el.dispatchEvent(
					new this.menuWindow.CustomEvent(this.el.dataset.collapseEvent, {
						bubbles: true,
						detail: { id: this.el.id, collapsed: this.collapsed },
					}),
				);
			}
		};
		this.handleSetCollapsed = (event) => {
			if (
				event.target !== this.el ||
				typeof event.detail?.collapsed !== "boolean"
			)
				return;
			this.setMenuCollapsed(event.detail.collapsed);
		};
		this.handleNavigationStart = ({ detail }) => {
			if (!navigationKinds.has(detail?.kind)) return;
			if (this.navigationScrollTop !== null) return;
			this.navigationScrollTop = this.menuScroller().scrollTop;
		};
		this.handleNavigationStop = ({ detail }) => {
			if (!navigationKinds.has(detail?.kind)) return;
			if (this.navigationScrollTop === null) return;
			this.restoreMenuScroll(this.navigationScrollTop);
			// The new root's initial patch can still follow redirect stop.
			if (detail.kind !== "redirect") this.navigationScrollTop = null;
		};
		this.el.addEventListener("click", this.handleMenuClick);
		this.el.addEventListener(
			"duskmoon:left-menu:set-collapsed",
			this.handleSetCollapsed,
		);
		this.menuWindow.addEventListener(
			"phx:page-loading-start",
			this.handleNavigationStart,
		);
		this.menuWindow.addEventListener(
			"phx:page-loading-stop",
			this.handleNavigationStop,
		);
		this.applyMenuState();
	},

	setMenuCollapsed(collapsed) {
		const scrollTop = this.navigationScrollTop ?? this.menuScroller().scrollTop;
		if (!this.collapsed && collapsed) this.captureGroups();
		this.collapsed = collapsed;
		this.applyMenuState();
		this.restoreMenuScroll(scrollTop);
	},

	syncServerCollapsed(force = false) {
		const value = this.el.dataset.serverCollapsed;
		if (
			(value !== "true" && value !== "false") ||
			(!force && value === this.lastServerCollapsed)
		)
			return;
		this.lastServerCollapsed = value;
		this.setMenuCollapsed(value === "true");
	},

	menuScroller() {
		return this.el.querySelector("[data-left-menu-scroll]");
	},

	captureGroups() {
		for (const group of this.el.querySelectorAll("details[id]")) {
			this.groupStates.set(group.id, group.open);
		}
	},

	applyMenuState() {
		this.el.dataset.collapsed = String(this.collapsed);
		for (const toggle of this.el.querySelectorAll("[data-left-menu-toggle]")) {
			toggle.setAttribute("aria-expanded", String(!this.collapsed));
			const label = this.collapsed
				? this.el.dataset.expandLabel
				: this.el.dataset.collapseLabel;
			toggle.setAttribute("aria-label", label);
			toggle.setAttribute("title", label);
		}
		const ids = new Set();
		for (const group of this.el.querySelectorAll("details[id]")) {
			ids.add(group.id);
			if (!this.groupStates.has(group.id)) {
				this.groupStates.set(group.id, group.open);
			}
			group.open = this.collapsed || this.groupStates.get(group.id);
		}
		for (const id of this.groupStates.keys()) {
			if (!ids.has(id)) this.groupStates.delete(id);
		}
		this.applyMenuTooltips();
	},

	applyMenuTooltips() {
		for (const link of this.el.querySelectorAll("[data-left-menu-tooltip]")) {
			const tooltipId = link.dataset.leftMenuTooltip;
			const anchor = link.dataset.leftMenuAnchor;
			const title = link.dataset.leftMenuTooltipTitle;
			const descriptions = new Set(
				(link.getAttribute("aria-describedby") || "")
					.split(/\s+/)
					.filter(Boolean),
			);
			const anchors = new Set(
				link.style
					.getPropertyValue("anchor-name")
					.split(",")
					.map((value) => value.trim())
					.filter(Boolean),
			);
			if (this.collapsed) {
				link.setAttribute("interestfor", tooltipId);
				descriptions.add(tooltipId);
				if (anchor) anchors.add(anchor);
				if (title) link.setAttribute("title", title);
			} else {
				if (link.getAttribute("interestfor") === tooltipId)
					link.removeAttribute("interestfor");
				descriptions.delete(tooltipId);
				anchors.delete(anchor);
				if (link.getAttribute("title") === title) link.removeAttribute("title");
				const surface = this.el.ownerDocument.getElementById(tooltipId);
				if (surface?.hidePopover && surface.matches(":popover-open"))
					surface.hidePopover();
			}
			if (descriptions.size)
				link.setAttribute("aria-describedby", [...descriptions].join(" "));
			else link.removeAttribute("aria-describedby");
			if (anchors.size)
				link.style.setProperty("anchor-name", [...anchors].join(", "));
			else link.style.removeProperty("anchor-name");
		}
	},

	restoreMenuScroll(top) {
		this.menuScroller().scrollTo({ top, behavior: "instant" });
	},

	beforeUpdate() {
		if (!this.collapsed) this.captureGroups();
		this.scrollTop = this.navigationScrollTop ?? this.menuScroller().scrollTop;
	},

	updated() {
		this.applyMenuState();
		this.syncServerCollapsed();
		this.restoreMenuScroll(this.navigationScrollTop ?? this.scrollTop);
	},

	reconnected() {
		this.applyMenuState();
		this.syncServerCollapsed(true);
		if (this.navigationScrollTop !== null) {
			this.restoreMenuScroll(this.navigationScrollTop);
		}
	},

	destroyed() {
		this.el.removeEventListener("click", this.handleMenuClick);
		this.el.removeEventListener(
			"duskmoon:left-menu:set-collapsed",
			this.handleSetCollapsed,
		);
		this.menuWindow.removeEventListener(
			"phx:page-loading-start",
			this.handleNavigationStart,
		);
		this.menuWindow.removeEventListener(
			"phx:page-loading-stop",
			this.handleNavigationStop,
		);
	},
};
