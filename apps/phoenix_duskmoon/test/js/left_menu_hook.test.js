import { afterEach, describe, expect, test } from "bun:test";
import { DuskmoonLeftMenuNavigation } from "../../assets/js/hooks/left_menu_navigation.js";
import { DuskmoonLeftMenu } from "../../assets/js/hooks/left_menu.js";

const mounted = [];
afterEach(() => {
	for (const hook of mounted.splice(0)) hook.destroyed();
});

describe("sticky left-menu active-page synchronization", () => {
	const success = [{ status: "fulfilled", value: { reply: { status: "ok" } } }];
	const settled = async () => {
		await Promise.resolve();
		await Promise.resolve();
	};

	function navigationHook(
		reply = success,
		{ available = true, active = "dashboard" } = {},
	) {
		const sent = [];
		const target = {};
		const targets = new Map(
			available ? [["sidebar:with.special[id]", target]] : [],
		);
		const hook = Object.assign(Object.create(DuskmoonLeftMenuNavigation), {
			el: {
				dataset: { activeNav: active, sidebarId: "sidebar:with.special[id]" },
				ownerDocument: { getElementById: (id) => targets.get(id) },
			},
			pushEventTo(target, event, payload) {
				sent.push({ target, event, payload });
				return typeof reply === "function" ? reply() : Promise.resolve(reply);
			},
		});
		hook.mounted();
		mounted.push(hook);
		return { hook, sent, target, targets };
	}

	test("targets the native element by literal id, deduplicates patches, and resends after reconnect", async () => {
		const { hook, sent, target } = navigationHook();
		await settled();
		hook.updated();
		expect(sent).toEqual([
			{
				target,
				event: "set_active_nav",
				payload: { active_nav: "dashboard" },
			},
		]);
		hook.el.dataset.activeNav = "settings";
		hook.updated();
		expect(sent.at(-1).payload).toEqual({ active_nav: "settings" });
		hook.reconnected();
		expect(sent).toHaveLength(3);
	});

	test("an empty active value clears highlighting, while a changed target id resends", async () => {
		const { hook, sent, targets } = navigationHook(success, { active: "" });
		await settled();
		expect(sent[0].payload).toEqual({ active_nav: "" });
		hook.updated();
		expect(sent).toHaveLength(1);
		const replacement = {};
		targets.set("another-sidebar", replacement);
		hook.el.dataset.sidebarId = "another-sidebar";
		hook.updated();
		expect(sent.at(-1).target).toBe(replacement);
		expect(sent).toHaveLength(2);
	});

	test("a remounted sidebar with the same id receives the unchanged active page", async () => {
		const { hook, sent, targets } = navigationHook();
		await settled();
		const replacement = {};
		targets.set(hook.el.dataset.sidebarId, replacement);
		hook.updated();
		expect(sent).toHaveLength(2);
		expect(sent[1]).toEqual({
			target: replacement,
			event: "set_active_nav",
			payload: { active_nav: "dashboard" },
		});
		await settled();
		hook.updated();
		expect(sent).toHaveLength(2);
	});

	test("unavailable target or missing data can retry after the next patch", () => {
		const { hook, sent, target, targets } = navigationHook(success, {
			available: false,
		});
		expect(sent).toHaveLength(0);
		targets.set(hook.el.dataset.sidebarId, target);
		hook.updated();
		expect(sent).toHaveLength(1);
		targets.clear();
		hook.updated();
		targets.set(hook.el.dataset.sidebarId, target);
		hook.updated();
		expect(sent).toHaveLength(2);
		delete hook.el.dataset.activeNav;
		hook.updated();
		expect(sent).toHaveLength(2);
		hook.el.dataset.activeNav = "dashboard";
		hook.updated();
		expect(sent).toHaveLength(3);
		delete hook.el.dataset.sidebarId;
		hook.updated();
		expect(sent).toHaveLength(3);
	});

	for (const reply of [
		undefined,
		[],
		[{ status: "rejected", reason: new Error("Disconnected") }],
		[{ status: "fulfilled", value: { reply: { status: "error" } } }],
		[{ status: "fulfilled", value: {} }],
		[
			...success,
			{ status: "fulfilled", value: { reply: { status: "error" } } },
		],
	]) {
		test(`allows retry after unsuccessful settled targets: ${JSON.stringify(reply)}`, async () => {
			const { hook, sent } = navigationHook(() => Promise.resolve(reply));
			await settled();
			hook.updated();
			expect(sent).toHaveLength(2);
		});
	}

	for (const failure of [
		() => Promise.reject(new Error("Disconnected")),
		() => {
			throw new Error("Disconnected");
		},
	]) {
		test(`allows retry after pushEventTo ${failure.toString().includes("reject") ? "rejects" : "throws"}`, async () => {
			const { hook, sent } = navigationHook(failure);
			await settled();
			hook.updated();
			expect(sent).toHaveLength(2);
		});
	}

	test("a stale failed request cannot clear a newer active page or reconnect request", async () => {
		const resolvers = [];
		const { hook, sent } = navigationHook(
			() => new Promise((resolve) => resolvers.push(resolve)),
		);
		hook.el.dataset.activeNav = "settings";
		hook.updated();
		resolvers[0]([]);
		await settled();
		hook.updated();
		expect(sent).toHaveLength(2);
		hook.reconnected();
		resolvers[1]([]);
		await settled();
		hook.updated();
		expect(sent).toHaveLength(3);
		resolvers[2](success);
		await settled();
	});

	test("destroy invalidates pending promises and prevents further sends", async () => {
		let reject;
		const { hook, sent } = navigationHook(
			() =>
				new Promise((_, fail) => {
					reject = fail;
				}),
		);
		hook.destroyed();
		reject(new Error("Disconnected"));
		await settled();
		expect(hook.navigationRequest).toBeNull();
		expect(hook.lastNavigation).toBeNull();
		hook.updated();
		hook.reconnected();
		expect(sent).toHaveLength(1);
	});
});

