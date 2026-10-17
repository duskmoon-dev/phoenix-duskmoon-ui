import { afterEach, describe, expect, test } from "bun:test";
import { DuskmoonSplitPane } from "../../assets/js/hooks/split_pane.js";

const mounted = [];
afterEach(() => mounted.splice(0).forEach((hook) => hook.destroyed()));

function mount({ width = 900, direction = "ltr", ...dataset } = {}) {
	const captures = new Set();
	const properties = new Map();
	let handle;
	let observer;
	let serverEvents = 0;
	const root = Object.assign(new EventTarget(), {
		clientWidth: width,
		dataset: {
			initialWidth: "280", minWidth: "160", maxWidth: "480",
			minSecondaryWidth: "240", stackAt: "640", ...dataset,
		},
		style: { setProperty: (key, value) => properties.set(key, value) },
		querySelector: () => handle,
		ownerDocument: {
			defaultView: {
				getComputedStyle: () => ({ direction, paddingLeft: "0px", paddingRight: "0px" }),
				ResizeObserver: class {
					constructor(callback) { this.callback = callback; observer = this; }
					observe(target) { this.target = target; }
					disconnect() { this.disconnected = true; }
				},
			},
		},
	});
	function replacementHandle() {
		const attrs = new Map();
		const next = {
			attrs,
			closest: () => next,
			focus: () => { next.focused = true; },
			setAttribute: (key, value) => attrs.set(key, value),
			setPointerCapture: (id) => captures.add(id),
			hasPointerCapture: (id) => captures.has(id),
			releasePointerCapture: (id) => {
				captures.delete(id);
				fire("lostpointercapture", { pointerId: id }, next);
			},
		};
		return next;
	}
	handle = replacementHandle();
	const hook = Object.assign(Object.create(DuskmoonSplitPane), {
		el: root,
		pushEvent: () => { serverEvents++; },
		pushEventTo: () => { serverEvents++; },
	});
	function fire(type, details = {}, target = handle) {
		const event = Object.assign(new Event(type, { cancelable: true }), {
			button: 0, isPrimary: true, pointerId: 1, clientX: 280, ...details,
		});
		Object.defineProperty(event, "target", { value: target });
		root.dispatchEvent(event);
		return event;
	}
	hook.mounted();
	mounted.push(hook);
	return {
		hook, root, captures, properties, observer, fire,
		get handle() { return handle; },
		get serverEvents() { return serverEvents; },
		replaceHandle() { handle = replacementHandle(); return handle; },
		resize(width) { root.clientWidth = width; observer.callback(); },
	};
}

