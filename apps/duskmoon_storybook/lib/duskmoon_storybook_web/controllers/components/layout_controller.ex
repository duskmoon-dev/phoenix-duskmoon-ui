defmodule DuskmoonStorybookWeb.Components.LayoutController do
  use DuskmoonStorybookWeb, :controller

  def bottom_sheet(conn, _params) do
    render(conn, :bottom_sheet, active_menu: "layout-bottom-sheet")
  end

  def divider(conn, _params) do
    render(conn, :divider, active_menu: "layout-divider")
  end

  def drawer(conn, _params) do
    render(conn, :drawer, active_menu: "layout-drawer")
  end

  def theme_switcher(conn, _params) do
    render(conn, :theme_switcher, active_menu: "layout-theme-switcher")
  end
end
