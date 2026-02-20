defmodule DuskmoonStorybookWeb.Components.NavigationController do
  use DuskmoonStorybookWeb, :controller

  def actionbar(conn, _params) do
    render(conn, :actionbar, active_menu: "navigation-actionbar")
  end

  def appbar(conn, _params) do
    render(conn, :appbar, active_menu: "navigation-appbar")
  end

  def bottom_nav(conn, _params) do
    render(conn, :bottom_nav, active_menu: "navigation-bottom-nav")
  end

  def breadcrumb(conn, _params) do
    render(conn, :breadcrumb, active_menu: "navigation-breadcrumb")
  end

  def left_menu(conn, _params) do
    render(conn, :left_menu, active_menu: "navigation-left-menu")
  end

  def navbar(conn, _params) do
    render(conn, :navbar, active_menu: "navigation-navbar")
  end

  def page_footer(conn, _params) do
    render(conn, :page_footer, active_menu: "navigation-page-footer")
  end

  def page_header(conn, _params) do
    render(conn, :page_header, active_menu: "navigation-page-header")
  end

  def steps(conn, _params) do
    render(conn, :steps, active_menu: "navigation-steps")
  end

  def tab(conn, _params) do
    render(conn, :tab, active_menu: "navigation-tab")
  end
end