describe("client-owned accessible split panes", () => {
	test("pointer capture resizes within both pane bounds, filters pointers and commits without server events", () => {
		const fixture = mount();
		const { hook, fire, captures, handle } = fixture;
		expect(fire("pointerdown").defaultPrevented).toBe(true);
		expect(captures.has(1)).toBe(true);
		expect(handle.focused).toBe(true);
		fire("pointermove", { pointerId: 2, clientX: 900 });
		expect(hook.currentWidth).toBe(280);
		fire("pointermove", { clientX: 900 });
		expect(hook.currentWidth).toBe(480);
		fire("pointermove", { clientX: -100 });
		expect(hook.currentWidth).toBe(160);
		fire("pointermove", { clientX: 330 });
		fire("pointerup");
		expect(hook.preferredWidth).toBe(330);
		expect(captures.size).toBe(0);
		expect(hook.splitDrag).toBeNull();
		expect(handle.attrs.get("aria-valuenow")).toBe("330");
		expect(fixture.serverEvents).toBe(0);
	});

	for (const type of ["pointercancel", "lostpointercapture"]) {
		test(`${type} restores the pre-drag width and cleans capture`, () => {
			const { hook, fire, captures, root } = mount();
			fire("pointerdown");
			fire("pointermove", { clientX: 400 });
			fire(type);
			expect(hook.preferredWidth).toBe(280);
			expect(hook.currentWidth).toBe(280);
			expect(captures.size).toBe(0);
			expect(root.dataset.splitPaneDragging).toBeUndefined();
		});
	}

	test("keyboard arrows and Home/End use the available range and leave other keys alone", () => {
		const { hook, fire, handle } = mount({ width: 650 });
		expect(handle.attrs.get("aria-valuemax")).toBe("394");
		for (const [key, width] of [["ArrowRight", 290], ["ArrowLeft", 280], ["Home", 160], ["End", 394]]) {
			expect(fire("keydown", { key }).defaultPrevented).toBe(true);
			expect(hook.currentWidth).toBe(width);
			expect(handle.attrs.get("aria-valuetext")).toBe(`${width} pixels`);
		}
		expect(fire("keydown", { key: "Tab" }).defaultPrevented).toBe(false);
	});

	test("RTL reverses pointer and arrow deltas", () => {
		const { hook, fire } = mount({ direction: "rtl" });
		fire("keydown", { key: "ArrowLeft" });
		expect(hook.currentWidth).toBe(290);
		fire("pointerdown");
		fire("pointermove", { clientX: 240 });
		expect(hook.currentWidth).toBe(330);
	});

	test("container resize clamps without losing preferred width and stacks both panes when necessary", () => {
		const fixture = mount();
		fixture.fire("keydown", { key: "End" });
		fixture.resize(650);
		expect(fixture.hook.currentWidth).toBe(394);
		expect(fixture.hook.preferredWidth).toBe(480);
		fixture.resize(400);
		expect(fixture.handle.hidden).toBe(true);
		expect(fixture.handle.tabIndex).toBe(-1);
		expect(fixture.fire("keydown", { key: "Home" }).defaultPrevented).toBe(false);
		fixture.resize(900);
		expect(fixture.handle.hidden).toBe(false);
		expect(fixture.handle.tabIndex).toBe(0);
		expect(fixture.hook.currentWidth).toBe(480);
	});

	test("stacks even below configured pane minima when stack_at is disabled and cancels an active drag", () => {
		const fixture = mount({ stackAt: "0" });
		fixture.fire("pointerdown");
		fixture.fire("pointermove", { clientX: 350 });
		fixture.resize(350);
		expect(fixture.hook.splitStacked).toBe(true);
		expect(fixture.hook.preferredWidth).toBe(280);
		expect(fixture.captures.size).toBe(0);
	});

	test("LiveView morph updates keep the latest width, bind replacement handle and accept new bounds", () => {
		const fixture = mount();
		fixture.fire("pointerdown");
		fixture.fire("pointermove", { clientX: 350 });
		fixture.hook.beforeUpdate();
		expect(fixture.captures.size).toBe(0);
		const replacement = fixture.replaceHandle();
		fixture.root.dataset.initialWidth = "200";
		fixture.properties.clear();
		fixture.hook.updated();
		expect(replacement.attrs.get("aria-valuenow")).toBe("350");
		expect(fixture.properties.get("--dm-split-pane-width")).toBe("350px");
		fixture.root.dataset.maxWidth = "300";
		fixture.hook.updated();
		expect(replacement.attrs.get("aria-valuenow")).toBe("300");
		fixture.fire("keydown", { key: "Home" });
		expect(fixture.hook.currentWidth).toBe(160);
	});

	test("ignores secondary pointers, non-primary buttons and nested splitter handles", () => {
		const { fire, captures } = mount();
		fire("pointerdown", { isPrimary: false });
		fire("pointerdown", { button: 2 });
		const nested = { closest: () => nested };
		fire("pointerdown", {}, nested);
		expect(captures.size).toBe(0);
	});

	test("destroy disconnects its observer, releases capture and removes event listeners", () => {
		const { hook, fire, captures, observer } = mount();
		fire("pointerdown");
		hook.destroyed();
		mounted.splice(mounted.indexOf(hook), 1);
		expect(observer.disconnected).toBe(true);
		expect(captures.size).toBe(0);
		fire("keydown", { key: "End" });
		expect(hook.preferredWidth).toBe(280);
	});
});
