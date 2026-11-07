import { expect, test } from "bun:test";
import { mkdtemp, mkdir, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { basename, join } from "node:path";
import { fileURLToPath } from "node:url";

test("structured Storybook composers keep one root, scoped recovery and rich portal editing", async () => {
	const directory = await mkdtemp(join(tmpdir(), "dm-composer-browser-"));
	let server, browser, timeout;
	try {
		const entry = join(directory, "entry.js");
		const proxy = join(directory, "roots.js");
		const output = join(directory, "build");
		await mkdir(output);
		await writeFile(
			proxy,
			`import {createRoot as original} from ${JSON.stringify(fileURLToPath(import.meta.resolve("react-dom/client")))};
export function createRoot(...args) { globalThis.rootCount = (globalThis.rootCount || 0) + 1; return original(...args); }`,
		);
		await writeFile(
			entry,
			`
import {DuskmoonComposedChat} from ${JSON.stringify(fileURLToPath(new URL("../../../duskmoon_storybook/assets/js/react_chat.js", import.meta.url)))};
const assert = (condition, message) => { if (!condition) throw new Error(message); };
const tick = () => new Promise(resolve => setTimeout(resolve, 30));
const waitFor = async (probe, message) => { for (let index = 0; index < 80; index++) { if (probe()) return; await tick(); } throw new Error(message); };
const button = (target, text) => [...target.querySelectorAll('button')].find(node => node.textContent.trim() === text);
const mounts = [];
function mount(name, contextKey) {
  const el = document.querySelector('#' + name);
  const scope = {contextKey, conversationId:'shared-conversation'};
  el.dataset.chat = JSON.stringify({conversationId:scope.conversationId, protocolVersion:1, scope, messages:[], event:'chat:event', label:name,
    metadata:{composerPortalId:name+'-portal'}, runtime:{active:false}, admission:{allowWhileStreaming:true},
    composer:{revision:0, options:{model:'fixture-small'}, providers:[], capabilities:{protocolVersion:1, documentVersions:[1], intents:['send','follow_up','steer'], commands:true, attachments:true, queue:{edit:'text',remove:true,promote:true},durableRecovery:false},queue:{protocolVersion:1,scope,revision:0,items:[]}},
    actions:{send:'chat.send',stop:'chat.stop',sync:'chat.sync',reconcile:'composer.reconcile',configure:'composer.configure',queue_edit:'composer.queue.edit',queue_remove:'composer.queue.remove',queue_promote:'composer.queue.promote'}});
  const calls = [], handlers = new Map();
  const hook = Object.assign(Object.create(DuskmoonComposedChat), {el,
    handleEvent(event, callback) { handlers.set(event, callback); return event; },
    removeHandleEvent(event) { handlers.delete(event); },
    pushEvent(event, payload, reply) { calls.push({event,payload,reply}); },
  });
  hook.mounted();
  const mounted = {hook,calls,handlers,scope,portal:document.querySelector('#'+name+'-portal')};
  mounts.push(mounted);
  return mounted;
}
function answer(call, outcome) {
  const body = call.payload;
  call.reply({request_id:body.request_id, instanceGeneration:body.instanceGeneration, receipt:{protocolVersion:1, clientSubmissionId:body.clientSubmissionId,scope:body.scope,operation:'prompt',outcome,
    ...(outcome === 'accepted' ? {delivery:'immediate',persistence:'volatile'} : {error:{code:'fixture_'+outcome,message:'Fixture '+outcome}})}});
}
const edit = async (editor, text) => { editor.focus(); const range = document.createRange(); range.selectNodeContents(editor); range.collapse(false); const selection = getSelection(); selection.removeAllRanges(); selection.addRange(range); await tick(); document.execCommand('insertText', false, text); };
(async () => {
  const first = mount('first', 'repository:one');
  const second = mount('second', 'repository:two');
  await waitFor(() => first.portal.querySelector('textarea') && second.portal.querySelector('textarea'), 'two independent composers did not mount');
  assert(rootCount === 2, 'expected one React root per chat');
  const originalRoot = first.hook.root;
  button(first.portal,'Load rich editor').click();
  await waitFor(() => first.portal.querySelector('[contenteditable=true]'), 'rich editor did not load');
  const editor = first.portal.querySelector('[contenteditable=true]');
  await edit(editor, '你好 🌙');
  await tick();
  assert(editor.textContent.includes('你好 🌙'), 'test editing did not insert CJK text: '+editor.outerHTML);
  const selected = getSelection();
  const originalAnchor = selected.anchorNode, originalOffset = selected.anchorOffset;
  editor.dispatchEvent(new CompositionEvent('compositionstart', {bubbles:true,data:'中'}));
  editor.dispatchEvent(new KeyboardEvent('keydown', {key:'Enter',code:'Enter',ctrlKey:true,isComposing:true,bubbles:true,cancelable:true}));
  first.hook.el.dataset.unrelatedPatch = 'patched';
  document.querySelector('#outside').textContent = 'Unrelated LiveView content changed';
  first.hook.renderChat();
  first.handlers.get('chat:event')({id:'first',conversation_id:first.scope.conversationId,scope:first.scope,instanceGeneration:first.hook.state.instanceGeneration,protocolVersion:1,type:'chat.message',message_id:'answer',sequence:1,message:{id:'answer',role:'assistant',content:'Streaming',status:'streaming'}});
  await tick();
  assert(first.calls.length === 0, 'IME composition submitted unexpectedly');
  assert(document.activeElement === editor && getSelection().anchorNode === originalAnchor && getSelection().anchorOffset === originalOffset, 'render/stream changed portal focus or selection: ' + JSON.stringify({active:document.activeElement?.outerHTML,anchor:getSelection().anchorNode?.textContent,offset:getSelection().anchorOffset,originalText:originalAnchor?.textContent,originalOffset,anchorConnected:originalAnchor?.isConnected,editorConnected:editor.isConnected}));
  assert(editor.textContent.includes('你好 🌙'), 'render/stream lost CJK draft');
  editor.dispatchEvent(new CompositionEvent('compositionend', {bubbles:true,data:'中'}));
  assert(rootCount === 2 && first.hook.root === originalRoot, 'rich activation mounted another React root');
  assert(second.portal.querySelector('textarea').value === '', 'another context received the first draft');
  // Complete the simulated streaming turn without replacing composer state.
  first.handlers.get('chat:event')({id:'first',conversation_id:first.scope.conversationId,scope:first.scope,instanceGeneration:first.hook.state.instanceGeneration,protocolVersion:1,type:'chat.complete',message_id:'answer',sequence:2});
  await tick();
  button(first.portal,'Send').click();
  await waitFor(() => first.calls.length === 1, 'structured submit was not dispatched');
  const accepted = first.calls[0];
  assert(accepted.payload.document.content.some(node => node.type === 'text' && node.text.includes('你好')), 'semantic document was flattened/lost');
  await edit(editor, ' 后续编辑');
  await tick();
  answer(accepted, 'accepted');
  await tick();
  assert(editor.textContent.includes('后续编辑'), 'accepted old revision cleared later editing');
  assert(first.portal.textContent.includes('volatile admission'), 'volatile receipt was not displayed truthfully');
  button(first.portal,'Send').click();
  await waitFor(() => first.calls.length === 2, 'second submission missing');
  answer(first.calls[1], 'rejected');
  await tick();
  assert(editor.textContent.includes('后续编辑'), 'backend rejection lost semantic draft');
  button(first.portal,'Send').click();
  await waitFor(() => first.calls.length === 3, 'unknown submission missing');
  answer(first.calls[2], 'unknown');
  await tick();
  assert(editor.textContent.includes('后续编辑'), 'unknown admission lost draft');
  assert(first.hook.adapter.recovery.getSnapshot().some(attempt => attempt.status === 'unknown'), 'unknown snapshot not retained by application owner');
  const count = first.calls.length;
  await tick();
  assert(first.calls.length === count, 'unknown submission was automatically replayed');
  const oldEvent = {id:'first',conversation_id:first.scope.conversationId,scope:second.scope,instanceGeneration:first.hook.state.instanceGeneration,protocolVersion:1,type:'chat.snapshot',messages:[],composer:{...first.hook.state.composer,revision:5}};
  first.handlers.get('chat:event')(oldEvent);
  await tick();
  assert(editor.textContent.includes('后续编辑'), 'other application scope overwrote draft');
  first.hook.destroyed();
  await tick();
  assert(!first.portal.querySelector('[contenteditable]') && first.handlers.size === 0 && first.hook.requests.size === 0, 'unmount leaked portal/listeners/requests');
  assert(first.hook.adapter.recovery.getSnapshot().some(attempt => attempt.status === 'unknown'), 'unmount discarded recovery linkage');
  assert(!first.calls.some(call => call.event === 'chat.stop'), 'unmount sent Stop');
  assert(second.portal.querySelector('textarea'), 'unmount removed another mount');
  second.hook.destroyed();
  document.querySelector('#result').textContent = 'passed';
})().catch(error => { document.querySelector('#result').textContent = error.stack; for (const mount of mounts) { try { if (!mount.hook.dead) mount.hook.destroyed(); } catch {} } });
`,
		);
		const build = await Bun.build({
			entrypoints: [entry],
			outdir: output,
			target: "browser",
			format: "esm",
			splitting: true,
			plugins: [
				{
					name: "count-chat-roots",
					setup(build) {
						build.onResolve({ filter: /^react-dom\/client$/ }, () => ({
							path: proxy,
						}));
					},
				},
			],
		});
		expect(build.success).toBe(true);
		const assets = new Map(
			build.outputs.map((artifact) => [
				`/${basename(artifact.path)}`,
				artifact,
			]),
		);
		server = Bun.serve({
			port: 0,
			hostname: "127.0.0.1",
			fetch(request) {
				const asset = assets.get(new URL(request.url).pathname);
				if (asset)
					return new Response(asset, {
						headers: { "content-type": "text/javascript" },
					});
				return new Response(
					'<div id="outside"></div><div id="first"></div><div id="first-portal"></div><div id="second"></div><div id="second-portal"></div><pre id="result">pending</pre><script type="module" src="/entry.js"></script>',
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
				"--dump-dom",
				"--virtual-time-budget=12000",
				`http://127.0.0.1:${server.port}`,
			],
			{ stdout: "pipe", stderr: "pipe" },
		);
		timeout = setTimeout(() => browser.kill(), 25_000);
		const [html, stderr, code] = await Promise.all([
			new Response(browser.stdout).text(),
			new Response(browser.stderr).text(),
			browser.exited,
		]);
		clearTimeout(timeout);
		expect(code).toBe(0);
		expect(html).toContain('<pre id="result">passed</pre>');
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
