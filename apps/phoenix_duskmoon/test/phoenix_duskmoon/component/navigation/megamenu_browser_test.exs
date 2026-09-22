defmodule PhoenixDuskmoon.Component.Navigation.MegamenuBrowserTest do
  use ExUnit.Case, async: false

  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Navigation.Megamenu

  alias DuskmoonBundler.Integration.CDPBrowser

  @moduletag :integration

  setup_all do
    {:ok, browser} = CDPBrowser.start_link()
    on_exit(fn -> CDPBrowser.stop(browser) end)

    core = Path.expand("../../../../../../node_modules/@duskmoon-dev/core/dist", __DIR__)

    css =
      [
        "themes/generated/sunshine.css",
        "themes/generated/moonlight.css",
        "components/megamenu.css"
      ]
      |> Enum.map_join("\n", &File.read!(Path.join(core, &1)))

    %{browser: browser, css: css}
  end

  test "shipped styles support native toggle, Escape, themes and responsive panels", %{
    browser: browser,
    css: css
  } do
    {:ok, page} = CDPBrowser.new_page(browser)
    on_exit(fn -> CDPBrowser.close_page(page) end)

    component =
      render_component(&dm_megamenu/1, %{
        id: "products",
        trigger: [%{inner_block: fn _, _ -> "Products" end}],
        group: [
          %{
            title: "Workspace",
            inner_block: fn _, _ ->
              Phoenix.HTML.raw(
                ~s(<ul class="menu"><li><a class="link" href="#projects">Projects</a></li></ul>)
              )
            end
          }
        ]
      })

    for theme <- ["sunshine", "moonlight"], width <- [375, 1280] do
      {:ok, _} =
        CDPBrowser.command(page, "Emulation.setDeviceMetricsOverride", %{
          "width" => width,
          "height" => 800,
          "deviceScaleFactor" => 1,
          "mobile" => false
        })

      html =
        "<!doctype html><html lang=\"en\" data-theme=\"#{theme}\"><head><meta name=\"viewport\" content=\"width=device-width,initial-scale=1\"><style>#{css}</style></head><body>#{component}</body></html>"

      :ok = CDPBrowser.goto(page, "data:text/html;base64," <> Base.encode64(html))

      assert {:ok, "none"} =
               CDPBrowser.evaluate(
                 page,
                 "getComputedStyle(document.getElementById('products-panel')).display"
               )

      assert {:ok, %{"open" => true, "fits" => true, "themed" => true}} =
               CDPBrowser.evaluate(page, """
               (async () => {
                 const trigger = document.getElementById('products-trigger');
                 const panel = document.getElementById('products-panel');
                 trigger.focus();
                 trigger.click();
                 await new Promise(resolve => setTimeout(resolve, 200));
                 const rect = panel.getBoundingClientRect();
                 const color = getComputedStyle(panel).backgroundColor;
                 return {
                   open: panel.matches(':popover-open'),
                   fits: rect.left >= 0 && rect.right <= innerWidth && rect.width > 0,
                   themed: color !== 'rgba(0, 0, 0, 0)' && color !== 'transparent'
                 };
               })()
               """)

      for type <- ["keyDown", "keyUp"] do
        {:ok, _} =
          CDPBrowser.command(page, "Input.dispatchKeyEvent", %{
            "type" => type,
            "key" => "Escape",
            "code" => "Escape",
            "windowsVirtualKeyCode" => 27
          })
      end

      assert {:ok, %{"closed" => true, "focusReturned" => true}} =
               CDPBrowser.evaluate(page, """
               ({
                 closed: !document.getElementById('products-panel').matches(':popover-open'),
                 focusReturned: document.activeElement.id === 'products-trigger'
               })
               """)
    end
  end
end
