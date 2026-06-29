defmodule DuskmoonStorybookWeb.Components.ActionController do
  use DuskmoonStorybookWeb, :controller

  def button(conn, _params) do
    render(conn, :button, active_menu: "action-button")
  end

  def link(conn, _params) do
    render(conn, :link, active_menu: "action-link")
  end

  def dropdown(conn, _params) do
    render(conn, :dropdown, active_menu: "action-dropdown")
  end

  def menu(conn, _params) do
    render(conn, :menu, active_menu: "action-menu")
  end

  def toggle(conn, _params) do
    render(conn, :toggle, active_menu: "action-toggle")
  end
end
