defmodule PhoenixDuskmoon.Component.CorePrimitivesBrowserTest do
  use ExUnit.Case, async: false
  use Phoenix.Component

  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Action.Fab
  import PhoenixDuskmoon.Component.Action.Swap
  import PhoenixDuskmoon.Component.DataDisplay.Carousel
  import PhoenixDuskmoon.Component.DataEntry.FilterGroup

  alias DuskmoonBundler.Integration.CDPBrowser

  @moduletag :integration

  setup_all do
    {:ok, browser} = CDPBrowser.start_link()
    on_exit(fn -> CDPBrowser.stop(browser) end)
    core = Path.expand("../../../../../node_modules/@duskmoon-dev/core/dist", __DIR__)

    css =
      [
        "themes/generated/sunshine.css",
        "themes/generated/moonlight.css",
        "components/button.css",
        "components/swap.css",
        "components/filter-group.css",
        "components/fab.css",
        "components/carousel.css"
      ]
      |> Enum.map_join("\n", &File.read!(Path.join(core, &1)))

    %{browser: browser, css: css}
  end

  setup %{browser: browser} do
    {:ok, page} = CDPBrowser.new_page(browser)
    on_exit(fn -> CDPBrowser.close_page(page) end)
    %{page: page}
  end

  test "swap and filters use keyboard selection, native submission and form reset", %{
    page: page,
    css: css
  } do
    assigns = %{}

    component =
      rendered_to_string(~H"""
      <form id="preferences">
        <.dm_swap id="sound" name="sound" label="Enable sound" rotate>
          <:on>Sound on</:on><:off>Sound off</:off>
        </.dm_swap>
        <.dm_filter_group name="status" label="Status" multiple={false}>
          <:option value="active" checked>Active</:option>
          <:option value="complete">Complete</:option>
        </.dm_filter_group>
        <.dm_filter_group name="tags[]" label="Tags">
          <:option value="design" checked>Design</:option>
          <:option value="code">Code</:option>
          <:option value="archived" disabled>Archived</:option>
        </.dm_filter_group>
      </form>
      """)

    for theme <- ["sunshine", "moonlight"], width <- [375, 1280] do
      load_page(page, css, component, theme, width)
      {:ok, _} = CDPBrowser.evaluate(page, "document.getElementById('sound').focus()")
      dispatch_key(page, " ", "Space", 32)

      assert {:ok, %{"checked" => true, "onVisible" => true, "offHidden" => true}} =
               CDPBrowser.evaluate(page, """
               ({checked: document.getElementById('sound').checked,
                 onVisible: getComputedStyle(document.querySelector('.swap-on')).visibility === 'visible',
                 offHidden: getComputedStyle(document.querySelector('.swap-off')).visibility === 'hidden'})
               """)

      {:ok, _} =
        CDPBrowser.evaluate(page, "document.querySelector('input[value=active]').focus()")

      dispatch_key(page, "ArrowRight", "ArrowRight", 39)
      {:ok, _} = CDPBrowser.evaluate(page, "document.querySelector('input[value=code]').click()")

      assert {:ok,
              %{
                "status" => "complete",
                "sound" => "true",
                "tags" => ["design", "code"],
                "disabled" => false
              }} =
               CDPBrowser.evaluate(page, """
               (() => {
                 document.querySelector('input[value=archived]').click();
                 const data = new FormData(document.getElementById('preferences'));
                 return {status: data.get('status'), sound: data.get('sound'), tags: data.getAll('tags[]'),
                   disabled: document.querySelector('input[value=archived]').checked};
               })()
               """)

      assert {:ok,
              %{"sound" => false, "status" => "active", "tags" => ["design"], "onHidden" => true}} =
               CDPBrowser.evaluate(page, """
               (() => {
                 document.getElementById('preferences').reset();
                 const data = new FormData(document.getElementById('preferences'));
                 return {sound: data.has('sound'), status: data.get('status'), tags: data.getAll('tags[]'),
                   onHidden: getComputedStyle(document.querySelector('.swap-on')).visibility === 'hidden'};
               })()
               """)
    end
  end

  test "FAB opens with its native command and supports Escape and light dismissal", %{
    page: page,
    css: css
  } do
    assigns = %{}

    component =
      rendered_to_string(~H"""
      <.dm_fab id="create" label="Create">
        <:trigger>+</:trigger>
        <button type="button" class="btn btn-primary">New document</button>
      </.dm_fab>
      """)

    for theme <- ["sunshine", "moonlight"], width <- [375, 1280] do
      load_page(page, css, component, theme, width)

      assert {:ok, "none"} =
               CDPBrowser.evaluate(
                 page,
                 "getComputedStyle(document.getElementById('create')).display"
               )

      assert {:ok, %{"open" => true, "fits" => true}} =
               CDPBrowser.evaluate(page, """
               (async () => {
                 const trigger = document.getElementById('create-trigger');
                 trigger.focus(); trigger.click();
                 await new Promise(resolve => setTimeout(resolve, 180));
                 const panel = document.getElementById('create');
                 const rect = panel.getBoundingClientRect();
                 return {open: panel.matches(':popover-open'), fits: rect.left >= 0 && rect.right <= innerWidth && rect.width > 0};
               })()
               """)

      dispatch_key(page, "Escape", "Escape", 27)

      assert {:ok, true} =
               CDPBrowser.evaluate(
                 page,
                 "!document.getElementById('create').matches(':popover-open') && document.activeElement.id === 'create-trigger'"
               )

      {:ok, _} = CDPBrowser.evaluate(page, "document.getElementById('create-trigger').click()")

      for type <- ["mousePressed", "mouseReleased"] do
        {:ok, _} =
          CDPBrowser.command(page, "Input.dispatchMouseEvent", %{
            "type" => type,
            "x" => 10,
            "y" => 10,
            "button" => "left",
            "clickCount" => 1
          })
      end

      assert {:ok, false} =
               CDPBrowser.evaluate(
                 page,
                 "document.getElementById('create').matches(':popover-open')"
               )
    end
  end

  test "carousel supports keyboard scrolling with shipped scroll-snap CSS", %{
    page: page,
    css: css
  } do
    assigns = %{}

    component =
      rendered_to_string(~H"""
      <.dm_carousel id="slides" label="Projects" style="width: 300px">
        <:item label="One"><div style="width: 260px; height: 80px">One</div></:item>
        <:item label="Two"><div style="width: 260px; height: 80px">Two</div></:item>
        <:item label="Three"><div style="width: 260px; height: 80px">Three</div></:item>
      </.dm_carousel>
      """)

    load_page(page, css, component, "sunshine", 375)

    assert {:ok, %{"overflow" => true, "snap" => "inline mandatory"}} =
             CDPBrowser.evaluate(page, """
             (() => {
               const carousel = document.getElementById('slides'); carousel.focus();
               return {overflow: carousel.scrollWidth > carousel.clientWidth, snap: getComputedStyle(carousel).scrollSnapType};
             })()
             """)

    dispatch_key(page, "ArrowRight", "ArrowRight", 39)

    assert {:ok, true} =
             CDPBrowser.evaluate(page, """
             (async () => {
               await new Promise(resolve => setTimeout(resolve, 600));
               return document.getElementById('slides').scrollLeft > 0;
             })()
             """)
  end

  defp load_page(page, css, component, theme, width) do
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
  end

  defp dispatch_key(page, key, code, number) do
    for type <- ["keyDown", "keyUp"] do
      {:ok, _} =
        CDPBrowser.command(page, "Input.dispatchKeyEvent", %{
          "type" => type,
          "key" => key,
          "code" => code,
          "windowsVirtualKeyCode" => number
        })
    end

    :ok
  end
end
