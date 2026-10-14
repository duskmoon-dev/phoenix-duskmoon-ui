defmodule DuskmoonStorybook.Integration.ProductionPreloadPlug do
  @moduledoc false
  @behaviour Plug

  def init(opts), do: opts

  def call(conn, opts) do
    if String.starts_with?(conn.request_path, "/assets/js/") do
      if String.ends_with?(conn.request_path, ".css") do
        send(opts[:test_pid], {:stylesheet_requested, self()})

        receive do
          :release_stylesheet -> :ok
        after
          10_000 -> raise "Stylesheet response was not released"
        end
      end

      Plug.Static.call(conn, Plug.Static.init(at: "/assets/js", from: opts[:outdir]))
    else
      conn
      |> Plug.Conn.put_resp_content_type("text/html")
      |> Plug.Conn.send_resp(200, """
      <div id="panel">Loading</div>
      <script>
        window.moduleErrors = [];
        addEventListener('error', event => window.moduleErrors.push(event.message || event.target.href), true);
        addEventListener('unhandledrejection', event => window.moduleErrors.push(String(event.reason)));
      </script>
      <script type="module" src="/assets/js/#{opts[:entry]}"></script>
      """)
    end
  end
end

defmodule DuskmoonStorybook.Integration.ProductionPreloadTest do
  use ExUnit.Case, async: false

  @moduletag :integration
  @moduletag :tmp_dir
  alias DuskmoonBundler.Integration.CDPBrowser

  setup_all do
    {:ok, browser} = CDPBrowser.start_link()
    on_exit(fn -> CDPBrowser.stop(browser) end)
    %{browser: browser}
  end

  test "production lazy panels preload assets relative to their bundle on nested routes", %{
    tmp_dir: tmp_dir,
    browser: browser
  } do
    on_exit(fn -> File.rm_rf!(tmp_dir) end)

    File.write!(Path.join(tmp_dir, "app.js"), """
    window.loadPanel = () => import('./panel.js');
    window.loadOther = () => import('./other.js');
    """)

    File.write!(Path.join(tmp_dir, "shared.js"), "export const value = 'panel-ready';")
    File.write!(Path.join(tmp_dir, "panel.css"), "#panel { color: rgb(12, 34, 56); }")

    File.write!(Path.join(tmp_dir, "panel.js"), """
    import { value } from './shared.js';
    import './panel.css';
    document.querySelector('#panel').textContent = value;
    export { value };
    """)

    File.write!(Path.join(tmp_dir, "other.js"), """
    import { value } from './shared.js';
    export { value };
    """)

    outdir = Path.join(tmp_dir, "dist")

    assert {:ok, result} =
             DuskmoonBundler.Builder.build(
               entry: Path.join(tmp_dir, "app.js"),
               outdir: outdir,
               name: "app",
               format: :esm,
               hash: true,
               minify: true,
               sourcemap: false
             )

    manifest = outdir |> Path.join("manifest.json") |> File.read!() |> Jason.decode!()
    entries = manifest["entries"]
    panel = entries |> Map.values() |> Enum.find(&String.contains?(&1["file"], "-panel-"))
    [shared | _] = panel["imports"]

    server =
      start_supervised!(
        {Bandit,
         plug:
           {DuskmoonStorybook.Integration.ProductionPreloadPlug,
            outdir: outdir, entry: Path.basename(result.js.path), test_pid: self()},
         port: 0,
         ip: :loopback,
         startup_log: false}
      )

    {:ok, {_ip, port}} = ThousandIsland.listener_info(server)

    for route <- ["/setup", "/account/setup/"] do
      {:ok, page} = CDPBrowser.new_page(browser)
      on_exit(fn -> CDPBrowser.close_page(page) end)
      :ok = CDPBrowser.goto(page, "http://127.0.0.1:#{port}#{route}")

      # A server-rendered absolute preload and the bundle's relative dependency
      # identify the same asset and must share one link.
      assert {:ok, true} =
               CDPBrowser.evaluate(page, """
               (async () => {
                 const link = document.createElement('link');
                 link.rel = 'modulepreload';
                 link.href = location.origin + #{Jason.encode!("/assets/js/" <> shared)};
                 await new Promise((resolve, reject) => {
                   link.onload = resolve; link.onerror = reject; document.head.append(link);
                 });
                 window.panelLoaded = false;
                 window.panelLoading = window.loadPanel().then(module => {
                   window.panelLoaded = true; return module.value;
                 });
                 return true;
               })()
               """)

      assert {:ok, []} =
               CDPBrowser.evaluate(page, """
               [...document.querySelectorAll('link')].map(link => new URL(link.href).pathname)
                 .filter(path => !path.startsWith('/assets/js/'))
               """)

      assert_receive {:stylesheet_requested, request_pid}, 5_000
      assert {:ok, false} = CDPBrowser.evaluate(page, "window.panelLoaded")
      send(request_pid, :release_stylesheet)

      assert {:ok,
              %{
                "value" => "panel-ready",
                "text" => "panel-ready",
                "color" => "rgb(12, 34, 56)",
                "sharedLinks" => 1,
                "stylesheets" => 1,
                "badAssets" => [],
                "errors" => []
              }} =
               CDPBrowser.evaluate(page, """
               (async () => {
                 const value = await window.panelLoading;
                 await window.loadPanel();
                 return {
                   value, text: document.querySelector('#panel').textContent,
                   color: getComputedStyle(document.querySelector('#panel')).color,
                   sharedLinks: [...document.querySelectorAll('link')].filter(link => link.href === location.origin + #{Jason.encode!("/assets/js/" <> shared)}).length,
                   stylesheets: document.querySelectorAll('link[rel="stylesheet"]').length,
                   badAssets: performance.getEntriesByType('resource').map(entry => new URL(entry.name).pathname)
                     .filter(path => /\\.(js|css)$/.test(path) && !path.startsWith('/assets/js/')),
                   errors: window.moduleErrors
                 };
               })()
               """)
    end
  end
end
