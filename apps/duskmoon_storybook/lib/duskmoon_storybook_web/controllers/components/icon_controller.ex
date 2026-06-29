defmodule DuskmoonStorybookWeb.Components.IconController do
  use DuskmoonStorybookWeb, :controller

  def icons(conn, _params) do
    render(conn, :icons, active_menu: "icon-icons")
  end
end
