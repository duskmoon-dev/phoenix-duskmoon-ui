import { describe, expect, mock, test } from "bun:test";
import React from "react";
import { renderToStaticMarkup } from "react-dom/server";
import { compileForm } from "@duskmoon-dev/components/json-schema-form";
import {
	ReactSchemaForm,
	changedPath,
	schemaErrors,
} from "../../assets/js/react_form/schema.js";

mock.module("react-dom/client", () => ({
	createRoot: () => ({
		render(node) {
			this.node = node;
		},
		unmount: mock(() => {}),
	}),
}));
const { DuskmoonReactForm } = await import(
	"../../assets/js/react_form/index.js"
);

const schema = {
	type: "object",
	required: ["profile"],
	properties: {
		profile: {
			type: "object",
			required: ["name"],
			properties: {
				name: { type: "string", title: "Name", minLength: 1, default: "Moon" },
				seats: { type: "integer", default: 0 },
				enabled: { type: "boolean", default: false },
				tier: {
					type: "integer",
					enum: [1, 2],
					default: 2,
					"x-widget": "select",
					"x-options": [
						{ value: 1, label: "Basic" },
						{ value: 2, label: "Team" },
					],
				},
			},
		},
		members: { type: "array", items: { type: "string" }, default: ["Ada"] },
	},
};

function hook({ values, target, debounce = "0" } = {}) {
	const attributes = {
		"phx-change": "validate",
		"phx-submit": "save",
		"phx-target": target,
		"phx-debounce": debounce,
	};
	const events = [];
	const handlers = new Map();
	const instance = Object.assign(Object.create(DuskmoonReactForm), {
		el: {
			id: "schema-profile",
			dataset: {
				schema: JSON.stringify(schema),
				...(values === undefined
					? {}
					: { initialValues: JSON.stringify(values) }),
			},
			querySelector: (selector) =>
				selector === "[data-dm-react-schema]" ? {} : null,
			getAttribute: (key) => attributes[key],
		},
		handleEvent: (event, handler) => handlers.set(event, handler),
		pushEvent: (event, payload, reply) =>
			events.push({ event, payload, reply }),
		pushEventTo: (target, event, payload, reply) =>
			events.push({ target, event, payload, reply }),
	});
	instance.mounted();
	return {
		instance,
		events,
		handlers,
		props: () => instance.schemaRoot.node.props,
	};
}

