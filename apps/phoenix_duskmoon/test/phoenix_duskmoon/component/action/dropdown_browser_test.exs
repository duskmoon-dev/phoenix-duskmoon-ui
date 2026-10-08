defmodule PhoenixDuskmoon.Component.Action.DropdownBrowserTest do
  use ExUnit.Case, async: false

  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Action.Dropdown

  alias DuskmoonBundler.Integration.CDPBrowser

  @moduletag :integration

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
