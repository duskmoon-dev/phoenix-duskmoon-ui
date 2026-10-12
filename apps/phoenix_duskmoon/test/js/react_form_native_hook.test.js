import { afterEach, describe, expect, test } from "bun:test";
import { DuskmoonReactForm } from "../../assets/js/react_form/index.js";

const mountedHooks = [];
afterEach(() => mountedHooks.splice(0).forEach((hook) => hook.destroyed()));
const tick = () => new Promise((resolve) => setTimeout(resolve, 5));

class NativeControl extends EventTarget {
	dispatchEvent(event) {
		const result = super.dispatchEvent(event);
		if (event.bubbles && this.form?.controls.includes(this)) {
			Object.defineProperty(event, "target", { value: this });
			return this.form.dispatchEvent(event) && result;
		}
		return result;
	}
}

function input(name, value, type = "text") {
	return Object.assign(new NativeControl(), { name, value, type, closest: () => null });
}

function checkbox(name, value, checked) {
	return Object.assign(input(name, value, "checkbox"), {
		name,
		value,
		checked,
		type: "checkbox",
		closest: () => null,
	});
}

function mount(debounce = 0, { values, fields = [] } = {}) {
	const controls = [
		checkbox("tool_names[]", "file.read", true),
		checkbox("tool_names[]", "file.write", false),
		checkbox("agent[toolset_ids][]", "tools", false),
		checkbox("agent[toolset_ids][]", "skills", true),
		checkbox("enabled", "on", true),
	];
	const form = Object.assign(new EventTarget(), {
		querySelectorAll: () => controls,
		controls,
		noValidate: true,
	});
	controls.forEach((control) => { control.form = form; });
	const events = [],
		handlers = new Map();
	const attrs = {
		"phx-change": "validate",
		"phx-submit": "save",
		"phx-target": "#agent",
		"phx-debounce": String(debounce),
	};
	const hook = Object.assign(Object.create(DuskmoonReactForm), {
		el: {
			id: "agent-form",
			dataset: values ? { initialValues: JSON.stringify(values) } : {},
			querySelector: (selector) =>
				selector === "[data-dm-react-form]" ? form : null,
			querySelectorAll: () => fields.map((name) => ({ dataset: { dmReactField: JSON.stringify({ name }) } })),
			getAttribute: (name) => attrs[name] ?? null,
		},
		handleEvent: (event, handler) => handlers.set(event, handler),
		pushEventTo: (target, event, payload, reply) =>
			events.push({ target, event, payload, reply }),
	});
	if (fields.length) hook.mountFields = () => {};
	hook.mounted();
	mountedHooks.push(hook);
	const add = (control) => { control.form = form; controls.push(control); return control; };
	return { hook, form, controls, events, add, reset: handlers.get("dm:form:reset") };
}

