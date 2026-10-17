defmodule DuskmoonStorybook.SplitPaneLivePatchTest do
  use ExUnit.Case, async: false
  alias DuskmoonBundler.Integration.CDPBrowser

  @moduletag :integration
  @moduletag timeout: 60_000
  @root Path.expand("../../../..", __DIR__)

  defmodule Fixture do
    use Phoenix.LiveView, layout: false
    import PhoenixDuskmoon.Component.Layout.SplitPane

    def mount(_params, _session, socket), do: {:ok, assign(socket, version: 0, filter: "")}

    def handle_event("patch", _params, socket),
      do: {:noreply, update(socket, :version, &(&1 + 1))}

    def handle_event("filter", %{"filter" => filter}, socket),
      do: {:noreply, assign(socket, :filter, filter)}

    def render(assigns) do
      ~H"""
      <main style="width:900px">
        <button id="patch-panes" phx-click="patch">Update files</button>
        <.dm_split_pane
          id="patch-split-pane"
          initial_width={if @version == 0, do: 280, else: 200}
          data-server-version={@version}
          data-server-filter={@filter}
          style="height:240px"
        >
          <:primary>
            <nav>Folders version {@version}</nav>
          </:primary>
          <section>
            <span id="file-version">Files version {@version}</span>
            <form id="file-filter-form" phx-change="filter">
              <input id="file-filter" name="filter" value={@filter} aria-label="Filter files" />
            </form>
          </section>
        </.dm_split_pane>
      </main>
      """
    end
  end

  defmodule Assets do
    @behaviour Plug
    alias DuskmoonStorybook.SplitPaneLivePatchTest.Fixture
    def init(assets), do: assets

    def call(%{request_path: "/test/split-pane"} = conn, _assets) do
      endpoint = DuskmoonStorybookWeb.Endpoint
      conn = %{conn | secret_key_base: endpoint.config(:secret_key_base)}

      conn =
        conn
        |> Plug.Conn.put_private(:phoenix_endpoint, endpoint)
        |> Plug.Session.call(
          Plug.Session.init(
            store: :cookie,
            key: "_duskmoon_storybook_web_key",
            signing_salt: "+Si2ZHDD"
          )
        )
        |> Plug.Conn.fetch_session()
        |> Plug.Conn.fetch_query_params()
        |> Plug.CSRFProtection.call(Plug.CSRFProtection.init([]))

      {:ok, content, _assigns} = Phoenix.LiveView.Static.render(conn, Fixture, [])
      csrf = Plug.CSRFProtection.get_csrf_token()

      html = """
      <!doctype html><html lang="en" data-theme="sunshine"><head>
      <meta name="csrf-token" content="#{csrf}"><link rel="stylesheet" href="/test/split.css">
      </head><body>#{Phoenix.HTML.safe_to_string(content)}
      <script type="module" src="/test/client.js"></script></body></html>
      """

      serve(conn, "text/html", html)
    end

    def call(conn, assets) do
      case assets[conn.request_path] do
        {type, body} -> serve(conn, type, body)
        nil -> DuskmoonStorybookWeb.Endpoint.call(conn, [])
      end
    end

    defp serve(conn, type, body) do
      conn |> Plug.Conn.put_resp_content_type(type) |> Plug.Conn.send_resp(200, body)
    end
  end

  setup_all do
    css_path = Path.join(@root, "apps/phoenix_duskmoon/assets/css/phoenix_duskmoon.css")

    {:ok, css} =
      DuskmoonBundler.Tailwind.build(
        css: File.read!(css_path),
        css_base: Path.dirname(css_path),
        sources: [%{base: Path.join(@root, "apps/phoenix_duskmoon/lib"), pattern: "**/*.ex"}]
      )

    assets = %{
      "/test/split.css" => {"text/css", css},
      "/test/client.js" => {"text/javascript", client()},
      "/test/phoenix.js" => js("deps/phoenix/priv/static/phoenix.mjs"),
      "/test/live-view.js" => js("deps/phoenix_live_view/priv/static/phoenix_live_view.esm.js"),
      "/test/split.js" => js("apps/phoenix_duskmoon/assets/js/hooks/split_pane.js")
    }

    server = start_supervised!({Bandit, plug: {Assets, assets}, ip: {127, 0, 0, 1}, port: 0})
    {:ok, {_ip, port}} = ThousandIsland.listener_info(server)
    {:ok, browser} = CDPBrowser.start_link()
    on_exit(fn -> CDPBrowser.stop(browser) end)
    {:ok, page} = CDPBrowser.new_page(browser)
    %{page: page, url: "http://localhost:#{port}/test/split-pane"}
  end

  test "a connected LiveView patch updates pane contents and retains the user's width", %{
    page: page,
    url: url
  } do
    assert :ok = CDPBrowser.goto(page, url)
    wait_for(page, "document.querySelector('.phx-connected') && window.splitHook")

    assert {:ok, _} =
             CDPBrowser.evaluate(page, """
             window.originalSplitPane = splitHook.el;
             document.getElementById("file-filter").focus();
             """)

    assert {:ok, _} = CDPBrowser.command(page, "Input.insertText", %{"text" => "report"})
    wait_for(page, "splitHook.el.dataset.serverFilter === 'report'")
    assert {:ok, _} = CDPBrowser.evaluate(page, "splitHook.splitHandle().focus()")

    assert {:ok, _} =
             CDPBrowser.command(page, "Input.dispatchKeyEvent", %{
               "type" => "keyDown",
               "key" => "End"
             })

    assert {:ok, _} =
             CDPBrowser.command(page, "Input.dispatchKeyEvent", %{
               "type" => "keyUp",
               "key" => "End"
             })

    assert {:ok, 480} =
             CDPBrowser.evaluate(
               page,
               "document.getElementById('patch-split-pane-primary').getBoundingClientRect().width"
             )

    assert {:ok, _} = CDPBrowser.evaluate(page, "document.getElementById('patch-panes').click()")
    wait_for(page, "document.getElementById('file-version').textContent === 'Files version 1'")

    assert {:ok,
            %{
              "sameRoot" => true,
              "initialWidth" => "200",
              "version" => "1",
              "width" => 480,
              "aria" => "480",
              "filter" => "report",
              "beforeUpdate" => true,
              "updated" => true,
              "events" => []
            }} =
             CDPBrowser.evaluate(page, """
             ({sameRoot: splitHook.el === originalSplitPane,
               initialWidth: originalSplitPane.dataset.initialWidth,
               version: originalSplitPane.dataset.serverVersion,
               width: document.getElementById("patch-split-pane-primary").getBoundingClientRect().width,
               aria: splitHook.splitHandle().getAttribute("aria-valuenow"),
               filter: document.getElementById("file-filter").value,
               beforeUpdate: window.splitBeforeUpdates > 0, updated: window.splitUpdates > 0,
               events: window.splitResizeEvents})
             """)
  end

  defp wait_for(page, condition) do
    assert {:ok, true} =
             CDPBrowser.evaluate(
               page,
               """
               new Promise((resolve, reject) => {
                 const deadline = Date.now() + 10000;
                 const check = () => {
                   if (#{condition}) resolve(true);
                   else if (Date.now() > deadline) reject(new Error("Timed out waiting for split-pane LiveView patch"));
                   else setTimeout(check, 20);
                 };
                 check();
               })
               """,
               timeout: 12_000
             )
  end

  defp js(path), do: {"text/javascript", File.read!(Path.join(@root, path))}

  defp client do
    """
    import {Socket} from "/test/phoenix.js";
    import {LiveSocket} from "/test/live-view.js";
    import {DuskmoonSplitPane} from "/test/split.js";
    window.splitBeforeUpdates = 0;
    window.splitUpdates = 0;
    window.splitResizeEvents = [];
    const split = {
      ...DuskmoonSplitPane,
      mounted() {
        const push = this.pushEvent.bind(this);
        this.pushEvent = (...args) => { splitResizeEvents.push(args); return push(...args); };
        DuskmoonSplitPane.mounted.call(this);
        window.splitHook = this;
      },
      beforeUpdate() { splitBeforeUpdates++; DuskmoonSplitPane.beforeUpdate.call(this); },
      updated() { splitUpdates++; DuskmoonSplitPane.updated.call(this); }
    };
    window.liveSocket = new LiveSocket("/live", Socket, {
      params: {_csrf_token: document.querySelector("meta[name=csrf-token]").content},
      hooks: {DuskmoonSplitPane: split}
    });
    liveSocket.connect();
    """
  end
end
