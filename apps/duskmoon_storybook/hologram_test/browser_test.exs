defmodule DuskmoonStorybook.Hologram.BrowserTest do
  use ExUnit.Case, async: false

  alias DuskmoonBundler.Integration.CDPBrowser
  alias DuskmoonStorybookWeb.Endpoint

  @moduletag timeout: 120_000

  setup_all do
    assert Hologram.enabled?(), "Enable the Storybook Hologram runtime with HOLOGRAM_START=1"

    css = Application.app_dir(:duskmoon_storybook, "priv/static/assets/css/app.css")
    assert File.exists?(css), "Build Storybook assets before running the Hologram browser tests"

    server = start_supervised!({Gaoxy.HTTP, plug: {Endpoint, []}, ip: {127, 0, 0, 1}, port: 0})
    %{local: {:ok, {_ip, port}}} = Gaoxy.info(server, :http)
    {:ok, browser} = CDPBrowser.start_link()
    on_exit(fn -> CDPBrowser.stop(browser) end)
    %{browser: browser, base_url: "http://localhost:#{port}"}
  end

  setup %{browser: browser, base_url: base_url} do
    {:ok, page} = CDPBrowser.new_page(browser)
    on_exit(fn -> CDPBrowser.close_page(page) end)

    assert {:ok, _} =
             CDPBrowser.command(page, "Storage.clearDataForOrigin", %{
               origin: base_url,
               storageTypes: "local_storage"
             })

    assert :ok = CDPBrowser.goto(page, base_url <> "/hologram/demos/playground", timeout: 30_000)
    wait_for(page, "document.querySelector('#hologram-runtime')?.dataset.ready === 'true'")
    %{page: page}
  end

  test "the initial document is server rendered without the LiveView bundle" do
    conn = Plug.Test.conn(:get, "/hologram/demos/playground") |> Endpoint.call(Endpoint.init([]))
    assert conn.status == 200
    assert conn.resp_body =~ "Server rendered"
    assert conn.resp_body =~ "hologram-count"
    assert conn.resp_body =~ "/assets/css/app"

    # The inline asset manifest lists app.js without loading it. Check actual scripts.
    script_sources =
      conn.resp_body
      |> LazyHTML.from_document()
      |> LazyHTML.query("script[src]")
      |> LazyHTML.attribute("src")

    assert script_sources != []
    refute Enum.any?(script_sources, &String.starts_with?(&1, "/assets/js/"))
  end

  test "Hologram uses the exact shared appbar and Components menu implementation" do
    document = fn path ->
      Plug.Test.conn(:get, path)
      |> Endpoint.call(Endpoint.init([]))
      |> Map.fetch!(:resp_body)
      |> LazyHTML.from_document()
    end

    hologram = document.("/hologram")
    components = document.("/components")

    for path <- ["/components", "/art-component"] do
      assert LazyHTML.query(document.(path), "header.storybook-appbar") |> LazyHTML.to_html() ==
               LazyHTML.query(hologram, "header.storybook-appbar") |> LazyHTML.to_html()
    end

    for selector <- ["body", "main.container", "footer"] do
      assert classes(components, selector) == classes(hologram, selector)
    end

    assert classes(components, "#components-sidebar") == classes(hologram, "#hologram-sidebar")

    assert LazyHTML.query(hologram, "#hologram-sidebar") |> LazyHTML.attribute("phx-hook") ==
             ["DuskmoonLeftMenu"]

    assert LazyHTML.query(hologram, "#hologram-sidebar-navigation")
           |> LazyHTML.attribute("phx-hook") ==
             ["DuskmoonLeftMenuNavigation"]

    assert LazyHTML.query(hologram, "#hologram-sidebar a") |> LazyHTML.attribute("href") ==
             ["/hologram", "/hologram/playground", "/hologram/tasks", "/hologram/preferences"]

    assert LazyHTML.query(hologram, "#hologram-demo") |> LazyHTML.attribute("src") ==
             ["/hologram/demos"]
  end

  test "hydration, styles, local actions, inputs and both themes", %{page: page} do
    set_document_theme(page, "sunshine")

    assert {:ok, true} =
             CDPBrowser.evaluate(page, """
             (() => {
               const button = document.querySelector('#hologram-increment');
               const style = getComputedStyle(button);
               return parseFloat(style.paddingLeft) > 0 &&
                 button.getBoundingClientRect().height >= 32 &&
                 !Array.from(document.scripts).some(script => script.src.includes('/assets/js/app.js'));
             })()
             """)

    screenshot(page, "sunshine")
    click(page, "#hologram-increment")
    wait_for(page, "document.querySelector('#hologram-count').textContent.trim() === '1'")

    assert {:ok, false} =
             CDPBrowser.evaluate(page, "document.querySelector('#hologram-decrement').disabled")

    assert {:ok, _} =
             CDPBrowser.evaluate(page, """
             const input = document.querySelector('#hologram-name');
             input.focus();
             input.value = 'Jonathan';
             input.dispatchEvent(new Event('input', {bubbles: true}));
             """)

    wait_for(page, "document.querySelector('#hologram-name-preview').textContent === 'Jonathan'")
    click(page, "#hologram-notifications")

    wait_for(
      page,
      "document.querySelector('#hologram-notifications-preview').textContent.includes('disabled')"
    )

    assert {:ok, false} =
             CDPBrowser.evaluate(
               page,
               "document.querySelector('#hologram-notifications').checked"
             )

    assert {:ok, light_background} =
             CDPBrowser.evaluate(
               page,
               "getComputedStyle(document.querySelector('#hologram-example')).backgroundColor"
             )

    set_document_theme(page, "moonlight")
    wait_for(page, "document.documentElement.dataset.theme === 'moonlight'")

    assert {:ok, dark_background} =
             CDPBrowser.evaluate(
               page,
               "getComputedStyle(document.querySelector('#hologram-example')).backgroundColor"
             )

    refute light_background == dark_background
    screenshot(page, "moonlight")

    assert {:ok, false} =
             CDPBrowser.evaluate(
               page,
               "document.querySelector('#hologram-notifications').checked"
             )

    assert {:ok, 0} =
             CDPBrowser.evaluate(page, """
             performance.getEntriesByType('resource').filter(entry => new URL(entry.name).pathname === '/hologram/command').length
             """)
  end

  test "native modal survives Hologram rendering and restores focus", %{page: page} do
    assert {:ok, true} =
             CDPBrowser.evaluate(page, "'commandForElement' in HTMLButtonElement.prototype")

    assert {:ok, _} =
             CDPBrowser.evaluate(page, "document.querySelector('#hologram-open-dialog').focus()")

    click(page, "#hologram-open-dialog")
    wait_for(page, "document.querySelector('#hologram-dialog').matches(':modal')")

    click(page, "#hologram-dialog-increment")
    wait_for(page, "document.querySelector('#hologram-dialog-count').textContent.trim() === '1'")

    assert {:ok, true} =
             CDPBrowser.evaluate(
               page,
               "document.querySelector('#hologram-dialog').matches(':modal')"
             )

    assert {:ok, _} =
             CDPBrowser.command(page, "Input.dispatchKeyEvent", %{
               type: "keyDown",
               key: "Escape",
               code: "Escape",
               windowsVirtualKeyCode: 27
             })

    assert {:ok, _} =
             CDPBrowser.command(page, "Input.dispatchKeyEvent", %{
               type: "keyUp",
               key: "Escape",
               code: "Escape",
               windowsVirtualKeyCode: 27
             })

    wait_for(page, "!document.querySelector('#hologram-dialog').open")
    assert {:ok, "hologram-open-dialog"} = CDPBrowser.evaluate(page, "document.activeElement.id")

    click(page, "#hologram-open-dialog")
    wait_for(page, "document.querySelector('#hologram-dialog').open")
    click(page, "#hologram-close-dialog")
    wait_for(page, "!document.querySelector('#hologram-dialog').open")
  end

  test "mobile layout does not overflow", %{page: page, base_url: base_url} do
    assert {:ok, _} =
             CDPBrowser.command(page, "Emulation.setDeviceMetricsOverride", %{
               width: 390,
               height: 844,
               deviceScaleFactor: 1,
               mobile: true
             })

    assert :ok = CDPBrowser.goto(page, base_url <> "/hologram/demos/playground")
    wait_for(page, "document.querySelector('#hologram-shell')?.dataset.ready === 'true'")

    assert {:ok, true} =
             CDPBrowser.evaluate(
               page,
               "document.documentElement.scrollWidth <= window.innerWidth"
             )

    screenshot(page, "mobile")
  end

  test "catalog links open the demos in their Phoenix host", %{
    page: page,
    base_url: base_url
  } do
    assert :ok = CDPBrowser.goto(page, base_url <> "/hologram/demos")
    wait_for(page, "document.querySelector('#hologram-shell')?.dataset.ready === 'true'")

    for path <- ["/hologram/playground", "/hologram/tasks", "/hologram/preferences"] do
      assert {:ok, true} =
               CDPBrowser.evaluate(page, """
               document.querySelector('#hologram-index a[href="#{path}"]')?.target === '_top'
               """)
    end

    assert :ok = CDPBrowser.goto(page, base_url <> "/hologram")
    wait_for_demo(page, "hologram-index")

    assert {:ok, _} =
             CDPBrowser.evaluate(page, """
             document.querySelector('#hologram-demo').contentDocument.querySelector('a[href="/hologram/playground"]').click();
             """)

    wait_for_demo(page, "hologram-example")
    assert {:ok, "/hologram/playground"} = CDPBrowser.evaluate(page, "location.pathname")

    assert {:ok, 1} =
             CDPBrowser.evaluate(page, "document.querySelectorAll('header.appbar').length")
  end

  test "the shared sidebar stays mounted and the theme updates the live Hologram demo", %{
    page: page,
    base_url: base_url
  } do
    assert :ok = CDPBrowser.goto(page, base_url <> "/hologram/playground")
    wait_for_demo(page, "hologram-example")

    assert {:ok, _} =
             CDPBrowser.evaluate(page, """
             window.originalHologramSidebar = document.querySelector('#hologram-sidebar');
             document.querySelector('#hologram-demo').contentDocument.querySelector('#hologram-increment').click();
             """)

    select_theme(page, "moonlight")

    wait_for(
      page,
      "document.querySelector('#hologram-demo').contentDocument.documentElement.dataset.theme === 'moonlight'"
    )

    assert {:ok, "1"} =
             CDPBrowser.evaluate(
               page,
               "document.querySelector('#hologram-demo').contentDocument.querySelector('#hologram-count').textContent.trim()"
             )

    assert {:ok, 0} =
             CDPBrowser.evaluate(
               page,
               "document.querySelector('#hologram-demo').contentDocument.querySelectorAll('header.appbar, nav[aria-label], footer').length"
             )

    click(page, "#hologram-sidebar [data-left-menu-toggle]")
    click(page, "#hologram-sidebar a[href='/hologram/tasks']")
    wait_for_demo(page, "hologram-tasks")

    wait_for(
      page,
      "document.querySelector('#hologram-sidebar a[href=\"/hologram/tasks\"]').getAttribute('aria-current') === 'page'"
    )

    assert {:ok, true} =
             CDPBrowser.evaluate(page, """
             originalHologramSidebar === document.querySelector('#hologram-sidebar') &&
               document.querySelector('#hologram-sidebar').dataset.collapsed === 'true'
             """)

    assert :ok = CDPBrowser.goto(page, base_url <> "/components")

    wait_for(
      page,
      "window.liveSocket?.isConnected() && document.documentElement.dataset.theme === 'moonlight'"
    )

    select_theme(page, "sunshine")
    assert :ok = CDPBrowser.goto(page, base_url <> "/hologram/preferences")
    wait_for_demo(page, "hologram-preferences")

    wait_for(
      page,
      "document.querySelector('#hologram-demo').contentDocument.documentElement.dataset.theme === 'sunshine'"
    )

    assert {:ok, "true"} =
             CDPBrowser.evaluate(
               page,
               "document.querySelector('#hologram-sidebar').dataset.collapsed"
             )

    click(page, "#hologram-sidebar [data-left-menu-toggle]")
    wait_for(page, "document.querySelector('#hologram-sidebar').dataset.collapsed === 'false'")
  end

  test "the host fits a narrow viewport and resizes with Hologram content", %{
    page: page,
    base_url: base_url
  } do
    assert {:ok, _} =
             CDPBrowser.command(page, "Emulation.setDeviceMetricsOverride", %{
               width: 390,
               height: 844,
               deviceScaleFactor: 1,
               mobile: true
             })

    assert :ok = CDPBrowser.goto(page, base_url <> "/hologram/playground")
    wait_for_demo(page, "hologram-example")
    click(page, "#hologram-sidebar [data-left-menu-toggle]")
    wait_for(page, "document.querySelector('#hologram-sidebar').dataset.collapsed === 'true'")

    wait_for(page, """
    document.documentElement.scrollWidth <= window.innerWidth &&
      document.querySelector('#hologram-demo').contentDocument.documentElement.scrollWidth <=
        document.querySelector('#hologram-demo').clientWidth &&
      Math.abs(document.querySelector('#hologram-demo').clientHeight -
        document.querySelector('#hologram-demo').contentDocument.body.getBoundingClientRect().height) < 2
    """)

    assert {:ok, height} =
             CDPBrowser.evaluate(page, "document.querySelector('#hologram-demo').clientHeight")

    assert {:ok, _} =
             CDPBrowser.evaluate(page, """
             document.querySelector('#hologram-demo').contentDocument.querySelector('details.collapse summary').click();
             """)

    wait_for(page, "document.querySelector('#hologram-demo').clientHeight > #{height}")

    screenshot(page, "shared-shell-mobile")
  end

  test "task form, completion, filtering and clearing work in the browser", %{
    page: page,
    base_url: base_url
  } do
    assert :ok = CDPBrowser.goto(page, base_url <> "/hologram/demos/tasks")
    wait_for(page, "document.querySelector('#hologram-shell')?.dataset.ready === 'true'")
    set_input(page, "#hologram-task-input", "  Review the Hologram demo  ")
    click(page, "#hologram-task-add")

    wait_for(
      page,
      "document.querySelector('#hologram-task-item-4')?.textContent.includes('Review the Hologram demo')"
    )

    wait_for(page, "document.querySelector('#hologram-task-input').value === ''")
    click(page, "#hologram-task-toggle-4")

    wait_for(
      page,
      "document.querySelector('#hologram-task-completed-count').textContent.trim() === '2'"
    )

    click(page, "#hologram-task-filter-completed")
    wait_for(page, "document.querySelectorAll('#hologram-task-list li').length === 2")
    click(page, "#hologram-task-clear-completed")

    wait_for(
      page,
      "document.querySelector('#hologram-task-empty')?.textContent.includes('No completed tasks')"
    )

    click(page, "#hologram-task-filter-all")
    wait_for(page, "document.querySelectorAll('#hologram-task-list li').length === 2")
  end

  test "profile controls preview, apply and reset values", %{page: page, base_url: base_url} do
    assert :ok = CDPBrowser.goto(page, base_url <> "/hologram/demos/preferences")
    wait_for(page, "document.querySelector('#hologram-shell')?.dataset.ready === 'true'")
    set_input(page, "#hologram-preferences-name", "  Hologram explorer  ")

    wait_for(
      page,
      "document.querySelector('#hologram-preferences-preview-name').textContent.includes('Hologram explorer')"
    )

    assert {:ok, _} =
             CDPBrowser.evaluate(page, """
             const select = document.querySelector('#hologram-preferences-mode');
             select.value = 'compact';
             select.dispatchEvent(new Event('change', {bubbles: true}));
             """)

    wait_for(
      page,
      "document.querySelector('#hologram-preferences-preview').dataset.density === 'compact'"
    )

    click(page, "#hologram-preferences-notifications")

    wait_for(
      page,
      "document.querySelector('#hologram-preferences-preview-notifications').textContent.includes('hidden')"
    )

    click(page, "#hologram-preferences-apply")

    wait_for(
      page,
      "document.querySelector('#hologram-preferences-applied-name').textContent.trim() === 'Hologram explorer'"
    )

    click(page, "#hologram-preferences-reset")

    wait_for(
      page,
      "document.querySelector('#hologram-preferences-name').value === 'Duskmoon explorer'"
    )

    wait_for(
      page,
      "document.querySelector('#hologram-preferences-preview').dataset.density === 'comfortable'"
    )

    assert {:ok, true} =
             CDPBrowser.evaluate(
               page,
               "document.querySelector('#hologram-preferences-notifications').checked"
             )
  end

  defp set_input(page, selector, value) do
    assert {:ok, _} =
             CDPBrowser.evaluate(page, """
             const input = document.querySelector(#{Jason.encode!(selector)});
             input.value = #{Jason.encode!(value)};
             input.dispatchEvent(new Event('input', {bubbles: true}));
             """)
  end

  defp classes(document, selector) do
    document
    |> LazyHTML.query(selector)
    |> LazyHTML.attribute("class")
    |> hd()
    |> String.split()
    |> MapSet.new()
  end

  defp set_document_theme(page, theme) do
    assert {:ok, _} =
             CDPBrowser.evaluate(page, "document.documentElement.dataset.theme = '#{theme}'")
  end

  defp select_theme(page, theme) do
    click(page, "[phx-hook='ThemeSwitcher'] summary")

    assert {:ok, _} =
             CDPBrowser.evaluate(page, """
             const input = document.querySelector('[phx-hook="ThemeSwitcher"] input[value="#{theme}"]');
             document.querySelector('label[for="' + input.id + '"]').click();
             """)

    wait_for(page, "document.documentElement.dataset.theme === '#{theme}'")
  end

  defp wait_for_demo(page, marker) do
    wait_for(page, """
    window.liveSocket?.isConnected() &&
      document.querySelector('#hologram-demo')?.contentDocument?.querySelector('##{marker}') &&
      document.querySelector('#hologram-demo').contentDocument.querySelector('#hologram-shell')?.dataset.ready === 'true'
    """)
  end

  defp click(page, selector) do
    assert {:ok, _} =
             CDPBrowser.evaluate(
               page,
               "document.querySelector(#{Jason.encode!(selector)}).click()"
             )
  end

  defp wait_for(page, expression) do
    assert {:ok, true} =
             CDPBrowser.evaluate(
               page,
               """
               new Promise((resolve, reject) => {
                 const deadline = Date.now() + 10000;
                 const poll = () => {
                   if (#{expression}) return resolve(true);
                   if (Date.now() > deadline) return reject(new Error('Hologram assertion timed out'));
                   setTimeout(poll, 25);
                 };
                 poll();
               })
               """,
               timeout: 15_000
             )
  end

  defp screenshot(page, name) do
    # Closed dropdown transitions have no visible effect and may never finish.
    assert {:ok, true} =
             CDPBrowser.evaluate(page, """
             (async () => {
               await document.fonts.ready;
               await new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve)));
               const animations = document.getAnimations().filter(animation =>
                 animation.playState === 'running' && animation.effect?.target?.checkVisibility() &&
                   animation.effect.getComputedTiming().iterations !== Infinity
               );
               await Promise.all(animations.map(animation => animation.finished.catch(() => {})));
               return true;
             })()
             """)

    assert {:ok, %{"data" => data}} =
             CDPBrowser.command(page, "Page.captureScreenshot", %{
               format: "png",
               captureBeyondViewport: true
             })

    directory = Path.join(Mix.Project.build_path(), "hologram-screenshots")
    File.mkdir_p!(directory)
    File.write!(Path.join(directory, "#{name}.png"), Base.decode64!(data))
  end
end
