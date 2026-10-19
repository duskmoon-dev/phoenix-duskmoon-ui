defmodule PhoenixDuskmoon.Component.DataDisplay.PaginationBrowserTest do
  use ExUnit.Case, async: false

  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataDisplay.Pagination

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
        "components/pagination.css"
      ]
      |> Enum.map_join("\n", &File.read!(Path.join(core, &1)))

    %{browser: browser, css: css}
  end

  test "secondary current buttons and links retain their theme color on hover", %{
    browser: browser,
    css: css
  } do
    {:ok, page} = CDPBrowser.new_page(browser)
    on_exit(fn -> CDPBrowser.close_page(page) end)

    for theme <- ["sunshine", "moonlight"], mode <- [:button, :link] do
      component =
        render_component(&dm_pagination/1, %{
          id: "pages",
          page_num: 2,
          page_size: 10,
          total: 30,
          el_color: "secondary",
          page_url: if(mode == :link, do: "#page-{page}"),
          page_link_type: "href"
        })

      html = """
      <!doctype html><html lang="en" data-theme="#{theme}"><head><style>#{css}</style></head>
      <body>#{component}<span id="expected" style="background:var(--color-secondary);color:var(--color-secondary-content)"></span>
      <span id="hover-expected" style="background:color-mix(in oklch,var(--color-secondary),black 10%)"></span></body></html>
      """

      :ok = CDPBrowser.goto(page, "data:text/html;base64," <> Base.encode64(html))

      {:ok, _} =
        CDPBrowser.command(page, "Input.dispatchMouseEvent", %{
          "type" => "mouseMoved",
          "x" => 900,
          "y" => 600
        })

      assert {:ok, %{"background" => true, "foreground" => true, "noTokenOverride" => true}} =
               CDPBrowser.evaluate(page, """
               (() => {
                 const current = document.querySelector('[aria-current="page"]');
                 const actual = getComputedStyle(current);
                 const expected = getComputedStyle(document.getElementById('expected'));
                 return {background: actual.backgroundColor === expected.backgroundColor,
                   foreground: actual.color === expected.color,
                   noTokenOverride: !document.querySelector('#pages ul').style.getPropertyValue('--color-primary')};
               })()
               """)

      {:ok, %{"x" => x, "y" => y}} =
        CDPBrowser.evaluate(page, """
        (() => {
          const rect = document.querySelector('[aria-current="page"]').getBoundingClientRect();
          return {x: rect.x + rect.width / 2, y: rect.y + rect.height / 2};
        })()
        """)

      {:ok, _} =
        CDPBrowser.command(page, "Input.dispatchMouseEvent", %{
          "type" => "mouseMoved",
          "x" => x,
          "y" => y
        })

      assert {:ok, true} =
               CDPBrowser.evaluate(page, """
               (async () => {
                 await new Promise(resolve => setTimeout(resolve, 300));
                 const current = document.querySelector('[aria-current="page"]');
                 const expected = document.getElementById('hover-expected');
                 return current.matches(':hover') &&
                   getComputedStyle(current).backgroundColor === getComputedStyle(expected).backgroundColor;
               })()
               """)
    end
  end
end
