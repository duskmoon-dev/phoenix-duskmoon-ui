defmodule PhoenixDuskmoon.Component.Action.DropdownBrowserTest do
  use ExUnit.Case, async: false

  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Action.Dropdown

  alias DuskmoonBundler.Integration.CDPBrowser

  @moduletag :integration

  defmodule Assets do
    @behaviour Plug

    def init(assets), do: assets

    def call(conn, assets) do
      case assets[conn.request_path] do
        {type, content} ->
          conn
          |> Plug.Conn.put_resp_header("content-security-policy", "script-src 'self'")
          |> Plug.Conn.put_resp_content_type(type)
          |> Plug.Conn.send_resp(200, content)

        nil ->
          Plug.Conn.send_resp(conn, 404, "Not found")
      end
    end
  end

  setup_all do
    {:ok, browser} = CDPBrowser.start_link()
    on_exit(fn -> CDPBrowser.stop(browser) end)
    %{browser: browser}
  end

  setup %{browser: browser} do
    {:ok, page} = CDPBrowser.new_page(browser)
    on_exit(fn -> CDPBrowser.close_page(page) end)
    %{page: page}
  end

  test "dropdown opens, remains visible, and exposes native expanded state under CSP", %{
    page: page
  } do
    component =
      render_component(&dm_dropdown/1, %{
        id: "notice",
        trigger: [%{inner_block: fn _, _ -> "Notifications" end}],
        content: [%{inner_block: fn _, _ -> "Content" end}]
      })

    css =
      "../../../../../../node_modules/@duskmoon-dev/core/dist/components/popover.css"
      |> Path.expand(__DIR__)
      |> File.read!()

    html = """
    <!doctype html><html lang="en"><head>
    <meta http-equiv="Content-Security-Policy" content="script-src 'self'">
    <style>#{css}</style>
    </head><body>#{component}</body></html>
    """

    # Use Core's reduced-motion path to inspect visibility without animation timing.
    assert {:ok, _} =
             CDPBrowser.command(page, "Emulation.setEmulatedMedia", %{
               "features" => [%{"name" => "prefers-reduced-motion", "value" => "reduce"}]
             })

    :ok = CDPBrowser.goto(page, "data:text/html;base64," <> Base.encode64(html))
    assert_expanded(page, false)

    # CDP supplies test input; the rendered page has no scripts or hook registration.
    assert {:ok, %{"open" => true, "visible" => true, "opacity" => "1"}} =
             CDPBrowser.evaluate(page, """
             (() => {
               const trigger = document.getElementById("notice-popover-trigger")
               const popover = document.getElementById("notice-popover")
               trigger.focus()
               trigger.click()
               const style = getComputedStyle(popover)
               return {
                 open: popover.matches(":popover-open"),
                 visible: style.visibility === "visible" && popover.getBoundingClientRect().width > 0,
                 opacity: style.opacity
               }
             })()
             """)

    assert_expanded(page, true)

    for type <- ["keyDown", "keyUp"] do
      assert {:ok, _} =
               CDPBrowser.command(page, "Input.dispatchKeyEvent", %{
                 "type" => type,
                 "key" => "Escape",
                 "code" => "Escape",
                 "windowsVirtualKeyCode" => 27
               })
    end

    assert {:ok, %{"closed" => true, "focusReturned" => true}} =
             CDPBrowser.evaluate(page, """
             (() => ({
               closed: !document.getElementById("notice-popover").matches(":popover-open"),
               focusReturned: document.activeElement === document.getElementById("notice-popover-trigger")
             }))()
             """)

    assert_expanded(page, false)
  end

  test "external hook mirrors native dropdown state under CSP and repairs patched triggers", %{
    page: page
  } do
    component =
      render_component(&dm_dropdown/1, %{
        id: "notice",
        trigger: [%{inner_block: fn _, _ -> "Notifications" end}],
        content: [%{inner_block: fn _, _ -> "Content" end}]
      })

    html = """
    <!doctype html><html lang="en"><body>#{component}
    <button id="outside" style="position:fixed;left:400px;top:400px">Outside</button>
    <script type="module" src="/client.js"></script></body></html>
    """

    client = """
    import {DuskmoonPopover} from "/popover.js";
    window.dropdownHook = {
      ...DuskmoonPopover,
      el: document.getElementById("notice-popover").parentElement
    };
    dropdownHook.mounted();
    """

    assets = %{
      "/" => {"text/html", html},
      "/client.js" => {"text/javascript", client},
      "/popover.js" =>
        {"text/javascript",
         File.read!(Path.expand("../../../../assets/js/hooks/duskmoon_popover.js", __DIR__))}
    }

    server = start_supervised!({Bandit, plug: {Assets, assets}, ip: {127, 0, 0, 1}, port: 0})
    {:ok, {_ip, port}} = ThousandIsland.listener_info(server)
    assert :ok = CDPBrowser.goto(page, "http://localhost:#{port}/")
    assert_dom_expanded(page, false)

    for close_method <- [:click, :escape] do
      assert {:ok, _} =
               CDPBrowser.evaluate(
                 page,
                 "document.getElementById('notice-popover-trigger').click()"
               )

      assert_dom_expanded(page, true)
      assert_expanded(page, true)

      if close_method == :click do
        assert {:ok, _} =
                 CDPBrowser.evaluate(
                   page,
                   "document.getElementById('notice-popover-trigger').click()"
                 )
      else
        for type <- ["keyDown", "keyUp"] do
          assert {:ok, _} =
                   CDPBrowser.command(page, "Input.dispatchKeyEvent", %{
                     "type" => type,
                     "key" => "Escape",
                     "code" => "Escape",
                     "windowsVirtualKeyCode" => 27
                   })
        end
      end

      assert_dom_expanded(page, false)
    end

    assert {:ok, _} =
             CDPBrowser.evaluate(
               page,
               "document.getElementById('notice-popover-trigger').click()"
             )

    assert_dom_expanded(page, true)

    for type <- ["mousePressed", "mouseReleased"] do
      assert {:ok, _} =
               CDPBrowser.command(page, "Input.dispatchMouseEvent", %{
                 "type" => type,
                 "x" => 420,
                 "y" => 410,
                 "button" => "left",
                 "clickCount" => 1
               })
    end

    assert_dom_expanded(page, false)

    assert {:ok, _} =
             CDPBrowser.evaluate(page, "document.getElementById('notice-popover').showPopover()")

    assert_dom_expanded(page, true)

    assert {:ok, _} =
             CDPBrowser.evaluate(page, """
             const trigger = document.getElementById('notice-popover-trigger');
             const replacement = trigger.cloneNode(true);
             replacement.removeAttribute('aria-expanded');
             trigger.replaceWith(replacement);
             dropdownHook.updated();
             """)

    assert_dom_expanded(page, true)

    assert {:ok, _} =
             CDPBrowser.evaluate(page, "document.getElementById('notice-popover').hidePopover()")

    assert_dom_expanded(page, false)
    assert_expanded(page, false)
  end

  defp assert_dom_expanded(page, expected) do
    assert {:ok, true} =
             CDPBrowser.evaluate(page, """
             (async () => {
               for (let attempt = 0; attempt < 100; attempt++) {
                 const trigger = document.getElementById('notice-popover-trigger');
                 const panel = document.getElementById('notice-popover');
                 if (trigger.getAttribute('aria-expanded') === '#{expected}' &&
                     panel.matches(':popover-open') === #{expected}) return true;
                 await new Promise(resolve => setTimeout(resolve, 10));
               }
               return false;
             })()
             """)
  end

  defp assert_expanded(page, expected) do
    assert {:ok, %{"nodes" => nodes}} =
             CDPBrowser.command(page, "Accessibility.getFullAXTree")

    trigger =
      Enum.find(nodes, fn node ->
        get_in(node, ["role", "value"]) == "button" &&
          get_in(node, ["name", "value"]) == "Notifications"
      end)

    assert trigger

    assert Enum.any?(trigger["properties"], fn property ->
             property["name"] == "expanded" && property["value"]["value"] == expected
           end)
  end
end
