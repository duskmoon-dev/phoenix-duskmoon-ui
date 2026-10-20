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

    root = Path.expand("../../../../../../", __DIR__)
    css_path = Path.join(root, "apps/phoenix_duskmoon/assets/css/phoenix_duskmoon.css")
    {:ok, _} = Application.ensure_all_started(:duskmoon_bundler)

    {:ok, layout_css} =
      DuskmoonBundler.Tailwind.build(
        css: File.read!(css_path),
        css_base: Path.dirname(css_path),
        sources: [%{base: Path.join(root, "apps/phoenix_duskmoon/lib"), pattern: "**/*.ex"}]
      )

    %{browser: browser, css: css, layout_css: layout_css}
  end

  for mode <- [:button, :link, :thin] do
    @tag mode: mode
    test "#{mode} pagination keeps hidden labels inside its scrolling pane", %{
      browser: browser,
      layout_css: css,
      mode: mode
    } do
      {:ok, page} = CDPBrowser.new_page(browser)
      on_exit(fn -> CDPBrowser.close_page(page) end)

      assert {:ok, _} =
               CDPBrowser.command(page, "Emulation.setDeviceMetricsOverride", %{
                 "width" => 1200,
                 "height" => 700,
                 "deviceScaleFactor" => 1,
                 "mobile" => false
               })

      component =
        render_component(
          if(mode == :thin, do: &dm_pagination_thin/1, else: &dm_pagination/1),
          %{
            id: "pages",
            page_num: 10,
            page_size: 10,
            total: 300,
            update_event: "change-page",
            page_url: if(mode == :link, do: "#page-{page}"),
            page_link_type: "href"
          }
        )

      html = """
      <!doctype html><html lang="en" data-theme="sunshine"><head><style>#{css}</style></head>
      <body style="margin:0"><div id="shell" style="height:100vh;display:flex;flex-direction:column;overflow:hidden">
      <header style="height:64px;flex-shrink:0">Page header</header>
      <main id="pane" style="flex:1;min-height:0;overflow:auto">
      <div style="height:1800px">Tall content</div>#{component}</main></div>
      <script>
        window.pagerClicks = [];
        document.getElementById('pages').addEventListener('click', event => {
          const control = event.target.closest('a,button');
          if (!control) return;
          event.preventDefault();
          window.pagerClicks.push({href: control.getAttribute('href'),
            event: control.getAttribute('phx-click'), current: control.getAttribute('phx-value-current')});
        });
      </script></body></html>
      """

      assert :ok = CDPBrowser.goto(page, "data:text/html;base64," <> Base.encode64(html))

      assert {:ok,
              %{
                "rootHeight" => 700,
                "viewportHeight" => 700,
                "staticAncestors" => true,
                "containedLabels" => true,
                "labels" => labels
              }} =
               CDPBrowser.evaluate(page, """
               (() => {
                 const nav = document.getElementById('pages');
                 const labels = [...nav.querySelectorAll('.sr-only')];
                 const ancestors = [nav.parentElement, document.getElementById('shell'), document.body];
                 return {rootHeight: document.documentElement.scrollHeight, viewportHeight: innerHeight,
                   staticAncestors: ancestors.every(node => getComputedStyle(node).position === 'static'),
                   containedLabels: labels.every(label => label.offsetParent && nav.contains(label.offsetParent)),
                   labels: labels.map(label => label.textContent.trim())};
               })()
               """)

      assert labels ==
               if(mode == :thin,
                 do: ["Previous", "Next"],
                 else: ["Previous", "More pages", "More pages", "Next"]
               )

      assert {:ok, %{"scrolled" => true, "rootHeight" => 700, "x" => x, "y" => y}} =
               CDPBrowser.evaluate(page, """
               (() => {
                 const pane = document.getElementById('pane');
                 pane.scrollTop = pane.scrollHeight;
                 const next = document.querySelector('#pages .pagination-next');
                 const rect = next.getBoundingClientRect();
                 return {scrolled: pane.scrollTop > 1000 && scrollY === 0,
                   rootHeight: document.documentElement.scrollHeight,
                   x: rect.x + rect.width / 2, y: rect.y + rect.height / 2};
               })()
               """)

      assert {:ok, %{"nodes" => nodes}} = CDPBrowser.command(page, "Accessibility.getFullAXTree")
      names = Enum.map(nodes, &get_in(&1, ["name", "value"]))
      assert "Pagination" in names
      assert "Previous page" in names
      assert "Next page" in names
      assert "Page 10" in names

      for type <- ["mousePressed", "mouseReleased"] do
        assert {:ok, _} =
                 CDPBrowser.command(page, "Input.dispatchMouseEvent", %{
                   "type" => type,
                   "x" => x,
                   "y" => y,
                   "button" => "left",
                   "clickCount" => 1
                 })
      end

      expected =
        if mode == :link,
          do: %{"href" => "#page-11", "event" => nil, "current" => nil},
          else: %{"href" => nil, "event" => "change-page", "current" => "11"}

      assert {:ok, [^expected]} = CDPBrowser.evaluate(page, "window.pagerClicks")
    end
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
