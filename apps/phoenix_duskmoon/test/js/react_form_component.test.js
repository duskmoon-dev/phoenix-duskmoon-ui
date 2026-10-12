import { describe, expect, test } from "bun:test";
import React from "react";
import { renderToStaticMarkup } from "react-dom/server";
import { ReactField } from "../../assets/js/react_form/component.js";
import { mkdtemp, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

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

	test("application disabling survives connection state changes for every field", () => {
		for (const type of ["text", "email", "password", "number", "checkbox", "textarea", "select", "multiselect"]) {
			for (const disconnected of [false, true, false]) {
				const html = render(type, { disabled: disconnected }, { disabled: true });
				expect(html).toMatch(/<(?:input|textarea|button)\b[^>]*disabled=""/);
			}
			expect(render(type, { disabled: false }, { disabled: false })).not.toContain('disabled=""');
		}
	});

	test("text controls receive supported attributes without numeric or textarea-only options", () => {
		for (const type of ["text", "email", "password"]) {
			const html = render(type, {}, { placeholder: "Enter value", autocomplete: "off", required: true, readonly: true, min: 1, max: 10, step: 2, rows: 5 });
			const input = html.match(/<input\b[^>]*>/)?.[0];
			expect(input).toContain('placeholder="Enter value"');
			expect(input).toContain('autoComplete="off"');
			expect(input).toContain('required=""');
			expect(input).toContain('readOnly=""');
			expect(input).not.toMatch(/\b(?:min|max|step|rows)=/);
		}
	});

	test("textarea rows and checkbox required target the controls", () => {
		const textarea = render("textarea", {}, { placeholder: "Notes", autocomplete: "off", required: true, readonly: true, rows: 5 }).match(/<textarea\b[^>]*>/)?.[0];
		expect(textarea).toContain('placeholder="Notes"');
		expect(textarea).toContain('autoComplete="off"');
		expect(textarea).toContain('required=""');
		expect(textarea).toContain('readOnly=""');
		expect(textarea).toContain('rows="5"');
		const checkbox = render("checkbox", {}, { required: true, readonly: true, placeholder: "Ignored", rows: 5 }).match(/<input\b[^>]*>/)?.[0];
		expect(checkbox).toContain('required=""');
		expect(checkbox).not.toMatch(/\b(?:readOnly|placeholder|rows)=/);
	});

	test("number attributes use upstream bounds and disable read-only stepping", () => {
		const config = { placeholder: "Count", autocomplete: "off", required: true, readonly: true, min: 0, max: 4, step: 2 };
		const html = render("number", { value: 2 }, config);
		const input = html.match(/<input\b[^>]*>/)?.[0];
		expect(input).toContain('placeholder="Count"');
		expect(input).toContain('autoComplete="off"');
		expect(input).toContain('required=""');
		expect(input).toContain('readOnly=""');
		expect(html).not.toContain('aria-label="Increase value"');
		expect(html).not.toContain('aria-label="Decrease value"');
		expect(render("number", { value: 4 }, { ...config, readonly: false })).toMatch(/<button[^>]*disabled=""[^>]*aria-label="Increase value"/);
		expect(render("number", { value: 0 }, { ...config, readonly: false })).toMatch(/<button[^>]*disabled=""[^>]*aria-label="Decrease value"/);
	});

	test("select placeholders use the upstream selection UI", () => {
		for (const type of ["select", "multiselect"]) {
			expect(render(type, {}, { placeholder: "Choose a moon" })).toContain('class="select-placeholder">Choose a moon</span>');
		}
	});

	test("mounted controls preserve required triggers, disabling and numeric constraints", async () => {
		const directory = await mkdtemp(join(tmpdir(), "dm-react-field-"));
		let server, browser, timeout;
		try {
			const entry = join(directory, "controls.js");
			await writeFile(entry, `
import React from ${JSON.stringify(fileURLToPath(import.meta.resolve("react")))};
import {createRoot} from ${JSON.stringify(fileURLToPath(import.meta.resolve("react-dom/client")))};
import {flushSync} from ${JSON.stringify(fileURLToPath(import.meta.resolve("react-dom")))};
import {ReactField} from ${JSON.stringify(fileURLToPath(new URL("../../assets/js/react_form/component.js", import.meta.url)))};
const host = document.querySelector('#controls');
const root = createRoot(host);
const changes = [];
let config, value, disabled;
const assert = (condition, message) => { if (!condition) throw new Error(message); };
function render() {
  root.render(React.createElement(ReactField, {config, value, disabled, key: config.type,
    onChange(next) { changes.push(next); value = next; render(); }}));
}
function mount(nextConfig, nextValue, disconnected = false) {
  config = nextConfig; value = nextValue; disabled = disconnected;
  flushSync(render);
}
try {
  for (const type of ['select', 'multiselect']) {
    const field = {name: 'role', type, label: 'Role', required: true, placeholder: 'Choose a role',
      options: [{value: 2, label: 'Two'}, {value: 3, label: 'Three'}]};
    mount(field, type === 'select' ? undefined : []);
    let trigger = host.querySelector('button[aria-haspopup="listbox"]');
    assert(trigger.getAttribute('aria-required') === 'true', type + ' trigger required missing');
    assert(trigger.textContent.includes('Choose a role'), type + ' placeholder missing');
    assert(!trigger.parentElement.hasAttribute('aria-required'), 'required only belongs on trigger');
    flushSync(() => trigger.click());
    flushSync(() => host.querySelector('[role="option"]').click());
    assert(type === 'select' ? value === 2 : value.length === 1 && value[0] === 2, type + ' selection changed type');
    assert(host.querySelector('button[aria-haspopup="listbox"]').getAttribute('aria-required') === 'true', 'required lost on selection');
    mount({...field, required: false}, value);
    assert(!host.querySelector('button[aria-haspopup="listbox"]').hasAttribute('aria-required'), 'required not removed');
    for (const disconnected of [false, true, false]) {
      mount({...field, disabled: true}, value, disconnected);
      trigger = host.querySelector('button[aria-haspopup="listbox"]');
      assert(trigger.disabled, type + ' application disabling lost on reconnect');
      const previousChanges = changes.length;
      flushSync(() => trigger.click());
      assert(changes.length === previousChanges, 'disabled select changed value');
    }
    mount(field, value, true);
    assert(host.querySelector('button[aria-haspopup="listbox"]').disabled, 'disconnect did not disable trigger');
    mount(field, value, false);
    assert(!host.querySelector('button[aria-haspopup="listbox"]').disabled, 'reconnect did not enable editable trigger');
  }
  const numeric = {name: 'seats', type: 'number', label: 'Seats', min: 0, max: 4, step: 2, readonly: true};
  mount(numeric, 2);
  let input = host.querySelector('input');
  assert(input.readOnly, 'numeric input not read-only');
  assert(!host.querySelector('button'), 'read-only numeric step controls present');
  const previousChanges = changes.length;
  flushSync(() => input.dispatchEvent(new KeyboardEvent('keydown', {key: 'ArrowUp', bubbles: true})));
  flushSync(() => input.dispatchEvent(new KeyboardEvent('keydown', {key: 'ArrowDown', bubbles: true})));
  assert(value === 2 && changes.length === previousChanges, 'read-only arrow keys changed numeric value');
  mount({...numeric, readonly: false}, 2);
  flushSync(() => host.querySelector('[aria-label="Increase value"]').click());
  assert(value === 4 && host.querySelector('input').value === '4', 'numeric step lost');
  assert(host.querySelector('[aria-label="Increase value"]').disabled, 'numeric maximum lost');
  input = host.querySelector('input');
  flushSync(() => input.dispatchEvent(new KeyboardEvent('keydown', {key: 'ArrowDown', bubbles: true})));
  assert(value === 2, 'editable numeric keyboard step lost');
  flushSync(() => host.querySelector('[aria-label="Decrease value"]').click());
  assert(value === 0 && host.querySelector('[aria-label="Decrease value"]').disabled, 'numeric minimum lost');
  root.unmount();
  document.querySelector('#result').textContent = 'passed';
} catch (error) { document.querySelector('#result').textContent = error.stack; }
`);
			const build = await Bun.build({ entrypoints: [entry], outdir: directory, target: "browser", format: "esm" });
			expect(build.success).toBe(true);
			server = Bun.serve({ port: 0, hostname: "127.0.0.1", fetch(request) {
				if (new URL(request.url).pathname === "/controls.js") return new Response(Bun.file(entry), { headers: { "content-type": "text/javascript" } });
				return new Response('<div id="controls"></div><pre id="result">pending</pre><script type="module" src="/controls.js"></script>', { headers: { "content-type": "text/html" } });
			} });
			const executable = process.env.CHROME_BIN || Bun.which("chromium") || Bun.which("google-chrome");
			expect(executable).toBeTruthy();
			browser = Bun.spawn([executable, "--headless", "--no-sandbox", "--disable-gpu", "--disable-dev-shm-usage", "--no-first-run", "--no-default-browser-check", `--user-data-dir=${join(directory, "profile")}`, "--dump-dom", "--virtual-time-budget=3000", `http://127.0.0.1:${server.port}`], { stdout: "pipe", stderr: "pipe" });
			timeout = setTimeout(() => browser.kill(), 20_000);
			const [html, , code] = await Promise.all([new Response(browser.stdout).text(), new Response(browser.stderr).text(), browser.exited]);
			expect(code).toBe(0);
			expect(html).toContain('<pre id="result">passed</pre>');
		} finally {
			clearTimeout(timeout);
			if (browser) { browser.kill(); await browser.exited; }
			server?.stop(true);
			await rm(directory, { recursive: true, force: true });
		}
	}, 30_000);
});
