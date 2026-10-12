import { afterEach, describe, expect, test } from "bun:test";
import { DuskmoonReactForm } from "../../assets/js/react_form/index.js";

const mountedHooks = [];
afterEach(() => mountedHooks.splice(0).forEach((hook) => hook.destroyed()));
const tick = () => new Promise((resolve) => setTimeout(resolve, 5));

function checkbox(name, value, checked) {
	return Object.assign(new EventTarget(), {
		name,
		value,
		checked,
		type: "checkbox",
		closest: () => null,
	});
}

function mount(debounce = 0) {
	const controls = [
		checkbox("tool_names[]", "file.read", true),
		checkbox("tool_names[]", "file.write", false),
		checkbox("agent[toolset_ids][]", "tools", false),
		checkbox("agent[toolset_ids][]", "skills", true),
		checkbox("enabled", "on", true),
	];
	const form = Object.assign(new EventTarget(), {
		querySelectorAll: () => controls,
	});
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
			dataset: {},
			querySelector: (selector) =>
				selector === "[data-dm-react-form]" ? form : null,
			querySelectorAll: () => [],
			getAttribute: (name) => attrs[name] ?? null,
		},
		handleEvent: (event, handler) => handlers.set(event, handler),
		pushEventTo: (target, event, payload, reply) =>
			events.push({ target, event, payload, reply }),
	});
	hook.mounted();
	mountedHooks.push(hook);
	return { hook, form, controls, events, reset: handlers.get("dm:form:reset") };
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
			controls[1].dispatchEvent(new Event(type));
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
			controls[0].dispatchEvent(new Event(type));
			await tick();
			expect(events[1].payload.values.tool_names).toEqual(["file.write"]);
			controls[1].checked = false;
			controls[1].dispatchEvent(new Event(type));
			await tick();
			expect(events[2].payload.values.tool_names).toEqual([]);
			expect(events[2].payload.changed).toEqual(["tool_names"]);
		});
	}

	test("nested group events preserve their path and ordinary checkboxes stay boolean", async () => {
		const { controls, events } = mount();
		controls[2].checked = true;
		controls[2].dispatchEvent(new Event("change"));
		await tick();
		expect(events[0].payload.changed).toEqual(["agent", "toolset_ids"]);
		expect(events[0].payload.values.agent.toolset_ids).toEqual([
			"tools",
			"skills",
		]);
		controls[4].checked = false;
		controls[4].dispatchEvent(new Event("input"));
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
		controls[1].dispatchEvent(new Event("change"));
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
		controls[1].dispatchEvent(new Event("change"));
		await tick();
		expect(events).toEqual([]);
		hook.reconnected();
		controls[0].checked = false;
		controls[0].dispatchEvent(new Event("input"));
		await tick();
		expect(events[0].payload.values.tool_names).toEqual(["file.write"]);
		controls[1].checked = false;
		controls[1].dispatchEvent(new Event("change"));
		hook.destroyed();
		await tick();
		expect(events).toHaveLength(1);
		const values = structuredClone(hook.values);
		controls[0].checked = true;
		controls[0].dispatchEvent(new Event("input"));
		controls[0].dispatchEvent(new Event("change"));
		expect(hook.values).toEqual(values);
	});
});
