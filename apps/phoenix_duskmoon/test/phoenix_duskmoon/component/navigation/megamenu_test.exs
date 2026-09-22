defmodule PhoenixDuskmoon.Component.Navigation.MegamenuTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Navigation.Megamenu

  defp render_menu(id, attrs \\ %{}) do
    render_component(
      &dm_megamenu/1,
      Map.merge(
        %{
          id: id,
          trigger: [%{inner_block: fn _, _ -> "Products" end}],
          group: [%{title: "Workspace", inner_block: fn _, _ -> "Project links" end}]
        },
        attrs
      )
    )
  end

  test "wires native popover targeting and accessible navigation labeling" do
    html = render_menu("products")
    assert html =~ ~s(id="products-trigger")
    assert html =~ ~s(type="button")
    assert html =~ ~s(popovertarget="products-panel")
    assert html =~ ~s(popovertargetaction="toggle")
    assert html =~ ~s(aria-controls="products-panel")
    assert html =~ ~s(id="products-panel")
    assert html =~ ~s(popover="auto")
    assert html =~ ~s(aria-labelledby="products-trigger")
    assert html =~ ~s(<h2 class="megamenu-heading">Workspace</h2>)
    assert html =~ "Project links"
    refute html =~ ~s(role="menu")
    refute html =~ "aria-expanded"
  end

  test "gives each trigger and panel pair a CSS-safe unique anchor" do
    first = render_menu("products:one")
    second = render_menu("products:two", %{full: true})
    [_, anchor] = Regex.run(~r/--megamenu-anchor: (--dm-megamenu-[A-F0-9]+)/, first)
    assert length(Regex.scan(Regex.compile!(anchor), first)) == 2
    refute second =~ anchor
    assert second =~ "megamenu-panel-full"
  end
end
