defmodule DuskmoonStorybook.LeftMenuHostStateTest do
  use ExUnit.Case, async: false

  alias DuskmoonBundler.Integration.CDPBrowser

  @moduletag :integration
  @moduletag timeout: 60_000
  @root Path.expand("../../../..", __DIR__)

  defmodule Assets do
    @behaviour Plug
    def init(assets), do: assets

    def call(conn, assets) do
      case assets[conn.request_path] do
        {type, body} ->
          conn
          |> Plug.Conn.put_resp_content_type(type)
          |> Plug.Conn.send_resp(200, body)

        nil ->
          DuskmoonStorybookWeb.Endpoint.call(conn, [])
      end
    end
  end

  setup_all do
    css_path = Path.join(@root, "apps/duskmoon_storybook/assets/css/app.css")

    {:ok, css} =
      DuskmoonBundler.Tailwind.build(
        css: File.read!(css_path),
        css_base: Path.dirname(css_path),
        sources: [
          %{base: Path.join(@root, "apps/phoenix_duskmoon/lib"), pattern: "**/*.ex"},
          %{base: Path.join(@root, "apps/duskmoon_storybook/lib"), pattern: "**/*.ex"}
        ]
      )

    assets = %{
      "/assets/js/app.js" => {"text/javascript", client()},
      "/assets/css/app.css" => {"text/css", css},
      "/test/phoenix.js" => js("deps/phoenix/priv/static/phoenix.mjs"),
      "/test/live-view.js" => js("deps/phoenix_live_view/priv/static/phoenix_live_view.esm.js"),
      "/test/menu.js" => js("apps/phoenix_duskmoon/assets/js/hooks/left_menu.js"),
      "/test/navigation.js" =>
        js("apps/phoenix_duskmoon/assets/js/hooks/left_menu_navigation.js"),
      "/test/host.js" => js("apps/duskmoon_storybook/assets/js/left_menu.js")
    }

    server = start_supervised!({Bandit, plug: {Assets, assets}, ip: {127, 0, 0, 1}, port: 0})
    {:ok, {_ip, port}} = ThousandIsland.listener_info(server)
    {:ok, browser} = CDPBrowser.start_link()
    on_exit(fn -> CDPBrowser.stop(browser) end)
    {:ok, page} = CDPBrowser.new_page(browser)
    %{page: page, url: "http://localhost:#{port}"}
  end

  test "real host events, patches and reconnect retain the controlled sticky DOM and group/scroll state",
       %{page: page, url: url} do
    assert {:ok, _} =
             CDPBrowser.command(page, "Emulation.setDeviceMetricsOverride", %{
               "width" => 1000,
               "height" => 400,
               "deviceScaleFactor" => 1,
               "mobile" => false
             })

    assert :ok =
             CDPBrowser.goto(
               page,
               url <> "/components/navigation/left-menu/live/dashboard?controlled=true"
             )

    wait_for(
      page,
      "document.querySelector('[data-phx-main].phx-connected') && document.querySelector('#left-menu-demo-sidebar[data-collapse-event]')"
    )

    assert {:ok, true} =
             CDPBrowser.evaluate(page, """
             (() => {
               window.originalMenu = document.getElementById("left-menu-demo-sidebar");
               window.originalScroll = originalMenu.querySelector("[data-left-menu-scroll]");
               originalScroll.scrollTop = 80;
               originalMenu.querySelector("[data-left-menu-toggle]").click();
               return originalMenu.dataset.collapsed === "true";
             })()
             """)

    wait_for(
      page,
      "document.getElementById('left-menu-host-state').dataset.notifications === '1'"
    )

    wait_for(
      page,
      "document.getElementById('left-menu-demo-sidebar-navigation').dataset.collapseState === 'true'"
    )

    assert {:ok, true} =
             CDPBrowser.evaluate(page, """
             (() => {
               originalScroll.scrollTop = 80;
               document.getElementById("left-menu-host-patch").click();
               return true;
             })()
             """)

    wait_for(
      page,
      "document.getElementById('left-menu-demo-sidebar-navigation').dataset.activeNav === 'settings' && document.getElementById('left-menu-demo-link-settings').getAttribute('aria-current') === 'page'"
    )

    assert_state(page, true, 80)

    assert {:ok, true} =
             CDPBrowser.evaluate(page, """
             (() => {
               document.getElementById("left-menu-host-expand").click();
               return true;
             })()
             """)

    wait_for(page, "originalMenu.dataset.collapsed === 'false'")
    assert_state(page, false, 80)

    # Zero is a valid scroll snapshot. Repeated silent setters must retain the
    # closed Administration group rather than capture its forced-open state.
    assert {:ok, true} =
             CDPBrowser.evaluate(page, """
             (() => {
               originalScroll.scrollTop = 0;
               for (const collapsed of [true, true, false]) {
                 originalMenu.dispatchEvent(new CustomEvent("duskmoon:left-menu:set-collapsed", {detail: {collapsed}}));
               }
               return originalScroll.scrollTop === 0 &&
                 !document.getElementById("left-menu-demo-sidebar-group-administration").open &&
                 document.getElementById("left-menu-host-state").dataset.notifications === "1";
             })()
             """)

    # A host session store would reload its saved value here. This demo reloads
    # false on mount; reconnect must reassert that authoritative value silently.
    assert {:ok, true} =
             CDPBrowser.evaluate(page, """
             (() => {
               originalMenu.dispatchEvent(new CustomEvent("duskmoon:left-menu:set-collapsed", {detail: {collapsed: true}}));
               return originalMenu.dataset.collapsed === "true";
             })()
             """)

    assert {:ok, true} =
             CDPBrowser.evaluate(page, """
             new Promise(resolve => liveSocket.disconnect(() => {
               liveSocket.connect();
               resolve(true);
             }))
             """)

    wait_for(
      page,
      "document.querySelector('[data-phx-main].phx-connected') && originalMenu.dataset.collapsed === 'false'"
    )

    assert_state(page, false, 0)
  end

  defp assert_state(page, collapsed, scroll_top) do
    assert {:ok, true} =
             CDPBrowser.evaluate(page, """
             document.getElementById("left-menu-demo-sidebar") === originalMenu &&
               originalMenu.querySelector("[data-left-menu-scroll]") === originalScroll &&
               originalMenu.dataset.collapsed === "#{collapsed}" && originalScroll.scrollTop === #{scroll_top}
             """)
  end

  defp wait_for(page, condition) do
    result =
      CDPBrowser.evaluate(
        page,
        """
        new Promise((resolve, reject) => {
          const deadline = Date.now() + 10000;
          const check = () => {
            if (#{condition}) resolve(true);
            else if (Date.now() > deadline) reject(new Error("Timed out waiting for host menu state"));
            else setTimeout(check, 20);
          };
          check();
        })
        """,
        timeout: 12_000
      )

    assert result == {:ok, true},
           inspect(CDPBrowser.evaluate(page, "sessionStorage.getItem('host-menu-diagnostics')"))
  end

  defp js(path), do: {"text/javascript", File.read!(Path.join(@root, path))}

  defp client do
    """
    import {Socket} from "/test/phoenix.js";
    import {LiveSocket} from "/test/live-view.js";
    import {DuskmoonLeftMenu} from "/test/menu.js";
    import {DuskmoonLeftMenuNavigation} from "/test/navigation.js";
    import {DuskmoonLeftMenuHostDemo} from "/test/host.js";
    const csrfToken = document.querySelector("meta[name=csrf-token]").content;
    window.liveSocket = new LiveSocket("/live", Socket, {
      params: {_csrf_token: csrfToken},
      hooks: {DuskmoonLeftMenu, DuskmoonLeftMenuNavigation, DuskmoonLeftMenuHostDemo},
      logger: (_view, kind, message, object) => {
        const entries = JSON.parse(sessionStorage.getItem("host-menu-diagnostics") || "[]");
        entries.push({kind, message, object});
        sessionStorage.setItem("host-menu-diagnostics", JSON.stringify(entries.slice(-40)));
      },
    });
    liveSocket.connect();
    """
  end
end
