defmodule DuskmoonStorybookWeb.Components.LayoutController do
  use DuskmoonStorybookWeb, :controller

  def divider(conn, _params) do
    render(conn, :divider, active_menu: "layout-divider")
  end

  def theme_switcher(conn, _params) do
    render(conn, :theme_switcher, active_menu: "layout-theme-switcher")
  end
end
