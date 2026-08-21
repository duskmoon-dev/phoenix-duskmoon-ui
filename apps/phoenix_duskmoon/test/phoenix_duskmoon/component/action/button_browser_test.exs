defmodule PhoenixDuskmoon.Component.Action.ButtonBrowserTest do
  use ExUnit.Case, async: false

  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Action.Button

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

  test "confirm modal traps focus and only confirm dispatches the action", %{page: page} do
    component =
      render_component(&dm_btn/1, %{
        id: "remove",
        confirm: "Remove?",
        "phx-click": "remove",
        type: "submit",
        form: "remove-form",
        inner_block: %{inner_block: fn _, _ -> "Remove" end}
      })

    runtime = File.read!(Path.expand("../../../../assets/js/phoenix_duskmoon.js", __DIR__))

    html =
      "<!doctype html><html lang=\"en\"><body><form id=\"remove-form\"></form><button id=\"outside\">Outside</button>#{component}<script type=\"module\">#{runtime}</script></body></html>"

    url = "data:text/html;base64," <> Base.encode64(html)

    :ok = CDPBrowser.goto(page, url)

    {:ok, initial_state} =
      CDPBrowser.evaluate(page, """
      (() => {
        const trigger = document.getElementById("remove")
        const dialog = document.getElementById("confirm-dialog-remove")
        const outside = document.getElementById("outside")
        const cancel = dialog.querySelector(".btn-ghost")
        const form = document.getElementById("remove-form")

        window.destructiveCount = 0
        window.submitCount = 0
        document.addEventListener("click", (event) => {
          const action = event.composedPath().find(
            (node) => node.getAttribute?.("phx-click") === "remove"
          )
          if (action) window.destructiveCount++
        })
        form.addEventListener("submit", (event) => {
          event.preventDefault()
          window.submitCount++
        })

        trigger.focus()
        trigger.click()
        outside.focus()

        return {
          openedModally: dialog.open && dialog.matches(":modal"),
          initialFocusOnCancel: document.activeElement === cancel,
          outsideFocusBlocked: document.activeElement === cancel
        }
      })()
      """)

    assert initial_state == %{
             "openedModally" => true,
             "initialFocusOnCancel" => true,
             "outsideFocusBlocked" => true
           }

    {:ok, %{"nodes" => nodes}} =
      CDPBrowser.command(page, "Accessibility.getFullAXTree", %{}, timeout: 5_000)

    dialog_nodes =
      Enum.filter(nodes, fn node ->
        node["ignored"] != true && get_in(node, ["role", "value"]) == "dialog"
      end)

    assert [%{"name" => %{"value" => "Confirmation"}}] = dialog_nodes

    :ok = dispatch_key(page, "Tab", "Tab", 9, 8)

    assert {:ok, true} =
             CDPBrowser.evaluate(
               page,
               "document.activeElement === document.querySelector('#confirm-dialog-remove .btn-primary')"
             )

    :ok = dispatch_key(page, "Tab", "Tab", 9)

    assert {:ok, true} =
             CDPBrowser.evaluate(
               page,
               "document.activeElement === document.querySelector('#confirm-dialog-remove .btn-ghost')"
             )

    :ok = dispatch_key(page, "Tab", "Tab", 9)

    assert {:ok, true} =
             CDPBrowser.evaluate(page, """
             document.getElementById("confirm-dialog-remove").open &&
               document.activeElement !== document.getElementById("outside")
             """)

    :ok = dispatch_key(page, "Escape", "Escape", 27)

    assert {:ok,
            %{
              "closed" => true,
              "focusReturned" => true,
              "destructiveCount" => 0,
              "submitCount" => 0
            }} =
             CDPBrowser.evaluate(page, """
             (() => ({
               closed: !document.getElementById("confirm-dialog-remove").open,
               focusReturned: document.activeElement === document.getElementById("remove"),
               destructiveCount: window.destructiveCount,
               submitCount: window.submitCount
             }))()
             """)

    assert {:ok,
            %{
              "closed" => true,
              "focusReturned" => true,
              "destructiveCount" => 0,
              "submitCount" => 0
            }} =
             CDPBrowser.evaluate(page, """
             (() => {
               const trigger = document.getElementById("remove")
               const dialog = document.getElementById("confirm-dialog-remove")
               trigger.focus()
               trigger.click()
               dialog.querySelector(".btn-ghost").click()
               return {
                 closed: !dialog.open,
                 focusReturned: document.activeElement === trigger,
                 destructiveCount: window.destructiveCount,
                 submitCount: window.submitCount
               }
             })()
             """)

    assert {:ok,
            %{
              "closed" => true,
              "focusReturned" => true,
              "destructiveCount" => 1,
              "submitCount" => 1
            }} =
             CDPBrowser.evaluate(page, """
             (() => {
               const trigger = document.getElementById("remove")
               const dialog = document.getElementById("confirm-dialog-remove")
               trigger.focus()
               trigger.click()
               dialog.querySelector(".btn-primary").click()
               return {
                 closed: !dialog.open,
                 focusReturned: document.activeElement === trigger,
                 destructiveCount: window.destructiveCount,
                 submitCount: window.submitCount
               }
             })()
             """)
  end

  defp dispatch_key(page, key, code, key_code, modifiers \\ 0) do
    params = %{
      "key" => key,
      "code" => code,
      "windowsVirtualKeyCode" => key_code,
      "modifiers" => modifiers
    }

    with {:ok, _result} <-
           CDPBrowser.command(page, "Input.dispatchKeyEvent", Map.put(params, "type", "keyDown")),
         {:ok, _result} <-
           CDPBrowser.command(page, "Input.dispatchKeyEvent", Map.put(params, "type", "keyUp")) do
      :ok
    end
  end
end
