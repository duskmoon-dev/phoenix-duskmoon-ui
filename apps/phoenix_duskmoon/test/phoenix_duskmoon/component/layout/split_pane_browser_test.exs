defmodule PhoenixDuskmoon.Component.Layout.SplitPaneBrowserTest do
  use ExUnit.Case, async: false
  use Phoenix.Component

  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Layout.SplitPane
  alias DuskmoonBundler.Integration.CDPBrowser

  @moduletag :integration

  setup_all do
    {:ok, browser} = CDPBrowser.start_link()
    on_exit(fn -> CDPBrowser.stop(browser) end)
    root = Path.expand("../../../../../../", __DIR__)
    css_path = Path.join(root, "apps/phoenix_duskmoon/assets/css/phoenix_duskmoon.css")
    {:ok, _} = Application.ensure_all_started(:duskmoon_bundler)

    {:ok, css} =
      DuskmoonBundler.Tailwind.build(
        css: File.read!(css_path),
        css_base: Path.dirname(css_path),
        sources: [%{base: Path.join(root, "apps/phoenix_duskmoon/lib"), pattern: "**/*.ex"}]
      )

    hook = File.read!(Path.join(root, "apps/phoenix_duskmoon/assets/js/hooks/split_pane.js"))
    %{browser: browser, css: css, hook: hook}
  end

  setup %{browser: browser} = context do
    {:ok, page} = CDPBrowser.new_page(browser)
    on_exit(fn -> CDPBrowser.close_page(page) end)

    assert {:ok, _} =
             CDPBrowser.command(page, "Emulation.setDeviceMetricsOverride", %{
               "width" => 1200,
               "height" => 700,
               "deviceScaleFactor" => 1,
               "mobile" => false
             })

    component = render_component(&fixture/1, %{})
    hook_url = "data:text/javascript;base64," <> Base.encode64(context.hook)

    html = """
    <!doctype html><html lang="en" data-theme="sunshine"><head><meta name="viewport" content="width=device-width,initial-scale=1"><style>#{context.css}</style></head>
    <body style="margin:0"><div id="container" style="width:900px">#{component}</div>
    <script type="module">
      import { DuskmoonSplitPane } from "#{hook_url}";
      window.resizeEvents = [];
      window.splitHook = {
        ...DuskmoonSplitPane, el: document.getElementById("files"),
        pushEvent(...args) { window.resizeEvents.push(args); },
        pushEventTo(...args) { window.resizeEvents.push(args); }
      };
      window.serverHTML = window.splitHook.el.innerHTML;
      window.splitHook.mounted();
    </script></body></html>
    """

    assert :ok = CDPBrowser.goto(page, "data:text/html;base64," <> Base.encode64(html))
    assert {:ok, true} = CDPBrowser.evaluate(page, "Boolean(window.splitHook?.splitObserver)")
    %{page: page}
  end

  test "real mouse capture drags outside the handle and keyboard exposes a bounded separator", %{
    page: page
  } do
    {x, y} = handle_position(page)
    mouse(page, "mousePressed", x, y)

    assert {:ok, true} =
             CDPBrowser.evaluate(
               page,
               "splitHook.splitHandle().hasPointerCapture(splitHook.splitDrag.pointerId)"
             )

    mouse(page, "mouseMoved", 850, y)
    assert_width(page, 480)
    mouse(page, "mouseReleased", 850, y)
    assert {:ok, true} = CDPBrowser.evaluate(page, "splitHook.splitDrag === null")

    for {key, expected} <- [{"ArrowLeft", 470}, {"Home", 160}, {"ArrowRight", 170}, {"End", 480}] do
      key(page, key)
      assert_width(page, expected)
    end

    assert {:ok, %{"nodes" => nodes}} = CDPBrowser.command(page, "Accessibility.getFullAXTree")
    separator = Enum.find(nodes, &(&1["role"]["value"] == "separator"))
    assert separator["name"]["value"] == "Resize folders"
    assert separator["value"]["value"] == 480
    properties = Map.new(separator["properties"], &{&1["name"], &1["value"]["value"]})
    assert properties["orientation"] == "vertical"
    assert properties["valuemin"] == 160
    assert properties["valuemax"] == 480
    assert {:ok, []} = CDPBrowser.evaluate(page, "window.resizeEvents")
  end

  test "native touch cancellation and lost pointer capture restore the starting width", %{
    page: page
  } do
    assert {:ok, _} =
             CDPBrowser.command(page, "Emulation.setTouchEmulationEnabled", %{"enabled" => true})

    {x, y} = handle_position(page)
    touch(page, "touchStart", [%{"x" => x, "y" => y}])
    touch(page, "touchMove", [%{"x" => x + 90, "y" => y}])
    assert_width(page, 370)
    touch(page, "touchCancel", [])
    assert_width(page, 280)
    assert {:ok, true} = CDPBrowser.evaluate(page, "splitHook.splitDrag === null")

    mouse(page, "mousePressed", x, y)
    mouse(page, "mouseMoved", x + 60, y)
    assert_width(page, 340)

    assert {:ok, _} =
             CDPBrowser.evaluate(
               page,
               "splitHook.splitHandle().releasePointerCapture(splitHook.splitDrag.pointerId)"
             )

    mouse(page, "mouseMoved", x + 65, y)
    assert_width(page, 280)
    mouse(page, "mouseReleased", x + 65, y)
  end

  test "container resizing stacks both panes and lifecycle patches restore client sizing on replaced markup",
       %{page: page} do
    assert {:ok, _} = CDPBrowser.evaluate(page, "splitHook.splitHandle().focus()")
    key(page, "End")
    assert_width(page, 480)

    assert {:ok, true} =
             CDPBrowser.evaluate(page, """
             (() => {
               splitHook.beforeUpdate();
               splitHook.el.innerHTML = serverHTML;
               splitHook.el.style.removeProperty("--dm-split-pane-width");
               document.getElementById("files-secondary").append(" Updated files");
               splitHook.updated();
               return document.getElementById("files-secondary").textContent.includes("Updated files");
             })()
             """)

    assert_width(page, 480)
    resize_container(page, 650)
    assert_width(page, 394)
    resize_container(page, 375)

    assert {:ok, %{"stacked" => true, "visible" => true, "separatorHidden" => true}} =
             CDPBrowser.evaluate(page, """
             (() => {
               const primary = document.getElementById("files-primary").getBoundingClientRect();
               const secondary = document.getElementById("files-secondary").getBoundingClientRect();
               const handle = splitHook.splitHandle();
               return {
                 stacked: secondary.top >= primary.bottom && primary.width === 375 && secondary.width === 375,
                 visible: primary.height > 0 && secondary.height > 0,
                 separatorHidden: getComputedStyle(handle).display === "none" && handle.tabIndex === -1
               };
             })()
             """)

    assert {:ok, %{"nodes" => nodes}} = CDPBrowser.command(page, "Accessibility.getFullAXTree")
    refute Enum.any?(nodes, &(&1["role"]["value"] == "separator"))
    resize_container(page, 900)
    assert_width(page, 480)

    assert {:ok, true} =
             CDPBrowser.evaluate(page, """
             splitHook.destroyed();
             const width = splitHook.preferredWidth;
             splitHook.splitHandle().dispatchEvent(new KeyboardEvent("keydown", {key: "Home", bubbles: true}));
             splitHook.preferredWidth === width && window.resizeEvents.length === 0
             """)
  end

  defp fixture(assigns) do
    ~H"""
    <.dm_split_pane id="files" resize_label="Resize folders" style="height:240px">
      <:primary><nav aria-label="Folders">Folder navigation</nav></:primary>
      <section>Files <input aria-label="Filter files" /></section>
    </.dm_split_pane>
    """
  end

  defp handle_position(page) do
    assert {:ok, %{"x" => x, "y" => y}} =
             CDPBrowser.evaluate(page, """
             (() => { const rect = splitHook.splitHandle().getBoundingClientRect();
               return {x: rect.x + rect.width / 2, y: rect.y + rect.height / 2}; })()
             """)

    {x, y}
  end

  defp mouse(page, type, x, y) do
    assert {:ok, _} =
             CDPBrowser.command(page, "Input.dispatchMouseEvent", %{
               "type" => type,
               "x" => x,
               "y" => y,
               "button" => "left",
               "buttons" => if(type == "mouseReleased", do: 0, else: 1),
               "clickCount" => 1
             })
  end

  defp touch(page, type, points) do
    assert {:ok, _} =
             CDPBrowser.command(page, "Input.dispatchTouchEvent", %{
               "type" => type,
               "touchPoints" => points
             })
  end

  defp key(page, key) do
    for type <- ["keyDown", "keyUp"] do
      assert {:ok, _} =
               CDPBrowser.command(page, "Input.dispatchKeyEvent", %{"type" => type, "key" => key})
    end
  end

  defp assert_width(page, width) do
    assert {:ok, %{"width" => ^width, "aria" => ^width}} =
             CDPBrowser.evaluate(page, """
             ({width: document.getElementById("files-primary").getBoundingClientRect().width,
               aria: Number(splitHook.splitHandle().getAttribute("aria-valuenow"))})
             """)
  end

  defp resize_container(page, width) do
    assert {:ok, _} =
             CDPBrowser.evaluate(page, """
             (async () => {
               document.getElementById("container").style.width = "#{width}px";
               await new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve)));
             })()
             """)
  end
end
