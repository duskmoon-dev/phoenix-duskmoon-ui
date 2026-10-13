defmodule DuskmoonBundler.Integration.VendorPlug do
  @moduledoc false
  @behaviour Plug
  def init(opts), do: opts

  def call(conn, opts) do
    opts = if is_list(opts), do: DuskmoonBundler.DevServer.init(opts), else: opts

    if conn.request_path == "/" do
      conn
      |> Plug.Conn.put_resp_content_type("text/html")
      |> Plug.Conn.send_resp(
        200,
        "<div id='chat'></div><div id='late'></div><script>window.moduleErrors=[];addEventListener('error',event=>window.moduleErrors.push(event.message||event.target.src),true);addEventListener('unhandledrejection',event=>window.moduleErrors.push(String(event.reason)));</script><script type='module' src='/assets/app.js'></script>"
      )
    else
      case DuskmoonBundler.DevServer.call(conn, opts) do
        %{halted: true} = conn -> conn
        conn -> Plug.Conn.send_resp(conn, 404, "not found")
      end
    end
  end
end

defmodule DuskmoonBundler.Integration.DevVendorTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  @moduletag timeout: 120_000
  # Cold dependency optimization can exceed 15 seconds on hosted CI runners.
  @navigation_timeout 30_000
  alias DuskmoonBundler.Integration.CDPBrowser
  alias DuskmoonBundler.JS.Vendor
  @fixture_dir Path.expand("../fixtures/dev_vendor", __DIR__)
  @project_root Path.expand("../../../../..", __DIR__)

  setup_all do
    {:ok, browser} = CDPBrowser.start_link()
    on_exit(fn -> CDPBrowser.stop(browser) end)
    %{browser: browser}
  end

  setup %{browser: browser} = context do
    on_exit(fn -> File.rm_rf!(@fixture_dir) end)
    File.rm_rf!(Path.join(Mix.Project.build_path(), "duskmoon_bundler/vendor"))
    File.rm_rf!(@fixture_dir)
    File.mkdir_p!(Path.join(@fixture_dir, "node_modules/cjs-contract"))
    File.mkdir_p!(Path.join(@fixture_dir, "node_modules/late-chat"))
    File.mkdir_p!(Path.join(@fixture_dir, "node_modules/callable"))
    File.mkdir_p!(Path.join(@fixture_dir, "node_modules/late-callable"))

    for {name, value} <- [{"cjs-null", "null"}, {"cjs-undefined", "undefined"}] do
      File.mkdir_p!(Path.join(@fixture_dir, "node_modules/#{name}"))

      File.write!(
        Path.join(@fixture_dir, "node_modules/#{name}/package.json"),
        Jason.encode!(%{name: name, main: "index.cjs"})
      )

      File.write!(
        Path.join(@fixture_dir, "node_modules/#{name}/index.cjs"),
        "module.exports = #{value};"
      )
    end

    File.write!(
      Path.join(@fixture_dir, "node_modules/callable/package.json"),
      ~s({"name":"callable","main":"index.cjs"})
    )

    File.write!(
      Path.join(@fixture_dir, "node_modules/callable/index.cjs"),
      "module.exports = function () { return 7; };"
    )

    File.write!(
      Path.join(@fixture_dir, "node_modules/late-callable/package.json"),
      ~s({"name":"late-callable","main":"index.cjs"})
    )

    File.write!(
      Path.join(@fixture_dir, "node_modules/late-callable/index.cjs"),
      "module.exports = {value: require('callable')(), nil: require('cjs-null') === null, undef: require('cjs-undefined') === undefined, portal: typeof require('react-dom').createPortal === 'function'};"
    )

    File.write!(
      Path.join(@fixture_dir, "node_modules/cjs-contract/package.json"),
      ~s({"name":"cjs-contract","main":"index.cjs"})
    )

    File.write!(
      Path.join(@fixture_dir, "node_modules/cjs-contract/index.cjs"),
      "module.exports = require('./exports.cjs');"
    )

    File.write!(
      Path.join(@fixture_dir, "node_modules/cjs-contract/exports.cjs"),
      "exports.singleton = {}; Object.defineProperty(exports, 'flag', {value: true});"
    )

    File.write!(
      Path.join(@fixture_dir, "node_modules/late-chat/package.json"),
      ~s({"name":"late-chat","main":"index.js","type":"module"})
    )

    late_source = """
    import React, { useState } from 'react';
    import { Button } from '@duskmoon-dev/components/button';
    export const reactIdentity = React;
    export function Late() {
      const [value, setValue] = useState('late-ready');
      return React.createElement(Button, {id: 'late-button', onClick: () => setValue('late-clicked')}, value);
    }
    """

    for name <- ["late-chat", "late-chat-two"] do
      File.mkdir_p!(Path.join(@fixture_dir, "node_modules/#{name}"))

      File.write!(
        Path.join(@fixture_dir, "node_modules/#{name}/package.json"),
        Jason.encode!(%{name: name, main: "index.js", type: "module"})
      )

      File.write!(Path.join(@fixture_dir, "node_modules/#{name}/index.js"), late_source)
    end

    File.write!(Path.join(@fixture_dir, "app.js"), """
    import * as Hooks from 'phoenix_duskmoon/hooks';
    import { DuskmoonReactForm } from 'phoenix_duskmoon/react-form';
    import {Composer, Message, reactIdentity, useStateIdentity} from './composer.js';
    import React, { useState } from 'react';
    import * as ReactNamespace from 'react';
    import { createRoot } from 'react-dom/client';
    import CJS, {singleton, flag} from 'cjs-contract';
    import * as CJSNamespace from 'cjs-contract';
    import { Chat } from '@duskmoon-dev/components/chat';
    import { createDuskmoonReactChat, useChatSubmission } from 'phoenix_duskmoon/react-chat';
    const h = React.createElement;
    window.contract = {hooks: ReactNamespace.useState === React.useState && useState === React.useState && reactIdentity === React && useStateIdentity === useState,
      cjs: CJS.singleton === singleton && CJSNamespace.singleton === singleton && flag === true,
      react: React, createRoot};
    const el = document.querySelector('#chat');
    el.dataset.chat = JSON.stringify({conversationId:'c1', messages:[{id:'m1',role:'assistant',content:'Consumer rendering',status:'streaming',metadata:{summary:'Turn summary'}}],runtime:{active:true},admission:{allowWhileStreaming:true}, event:'chat:event', actions:{send:'chat.send',sync:'chat.sync',stop:'chat.stop'}});
    window.hook = Object.assign(Object.create(createDuskmoonReactChat({Composer,renderMessage:Message})), {el,
      handleEvent(_name, handler){window.chatEvent=handler; return 1;}, removeHandleEvent(){},
      pushEvent(event, body, reply){window.admission={event,body}; reply({status:'ok',admission:'steering'});}});
    window.hook.mounted();
    """)

    File.write!(Path.join(@fixture_dir, "composer.js"), """
    import React, {useState} from 'react';
    import {Chat} from '@duskmoon-dev/components/chat';
    import {useChatSubmission} from 'phoenix_duskmoon/react-chat';
    export const reactIdentity = React;
    export const useStateIdentity = useState;
    export function Composer(props) {
      const [value, setValue] = useState('custom draft');
      const {submit, busy, notice} = useChatSubmission(props);
      return React.createElement(Chat.Composer, {value, onValueChange: setValue, canSubmit: props.canSubmit,
        generating: props.active, busy, error: notice || undefined,
        textareaProps: {'aria-label': 'Custom draft'}, onSubmit: async ({value}) => {await submit({text: value}); return true;}});
    }
    export function Message({message,targetId,timeline}) {
      return React.createElement(Chat,{id:targetId,timeline},React.createElement(Chat.Bubble,null,message.content),React.createElement(Chat.Footer,null,message.metadata?.summary));
    }
    """)

    File.write!(
      Path.join(@fixture_dir, "unreferenced_test.js"),
      ~s(import { test } from "bun:test";)
    )

    if context[:cjs] do
      File.write!(Path.join(@fixture_dir, "app.js"), """
      import callable from 'callable';
      import nullValue from 'cjs-null';
      import undefinedValue from 'cjs-undefined';
      import {createPortal} from 'react-dom';
      window.contract = {value:callable(), nil:nullValue===null, undef:undefinedValue===undefined, portal:typeof createPortal==='function'};
      """)
    end

    opts = [
      root: @fixture_dir,
      entry: Path.join(@fixture_dir, "app.js"),
      prefix: "/assets",
      vendor_prebundle: context[:vendor_prebundle] != false,
      resolve_dirs: [Path.join(@project_root, "node_modules"), Path.join(@project_root, "apps")]
    ]

    config = DuskmoonBundler.DevServer.init(opts)
    plug_config = if context[:runtime_init], do: opts, else: config

    server =
      start_supervised!(
        {Bandit,
         plug: {DuskmoonBundler.Integration.VendorPlug, plug_config},
         port: 0,
         ip: :loopback,
         startup_log: false},
        id: :dev_vendor_server
      )

    {:ok, {_ip, port}} = ThousandIsland.listener_info(server)
    {:ok, page} = CDPBrowser.new_page(browser)

    on_exit(fn -> CDPBrowser.close_page(page) end)

    %{page: page, config: config, port: port}
  end

  @tag runtime_init: true, vendor_prebundle: false
  test "on-demand local consumers retain one runtime during graph discovery", %{
    browser: browser,
    config: config,
    page: page,
    port: port
  } do
    # An uncalled dynamic registration must not enter the initial static graph.
    File.write!(
      Path.join(@fixture_dir, "app.js"),
      "\nwindow.unusedRegistration = () => import('not-installed-dynamic-vendor');\n",
      [:append]
    )

    check = fn page, port, config ->
      :ok = CDPBrowser.goto(page, "http://127.0.0.1:#{port}/", timeout: @navigation_timeout)

      # A queued startup load event can precede cold vendor graph completion.
      assert {:ok, %{"hooks" => true, "text" => "custom draft", "errors" => []}} =
               CDPBrowser.evaluate(
                 page,
                 """
                 (async () => {
                   const deadline = performance.now() + #{@navigation_timeout};
                   while(!document.querySelector('textarea') && !window.moduleErrors?.length && performance.now() < deadline) await new Promise(r=>setTimeout(r,20));
                   return {hooks:window.contract?.hooks ?? false,text:document.querySelector('textarea')?.value ?? null,errors:window.moduleErrors};
                 })()
                 """,
                 timeout: @navigation_timeout + 1_000
               )

      opts = [
        node_modules: config.node_modules,
        resolve_dirs: config.resolve_dirs,
        plugins: config.plugins,
        module_types: config.module_types,
        browser_token: config.vendor_url_token
      ]

      hash = Vendor.browser_hash(opts)

      for specifier <- ["late-chat", "late-chat-two"] do
        url = Vendor.vendor_url(specifier, opts)

        assert {:ok, %{"sameReact" => true, "text" => "late-clicked", "errors" => []}} =
                 CDPBrowser.evaluate(
                   page,
                   """
                   (async () => {
                     const late = await import(#{Jason.encode!(url)});
                     const root = window.contract.createRoot(document.querySelector('#late'));
                     root.render(window.contract.react.createElement(late.Late));
                     for(let i=0;i<100 && !document.querySelector('#late-button');i++) await new Promise(r=>setTimeout(r,20));
                     document.querySelector('#late-button').click();
                     await new Promise(r=>setTimeout(r,30));
                     const result = {sameReact:late.reactIdentity===window.contract.react,
                       text:document.querySelector('#late-button').textContent,errors:window.moduleErrors};
                     root.unmount(); return result;
                   })()
                   """,
                   timeout: 10_000
                 )

        assert Vendor.browser_hash(opts) == hash
      end
    end

    check.(page, port, config)
    assert :ok = stop_supervised(:dev_vendor_server)
    config = %{config | vendor_url_token: "restarted-on-demand-graph"}

    server =
      start_supervised!(
        {Bandit,
         plug: {DuskmoonBundler.Integration.VendorPlug, config},
         port: 0,
         ip: :loopback,
         startup_log: false},
        id: :dev_vendor_server
      )

    {:ok, {_ip, port}} = ThousandIsland.listener_info(server)
    {:ok, page} = CDPBrowser.new_page(browser)
    on_exit(fn -> CDPBrowser.close_page(page) end)
    check.(page, port, config)
  end

  @tag runtime_init: true
  test "real React consumers share named/namespace hooks with public chat and upstream parts", %{
    page: page,
    config: config,
    port: port
  } do
    :ok = CDPBrowser.goto(page, "http://127.0.0.1:#{port}/", timeout: @navigation_timeout)

    assert {:ok, %{"hooks" => true, "cjs" => true, "text" => "custom draft", "summary" => true}} =
             CDPBrowser.evaluate(
               page,
               """
               (async () => {
                 for(let i=0;i<100 && !document.querySelector('textarea');i++) await new Promise(r=>setTimeout(r,20));
                 return {hooks:window.contract?.hooks,cjs:window.contract?.cjs,text:document.querySelector('textarea')?.value,summary:document.body.textContent.includes('Turn summary')};
               })()
               """,
               timeout: 10_000
             )

    assert {:ok, %{"text" => "custom draft", "event" => "chat.send"}} =
             CDPBrowser.evaluate(page, """
             (async () => {
               [...document.querySelectorAll('button')].find(button=>button.textContent==='Send').click();
               await new Promise(r=>setTimeout(r,30));
               return {text:window.admission.body.text,event:window.admission.event};
             })()
             """)

    # Simulate an entry cache miss after the initial graph was served. On-demand
    # recovery must rebuild the whole known graph, retaining existing chunk IDs.
    vendor_opts = [
      node_modules: config.node_modules,
      resolve_dirs: config.resolve_dirs,
      plugins: config.plugins,
      module_types: config.module_types,
      vendor_source: config.vendor_source,
      browser_hash: config.vendor_hash,
      browser_token: config.vendor_url_token
    ]

    {:ok, old_chat} = Vendor.read("phoenix_duskmoon/react-chat", vendor_opts)

    cache_path =
      Path.join([
        Mix.Project.build_path(),
        "duskmoon_bundler/vendor",
        "phoenix_duskmoon__slash__react-chat.js"
      ])

    File.rm!(cache_path)

    assert {:ok, restored_chat} =
             Vendor.bundle_on_demand(
               "phoenix_duskmoon/react-chat",
               config.node_modules,
               vendor_opts
             )

    {:ok, original_imports} = OXC.select(old_chat, "chat.js", :import_specifiers)
    {:ok, restored_imports} = OXC.select(restored_chat, "chat.js", :import_specifiers)
    assert Enum.sort(original_imports) == Enum.sort(restored_imports)

    recovered_url = Vendor.vendor_url("phoenix_duskmoon/react-chat", vendor_opts) <> "&recovery=1"
    recovered_react_url = Vendor.vendor_url("react", vendor_opts) <> "&recovery=1"

    # Load the regenerated modules in the original page, with a new top-level URL
    # so the browser cannot satisfy the check from its original module cache.
    assert {:ok, %{"sameReact" => true, "text" => "recovered-clicked"}} =
             CDPBrowser.evaluate(
               page,
               """
               (async () => {
                 const recovered = await import(#{Jason.encode!(recovered_url)});
                 const react = await import(#{Jason.encode!(recovered_react_url)});
                 const original = window.contract.react;
                 function Composer(props) {
                   const [value, setValue] = original.useState('recovered-ready');
                   const {submit} = recovered.useChatSubmission(props);
                   return original.createElement('button', {id:'recovered-button',onClick:async()=>{await submit({text:value});setValue('recovered-clicked');}}, value);
                 }
                 const root = window.contract.createRoot(document.querySelector('#late'));
                 root.render(original.createElement(recovered.ReactChat, {
                   state:recovered.initialState('recovered', []),connected:true,
                   bridge:{send:async()=>({status:'ok'})},options:{Composer}
                 }));
                 for(let i=0;i<100 && !document.querySelector('#recovered-button');i++) await new Promise(r=>setTimeout(r,20));
                 document.querySelector('#recovered-button').click();
                 await new Promise(r=>setTimeout(r,30));
                 const result = {sameReact:react.default===original && react.useState===original.useState,text:document.querySelector('#recovered-button').textContent};
                 root.unmount(); return result;
               })()
               """,
               timeout: 10_000
             )

    # A package discovered later reuses optimized peer entrypoints instead of
    # bundling a second React dispatcher into its own module.
    late_url =
      Vendor.vendor_url("late-chat",
        browser_hash: Vendor.browser_hash(vendor_opts),
        browser_token: config.vendor_url_token
      )

    assert {:ok, %{"sameReact" => true, "text" => "late-clicked"}} =
             CDPBrowser.evaluate(
               page,
               """
               (async () => {
                 const late = await import(#{Jason.encode!(late_url)});
                 const root = window.contract.createRoot(document.querySelector('#late'));
                 root.render(window.contract.react.createElement(late.Late));
                 for(let i=0;i<100 && !document.querySelector('#late-button');i++) await new Promise(r=>setTimeout(r,20));
                 document.querySelector('#late-button').click();
                 await new Promise(r=>setTimeout(r,30));
                 const result = {sameReact:late.reactIdentity===window.contract.react,text:document.querySelector('#late-button').textContent};
                 root.unmount(); window.hook.destroyed(); return result;
               })()
               """,
               timeout: 10_000
             )

    late_two_url = Vendor.vendor_url("late-chat-two", vendor_opts)

    assert {:ok, %{"sameReact" => true, "text" => "late-clicked"}} =
             CDPBrowser.evaluate(
               page,
               """
               (async () => {
                 const late = await import(#{Jason.encode!(late_two_url)});
                 const root = window.contract.createRoot(document.querySelector('#late'));
                 root.render(window.contract.react.createElement(late.Late));
                 for(let i=0;i<100 && !document.querySelector('#late-button');i++) await new Promise(r=>setTimeout(r,20));
                 document.querySelector('#late-button').click();
                 await new Promise(r=>setTimeout(r,30));
                 const result = {sameReact:late.reactIdentity===window.contract.react,text:document.querySelector('#late-button').textContent};
                 root.unmount(); return result;
               })()
               """,
               timeout: 10_000
             )
  end

  @tag cjs: true, vendor_prebundle: false
  test "late CommonJS requires retain primitive defaults and namespace-only proxies", %{
    browser: browser,
    page: page,
    config: config,
    port: port
  } do
    :ok = CDPBrowser.goto(page, "http://127.0.0.1:#{port}/", timeout: @navigation_timeout)
    expected = %{"value" => 7, "nil" => true, "undef" => true, "portal" => true}

    assert {:ok, ^expected} =
             CDPBrowser.evaluate(page, """
             (async()=>{for(let i=0;i<100&&!window.contract;i++)await new Promise(r=>setTimeout(r,20));return window.contract;})()
             """)

    callable_url =
      Vendor.vendor_url("late-callable",
        browser_hash: config.vendor_hash,
        browser_token: config.vendor_url_token
      )

    assert {:ok, ^expected} =
             CDPBrowser.evaluate(
               page,
               "import(#{Jason.encode!(callable_url)}).then(module=>module.default)",
               timeout: 15_000
             )

    # Emulate a new VM/configuration while retaining its existing disk cache.
    # Load the optimized late entry first so other vendor requests cannot repair
    # stale external URLs before this regression observes them.
    new_config = %{config | vendor_url_token: "restarted-vendor-configuration"}

    restarted_url =
      Vendor.vendor_url("late-callable",
        node_modules: new_config.node_modules,
        resolve_dirs: new_config.resolve_dirs,
        plugins: new_config.plugins,
        module_types: new_config.module_types,
        vendor_source: new_config.vendor_source,
        browser_token: new_config.vendor_url_token
      )

    File.write!(
      Path.join(@fixture_dir, "app.js"),
      "const url = #{Jason.encode!(restarted_url)}; import(url).then(({default: contract}) => {window.restartContract = contract;});"
    )

    assert :ok = stop_supervised(:dev_vendor_server)

    restarted_server =
      start_supervised!(
        {Bandit,
         plug: {DuskmoonBundler.Integration.VendorPlug, new_config},
         port: 0,
         ip: :loopback,
         startup_log: false},
        id: :dev_vendor_server
      )

    {:ok, {_ip, restarted_port}} = ThousandIsland.listener_info(restarted_server)
    {:ok, restarted_page} = CDPBrowser.new_page(browser)
    on_exit(fn -> CDPBrowser.close_page(restarted_page) end)

    :ok =
      CDPBrowser.goto(restarted_page, "http://127.0.0.1:#{restarted_port}/",
        timeout: @navigation_timeout
      )

    assert {:ok, %{"contract" => ^expected, "errors" => []}} =
             CDPBrowser.evaluate(
               restarted_page,
               """
               (async()=>{for(let i=0;i<500&&!window.restartContract;i++)await new Promise(r=>setTimeout(r,20));return {contract:window.restartContract??null,errors:window.moduleErrors};})()
               """,
               timeout: 15_000
             )
  end
end
