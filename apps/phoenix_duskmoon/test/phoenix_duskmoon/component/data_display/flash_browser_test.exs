defmodule PhoenixDuskmoon.Component.DataDisplay.FlashBrowserTest do
  use ExUnit.Case, async: false

  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataDisplay.Flash

  alias DuskmoonBundler.Integration.CDPBrowser

  @moduletag :integration

  setup_all do
    {:ok, browser} = CDPBrowser.start_link()
    on_exit(fn -> CDPBrowser.stop(browser) end)
    %{browser: browser}
  end

  test "connection commands expose the alert only while disconnected", %{browser: browser} do
    {:ok, page} = CDPBrowser.new_page(browser)
    on_exit(fn -> CDPBrowser.close_page(page) end)

    component = render_component(&dm_flash_group/1, %{flash: %{}})
    phoenix = File.read!(Application.app_dir(:phoenix, "priv/static/phoenix.js"))

    live_view =
      File.read!(Application.app_dir(:phoenix_live_view, "priv/static/phoenix_live_view.js"))

    html = """
    <!doctype html><html lang="en"><body>
    <div id="flash-test" data-phx-session="test">#{component}</div>
    <script>#{phoenix}</script><script>#{live_view}</script>
    <script>
      // Data URLs have no browser storage; connection commands need no persisted state.
      const storage = {getItem: () => null, setItem: () => {}, removeItem: () => {}}
      window.liveSocket = new LiveView.LiveSocket('ws://localhost/live', Phoenix.Socket, {
        localStorage: storage, sessionStorage: storage
      })
      window.liveSocket.newRootView(document.getElementById('flash-test'))
    </script>
    </body></html>
    """

    :ok = CDPBrowser.goto(page, "data:text/html;base64," <> Base.encode64(html))

    assert_alert_state(page, false)

    for {event, exposed} <- [{"phx-disconnected", true}, {"phx-connected", false}] do
      assert {:ok, true} =
               CDPBrowser.evaluate(page, """
               (async () => {
                 const alert = document.getElementById('disconnected')
                 window.liveSocket.execJS(alert, alert.getAttribute('#{event}'))
                 await new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve)))
                 return true
               })()
               """)

      assert_alert_state(page, exposed)
    end
  end

  defp assert_alert_state(page, exposed) do
    assert {:ok, ^exposed} =
             CDPBrowser.evaluate(
               page,
               "document.getElementById('disconnected').classList.contains('toast-open')"
             )

    assert {:ok, %{"nodes" => nodes}} =
             CDPBrowser.command(page, "Accessibility.getFullAXTree", %{}, timeout: 5_000)

    alerts =
      Enum.filter(nodes, fn node ->
        node["ignored"] != true && get_in(node, ["role", "value"]) == "alert"
      end)

    assert length(alerts) == if(exposed, do: 1, else: 0)
  end
end
