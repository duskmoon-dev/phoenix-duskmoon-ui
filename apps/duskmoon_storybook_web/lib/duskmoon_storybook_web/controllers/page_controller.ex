defmodule DuskmoonStorybookWeb.PageController do
  use DuskmoonStorybookWeb, :controller

  def page(conn, _params) do
    render(conn, :page, layout: false)
  end
end
