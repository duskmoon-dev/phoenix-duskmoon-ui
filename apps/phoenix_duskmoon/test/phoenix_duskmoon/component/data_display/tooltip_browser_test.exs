defmodule PhoenixDuskmoon.Component.DataDisplay.TooltipBrowserTest do
  use ExUnit.Case, async: false
  use Phoenix.Component

  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Action.Button
  import PhoenixDuskmoon.Component.DataDisplay.Tooltip

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

  test "Core hint tooltip is hidden out of flow and opens on hover and keyboard focus", %{
    page: page
  } do
    component = render_component(&tooltip_button/1, %{})
    :ok = load_fixture(page, component)

    assert {:ok, %{"supported" => true, "hidden" => true, "outOfFlow" => true}} =
             CDPBrowser.evaluate(page, """
             (() => {
               const trigger = document.getElementById("help-trigger")
               const tooltip = document.getElementById("help-tooltip")
               window.afterTop = document.getElementById("after").getBoundingClientRect().top
               return {
                 supported: "interestForElement" in trigger,
                 hidden: !tooltip.matches(":popover-open") && getComputedStyle(tooltip).display === "none",
                 outOfFlow: tooltip.getBoundingClientRect().width === 0
               }
             })()
             """)

    :ok = hover_trigger(page, "help-trigger")
    assert_tooltip_visible(page, "help-tooltip")

    assert {:ok, true} =
             CDPBrowser.evaluate(page, """
             document.getElementById("after").getBoundingClientRect().top === window.afterTop &&
               document.getElementById("help-trigger").getAttribute("aria-describedby") === "help-tooltip"
             """)

    assert {:ok, _} =
             CDPBrowser.command(page, "Input.dispatchMouseEvent", %{
               "type" => "mouseMoved",
               "x" => 0,
               "y" => 0
             })

    assert {:ok, true} =
             CDPBrowser.evaluate(page, """
             (async () => {
               await new Promise((resolve) => setTimeout(resolve, 800))
               return !document.getElementById("help-tooltip").matches(":popover-open")
             })()
             """)

    :ok = dispatch_key(page, "Tab", "Tab", 9)
    assert_tooltip_visible(page, "help-tooltip")

    assert {:ok, true} =
             CDPBrowser.evaluate(page, "document.activeElement.id === 'help-trigger'")

    assert {:ok, %{"nodes" => nodes}} =
             CDPBrowser.command(page, "Accessibility.getFullAXTree")

    assert Enum.any?(nodes, fn node ->
             get_in(node, ["role", "value"]) == "button" &&
               get_in(node, ["description", "value"]) == "Helpful text"
           end)
  end

  test "tooltip confirmation trigger opens help and modal while only confirmation activates delete",
       %{
         page: page
       } do
    component = render_component(&tooltip_confirmation/1, %{})
    :ok = load_fixture(page, component)

    assert {:ok, _} =
             CDPBrowser.evaluate(page, """
             window.deleteCount = 0
             document.addEventListener("click", (event) => {
               if (event.composedPath().some((node) => node.getAttribute?.("phx-click") === "delete")) {
                 window.deleteCount++
               }
             })
             """)

    :ok = hover_trigger(page, "delete-record")
    assert_tooltip_visible(page, "delete-help-tooltip")

    assert {:ok, %{"modal" => true, "count" => 0}} =
             CDPBrowser.evaluate(page, """
             (() => {
               document.getElementById("delete-record").focus()
               document.getElementById("delete-record").click()
               return {
                 modal: document.getElementById("confirm-dialog-delete-record").matches(":modal"),
                 count: window.deleteCount
               }
             })()
             """)

    # Remove hover interest so the following tooltip proves restored keyboard focus.
    assert {:ok, _} =
             CDPBrowser.command(page, "Input.dispatchMouseEvent", %{
               "type" => "mouseMoved",
               "x" => 0,
               "y" => 0
             })

    assert {:ok, %{"closed" => true, "count" => 0}} =
             CDPBrowser.evaluate(page, """
             (() => {
               const dialog = document.getElementById("confirm-dialog-delete-record")
               dialog.querySelector('button[command="close"]:not([phx-click])').click()
               return {closed: !dialog.open, count: window.deleteCount}
             })()
             """)

    # Closing returns keyboard focus to the visible trigger, whose interest opens help.
    assert_tooltip_visible(page, "delete-help-tooltip")

    assert {:ok, true} =
             CDPBrowser.evaluate(page, "document.activeElement.id === 'delete-record'")

    assert {:ok, _} =
             CDPBrowser.evaluate(page, "document.getElementById('delete-record').click()")

    :ok = dispatch_key(page, "Escape", "Escape", 27)

    assert {:ok, %{"closed" => true, "count" => 0}} =
             CDPBrowser.evaluate(page, """
             ({closed: !document.getElementById("confirm-dialog-delete-record").open, count: window.deleteCount})
             """)

    assert {:ok, %{"closed" => true, "count" => 1}} =
             CDPBrowser.evaluate(page, """
             (() => {
               const dialog = document.getElementById("confirm-dialog-delete-record")
               document.getElementById("delete-record").click()
               document.getElementById("delete-record-confirm").click()
               return {closed: !dialog.open, count: window.deleteCount}
             })()
             """)
  end

  defp tooltip_button(assigns) do
    ~H"""
    <.dm_tooltip id="help" content="Helpful text" :let={trigger_attrs}>
      <button id="help-trigger" type="button" {trigger_attrs}>Help</button>
    </.dm_tooltip>
    """
  end

  defp tooltip_confirmation(assigns) do
    ~H"""
    <.dm_tooltip id="delete-help" content="Delete this record" :let={trigger_attrs}>
      <.dm_btn id="delete-record" confirm="Delete this record?" phx-click="delete" {trigger_attrs}>
        Delete
      </.dm_btn>
    </.dm_tooltip>
    """
  end

  defp load_fixture(page, component) do
    css =
      "../../../../../../node_modules/@duskmoon-dev/core/dist/components/tooltip.css"
      |> Path.expand(__DIR__)
      |> File.read!()

    html = """
    <!doctype html><html lang="en"><head><style>#{css}</style></head>
    <body><main style="padding: 80px">#{component}<p id="after">After tooltip</p></main></body></html>
    """

    # Core provides a reduced-motion path so style assertions avoid animation timing.
    assert {:ok, _} =
             CDPBrowser.command(page, "Emulation.setEmulatedMedia", %{
               "features" => [%{"name" => "prefers-reduced-motion", "value" => "reduce"}]
             })

    CDPBrowser.goto(page, "data:text/html;base64," <> Base.encode64(html))
  end

  defp hover_trigger(page, id) do
    assert {:ok, %{"x" => x, "y" => y}} =
             CDPBrowser.evaluate(page, """
             (() => {
               const rect = document.getElementById("#{id}").getBoundingClientRect()
               return {x: rect.x + rect.width / 2, y: rect.y + rect.height / 2}
             })()
             """)

    assert {:ok, _} =
             CDPBrowser.command(page, "Input.dispatchMouseEvent", %{
               "type" => "mouseMoved",
               "x" => x,
               "y" => y
             })

    :ok
  end

  defp assert_tooltip_visible(page, id) do
    assert {:ok, %{"open" => true, "opacity" => "1", "outOfFlow" => true, "width" => width}} =
             CDPBrowser.evaluate(page, """
             (async () => {
               await new Promise((resolve) => setTimeout(resolve, 800))
               const tooltip = document.getElementById("#{id}")
               const style = getComputedStyle(tooltip)
               return {
                 open: tooltip.matches(":popover-open"),
                 opacity: style.opacity,
                 outOfFlow: style.position === "absolute",
                 width: tooltip.getBoundingClientRect().width
               }
             })()
             """)

    assert width > 0
  end

  defp dispatch_key(page, key, code, key_code) do
    for type <- ["keyDown", "keyUp"] do
      assert {:ok, _} =
               CDPBrowser.command(page, "Input.dispatchKeyEvent", %{
                 "type" => type,
                 "key" => key,
                 "code" => code,
                 "windowsVirtualKeyCode" => key_code
               })
    end

    :ok
  end
end