describe("native React Form checkbox groups", () => {
	test("mount collects group selections and singleton booleans", () => {
		const { hook } = mount();
		expect(hook.values).toEqual({
			tool_names: ["file.read"],
			agent: { toolset_ids: ["skills"] },
			enabled: true,
		});
	});

	for (const type of ["input", "change"]) {
		test(`${type} sends all selected group values and clears the last selection`, async () => {
			const { controls, events } = mount();
			controls[1].checked = true;
			controls[1].dispatchEvent(new Event(type, { bubbles: true }));
			await tick();
			expect(events[0]).toMatchObject({
				target: "#agent",
				event: "validate",
				payload: {
					id: "agent-form",
					changed: ["tool_names"],
					values: { tool_names: ["file.read", "file.write"], enabled: true },
				},
			});
			controls[0].checked = false;
			controls[0].dispatchEvent(new Event(type, { bubbles: true }));
			await tick();
			expect(events[1].payload.values.tool_names).toEqual(["file.write"]);
			controls[1].checked = false;
			controls[1].dispatchEvent(new Event(type, { bubbles: true }));
			await tick();
			expect(events[2].payload.values.tool_names).toEqual([]);
			expect(events[2].payload.changed).toEqual(["tool_names"]);
		});
	}

	test("nested group events preserve their path and ordinary checkboxes stay boolean", async () => {
		const { controls, events } = mount();
		controls[2].checked = true;
		controls[2].dispatchEvent(new Event("change", { bubbles: true }));
		await tick();
		expect(events[0].payload.changed).toEqual(["agent", "toolset_ids"]);
		expect(events[0].payload.values.agent.toolset_ids).toEqual([
			"tools",
			"skills",
		]);
		controls[4].checked = false;
		controls[4].dispatchEvent(new Event("input", { bubbles: true }));
		await tick();
		expect(events[1].payload.values.enabled).toBe(false);
		expect(events[1].payload.values.tool_names).toEqual(["file.read"]);
	});

	test("targeted reset restores each checkbox by its value, including empty groups", () => {
		const { hook, controls, reset } = mount();
		const values = {
			tool_names: ["file.write"],
			agent: { toolset_ids: [] },
			enabled: false,
		};
		reset({ id: "another-form", values });
		expect(hook.values.tool_names).toEqual(["file.read"]);
		reset({ id: "agent-form", values });
		expect(hook.values).toEqual(values);
		expect(controls.map((control) => control.checked)).toEqual([
			false,
			true,
			false,
			false,
			false,
		]);
		reset({ id: "agent-form" });
		expect(controls.map((control) => control.checked)).toEqual([
			true,
			false,
			false,
			true,
			true,
		]);
	});

	test("native reset restores initial selections and cancels pending change events", async () => {
		const { hook, form, controls, events } = mount(20);
		controls[0].checked = false;
		controls[1].checked = true;
		controls[1].dispatchEvent(new Event("change", { bubbles: true }));
		form.dispatchEvent(new Event("reset"));
		await new Promise((resolve) => setTimeout(resolve, 30));
		expect(hook.values).toEqual(hook.initialValues);
		expect(controls.map((control) => control.checked)).toEqual([
			true,
			false,
			false,
			true,
			true,
		]);
		expect(events).toEqual([]);
		expect(form.dispatchEvent(new Event("submit", { cancelable: true }))).toBe(
			false,
		);
		expect(events.at(-1)).toMatchObject({
			event: "save",
			payload: {
				values: {
					tool_names: ["file.read"],
					agent: { toolset_ids: ["skills"] },
					enabled: true,
				},
			},
		});
	});

	test("disconnect suppresses delivery and destruction removes native listeners", async () => {
		const { hook, controls, events } = mount();
		hook.disconnected();
		controls[1].checked = true;
		controls[1].dispatchEvent(new Event("change", { bubbles: true }));
		await tick();
		expect(events).toEqual([]);
		hook.reconnected();
		controls[0].checked = false;
		controls[0].dispatchEvent(new Event("input", { bubbles: true }));
		await tick();
		expect(events[0].payload.values.tool_names).toEqual(["file.write"]);
		controls[1].checked = false;
		controls[1].dispatchEvent(new Event("change", { bubbles: true }));
		hook.destroyed();
		await tick();
		expect(events).toHaveLength(1);
		const values = structuredClone(hook.values);
		controls[0].checked = true;
		controls[0].dispatchEvent(new Event("input", { bubbles: true }));
		controls[0].dispatchEvent(new Event("change", { bubbles: true }));
		expect(hook.values).toEqual(values);
	});

	test("submission snapshots changed hidden, replacement and new typed controls", () => {
		const { hook, controls, events, add } = mount(0, {
			values: { provider: "old", profile: { title: "React draft", enabled: false } },
			fields: [["profile", "title"], ["profile", "enabled"]],
		});
		const hidden = add(input("provider", "first", "hidden"));
		hidden.value = "programmatic";
		hook.submit();
		expect(events[0].payload.values.provider).toBe("programmatic");
		const replacement = input("provider", "replacement", "hidden");
		replacement.form = hidden.form;
		controls.splice(controls.indexOf(hidden), 1, replacement);
		add(input("profile[seats]", "0", "number"));
		add(input("profile[empty]", "", "number"));
		add(input("profile[title]", "native collision"));
		add(input("profile", "native ancestor collision"));
		add(input("profile[title][nested]", "native descendant collision"));
		const marked = add(input("alien", "React subtree"));
		marked.closest = () => ({});
		hook.submit();
		expect(events[1].payload.values).toMatchObject({
			provider: "replacement",
			profile: { title: "React draft", enabled: false, seats: 0, empty: null },
		});
		expect(events[1].payload.values).not.toHaveProperty("alien");
		expect(hidden.value).toBe("programmatic");
	});

	test("delegated events use current group nodes and ignore detached or React-owned controls", async () => {
		const { hook, form, controls, events, add, reset } = mount();
		const detached = controls[1];
		const replacement = checkbox("tool_names[]", "file.search", true);
		replacement.form = form;
		controls.splice(1, 1, replacement);
		const added = add(checkbox("tool_names[]", "file.write", true));
		replacement.dispatchEvent(new Event("input", { bubbles: true }));
		await tick();
		expect(events[0].payload.values.tool_names).toEqual(["file.read", "file.search", "file.write"]);
		added.checked = false;
		added.dispatchEvent(new Event("change", { bubbles: true }));
		await tick();
		expect(events[1].payload.values.tool_names).toEqual(["file.read", "file.search"]);
		const marked = add(input("alien", "ignored"));
		marked.closest = () => ({});
		marked.dispatchEvent(new Event("change", { bubbles: true }));
		detached.dispatchEvent(new Event("change", { bubbles: true }));
		form.dispatchEvent(new Event("input"));
		await tick();
		expect(events).toHaveLength(2);
		expect(hook.values).not.toHaveProperty("alien");
		reset({ id: "agent-form", values: { tool_names: ["file.search"], agent: { toolset_ids: [] }, enabled: false } });
		expect(controls[0].checked).toBe(false);
		expect(replacement.checked).toBe(true);
		expect(added.checked).toBe(false);
		reset({ id: "agent-form" });
		expect(controls[0].checked).toBe(true);
		expect(replacement.checked).toBe(false);
		expect(added.checked).toBe(false);
		hook.destroyed();
		const values = structuredClone(hook.values);
		const afterDestroy = add(input("new_after_destroy", "ignored"));
		afterDestroy.dispatchEvent(new Event("input", { bubbles: true }));
		added.checked = true;
		added.dispatchEvent(new Event("change", { bubbles: true }));
		await tick();
		expect(hook.values).toEqual(values);
		expect(events).toHaveLength(2);
	});

	test("classic direct submit reports enabled native validation and blocks invalid values", () => {
		const { hook, form, events } = mount();
		let reports = 0;
		form.noValidate = false;
		form.reportValidity = () => { reports++; return false; };
		hook.submit();
		expect(reports).toBe(1);
		expect(events).toEqual([]);
		form.reportValidity = () => { reports++; return true; };
		hook.submit();
		expect(reports).toBe(2);
		expect(events[0].event).toBe("save");
		form.noValidate = true;
		form.reportValidity = () => { throw new Error("Default novalidate must bypass browser validation"); };
		hook.submit();
		expect(events).toHaveLength(2);
	});
});
