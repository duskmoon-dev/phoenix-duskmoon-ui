import { expect, test } from "bun:test";
import { mkdtemp, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

test("React Chat submits on secure and HTTP LAN origins without losing admission or drafts", async () => {
	const directory = await mkdtemp(join(tmpdir(), "dm-react-chat-"));
	let server, browser, timeout;
	try {
		const entry = join(directory, "submission.js");
		await writeFile(
			entry,
			`
import React from ${JSON.stringify(fileURLToPath(import.meta.resolve("react")))};
import {createRoot} from ${JSON.stringify(fileURLToPath(import.meta.resolve("react-dom/client")))};
import {flushSync} from ${JSON.stringify(fileURLToPath(import.meta.resolve("react-dom")))};
import {ReactChat, useChatSubmission} from ${JSON.stringify(fileURLToPath(new URL("../../assets/js/react_chat/chat.js", import.meta.url)))};
import {initialState} from ${JSON.stringify(fileURLToPath(new URL("../../assets/js/react_chat/state.js", import.meta.url)))};
const assert = (condition, message) => { if (!condition) throw new Error(message); };
const tick = () => new Promise(resolve => setTimeout(resolve, 20));
const insecure = location.hostname === 'chat.test';
let nativeCalls = 0, randomCalls = 0, submission;
const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/;
const requests = [];
const bridge = {send(action, payload) {
  assert(action === 'send', 'unexpected bridge action');
  return new Promise((resolve, reject) => requests.push({payload, resolve, reject}));
}};
const Probe = ({canSubmit}) => {
  submission = useChatSubmission({bridge, canSubmit});
  return React.createElement('output', {id: 'notice'}, submission.notice);
};
const root = createRoot(document.querySelector('#chat'));
const render = canSubmit => flushSync(() => root.render(React.createElement(React.Fragment, null,
  React.createElement(Probe, {canSubmit}),
  React.createElement(ReactChat, {state: initialState('c1', []), bridge, connected: true, label: 'Conversation'}))));
try {
  assert(window.isSecureContext === !insecure, 'unexpected origin security context');
  if (insecure) {
    assert(typeof crypto.randomUUID === 'undefined', 'LAN origin unexpectedly exposes randomUUID');
    const random = crypto.getRandomValues.bind(crypto);
    crypto.getRandomValues = bytes => {
      randomCalls++;
      assert(bytes instanceof Uint8Array && bytes.length === 16, 'UUID must use 16 cryptographic bytes');
      return randomCalls === 1 ? bytes.fill(255) : random(bytes);
    };
  } else {
    assert(typeof crypto.randomUUID === 'function', 'loopback origin lacks native UUID');
    const native = crypto.randomUUID.bind(crypto);
    crypto.randomUUID = () => { nativeCalls++; return native(); };
    crypto.getRandomValues = () => { throw new Error('native UUID should be preferred'); };
  }
  render(false);
  await submission.submit({text: 'Blocked'}).then(
    () => { throw new Error('admission gate accepted blocked request'); },
    error => assert(error.message === 'Chat is not accepting messages', 'wrong admission error'));
  assert(requests.length === 0 && nativeCalls === 0 && randomCalls === 0, 'blocked request generated/sent an ID');
  render(true);
  const admitted = submission.submit({text: 'Hello', attachments: [{upload_id: 'image-1'}]});
  assert(requests.length === 1 && uuid.test(requests[0].payload.request_id), 'send did not receive a UUIDv4');
  if (insecure) assert(requests[0].payload.request_id === 'ffffffff-ffff-4fff-bfff-ffffffffffff', 'fallback missed UUID version/variant bits');
  assert(requests[0].payload.text === 'Hello' && requests[0].payload.attachments[0].upload_id === 'image-1', 'send lost payload');
  await submission.submit({text: 'Duplicate'}).then(
    () => { throw new Error('overlapping request accepted'); },
    error => assert(error.message === 'Chat is not accepting messages', 'wrong pending error'));
  assert(requests.length === 1, 'pending guard sent duplicate');
  const acknowledgement = {status: 'ok', admission: 'steering', runtime_request_id: 'runtime-1'};
  requests[0].resolve(acknowledgement);
  assert(await admitted === acknowledgement, 'admission acknowledgement changed');
  await tick();
  const rejected = submission.submit({text: 'Retry'}).catch(error => error);
  assert(uuid.test(requests[1].payload.request_id) && requests[1].payload.request_id !== requests[0].payload.request_id, 'new send reused UUID');
  const rejection = Object.assign(new Error('Not admitted'), {response: {admission: 'blocked'}});
  requests[1].reject(rejection);
  assert(await rejected === rejection, 'admission rejection metadata changed');
  await tick();
  assert(!submission.busy && document.querySelector('#notice').textContent === 'Not admitted', 'rejection did not unlock/report');
  const duplicate = submission.submit({text: 'Retry', request_id: requests[0].payload.request_id});
  assert(requests[2].payload.request_id === requests[0].payload.request_id, 'caller deduplication ID changed');
  requests[2].resolve({status: 'ok', duplicate: true});
  assert((await duplicate).duplicate === true, 'duplicate acknowledgement changed');
  await tick();
  const input = document.querySelector('input');
  Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value').set.call(input, 'Keep draft');
  input.dispatchEvent(new Event('input', {bubbles: true}));
  await tick();
  const form = document.querySelector('form');
  form.requestSubmit();
  await tick();
  assert(requests.length === 4 && requests[3].payload.text === 'Keep draft', 'default composer did not send');
  requests[3].reject(new Error('Draft rejected'));
  await tick();
  assert(input.value === 'Keep draft' && document.querySelector('[role="alert"]').textContent === 'Draft rejected', 'rejected composer lost draft/notice');
  form.requestSubmit();
  await tick();
  assert(requests.length === 5, 'rejected composer stayed busy');
  requests[4].resolve({status: 'ok'});
  await tick();
  assert(input.value === '', 'accepted composer did not clear submitted draft');
  assert(insecure ? randomCalls === 5 && nativeCalls === 0 : nativeCalls === 5 && randomCalls === 0, 'wrong request-ID generator');
  document.querySelector('#result').textContent = 'passed';
} catch (error) { document.querySelector('#result').textContent = error.stack; }
finally { root.unmount(); }
`,
		);
		const build = await Bun.build({
			entrypoints: [entry],
			outdir: directory,
			target: "browser",
			format: "esm",
		});
		expect(build.success).toBe(true);
		server = Bun.serve({
			port: 0,
			hostname: "127.0.0.1",
			fetch(request) {
				if (new URL(request.url).pathname === "/submission.js")
					return new Response(Bun.file(entry), {
						headers: { "content-type": "text/javascript" },
					});
				return new Response(
					'<div id="chat"></div><pre id="result">pending</pre><script type="module" src="/submission.js"></script>',
					{ headers: { "content-type": "text/html" } },
				);
			},
		});
		const executable =
			process.env.CHROME_BIN ||
			Bun.which("chromium") ||
			Bun.which("google-chrome");
		expect(executable).toBeTruthy();
		for (const host of ["127.0.0.1", "chat.test"]) {
			browser = Bun.spawn(
				[
					executable,
					"--headless",
					"--no-sandbox",
					"--disable-gpu",
					"--disable-dev-shm-usage",
					"--no-first-run",
					"--no-default-browser-check",
					"--no-proxy-server",
					"--host-resolver-rules=MAP chat.test 127.0.0.1",
					`--user-data-dir=${join(directory, host)}`,
					"--dump-dom",
					"--virtual-time-budget=5000",
					`http://${host}:${server.port}`,
				],
				{ stdout: "pipe", stderr: "pipe" },
			);
			timeout = setTimeout(() => browser.kill(), 20_000);
			const [html, , code] = await Promise.all([
				new Response(browser.stdout).text(),
				new Response(browser.stderr).text(),
				browser.exited,
			]);
			clearTimeout(timeout);
			expect(code).toBe(0);
			expect(html).toContain('<pre id="result">passed</pre>');
		}
	} finally {
		clearTimeout(timeout);
		if (browser) {
			browser.kill();
			await browser.exited;
		}
		server?.stop(true);
		await rm(directory, { recursive: true, force: true });
	}
}, 60_000);
