defmodule DuskmoonStorybookWeb.Components.FeedbackController do
  use DuskmoonStorybookWeb, :controller

  def dialog(conn, _params) do
    render(conn, :dialog, active_menu: "feedback-dialog")
  end

  def loading(conn, _params) do
    render(conn, :loading, active_menu: "feedback-loading")
  end
end
