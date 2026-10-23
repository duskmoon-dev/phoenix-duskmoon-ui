defmodule DuskmoonStorybook.Hologram.BrowserTest do
  use ExUnit.Case, async: false

  alias DuskmoonBundler.Integration.CDPBrowser
  alias DuskmoonStorybookWeb.Endpoint

  @moduletag timeout: 120_000

  setup_all do
    assert Hologram.enabled?(), "Run this suite through scripts/with-hologram-example.sh"

    css = Application.app_dir(:duskmoon_storybook, "priv/static/assets/css/app.css")
    assert File.exists?(css), "Build Storybook assets before running the Hologram browser tests"

    server = start_supervised!({Bandit, plug: Endpoint, ip: {127, 0, 0, 1}, port: 0})
    {:ok, {_ip, port}} = ThousandIsland.listener_info(server)
    {:ok, browser} = CDPBrowser.start_link()
    on_exit(fn -> CDPBrowser.stop(browser) end)
    %{browser: browser, base_url: "http://127.0.0.1:#{port}"}
  end

  setup %{browser: browser, base_url: base_url} do
    {:ok, page} = CDPBrowser.new_page(browser)
    on_exit(fn -> CDPBrowser.close_page(page) end)
    assert :ok = CDPBrowser.goto(page, base_url <> "/examples/hologram", timeout: 30_000)
    wait_for(page, "document.querySelector('#hologram-runtime')?.dataset.ready === 'true'")
    %{page: page}
  end

  test "the initial document is server rendered without the LiveView bundle" do
    conn = Plug.Test.conn(:get, "/examples/hologram") |> Endpoint.call(Endpoint.init([]))
    assert conn.status == 200
    assert conn.resp_body =~ "Server rendered"
    assert conn.resp_body =~ "hologram-count"
    assert conn.resp_body =~ "/assets/css/app"
    refute conn.resp_body =~ "/assets/js/app.js"
  end

  test "hydration, styles, local actions, inputs and both themes", %{page: page} do
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

    assert {:ok, light_background} =
             CDPBrowser.evaluate(
               page,
               "getComputedStyle(document.querySelector('#hologram-example')).backgroundColor"
             )

    click(page, "#hologram-moonlight")
    wait_for(page, "document.querySelector('#hologram-example').dataset.theme === 'moonlight'")

    assert {:ok, dark_background} =
             CDPBrowser.evaluate(
               page,
               "getComputedStyle(document.querySelector('#hologram-example')).backgroundColor"
             )

    refute light_background == dark_background
    screenshot(page, "moonlight")

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
             CDPBrowser.evaluate(page, "document.querySelector('#hologram-dialog').matches(':modal')")

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

  test "mobile layout does not overflow", %{page: page} do
    assert {:ok, _} =
             CDPBrowser.command(page, "Emulation.setDeviceMetricsOverride", %{
               width: 390,
               height: 844,
               deviceScaleFactor: 1,
               mobile: true
             })

    assert {:ok, true} =
             CDPBrowser.evaluate(
               page,
               "document.documentElement.scrollWidth <= window.innerWidth"
             )

    screenshot(page, "mobile")
  end

  defp click(page, selector) do
    assert {:ok, _} =
             CDPBrowser.evaluate(page, "document.querySelector(#{Jason.encode!(selector)}).click()")
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
