defmodule DuskmoonBundler.Integration.HoistedRegistrarBuildTest.Static do
  @moduledoc false
  @behaviour Plug

  def init(opts), do: Plug.Static.init(opts)

  def call(conn, opts) do
    case Plug.Static.call(conn, opts) do
      %{halted: true} = conn -> conn
      conn -> Plug.Conn.send_resp(conn, 404, "not found")
    end
  end
end

defmodule DuskmoonBundler.Integration.HoistedRegistrarBuildTest do
  use ExUnit.Case, async: false

  alias DuskmoonBundler.Integration.CDPBrowser

  @moduletag :integration

  setup_all do
    {:ok, browser} = CDPBrowser.start_link()
    on_exit(fn -> CDPBrowser.stop(browser) end)
    %{browser: browser}
  end

  test "explicit workspace resolve directory bundles a hoisted lazy registrar for static hosting",
       %{browser: browser} do
    root = Path.join(System.tmp_dir!(), "hoisted-registrar-#{System.unique_integer([:positive])}")
    on_exit(fn -> File.rm_rf!(root) end)
    workspace = Path.join(root, "apps/demo")
    assets = Path.join(workspace, "assets")
    outdir = Path.join(root, "public")
    package = Path.join(root, "node_modules/@example/widget")
    File.mkdir_p!(assets)
    File.mkdir_p!(Path.join(workspace, "node_modules"))
    File.mkdir_p!(package)

    File.write!(
      Path.join(package, "package.json"),
      ~s({"name":"@example/widget","type":"module","exports":{"./register":"./register.js"}})
    )

    File.write!(Path.join(package, "register.js"), """
    customElements.define('test-hoisted-widget', class extends HTMLElement {
      connectedCallback() { this.attachShadow({mode: 'open'}).innerHTML = '<button>Registered from a lazy chunk</button>'; }
    });
    """)

    entry = Path.join(assets, "app.js")

    File.write!(entry, """
    const registrars = {'test-hoisted-widget': () => import('@example/widget/register')};
    document.getElementById('load-widget').addEventListener('click', async () => {
      await registrars['test-hoisted-widget']();
      document.getElementById('status').textContent = 'loaded';
    });
    """)

    assert {:ok, result} =
             DuskmoonBundler.Builder.build(
               entry: entry,
               root: assets,
               outdir: outdir,
               resolve_dirs: [Path.join(root, "node_modules")],
               format: :esm,
               minify: true,
               sourcemap: false,
               hash: false
             )

    assert Enum.count(result.chunks) >= 2

    File.write!(Path.join(outdir, "index.html"), """
    <!doctype html><html lang="en"><body>
      <button id="load-widget">Load widget</button><p id="status">idle</p>
      <test-hoisted-widget></test-hoisted-widget>
      <script type="module" src="/#{Path.basename(result.js.path)}"></script>
    </body></html>
    """)

    server =
      start_supervised!(
        {Bandit,
         plug: {__MODULE__.Static, at: "/", from: outdir},
         ip: :loopback,
         port: 0,
         startup_log: false}
      )

    {:ok, {_ip, port}} = ThousandIsland.listener_info(server)
    {:ok, page} = CDPBrowser.new_page(browser)
    on_exit(fn -> CDPBrowser.close_page(page) end)
    :ok = CDPBrowser.goto(page, "http://127.0.0.1:#{port}/index.html")

    assert {:ok, true} = CDPBrowser.evaluate(page, "!customElements.get('test-hoisted-widget')")

    assert {:ok,
            %{"defined" => true, "content" => "Registered from a lazy chunk", "loaded" => true}} =
             CDPBrowser.evaluate(page, """
             (async () => {
               document.getElementById('load-widget').click();
               await Promise.race([
                 customElements.whenDefined('test-hoisted-widget'),
                 new Promise((_, reject) => setTimeout(() => reject(new Error('registrar did not load')), 3000))
               ]);
               await new Promise(resolve => setTimeout(resolve, 20));
               return {defined: !!customElements.get('test-hoisted-widget'),
                 content: document.querySelector('test-hoisted-widget').shadowRoot.textContent,
                 loaded: document.getElementById('status').textContent === 'loaded'};
             })()
             """)
  end
end
