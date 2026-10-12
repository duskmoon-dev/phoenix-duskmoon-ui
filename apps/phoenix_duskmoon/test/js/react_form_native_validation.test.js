import { expect, test } from "bun:test";
import { mkdtemp, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

test("mounted classic forms validate native constraints and snapshot current controls", async () => {
	const directory = await mkdtemp(join(tmpdir(), "dm-react-form-native-"));
	let server, browser, timeout;
	try {
		const entry = join(directory, "native.js");
		await writeFile(entry, `
import {flushSync} from ${JSON.stringify(fileURLToPath(import.meta.resolve("react-dom")))};
import {DuskmoonReactForm} from ${JSON.stringify(fileURLToPath(new URL("../../assets/js/react_form/index.js", import.meta.url)))};
const assert = (condition, message) => { if (!condition) throw new Error(message); };
const tick = () => new Promise(resolve => setTimeout(resolve, 20));
const el = document.querySelector('#native-form');
el.dataset.initialValues = JSON.stringify({profile: {title: 'React initial', toolset_ids: ['tools']}, quantity: 0});
el.querySelector('[data-dm-react-field]').dataset.dmReactField = JSON.stringify({name: ['profile', 'title'], type: 'text', label: 'React title'});
const events = [], handlers = new Map();
const hook = Object.assign(Object.create(DuskmoonReactForm), {el,
  handleEvent: (event, handler) => handlers.set(event, handler),
  pushEvent: (event, payload) => events.push({event, payload: structuredClone(payload)})});
const saves = () => events.filter(entry => entry.event === 'save');
const input = name => [...hook.form.querySelectorAll('[name]')].find(control => control.name === name);
const createInput = (name, value, type = 'hidden') => {
  const control = document.createElement('input'); control.name = name; control.type = type; control.value = value; return control;
};
try {
  flushSync(() => hook.mounted());
  const form = hook.form;
  const title = input('title'), code = input('code'), email = input('email'), importance = input('importance');
  assert(form.noValidate, 'default classic form must retain novalidate');
  title.value = '';
  hook.submit();
  assert(saves().length === 1, 'default novalidate blocked direct submit');
  form.requestSubmit();
  assert(saves().length === 2, 'default novalidate blocked requestSubmit');
  title.value = 'Valid';
  form.noValidate = false;
  let invalidEvents = 0;
  form.addEventListener('invalid', () => invalidEvents++, true);
  for (const [control, invalid, flag, valid] of [
    [title, '', 'valueMissing', 'Valid'],
    [code, 'bad', 'patternMismatch', 'MO'],
    [email, 'bad', 'typeMismatch', 'moon@example.com'],
    [importance, '-0.1', 'rangeUnderflow', '0.5'],
    [importance, '1.1', 'rangeOverflow', '0.5'],
    [importance, '0.25', 'stepMismatch', '0.5'],
  ]) {
    control.value = invalid;
    assert(control.validity[flag], 'browser did not expose ' + flag);
    const before = saves().length, reports = invalidEvents;
    hook.submit();
    assert(saves().length === before && invalidEvents > reports, flag + ' direct submit did not report/block invalidity');
    form.requestSubmit();
    assert(saves().length === before, flag + ' requestSubmit delivered invalid values');
    control.value = valid;
  }
  flushSync(() => hook.change(['profile', 'title'], 'React draft'));
  await tick();
  const hidden = input('provider');
  hidden.value = 'programmatic';
  form.requestSubmit();
  let latest = saves().at(-1).payload.values;
  assert(latest.provider === 'programmatic' && latest.profile.title === 'React draft', 'valid requestSubmit lost current hidden or React value');
  assert(latest.importance === 0.5 && latest.enabled === false && latest.quantity === 0, 'native snapshot changed JSON types');
  const replacement = createInput('provider', 'replacement');
  hidden.replaceWith(replacement);
  form.append(createInput('profile[city]', 'Shanghai', 'text'));
  form.append(createInput('profile[title]', 'native collision'));
  form.append(createInput('profile', 'native ancestor'));
  form.append(createInput('profile[title][nested]', 'native descendant'));
  const before = saves().length;
  hook.submit();
  latest = saves().at(-1).payload.values;
  assert(saves().length === before + 1, 'valid direct submit not delivered');
  assert(latest.provider === 'replacement' && latest.profile.city === 'Shanghai' && latest.profile.title === 'React draft', 'replacement/new native snapshot overwrote React ownership');
  const marked = el.querySelector('[data-dm-react-field] input');
  marked.name = 'alien';
  const eventCount = events.length;
  marked.dispatchEvent(new Event('input', {bubbles: true}));
  marked.dispatchEvent(new Event('change', {bubbles: true}));
  await tick();
  assert(events.length === eventCount && !('alien' in hook.values), 'marked controls entered delegated native state');
  const detached = [...form.querySelectorAll('input[name="tool_names[]"]')][1];
  const search = createInput('tool_names[]', 'file.search', 'checkbox'); search.checked = true;
  detached.replaceWith(search);
  search.dispatchEvent(new Event('input', {bubbles: true}));
  await tick();
  assert(hook.values.tool_names.join(',') === 'file.read,file.search', 'replacement group input did not use current nodes');
  const write = createInput('tool_names[]', 'file.write', 'checkbox'); write.checked = true; form.append(write);
  write.dispatchEvent(new Event('change', {bubbles: true}));
  await tick();
  assert(hook.values.tool_names.join(',') === 'file.read,file.search,file.write', 'new group change did not use current nodes');
  const skills = createInput('profile[toolset_ids][]', 'skills', 'checkbox'); skills.checked = true; form.append(skills);
  skills.dispatchEvent(new Event('change', {bubbles: true}));
  await tick();
  assert(hook.values.profile.toolset_ids.join(',') === 'tools,skills' && hook.values.profile.title === 'React draft', 'nested native event overwrote React sibling');
  const detachedCount = events.length;
  detached.dispatchEvent(new Event('change', {bubbles: true}));
  await tick();
  assert(events.length === detachedCount, 'detached control retained native listener');
  flushSync(() => handlers.get('dm:form:reset')({id: el.id, values: {tool_names: ['file.search'], profile: {title: 'Server reset', toolset_ids: []}, enabled: false}}));
  assert(search.checked && !write.checked && !skills.checked && marked.value === 'Server reset', 'server reset did not update current nodes');
  form.reset();
  await tick();
  assert(input('tool_names[]').checked && !search.checked && !write.checked && !skills.checked, 'native reset did not restore current group nodes');
  assert(marked.value === 'React initial' && replacement.value === 'old', 'native reset lost React or replacement defaults');
  const state = JSON.stringify(hook.values), delivered = events.length;
  hook.destroyed();
  const afterDestroy = createInput('new_after_destroy', 'ignored', 'text'); form.append(afterDestroy);
  afterDestroy.dispatchEvent(new Event('input', {bubbles: true}));
  write.checked = true; write.dispatchEvent(new Event('change', {bubbles: true}));
  await tick();
  assert(JSON.stringify(hook.values) === state && events.length === delivered, 'destroy left delegated native handlers');
  document.querySelector('#result').textContent = 'passed';
} catch (error) { document.querySelector('#result').textContent = error.stack; hook.destroyed(); }
`);
		const build = await Bun.build({ entrypoints: [entry], outdir: directory, target: "browser", format: "esm" });
		expect(build.success).toBe(true);
		server = Bun.serve({ port: 0, hostname: "127.0.0.1", fetch(request) {
			if (new URL(request.url).pathname === "/native.js") return new Response(Bun.file(entry), { headers: { "content-type": "text/javascript" } });
			return new Response(`<div id="native-form" phx-change="validate" phx-submit="save"><form data-dm-react-form novalidate>
<input name="title" required value="Valid"><input name="code" pattern="[A-Z]{2}" value="MO">
<input name="email" type="email" value="moon@example.com"><input name="importance" type="number" min="0" max="1" step="0.1" value="0.5">
<input name="provider" type="hidden" value="old"><input name="enabled" type="checkbox">
<input name="tool_names[]" type="checkbox" value="file.read" checked><input name="tool_names[]" type="checkbox" value="file.write">
<input name="profile[toolset_ids][]" type="checkbox" value="tools" checked><span data-dm-react-field></span>
</form></div><pre id="result">pending</pre><script type="module" src="/native.js"></script>`, { headers: { "content-type": "text/html" } });
		} });
		const executable = process.env.CHROME_BIN || Bun.which("chromium") || Bun.which("google-chrome");
		expect(executable).toBeTruthy();
		browser = Bun.spawn([executable, "--headless", "--no-sandbox", "--disable-gpu", "--disable-dev-shm-usage", "--no-first-run", "--no-default-browser-check", `--user-data-dir=${join(directory, "profile")}`, "--dump-dom", "--virtual-time-budget=5000", `http://127.0.0.1:${server.port}`], { stdout: "pipe", stderr: "pipe" });
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
