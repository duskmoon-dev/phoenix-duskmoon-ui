import { describe, expect, test } from "bun:test";
import React from "react";
import { renderToStaticMarkup } from "react-dom/server";
import { ReactField } from "../../assets/js/react_form/component.js";

function field(config, props = {}) {
	return React.createElement(ReactField, {
		config,
		onChange: () => {},
		...props,
	});
}

function render(type, props = {}, config = {}) {
	return renderToStaticMarkup(
		field(
			{ name: ["profile", "value"], type, label: "Profile value", ...config },
			props,
		),
	);
}

describe("React form upstream field composition", () => {
	test("labels address native controls through upstream Form.Item IDs", () => {
		for (const type of [
			"text",
			"email",
			"password",
			"number",
			"checkbox",
			"textarea",
		]) {
			const html = render(type);
			const labelId = html.match(
				/<label[^>]*for="([^"]+)"[^>]*>Profile value<\/label>/,
			)?.[1];

			expect(labelId).toBeDefined();
			expect(html).toContain('class="form-item-label"');
			expect(html).toMatch(
				new RegExp(`<(?:input|textarea)\\b[^>]*id="${labelId}"`),
			);
		}
	});

	test("nested field paths supply a fallback label", () => {
		const html = render(
			"text",
			{ value: "Moon" },
			{ label: null, name: ["address", "city"] },
		);

		expect(html).toContain('aria-label="address.city"');
		expect(html).toMatch(/<label[^>]*>address.city<\/label>/);
		expect(html).toContain('value="Moon"');
	});

	test("select labels and backend errors target the interactive trigger", () => {
		for (const type of ["select", "multiselect"]) {
			const html = render(
				type,
				{ errors: ["Choose a value"] },
				{ options: [{ value: 2, label: "Two" }] },
			);
			const id = html.match(/<label[^>]*for="([^"]+)"/)?.[1];
			const trigger = html.match(
				/<button[^>]*aria-haspopup="listbox"[^>]*>/,
			)?.[0];
			expect(trigger).toContain(`id="${id}"`);
			expect(trigger).toContain('aria-label="Profile value"');
			expect(trigger).toContain('aria-invalid="true"');
			const errorId = trigger.match(/aria-describedby="([^"]+)"/)?.[1];
			expect(html).toContain(`id="${errorId}" role="alert"`);
		}
	});

	test("field errors link each control to its own upstream alert", () => {
		const html = renderToStaticMarkup(
			React.createElement(
				React.Fragment,
				null,
				field(
					{ name: "name", type: "text", label: "Name" },
					{ errors: ["Required", "Use <letters>"] },
				),
				field(
					{ name: "age", type: "number", label: "Age" },
					{ errors: ["Must be positive"] },
				),
			),
		);
		const errorIds = [...html.matchAll(/aria-describedby="([^"]+)"/g)].map(
			([, id]) => id,
		);

		expect(errorIds).toHaveLength(2);
		expect(new Set(errorIds).size).toBe(2);
		errorIds.forEach((id) => {
			expect(html).toContain(`id="${id}" role="alert" class="form-error-list"`);
		});
		expect([...html.matchAll(/aria-invalid="true"/g)]).toHaveLength(2);
		expect(html).toContain("<div>Required</div><div>Use &lt;letters&gt;</div>");
		expect(html).toContain("<div>Must be positive</div>");
	});

	test("valid fields omit error announcements and invalid attributes", () => {
		for (const errors of [undefined, []]) {
			const html = render("text", { errors });

			expect(html).not.toContain("aria-invalid");
			expect(html).not.toContain("aria-describedby");
			expect(html).not.toContain("form-error-list");
			expect(html).not.toContain("form-item-error");
		}
	});

	test("preserves numeric zero and checked boolean values", () => {
		expect(render("number", { value: 0 })).toMatch(/<input[^>]*value="0"/);
		expect(render("number", { value: null })).toMatch(/<input[^>]*value=""/);
		expect(render("checkbox", { value: true })).toMatch(
			/<input[^>]*checked=""/,
		);
		expect(render("checkbox", { value: false })).not.toContain('checked=""');
	});

	test("numeric select values resolve their labels and multiple selections", () => {
		const config = {
			options: [
				{ value: 2, label: "Two" },
				{ value: 3, label: "Three" },
			],
		};
		const single = render("select", { value: 2 }, config);
		const multiple = render("multiselect", { value: [2, 3] }, config);

		expect(single).toContain('class="select-selection">Two</span>');
		expect(multiple).toContain('class="select-tag">Two</span>');
		expect(multiple).toContain('class="select-tag">Three</span>');
	});

	test("disconnected fields disable their native controls", () => {
		for (const type of ["text", "number", "checkbox", "textarea"]) {
			expect(render(type, { disabled: true })).toMatch(
				/<(?:input|textarea)\b[^>]*disabled=""/,
			);
		}
		expect(render("select", { disabled: true })).toMatch(
			/<button[^>]*disabled=""/,
		);
	});
});
