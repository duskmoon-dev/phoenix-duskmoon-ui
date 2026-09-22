defmodule PhoenixDuskmoon.Component.Layout.SidebarLayoutTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Layout.SidebarLayout

  test "keeps sidebar and content as direct siblings for the upstream grid" do
    html =
      render_component(&dm_sidebar_layout/1, %{
        id: "workspace",
        position: "end",
        compact: true,
        sidebar: [%{inner_block: fn _, _ -> "Navigation" end}],
        inner_block: [%{inner_block: fn _, _ -> "Workspace" end}]
      })

    assert html =~ ~s(class="sidebar-layout sidebar-layout-end sidebar-layout-compact")

    assert html =~
             ~r/<aside class="sidebar-layout-sidebar\s*">\s*Navigation\s*<\/aside>\s*<div class="sidebar-layout-content\s*">\s*Workspace\s*<\/div>/

    refute html =~ "phx-hook"
  end

  test "hidden only controls the sidebar and leaves content accessible" do
    html =
      render_component(&dm_sidebar_layout/1, %{
        hidden: true,
        style: "--sidebar-layout-width: 20rem",
        sidebar: [%{inner_block: fn _, _ -> "Navigation" end}],
        inner_block: [%{inner_block: fn _, _ -> "Content" end}]
      })

    assert html =~ "sidebar-layout-hidden"
    assert html =~ ~s(style="--sidebar-layout-width: 20rem")
    refute html =~ ~r/\shidden(?:=|>)/
    assert html =~ "Content"
  end
end
