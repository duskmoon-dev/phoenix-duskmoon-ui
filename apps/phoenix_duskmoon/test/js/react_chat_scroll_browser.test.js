import { expect, test } from "bun:test";
import { mkdtemp, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { basename, join } from "node:path";
import { fileURLToPath } from "node:url";

test("chat scrolling separates one-shot jumps from following and cleans up per mount", async () => {
	const directory = await mkdtemp(join(tmpdir(), "dm-chat-scroll-browser-"));
	let server, browser, socket, timeout;
	try {
		const entry = join(directory, "entry.js");
		await writeFile(
			entry,
			`
import React from ${JSON.stringify(fileURLToPath(import.meta.resolve("react")))};
import {createRoot} from ${JSON.stringify(fileURLToPath(import.meta.resolve("react-dom/client")))};
import {flushSync} from ${JSON.stringify(fileURLToPath(import.meta.resolve("react-dom")))};
import {ReactChat} from ${JSON.stringify(fileURLToPath(new URL("../../assets/js/react_chat/chat.js", import.meta.url)))};
import {initialState} from ${JSON.stringify(fileURLToPath(new URL("../../assets/js/react_chat/state.js", import.meta.url)))};
const assert = (condition, message) => { if (!condition) throw new Error(message); };
const tick = () => new Promise(resolve => requestAnimationFrame(() => setTimeout(resolve, 30)));
const waitFor = async (probe, message) => { for (let index = 0; index < 80; index++) { if (probe()) return; await tick(); } throw new Error(message); };
const bottom = el => el.scrollHeight - el.scrollTop - el.clientHeight < 2;
const observers = new Set();
const NativeResizeObserver = ResizeObserver;
globalThis.ResizeObserver = class extends NativeResizeObserver {
  observe(target, ...args) {
    if (target.matches('[data-chat-messages]')) observers.add(this);
    return super.observe(target, ...args);
  }
  disconnect() { observers.delete(this); super.disconnect(); }
};
const messages = Array.from({length:12}, (_, index) => ({id:'message-'+index, role:'assistant', content:('Message '+index+'. ').repeat(30) + (index === 11 ? '\\n\\n![Late preview](/preview.svg)' : '')}));
const mounts = [];
function mount(id) {
  const node = document.getElementById(id);
  const root = createRoot(node);
  const chat = {node, root, state:initialState(id, messages, {instanceGeneration:1})};
  chat.render = () => flushSync(() => root.render(React.createElement(ReactChat, {
    state:chat.state, connected:true, label:id, bridge:{send:async () => ({status:'ok'})},
  })));
  chat.append = () => {
    chat.state = {...chat.state, messages:[...chat.state.messages, {id:'message-'+chat.state.messages.length,role:'assistant',status:'streaming',content:'New streaming message. '.repeat(40)}]};
    chat.render();
  };
  chat.render();
  chat.viewport = node.querySelector('[data-chat-messages]');
  chat.pin = node.querySelector('button[aria-label="Stick to bottom"]');
  chat.jump = node.querySelector('button[aria-label="Jump to latest"]');
  chat.sticking = () => chat.pin.getAttribute('aria-pressed') === 'true';
  mounts.push(chat);
  return chat;
}
(async () => {
  const first = mount('first'), second = mount('second');
  await waitFor(() => observers.size === 2 && bottom(first.viewport) && bottom(second.viewport), 'initial transcripts did not follow to the bottom');
  assert(first.sticking() && second.sticking(), 'following should start enabled');
  for (const chat of mounts) {
    for (const button of [chat.pin, chat.jump]) {
      assert(button.querySelector('svg[aria-hidden="true"]') && !button.textContent.trim(), 'scroll control is not an accessible icon button');
      assert(button.getAttribute('aria-controls') === chat.viewport.id, 'scroll control points to another transcript');
      assert(!chat.viewport.contains(button), 'floating control scrolls with the transcript');
    }
  }
  assert(first.jump.disabled, 'jump should be disabled at the bottom');
  first.append();
  await waitFor(() => bottom(first.viewport), 'new messages did not follow');
  const last = first.state.messages.at(-1);
  first.state = {...first.state, messages:first.state.messages.map(message => message.id === last.id ? {...message,content:message.content+'\\n\\n'+ 'Streamed content. '.repeat(80)} : message)};
  first.render();
  await waitFor(() => bottom(first.viewport), 'streamed content did not follow');
  assert(first.sticking(), 'content growth cancelled following');
  const image = first.node.querySelector('img');
  const beforeImage = first.viewport.scrollHeight;
  image.style.height = '180px';
  await waitFor(() => first.viewport.scrollHeight > beforeImage && bottom(first.viewport), 'late image sizing did not follow');
  first.node.style.height = '280px';
  await waitFor(() => first.viewport.clientHeight < 250 && bottom(first.viewport), 'viewport resizing did not follow');

  first.viewport.scrollTo({top:100,behavior:'instant'});
  await waitFor(() => !first.sticking() && !first.jump.disabled, 'scrolling into history did not pause following');
  const readingPosition = first.viewport.scrollTop;
  first.append();
  second.append();
  await tick();
  assert(Math.abs(first.viewport.scrollTop - readingPosition) < 2, 'new messages moved the history reading position');
  assert(second.sticking() && bottom(second.viewport), 'another mount inherited paused following');
  image.style.height = '360px';
  await tick();
  assert(Math.abs(first.viewport.scrollTop - readingPosition) < 2, 'late content moved paused history');

  first.jump.click();
  await waitFor(() => bottom(first.viewport), 'one-shot jump did not reach the latest message');
  assert(!first.sticking(), 'one-shot jump enabled persistent following');
  const jumpedPosition = first.viewport.scrollTop;
  first.append();
  await tick();
  assert(!bottom(first.viewport) && Math.abs(first.viewport.scrollTop - jumpedPosition) < 2, 'one-shot jump kept following later messages');
  first.viewport.scrollTo({top:first.viewport.scrollHeight,behavior:'instant'});
  await tick();
  assert(!first.sticking(), 'manually reaching the bottom enabled following');
  first.pin.click();
  await waitFor(() => first.sticking() && bottom(first.viewport), 'pin did not resume following');
  first.append();
  await waitFor(() => bottom(first.viewport), 'pinned transcript did not follow new messages');
  first.pin.click();
  await waitFor(() => !first.sticking(), 'pin did not turn following off');
  const unpinnedPosition = first.viewport.scrollTop;
  first.append();
  await tick();
  assert(Math.abs(first.viewport.scrollTop - unpinnedPosition) < 2 && !bottom(first.viewport), 'disabled pin still followed');

  first.pin.click();
  await waitFor(() => first.sticking() && bottom(first.viewport), 'pin did not return to the bottom');
  first.node.querySelector('[data-chat-target]').click();
  await waitFor(() => !first.sticking() && first.viewport.scrollTop < 100, 'reply navigation did not pause following and reach history');
  second.pin.click();
  await waitFor(() => !second.sticking(), 'second mount did not pause');
  first.state = initialState('another-conversation', messages, {instanceGeneration:2});
  first.render();
  await waitFor(() => first.sticking() && bottom(first.viewport), 'conversation switch retained the previous follow setting');
  assert(!second.sticking(), 'conversation switch changed another mount');
  first.root.unmount();
  await waitFor(() => observers.size === 1, 'unmount leaked its scroll observer');
  assert(second.node.querySelector('[data-chat-messages]'), 'unmount removed the other transcript');
  second.root.unmount();
  await waitFor(() => observers.size === 0, 'final unmount leaked scroll observers');
  document.querySelector('#result').textContent = 'passed';
})().catch(error => { document.querySelector('#result').textContent = error.stack; for (const chat of mounts) { try { chat.root.unmount(); } catch {} } });
`,
		);
		const build = await Bun.build({
			entrypoints: [entry],
			target: "browser",
			format: "esm",
		});
		expect(build.success).toBe(true);
		const assets = new Map(
			build.outputs.map((artifact) => [
				`/${basename(artifact.path)}`,
				artifact,
			]),
		);
		const core = Bun.file(
			fileURLToPath(import.meta.resolve("@duskmoon-dev/core/standalone.css")),
		);
		server = Bun.serve({
			port: 0,
			hostname: "127.0.0.1",
			fetch(request) {
				const path = new URL(request.url).pathname;
				const asset = assets.get(path);
				if (asset)
					return new Response(asset, {
						headers: { "content-type": "text/javascript" },
					});
				if (path === "/core.css") return new Response(core);
				if (path === "/preview.svg")
					return new Response(
						'<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100"/>',
						{
							headers: { "content-type": "image/svg+xml" },
						},
					);
				return new Response(
					`<!doctype html><html data-theme="sunshine"><head><link rel="stylesheet" href="/core.css"><style>
/* Constrain the browser fixture without a generated application CSS dependency. */
#first, #second { height:360px; width:560px; }
section { display:flex; flex-direction:column; gap:12px; height:100%; }
section > div:first-child { position:relative; flex:1; min-height:0; }
[data-chat-messages] { height:100%; }
[aria-label="Transcript scrolling"] { position:absolute; bottom:12px; right:12px; display:flex; gap:8px; }
.chat-scroll-body { padding-bottom:64px; }
.markdown-body img { height:0; width:100%; }
</style></head><body><div id="first"></div><div id="second"></div><pre id="result">pending</pre><script type="module" src="/entry.js"></script></body></html>`,
					{ headers: { "content-type": "text/html" } },
				);
			},
		});
		const executable =
			process.env.CHROME_BIN ||
			Bun.which("chromium") ||
			Bun.which("google-chrome");
		expect(executable).toBeTruthy();
		browser = Bun.spawn(
			[
				executable,
				"--headless",
				"--no-sandbox",
				"--disable-gpu",
				"--disable-dev-shm-usage",
				"--no-first-run",
				"--no-default-browser-check",
				`--user-data-dir=${join(directory, "chrome")}`,
				"--remote-debugging-port=0",
				"about:blank",
			],
			{ stdout: "ignore", stderr: "ignore" },
		);
		timeout = setTimeout(() => browser.kill(), 25_000);
		let port;
		for (let attempt = 0; attempt < 100; attempt++) {
			const portFile = Bun.file(
				join(directory, "chrome", "DevToolsActivePort"),
			);
			if (await portFile.exists())
				port = Number((await portFile.text()).split("\n")[0]);
			if (port > 0) break;
			await Bun.sleep(30);
		}
		expect(port).toBeGreaterThan(0);
		const targets = await fetch(`http://127.0.0.1:${port}/json/list`).then(
			(response) => response.json(),
		);
		const target = targets.find((target) => target.type === "page");
		// Native scroll events need real rendering frames; virtual-time dump-dom skips them.
		socket = new WebSocket(target.webSocketDebuggerUrl);
		await new Promise((resolve, reject) => {
			socket.onopen = resolve;
			socket.onerror = reject;
		});
		let nextId = 0,
			loaded;
		const requests = new Map();
		const pageLoaded = new Promise((resolve, reject) => {
			loaded = resolve;
			socket.onclose = () => {
				const error = new Error(
					"Browser closed before the scroll checks finished",
				);
				reject(error);
				for (const request of requests.values()) request.reject(error);
			};
		});
		socket.onmessage = (event) => {
			const response = JSON.parse(event.data);
			if (response.method === "Page.loadEventFired") loaded();
			const request = requests.get(response.id);
			if (!request) return;
			requests.delete(response.id);
			if (response.error || response.result.exceptionDetails)
				request.reject(new Error(JSON.stringify(response)));
			else request.resolve(response.result);
		};
		const command = (method, params = {}) =>
			new Promise((resolve, reject) => {
				const id = ++nextId;
				requests.set(id, { resolve, reject });
				socket.send(JSON.stringify({ id, method, params }));
			});
		await command("Page.enable");
		await command("Page.navigate", { url: `http://127.0.0.1:${server.port}` });
		await pageLoaded;
		const result = await command("Runtime.evaluate", {
			expression: `new Promise(resolve => { const probe = () => { const result = document.querySelector('#result')?.textContent; if (result && result !== 'pending') resolve(result); else setTimeout(probe, 30); }; probe(); })`,
			awaitPromise: true,
			returnByValue: true,
		});
		expect(result.result.value).toBe("passed");
	} finally {
		clearTimeout(timeout);
		socket?.close();
		if (browser) {
			browser.kill();
			await browser.exited;
		}
		server?.stop(true);
		await rm(directory, { recursive: true, force: true });
	}
}, 60_000);
