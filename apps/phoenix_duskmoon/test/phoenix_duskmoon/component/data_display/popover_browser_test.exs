defmodule PhoenixDuskmoon.Component.DataDisplay.PopoverBrowserTest do
  use ExUnit.Case, async: false

  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataDisplay.Popover
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

  test "HTML command opens and Escape closes the native popover", %{page: page} do
    trigger = [
      %{
        __slot__: :trigger,
        inner_block: fn _, attrs ->
          escaped_attrs =
            attrs |> Phoenix.HTML.attributes_escape() |> Phoenix.HTML.safe_to_string()

          Phoenix.HTML.raw(~s(<button id="trigger" type="button" #{escaped_attrs}>Open</button>))
        end
      }
    ]

    component =
      render_component(&dm_popover/1, %{
        id: "native-popover",
        trigger: trigger,
        inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Content" end}]
      })

    html = "<!doctype html><html lang=\"en\"><body>#{component}</body></html>"
    :ok = CDPBrowser.goto(page, "data:text/html;base64," <> Base.encode64(html))

    assert {:ok, true} =
             CDPBrowser.evaluate(page, """
             (() => {
               const trigger = document.getElementById("trigger")
               const popover = document.getElementById("native-popover")
               trigger.focus()
               trigger.click()
               return popover.matches(":popover-open")
             })()
             """)

    :ok = dispatch_key(page, "Escape", "Escape", 27)

    assert {:ok, %{"closed" => true, "focusReturned" => true}} =
             CDPBrowser.evaluate(page, """
             (() => ({
               closed: !document.getElementById("native-popover").matches(":popover-open"),
               focusReturned: document.activeElement === document.getElementById("trigger")
             }))()
             """)
  end

  test "interestfor opens the native hint popover for keyboard focus", %{page: page} do
    component =
      render_component(&dm_tooltip/1, %{
        id: "native-help",
        content: "Helpful text",
        inner_block: %{
          inner_block: fn _, attrs ->
            escaped_attrs =
              attrs |> Phoenix.HTML.attributes_escape() |> Phoenix.HTML.safe_to_string()

            Phoenix.HTML.raw(
              ~s(<button id="tooltip-trigger" type="button" #{escaped_attrs}>Help</button>)
            )
          end
        }
      })

    html = "<!doctype html><html lang=\"en\"><body>#{component}</body></html>"
    :ok = CDPBrowser.goto(page, "data:text/html;base64," <> Base.encode64(html))

    assert {:ok, %{"interestforSupported" => true, "opened" => true}} =
             CDPBrowser.evaluate(page, """
             (async () => {
               const trigger = document.getElementById("tooltip-trigger")
               const tooltip = document.getElementById("native-help-tooltip")
               trigger.focus()
               await new Promise((resolve) => setTimeout(resolve, 800))
               return {
                 interestforSupported: "interestForElement" in trigger,
                 opened: tooltip.matches(":popover-open")
               }
             })()
             """)
  end

  defp dispatch_key(page, key, code, key_code) do
    params = %{
      "key" => key,
      "code" => code,
      "windowsVirtualKeyCode" => key_code
    }

    with {:ok, _result} <-
           CDPBrowser.command(page, "Input.dispatchKeyEvent", Map.put(params, "type", "keyDown")),
         {:ok, _result} <-
           CDPBrowser.command(page, "Input.dispatchKeyEvent", Map.put(params, "type", "keyUp")) do
      :ok
    end
  end
end