class Element extends EventTarget {
	constructor(attrs = {}) {
		super();
		this.attrs = new Map(Object.entries(attrs));
		this.dataset = {};
		const styles = new Map();
		this.style = {
			getPropertyValue: (name) => styles.get(name) || "",
			setProperty: (name, value) => styles.set(name, value),
			removeProperty: (name) => styles.delete(name),
		};
	}
	getAttribute(name) {
		return this.attrs.get(name) ?? null;
	}
	setAttribute(name, value) {
		this.attrs.set(name, value);
	}
	removeAttribute(name) {
		this.attrs.delete(name);
	}
}

function mount({
	collapsed = false,
	stored = null,
	storageUnavailable = false,
	storageKey = "sidebar",
} = {}) {
	const menuWindow = new EventTarget();
	const storage = new Map(stored === null ? [] : [[storageKey, stored]]);
	Object.defineProperty(menuWindow, "localStorage", {
		get() {
			if (storageUnavailable) throw new Error("Storage unavailable");
			return {
				getItem: (key) => storage.get(key) ?? null,
				setItem: (key, value) => storage.set(key, value),
			};
		},
	});
	const el = new Element();
	el.dataset = {
		collapsed: String(collapsed),
		storageKey,
		expandLabel: "Expand menu",
		collapseLabel: "Collapse menu",
	};
	const toggle = new Element();
	toggle.closest = () => toggle;
	const scroller = {
		scrollTop: 0,
		scrollTo({ top }) {
			this.scrollTop = top;
		},
	};
	const groups = [
		{ id: "overview", open: false },
		{ id: "settings", open: true },
	];
	const links = [];
	const surfaces = new Map();
	el.ownerDocument = {
		defaultView: menuWindow,
		getElementById: (id) => surfaces.get(id),
	};
	el.querySelector = () => scroller;
	el.querySelectorAll = (selector) =>
		({
			"[data-left-menu-toggle]": [toggle],
			"details[id]": groups,
			"[data-left-menu-tooltip]": links,
		})[selector];
	el.contains = (node) => node === toggle;
	const hook = Object.assign(Object.create(DuskmoonLeftMenu), { el });
	hook.mounted();
	mounted.push(hook);
	const click = (target = toggle) => {
		const event = new Event("click");
		Object.defineProperty(event, "target", { value: target });
		el.dispatchEvent(event);
	};
	const navigation = (phase, kind) =>
		menuWindow.dispatchEvent(
			new CustomEvent(`phx:page-loading-${phase}`, { detail: { kind } }),
		);
	return {
		hook,
		el,
		toggle,
		scroller,
		groups,
		storage,
		links,
		surfaces,
		click,
		navigation,
	};
}

