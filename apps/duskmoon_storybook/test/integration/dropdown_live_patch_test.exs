defmodule DuskmoonStorybook.DropdownLivePatchTest do
  use ExUnit.Case, async: false

  alias DuskmoonBundler.Integration.CDPBrowser

  @moduletag :integration
  @moduletag timeout: 60_000
  @root Path.expand("../../../..", __DIR__)

  defmodule Fixture do
    use Phoenix.LiveView, layout: false
    import PhoenixDuskmoon.Component.Action.Dropdown

    def mount(_params, _session, socket), do: {:ok, assign(socket, version: 0)}

    def handle_event("patch", _params, socket),
      do: {:noreply, update(socket, :version, &(&1 + 1))}

    def render(assigns) do
      ~H"""
      <main>
        <.dm_dropdown id="patch-dropdown">
          <:trigger>Notifications {@version}</:trigger>
          <:content>Notification content</:content>
        </.dm_dropdown>
      </main>
      """
    end
  end

  defmodule Assets do
    @behaviour Plug
    alias DuskmoonStorybook.DropdownLivePatchTest.Fixture

    def init(assets), do: assets

    def call(%{request_path: "/test/dropdown"} = conn, _assets) do
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
      <!doctype html><html lang="en"><head>
      <meta name="csrf-token" content="#{csrf}">
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
      conn
      |> Plug.Conn.put_resp_header("content-security-policy", "script-src 'self'")
      |> Plug.Conn.put_resp_content_type(type)
      |> Plug.Conn.send_resp(200, body)
    end
  end

  setup_all do
    assets = %{
      "/test/client.js" => {"text/javascript", client()},
      "/test/phoenix.js" => js("deps/phoenix/priv/static/phoenix.mjs"),
      "/test/live-view.js" => js("deps/phoenix_live_view/priv/static/phoenix_live_view.esm.js"),
      "/test/popover.js" => js("apps/phoenix_duskmoon/assets/js/hooks/duskmoon_popover.js")
    }

    server = start_supervised!({Gaoxy.HTTP, plug: {Assets, assets}, ip: {127, 0, 0, 1}, port: 0})
    %{local: {:ok, {_ip, port}}} = Gaoxy.info(server, :http)
    {:ok, browser} = CDPBrowser.start_link()
    on_exit(fn -> CDPBrowser.stop(browser) end)
    {:ok, page} = CDPBrowser.new_page(browser)
    %{page: page, url: "http://localhost:#{port}/test/dropdown"}
  end

  test "a connected trigger-only patch retains native visibility and expanded state under CSP", %{
    page: page,
    url: url
  } do
    assert :ok = CDPBrowser.goto(page, url)

    wait_for(
      page,
      "document.querySelector('.phx-connected') && window.dropdownHook && dropdownTrigger().getAttribute('aria-expanded') === 'false'"
    )

    assert {:ok, _} =
             CDPBrowser.evaluate(page, """
             window.originalWrapper = dropdownHook.el;
             window.originalPanel = document.getElementById("patch-dropdown-popover");
             dropdownTrigger().focus();
             dropdownTrigger().click();
             """)

    wait_for(page, "dropdownTrigger().getAttribute('aria-expanded') === 'true'")

    # A real server event updates only the trigger slot, leaving the panel unchanged.
    assert {:ok, _} = CDPBrowser.evaluate(page, "dropdownHook.pushEvent('patch', {})")

    wait_for(page, "dropdownTrigger().textContent.trim() === 'Notifications 1'")

    assert {:ok,
            %{
              "sameWrapper" => true,
              "samePanel" => true,
              "open" => true,
              "expanded" => "true",
              "updated" => true,
              "cspViolations" => []
            }} =
             CDPBrowser.evaluate(page, """
             ({sameWrapper: dropdownHook.el === originalWrapper,
               samePanel: document.getElementById("patch-dropdown-popover") === originalPanel,
               open: originalPanel.matches(":popover-open"),
               expanded: dropdownTrigger().getAttribute("aria-expanded"),
               updated: window.dropdownUpdates > 0,
               cspViolations: window.dropdownCspViolations})
             """)

    for type <- ["keyDown", "keyUp"] do
      assert {:ok, _} =
               CDPBrowser.command(page, "Input.dispatchKeyEvent", %{
                 "type" => type,
                 "key" => "Escape",
                 "code" => "Escape",
                 "windowsVirtualKeyCode" => 27
               })
    end

    wait_for(
      page,
      "!originalPanel.matches(':popover-open') && dropdownTrigger().getAttribute('aria-expanded') === 'false'"
    )
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
                   else if (Date.now() > deadline) reject(new Error("Timed out waiting for dropdown LiveView patch"));
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
    import {DuskmoonPopover} from "/test/popover.js";
    window.dropdownUpdates = 0;
    window.dropdownCspViolations = [];
    window.addEventListener("securitypolicyviolation", event => {
      dropdownCspViolations.push(event.violatedDirective);
    });
    window.dropdownTrigger = () => document.getElementById("patch-dropdown-popover-trigger");
    const dropdown = {
      ...DuskmoonPopover,
      mounted() {
        DuskmoonPopover.mounted.call(this);
        window.dropdownHook = this;
      },
      updated() {
        dropdownUpdates++;
        DuskmoonPopover.updated.call(this);
      }
    };
    window.liveSocket = new LiveSocket("/live", Socket, {
      params: {_csrf_token: document.querySelector("meta[name=csrf-token]").content},
      hooks: {DuskmoonPopover: dropdown}
    });
    liveSocket.connect();
    """
  end
end
