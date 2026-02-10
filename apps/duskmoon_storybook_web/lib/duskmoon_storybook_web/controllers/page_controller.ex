defmodule DuskmoonStorybookWeb.PageController do
  use DuskmoonStorybookWeb, :controller

  def redirect_to_components(conn, _params) do
    redirect(conn, to: ~p"/components/action/button")
  end
end
