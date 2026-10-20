defmodule PhoenixDuskmoon.Component.Navigation.LeftMenuBrowserTest do
  use ExUnit.Case, async: false
  use Phoenix.Component

  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Navigation.LeftMenu

  alias DuskmoonBundler.Integration.CDPBrowser

  @moduletag :integration

  setup_all do
    {:ok, browser} = CDPBrowser.start_link()
    on_exit(fn -> CDPBrowser.stop(browser) end)
    root = Path.expand("../../../../../../", __DIR__)
    css_path = Path.join(root, "apps/duskmoon_storybook/assets/css/app.css")
    {:ok, _} = Application.ensure_all_started(:duskmoon_bundler)

    {:ok, css} =
      DuskmoonBundler.Tailwind.build(
        css: File.read!(css_path),
        css_base: Path.dirname(css_path),
        sources: [
          %{base: Path.join(root, "apps/phoenix_duskmoon/lib"), pattern: "**/*.ex"},
          %{base: __DIR__, pattern: "left_menu_browser_test.exs"}
        ]
      )

    hook = File.read!(Path.join(root, "apps/phoenix_duskmoon/assets/js/hooks/left_menu.js"))
    %{browser: browser, css: css, hook: hook}
  end

  setup %{browser: browser} do
    {:ok, page} = CDPBrowser.new_page(browser)
    on_exit(fn -> CDPBrowser.close_page(page) end)
    %{page: page}
  end

  test "real styles keep header/footer fixed and collapse a scrolling menu to an accessible rail",
       context do
    for {width, height} <- [{1280, 420}, {375, 360}] do
      :ok = load_fixture(context, width, height)

      assert {:ok, %{"width" => 288, "scrolls" => true, "fixed" => true}} =
               CDPBrowser.evaluate(context.page, """
               (() => {
                 const menu = document.getElementById("sidebar");
                 const scroller = menu.querySelector("[data-left-menu-scroll]");
                 const fixed = ["[data-fixture-header]", "[data-fixture-footer]", "[data-left-menu-toggle]"]
                   .map(selector => menu.querySelector(selector));
                 const positions = fixed.map(el => el.getBoundingClientRect().top);
                 scroller.scrollTop = 150;
                 return {
                   width: menu.getBoundingClientRect().width,
                   scrolls: scroller.scrollHeight > scroller.clientHeight && scroller.scrollTop === 150,
                   fixed: menu.scrollHeight <= menu.clientHeight + 1 && fixed.every((el, index) => {
                     const rect = el.getBoundingClientRect();
                     return rect.top === positions[index] && rect.top >= 0 && rect.bottom <= innerHeight;
                   })
                 };
               })()
               """)

      assert {:ok,
              %{
                "width" => 72,
                "groupsOpen" => true,
                "centered" => true,
                "labelClipped" => true,
                "toggleCentered" => true,
                "expanded" => "false"
              }} =
               CDPBrowser.evaluate(context.page, """
               (async () => {
                 const menu = document.getElementById("sidebar");
                 menu.querySelector("[data-left-menu-toggle]").click();
                 await new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve)));
                 const scroller = menu.querySelector("[data-left-menu-scroll]");
                 scroller.scrollTop = 0;
                 const link = document.getElementById("first-link");
                 const icon = link.querySelector("svg").getBoundingClientRect();
                 const item = link.getBoundingClientRect();
                 const label = link.querySelector("[data-left-menu-label]");
                 const labelStyle = getComputedStyle(label);
                 const rail = menu.getBoundingClientRect();
                 const toggle = menu.querySelector("[data-left-menu-toggle]");
                 const button = toggle.getBoundingClientRect();
                 return {
                   width: rail.width,
                   groupsOpen: [...menu.querySelectorAll("details")].every(group => group.open),
                   centered: icon.width > 0 && Math.abs((icon.left + icon.right - item.left - item.right) / 2) < 1,
                   labelClipped: label.getBoundingClientRect().width <= 1 && labelStyle.position === "absolute" &&
                     labelStyle.overflow === "hidden" &&
                     (labelStyle.clipPath !== "none" || labelStyle.clip !== "auto"),
                   toggleCentered: Math.abs((button.left + button.right - rail.left - rail.right) / 2) < 1,
                   expanded: toggle.getAttribute("aria-expanded")
                 };
               })()
               """)

      assert {:ok, %{"nodes" => nodes}} =
               CDPBrowser.command(context.page, "Accessibility.getFullAXTree")

      assert Enum.any?(nodes, fn node ->
               get_in(node, ["role", "value"]) == "link" &&
                 get_in(node, ["name", "value"]) == "Dashboard"
             end)

      assert {:ok, %{"width" => 288, "groupRestored" => true, "tooltipDisabled" => true}} =
               CDPBrowser.evaluate(context.page, """
               (async () => {
                 const menu = document.getElementById("sidebar");
                 menu.querySelector("[data-left-menu-toggle]").click();
                 await new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve)));
                 return {
                   width: menu.getBoundingClientRect().width,
                   groupRestored: !document.getElementById("closed-group").open && document.getElementById("open-group").open,
                   tooltipDisabled: !document.getElementById("first-link").hasAttribute("interestfor")
                 };
               })()
               """)
    end
  end

  test "collapsed link tooltips open outside the scroller on hover and keyboard focus", context do
    :ok = load_fixture(context, 375, 360)

    assert {:ok, %{"supported" => true, "x" => x, "y" => y}} =
             CDPBrowser.evaluate(context.page, """
             (async () => {
               document.querySelector("[data-left-menu-toggle]").click();
               await new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve)));
               const link = document.getElementById("first-link");
               const rect = link.getBoundingClientRect();
               return {supported: "interestForElement" in link, x: rect.x + rect.width / 2, y: rect.y + rect.height / 2};
             })()
             """)

    assert {:ok, _} =
             CDPBrowser.command(context.page, "Input.dispatchMouseEvent", %{
               "type" => "mouseMoved",
               "x" => x,
               "y" => y
             })

    assert_tooltip_visible(context.page)

    assert {:ok, _} =
             CDPBrowser.command(context.page, "Input.dispatchMouseEvent", %{
               "type" => "mouseMoved",
               "x" => 350,
               "y" => 350
             })

    assert {:ok, _} =
             CDPBrowser.evaluate(context.page, """
             (async () => {
               await new Promise(resolve => setTimeout(resolve, 800));
               document.getElementById("focus-start").focus();
             })()
             """)

    for type <- ["keyDown", "keyUp"] do
      assert {:ok, _} =
               CDPBrowser.command(context.page, "Input.dispatchKeyEvent", %{
                 "type" => type,
                 "key" => "Tab",
                 "code" => "Tab",
                 "windowsVirtualKeyCode" => 9
               })
    end

    assert {:ok, true} =
             CDPBrowser.evaluate(context.page, "document.activeElement.id === 'first-link'")

    assert_tooltip_visible(context.page)

    assert {:ok, true} =
             CDPBrowser.evaluate(context.page, """
             document.querySelector("[data-left-menu-toggle]").click();
             !document.getElementById("open-group-dashboard-hint-tooltip").matches(":popover-open")
             """)
  end

  test "disabled entries keep their content and rail tooltips without navigation or handlers",
       context do
    :ok = load_fixture(context, 375, 360)

    assert {:ok,
            %{
              "button" => true,
              "disabled" => true,
              "noNavigation" => true,
              "noHandlers" => true,
              "content" => true,
              "styled" => true
            }} =
             CDPBrowser.evaluate(context.page, """
             (() => {
               const item = document.getElementById('unavailable-item');
               const forbidden = /^(?:on|phx-|data-phx-)/;
               return {button: item.tagName === 'BUTTON', disabled: item.getAttribute('aria-disabled') === 'true' && item.tabIndex === -1,
                 noNavigation: !item.hasAttribute('href') && !item.hasAttribute('navigate') && !item.hasAttribute('patch'),
                 noHandlers: [...item.attributes].every(attr => !forbidden.test(attr.name)),
                 content: item.textContent.includes('Services') && item.textContent.includes('Requires scope') && !!item.querySelector('svg'),
                 styled: getComputedStyle(item).display === 'flex' && Number(getComputedStyle(item).opacity) < 1};
             })()
             """)

    assert {:ok, %{"nodes" => nodes}} =
             CDPBrowser.command(context.page, "Accessibility.getFullAXTree")

    assert Enum.any?(nodes, fn node ->
             get_in(node, ["role", "value"]) == "button" &&
               get_in(node, ["name", "value"]) == "Services" &&
               get_in(node, ["description", "value"]) == "Requires scope" &&
               Enum.any?(node["properties"] || [], fn property ->
                 property["name"] == "disabled" && get_in(property, ["value", "value"]) == true
               end)
           end)

    assert {:ok, %{"centered" => true, "labelClipped" => true, "x" => x, "y" => y}} =
             CDPBrowser.evaluate(context.page, """
             (async () => {
               window.unavailableClicks = 0;
               document.querySelector('[data-left-menu-toggle]').click();
               await new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve)));
               const item = document.getElementById('unavailable-item');
               const rect = item.getBoundingClientRect();
               const icon = item.querySelector('svg').getBoundingClientRect();
               const label = item.querySelector('[data-left-menu-label]');
               return {centered: Math.abs((icon.left + icon.right - rect.left - rect.right) / 2) < 1,
                 labelClipped: label.getBoundingClientRect().width <= 1 && getComputedStyle(label).position === 'absolute',
                 x: rect.x + rect.width / 2, y: rect.y + rect.height / 2};
             })()
             """)

    assert {:ok, _} =
             CDPBrowser.command(context.page, "Input.dispatchMouseEvent", %{
               "type" => "mouseMoved",
               "x" => x,
               "y" => y
             })

    assert_tooltip_visible(context.page, "open-group-services-hint-tooltip", "unavailable-item")

    for type <- ["mousePressed", "mouseReleased"] do
      assert {:ok, _} =
               CDPBrowser.command(context.page, "Input.dispatchMouseEvent", %{
                 "type" => type,
                 "x" => x,
                 "y" => y,
                 "button" => "left",
                 "clickCount" => 1
               })
    end

    assert {:ok, true} =
             CDPBrowser.evaluate(context.page, """
             window.unavailableClicks === 0 && location.hash === ''
             """)

    assert {:ok, _} =
             CDPBrowser.evaluate(context.page, "document.getElementById('focus-start').focus()")

    for _ <- 1..2, type <- ["keyDown", "keyUp"] do
      assert {:ok, _} =
               CDPBrowser.command(context.page, "Input.dispatchKeyEvent", %{
                 "type" => type,
                 "key" => "Tab",
                 "code" => "Tab",
                 "windowsVirtualKeyCode" => 9
               })
    end

    assert {:ok, true} =
             CDPBrowser.evaluate(
               context.page,
               "document.activeElement.getAttribute('href') === '#item-1'"
             )
  end

  defp menu_fixture(assigns) do
    ~H"""
    <.dm_left_menu id="sidebar" collapsible class="sticky top-0 h-dvh">
      <:header><strong data-fixture-header data-left-menu-label>Application</strong></:header>
      <:menu>
        <.dm_left_menu_group id="open-group" active="dashboard">
          <:title>Workspace</:title>
          <:menu id="dashboard" to="#dashboard" icon="view-dashboard" label="Dashboard" rest={%{id: "first-link"}}>
            Dashboard
          </:menu>
          <:menu id="services" disabled icon="cog" label="Services" rest={%{
            id: "unavailable-item",
            "aria-describedby": "scope-required",
            href: "#unavailable",
            "phx-click": "unavailable",
            "data-phx-link": "redirect",
            onclick: "window.unavailableClicks++"
          }}>
            Services <span id="scope-required">Requires scope</span>
          </:menu>
          <:menu :for={item <- 1..24} id={"item-#{item}"} to={"#item-#{item}"} icon="folder" label={"Item #{item}"}>
            Item {item}
          </:menu>
        </.dm_left_menu_group>
        <.dm_left_menu_group id="closed-group" open={false}>
          <:title>Account</:title>
          <:menu id="settings" to="#settings" icon="cog" label="Settings">Settings</:menu>
        </.dm_left_menu_group>
      </:menu>
      <:footer><span data-fixture-footer data-left-menu-label>Account</span></:footer>
    </.dm_left_menu>
    """
  end

  defp load_fixture(context, width, height) do
    assert {:ok, _} =
             CDPBrowser.command(context.page, "Emulation.setDeviceMetricsOverride", %{
               "width" => width,
               "height" => height,
               "deviceScaleFactor" => 1,
               "mobile" => false
             })

    assert {:ok, _} =
             CDPBrowser.command(context.page, "Emulation.setEmulatedMedia", %{
               "features" => [%{"name" => "prefers-reduced-motion", "value" => "reduce"}]
             })

    component = render_component(&menu_fixture/1, %{})
    hook_url = "data:text/javascript;base64," <> Base.encode64(context.hook)

    html = """
    <!doctype html><html lang="en" data-theme="sunshine"><head><meta name="viewport" content="width=device-width,initial-scale=1"><style>#{context.css}</style></head>
    <body style="margin:0;display:flex"><button id="focus-start" style="position:fixed;left:-1000px">Start</button>
    #{component}<main style="min-width:0;flex:1">Page content</main>
    <script type="module">
      import { DuskmoonLeftMenu } from "#{hook_url}";
      window.menuHook = { ...DuskmoonLeftMenu, el: document.getElementById("sidebar") };
      window.menuHook.mounted();
    </script></body></html>
    """

    CDPBrowser.goto(context.page, "data:text/html;base64," <> Base.encode64(html))
  end

  defp assert_tooltip_visible(
         page,
         tooltip_id \\ "open-group-dashboard-hint-tooltip",
         item_id \\ "first-link"
       ) do
    assert {:ok, %{"open" => true, "outsideScroll" => true, "fits" => true}} =
             CDPBrowser.evaluate(page, """
             (async () => {
               await new Promise(resolve => setTimeout(resolve, 800));
               const tooltip = document.getElementById(#{Jason.encode!(tooltip_id)});
               const rect = tooltip.getBoundingClientRect();
               const scroller = document.querySelector("[data-left-menu-scroll]").getBoundingClientRect();
               const link = document.getElementById(#{Jason.encode!(item_id)}).getBoundingClientRect();
               return {
                 open: tooltip.matches(":popover-open") && getComputedStyle(tooltip).opacity === "1",
                 outsideScroll: rect.left >= link.right && rect.right > scroller.right && rect.width > 0,
                 fits: rect.left >= 0 && rect.right <= innerWidth && rect.top >= 0 && rect.bottom <= innerHeight
               };
             })()
             """)
  end
end
