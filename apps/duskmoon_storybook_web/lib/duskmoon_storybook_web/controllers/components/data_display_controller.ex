defmodule DuskmoonStorybookWeb.Components.DataDisplayController do
  use DuskmoonStorybookWeb, :controller

  def accordion(conn, _params) do
    render(conn, :accordion, active_menu: "data-display-accordion")
  end

  def avatar(conn, _params) do
    render(conn, :avatar, active_menu: "data-display-avatar")
  end

  def badge(conn, _params) do
    render(conn, :badge, active_menu: "data-display-badge")
  end

  def card(conn, _params) do
    render(conn, :card, active_menu: "data-display-card")
  end

  def chip(conn, _params) do
    render(conn, :chip, active_menu: "data-display-chip")
  end

  def stat(conn, _params) do
    render(conn, :stat, active_menu: "data-display-stat")
  end

  def flash(conn, _params) do
    render(conn, :flash, active_menu: "data-display-flash")
  end

  def markdown(conn, _params) do
    render(conn, :markdown, active_menu: "data-display-markdown")
  end

  def pagination(conn, _params) do
    render(conn, :pagination, active_menu: "data-display-pagination")
  end

  def progress(conn, _params) do
    render(conn, :progress, active_menu: "data-display-progress")
  end

  def skeleton(conn, _params) do
    render(conn, :skeleton, active_menu: "data-display-skeleton")
  end

  def table(conn, _params) do
    render(conn, :table, active_menu: "data-display-table")
  end

  def tooltip(conn, _params) do
    render(conn, :tooltip, active_menu: "data-display-tooltip")
  end
end