describe("left-menu collapse and LiveView navigation", () => {
	test("delegates icon clicks, syncs accessible labels, and restores individual group states", () => {
		const { el, toggle, groups, storage, click } = mount();
		expect(toggle.getAttribute("aria-expanded")).toBe("true");
		expect(toggle.getAttribute("aria-label")).toBe("Collapse menu");
		expect(toggle.getAttribute("title")).toBe("Collapse menu");
		click({ closest: () => toggle });
		expect(el.dataset.collapsed).toBe("true");
		expect(toggle.getAttribute("aria-expanded")).toBe("false");
		expect(toggle.getAttribute("aria-label")).toBe("Expand menu");
		expect(toggle.getAttribute("title")).toBe("Expand menu");
		expect(groups.map((group) => group.open)).toEqual([true, true]);
		expect(storage.get("sidebar")).toBe("true");
		click();
		expect(groups.map((group) => group.open)).toEqual([false, true]);
		expect(toggle.getAttribute("title")).toBe("Collapse menu");
		expect(storage.get("sidebar")).toBe("false");
		click({ closest: () => null });
		expect(el.dataset.collapsed).toBe("false");
	});

	test("restores saved collapse without treating forced-open groups as user choices", () => {
		const { hook, groups, el, click } = mount({ stored: "true" });
		expect(el.dataset.collapsed).toBe("true");
		hook.beforeUpdate();
		groups.splice(
			0,
			2,
			{ id: "overview", open: true },
			{ id: "settings", open: false },
			{ id: "new", open: false },
		);
		el.dataset.collapsed = "false";
		hook.updated();
		expect(el.dataset.collapsed).toBe("true");
		expect(groups.map((group) => group.open)).toEqual([true, true, true]);
		click();
		expect(groups.map((group) => group.open)).toEqual([false, true, false]);
	});

	test("patch restores client group choices and the current scrolling element", () => {
		const { hook, groups, scroller } = mount();
		groups[0].open = true;
		groups[1].open = false;
		scroller.scrollTop = 192;
		hook.beforeUpdate();
		groups.splice(
			0,
			2,
			{ id: "overview", open: false },
			{ id: "settings", open: true },
		);
		const replacement = {
			scrollTop: 0,
			scrollTo({ top }) {
				this.scrollTop = top;
			},
		};
		hook.el.querySelector = () => replacement;
		hook.updated();
		expect(groups.map((group) => group.open)).toEqual([true, false]);
		expect(replacement.scrollTop).toBe(192);
	});

	test("nested initial start never overwrites redirect position, including the later initial patch", () => {
		const { hook, navigation, scroller } = mount();
		scroller.scrollTop = 280;
		navigation("start", "redirect");
		scroller.scrollTop = 0;
		navigation("start", "initial");
		navigation("stop", "redirect");
		expect(scroller.scrollTop).toBe(280);
		scroller.scrollTop = 0;
		hook.beforeUpdate();
		hook.updated();
		expect(scroller.scrollTop).toBe(280);
		scroller.scrollTop = 0;
		navigation("stop", "initial");
		expect(scroller.scrollTop).toBe(280);
		// Completing initial releases the snapshot for the next navigation.
		scroller.scrollTop = 88;
		navigation("start", "patch");
		scroller.scrollTop = 0;
		navigation("stop", "patch");
		expect(scroller.scrollTop).toBe(88);
	});

	test("zero is a valid saved position; unrelated loading events do not alter snapshots", () => {
		const { navigation, scroller } = mount();
		navigation("start", "initial");
		scroller.scrollTop = 42;
		navigation("start", "patch");
		navigation("stop", "element");
		expect(scroller.scrollTop).toBe(42);
		navigation("stop", "initial");
		expect(scroller.scrollTop).toBe(0);
		scroller.scrollTop = 60;
		navigation("start", "element");
		navigation("stop", "patch");
		expect(scroller.scrollTop).toBe(60);
	});

	test("storage errors and absent keys preserve usable in-page toggles", () => {
		const unavailable = mount({ storageUnavailable: true });
		unavailable.click();
		expect(unavailable.el.dataset.collapsed).toBe("true");
		unavailable.click();
		expect(unavailable.el.dataset.collapsed).toBe("false");
		const withoutKey = mount({ storageKey: "", stored: "true" });
		expect(withoutKey.el.dataset.collapsed).toBe("false");
		withoutKey.click();
		expect(withoutKey.storage.size).toBe(1);
	});

	test("reconnect reapplies state without reverting a newer manual scroll position", () => {
		const { hook, scroller, el, click } = mount();
		click();
		el.dataset.collapsed = "false";
		scroller.scrollTop = 150;
		hook.reconnected();
		expect(el.dataset.collapsed).toBe("true");
		expect(scroller.scrollTop).toBe(150);
	});

	test("destroy removes click and both window navigation listeners", () => {
		const { hook, el, click, navigation, scroller } = mount();
		hook.destroyed();
		click();
		expect(el.dataset.collapsed).toBe("false");
		scroller.scrollTop = 120;
		navigation("start", "patch");
		scroller.scrollTop = 10;
		navigation("stop", "patch");
		expect(scroller.scrollTop).toBe(10);
		expect(hook.navigationScrollTop).toBeNull();
	});

	test("tooltip association follows collapse while retaining unrelated descriptions and styles", () => {
		const { hook, links, surfaces, click } = mount();
		const link = new Element({
			"aria-describedby": "help item-tooltip",
			interestfor: "item-tooltip",
			title: "Item",
		});
		link.dataset = {
			leftMenuTooltip: "item-tooltip",
			leftMenuAnchor: "--anchor-item-tooltip",
			leftMenuTooltipTitle: "Item",
		};
		link.style.setProperty("anchor-name", "--custom, --anchor-item-tooltip");
		link.style.setProperty("color", "red");
		let open = true;
		surfaces.set("item-tooltip", {
			matches: () => open,
			hidePopover() {
				open = false;
			},
		});
		links.push(link);
		hook.beforeUpdate();
		hook.updated();
		expect(link.getAttribute("aria-describedby")).toBe("help");
		expect(link.getAttribute("interestfor")).toBeNull();
		expect(link.getAttribute("title")).toBeNull();
		expect(link.style.getPropertyValue("anchor-name")).toBe("--custom");
		expect(open).toBe(false);
		click();
		expect(link.getAttribute("aria-describedby")).toBe("help item-tooltip");
		expect(link.getAttribute("interestfor")).toBe("item-tooltip");
		expect(link.getAttribute("title")).toBe("Item");
		expect(link.style.getPropertyValue("anchor-name")).toBe(
			"--custom, --anchor-item-tooltip",
		);
		click();
		expect(link.style.getPropertyValue("color")).toBe("red");
		expect(link.getAttribute("aria-describedby")).toBe("help");
	});
});