describe("Published schema form integration", () => {
	test("renders upstream controls, typed defaults and linked backend errors", () => {
		const compiled = compileForm(schema);
		const values = compiled.initialValue();
		expect(values).toEqual({
			profile: { name: "Moon", seats: 0, enabled: false, tier: 2 },
			members: ["Ada"],
		});
		const html = renderToStaticMarkup(
			React.createElement(ReactSchemaForm, {
				compiled,
				value: values,
				errors: { "/profile/name": "Reserved name" },
				onSubmit: () => {},
			}),
		);
		expect(html).toContain('class="form form-vertical schema-form"');
		expect(html).toContain('value="0"');
		expect(html).toContain("Reserved name");
		const errorId = html.match(/aria-describedby="([^"]+)"/)?.[1];
		expect(html).toContain(
			`id="${errorId}" class="schema-field-error" role="alert">Reserved name`,
		);
		expect(html).toContain("<legend>tier</legend>");
		expect(html).toContain("Team");
		expect(html).toContain("Remove members 1");
		expect(
			compiled.validate({ ...values, profile: { ...values.profile, name: "" } })
				.valid,
		).toBe(false);
	});

	test("disconnected schema disables its upstream form controls as a group", () => {
		const html = renderToStaticMarkup(
			React.createElement(ReactSchemaForm, {
				schema,
				disabled: true,
				onSubmit: () => {},
			}),
		);
		expect(html).toStartWith('<fieldset disabled="">');
		expect(html.match(/<form\b/g)).toHaveLength(1);
	});

	test("adapts nested, dotted, array and escaped pointer backend errors", () => {
		expect(
			schemaErrors({
				profile: { name: ["Required", "Reserved"] },
				members: [{ email: ["Invalid"] }],
				"profile.seats": ["Too small"],
				"/profile/tier": "Unsupported",
				"": "Rejected",
				"a/b~c": ["Invalid key"],
				ignored: [],
			}),
		).toEqual({
			"/profile/name": "Required; Reserved",
			"/members/0/email": "Invalid",
			"/profile/seats": "Too small",
			"/profile/tier": "Unsupported",
			"": "Rejected",
			"/a~1b~0c": "Invalid key",
		});
	});

	test("reports field paths and common parent paths for bulk changes", () => {
		expect(
			changedPath({ profile: { name: "Moon" } }, { profile: { name: "Sun" } }),
		).toEqual(["profile", "name"]);
		expect(
			changedPath({ members: ["Ada"] }, { members: ["Ada", "Grace"] }),
		).toEqual(["members", "1"]);
		expect(
			changedPath(
				{ profile: { name: "Moon", seats: 0 } },
				{ profile: { name: "Sun", seats: 1 } },
			),
		).toEqual(["profile"]);
		expect(changedPath({ a: 1, b: 2 }, { a: 3, b: 4 })).toEqual([]);
	});

	test("changes and submits typed values through existing targeted LiveView events", async () => {
		const { instance, events, props } = hook({ target: "#editor" });
		const values = {
			...instance.values,
			profile: { ...instance.values.profile, seats: 3 },
		};
		props().onChange(values);
		await Bun.sleep(5);
		expect(events[0]).toMatchObject({
			target: "#editor",
			event: "validate",
			payload: {
				id: "schema-profile",
				values,
				revision: 1,
				changed: ["profile", "seats"],
			},
		});
		expect(events[0].payload.values.profile.enabled).toBe(false);
		events[0].reply({
			status: "error",
			errors: { profile: { seats: ["Quota exceeded"] } },
		});
		expect(props().errors).toEqual({ "/profile/seats": "Quota exceeded" });
		props().onSubmit(values);
		expect(events[1]).toMatchObject({
			event: "save",
			payload: { values, revision: 2 },
		});
		expect(events[1].payload).not.toHaveProperty("changed");
		instance.destroyed();
	});

	test("new drafts ignore stale replies before the debounced event is sent", () => {
		const { instance, events, props } = hook({ debounce: "1000" });
		props().onSubmit(instance.values);
		props().onChange({
			...instance.values,
			profile: { ...instance.values.profile, name: "Sun" },
		});
		events[0].reply({
			status: "error",
			errors: { "/profile/name": "Old error" },
		});
		expect(props().errors).toEqual({});
		instance.destroyed();
		events[0].reply({ status: "error", errors: { "": "Late error" } });
		expect(instance.errors).toEqual({});
		expect(instance.schemaRoot.unmount).toHaveBeenCalledTimes(1);
	});

	test("explicit reset clears errors and pending changes and ignores other form IDs", async () => {
		const { instance, events, handlers, props } = hook({ debounce: "20" });
		const original = structuredClone(instance.values);
		props().onSubmit(original);
		events[0].reply({
			status: "error",
			errors: { "/profile/name": "Reserved" },
		});
		props().onChange({
			...original,
			profile: { ...original.profile, name: "Sun" },
		});
		handlers.get("dm:form:reset")({ id: "another", values: {} });
		expect(instance.values.profile.name).toBe("Sun");
		const resetValues = { ...original, members: ["Grace"] };
		handlers.get("dm:form:reset")({
			id: "schema-profile",
			values: resetValues,
		});
		expect(props().value).toEqual(resetValues);
		expect(props().errors).toEqual({});
		expect(instance.schemaRevision).toBe(1);
		await Bun.sleep(30);
		expect(events).toHaveLength(1);
		events[0].reply({
			status: "error",
			errors: { "/profile/name": "Stale after reset" },
		});
		expect(props().errors).toEqual({});
		props().onReset();
		expect(instance.values).toEqual(original);
		instance.destroyed();
	});

	test("disconnect cancels pending validation while preserving the draft", async () => {
		const { instance, events, props } = hook({ debounce: "20" });
		props().onChange({ ...instance.values, profile: { ...instance.values.profile, name: "Sun" } });
		instance.disconnected();
		await Bun.sleep(30);
		expect(events).toHaveLength(0);
		expect(instance.values.profile.name).toBe("Sun");
		instance.reconnected();
		props().onSubmit(instance.values);
		expect(events[0].payload.values.profile.name).toBe("Sun");
		instance.destroyed();
	});

	test("preserves supplied values and disables transport while disconnected", () => {
		const supplied = {
			profile: { name: "Ada", seats: 8, tier: 1, enabled: true },
			members: [],
		};
		const { instance, events, props } = hook({ values: supplied });
		expect(props().value).toEqual(supplied);
		instance.disconnected();
		expect(props().disabled).toBe(true);
		props().onSubmit(supplied);
		expect(events).toHaveLength(0);
		instance.reconnected();
		expect(props().disabled).toBe(false);
		props().onSubmit(supplied);
		expect(events).toHaveLength(1);
		instance.destroyed();
	});
});
