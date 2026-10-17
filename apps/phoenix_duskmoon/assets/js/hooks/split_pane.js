/** Client-owned horizontal pane sizing; no resize events are sent to LiveView. */
export const DuskmoonSplitPane = {
	mounted() {
		this.splitWindow = this.el.ownerDocument.defaultView;
		this.preferredWidth = Number(this.el.dataset.initialWidth);
		this.onSplitPointerDown = (event) => {
			const handle = this.splitHandle();
			if (
				this.splitDrag || this.splitStacked || event.button !== 0 ||
				!event.isPrimary || event.target.closest?.("[data-split-pane-handle]") !== handle
			) return;
			event.preventDefault();
			handle.focus({ preventScroll: true });
			this.splitDrag = {
				pointerId: event.pointerId,
				x: event.clientX,
				width: this.currentWidth,
				preferredWidth: this.preferredWidth,
				direction: this.splitWindow.getComputedStyle(this.el).direction === "rtl" ? -1 : 1,
				handle,
			};
			handle.setPointerCapture(event.pointerId);
			this.el.dataset.splitPaneDragging = "true";
		};
		this.onSplitPointerMove = (event) => {
			const drag = this.splitDrag;
			if (!drag || event.pointerId !== drag.pointerId) return;
			this.setSplitWidth(drag.width + (event.clientX - drag.x) * drag.direction);
		};
		this.onSplitPointerUp = (event) => {
			if (event.pointerId === this.splitDrag?.pointerId) this.finishSplitDrag(false);
		};
		this.onSplitPointerCancel = (event) => {
			if (event.pointerId === this.splitDrag?.pointerId) this.finishSplitDrag(true);
		};
		this.onSplitKeyDown = (event) => {
			if (this.splitStacked || event.target !== this.splitHandle()) return;
			const direction = this.splitWindow.getComputedStyle(this.el).direction === "rtl" ? -1 : 1;
			const widths = {
				ArrowLeft: this.currentWidth - 10 * direction,
				ArrowRight: this.currentWidth + 10 * direction,
				Home: this.splitMin,
				End: this.splitMax,
			};
			if (!Object.hasOwn(widths, event.key)) return;
			event.preventDefault();
			this.finishSplitDrag(false);
			this.setSplitWidth(widths[event.key]);
		};
		this.splitListeners = {
			pointerdown: this.onSplitPointerDown,
			pointermove: this.onSplitPointerMove,
			pointerup: this.onSplitPointerUp,
			pointercancel: this.onSplitPointerCancel,
			lostpointercapture: this.onSplitPointerCancel,
			keydown: this.onSplitKeyDown,
		};
		for (const [type, listener] of Object.entries(this.splitListeners)) {
			this.el.addEventListener(type, listener);
		}
		this.splitObserver = new this.splitWindow.ResizeObserver(() => this.applySplitPane());
		this.splitObserver.observe(this.el);
		this.applySplitPane();
	},

	splitHandle() {
		return this.el.querySelector(":scope > [data-split-pane-handle]");
	},

	setSplitWidth(width) {
		this.preferredWidth = Math.max(this.splitMin, Math.min(this.splitMax, Math.round(width)));
		this.applySplitPane();
	},

	applySplitPane() {
		const { minWidth, maxWidth, minSecondaryWidth, stackAt } = this.el.dataset;
		const style = this.splitWindow.getComputedStyle(this.el);
		const available = this.el.clientWidth - (parseFloat(style.paddingLeft) || 0) -
			(parseFloat(style.paddingRight) || 0);
		this.splitMin = Number(minWidth);
		const availableMax = Math.floor(available - 16 - Number(minSecondaryWidth));
		this.splitMax = Math.max(this.splitMin, Math.min(Number(maxWidth), availableMax));
		this.splitStacked = available < Number(stackAt) || availableMax < this.splitMin;
		if (this.splitStacked && this.splitDrag) this.finishSplitDrag(true);
		this.currentWidth = Math.max(this.splitMin, Math.min(this.splitMax, this.preferredWidth));
		this.el.style.setProperty("--dm-split-pane-width", `${this.currentWidth}px`);
		this.el.dataset.splitPaneStacked = String(this.splitStacked);
		const handle = this.splitHandle();
		handle.hidden = this.splitStacked;
		handle.tabIndex = this.splitStacked ? -1 : 0;
		handle.setAttribute("aria-valuemin", String(this.splitMin));
		handle.setAttribute("aria-valuemax", String(this.splitMax));
		handle.setAttribute("aria-valuenow", String(this.currentWidth));
		handle.setAttribute("aria-valuetext", `${this.currentWidth} pixels`);
	},

	finishSplitDrag(cancelled, refresh = true) {
		const drag = this.splitDrag;
		if (!drag) return;
		this.splitDrag = null;
		if (cancelled) this.preferredWidth = drag.preferredWidth;
		delete this.el.dataset.splitPaneDragging;
		if (drag.handle.hasPointerCapture(drag.pointerId)) {
			drag.handle.releasePointerCapture(drag.pointerId);
		}
		if (refresh) this.applySplitPane();
	},

	beforeUpdate() {
		// Release capture before morphing, retaining the latest client-owned width.
		this.finishSplitDrag(false);
	},

	updated() {
		this.applySplitPane();
	},

	destroyed() {
		this.finishSplitDrag(false, false);
		this.splitObserver.disconnect();
		for (const [type, listener] of Object.entries(this.splitListeners)) {
			this.el.removeEventListener(type, listener);
		}
	},
};
