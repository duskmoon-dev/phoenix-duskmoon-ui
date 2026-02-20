defmodule DuskmoonStorybookWeb.Components.DataEntryController do
  use DuskmoonStorybookWeb, :controller

  def checkbox(conn, _params) do
    render(conn, :checkbox, active_menu: "data-entry-checkbox")
  end

  def compact_input(conn, _params) do
    render(conn, :compact_input, active_menu: "data-entry-compact-input")
  end

  def form(conn, _params) do
    render(conn, :form, active_menu: "data-entry-form")
  end

  def input(conn, _params) do
    render(conn, :input, active_menu: "data-entry-input")
  end

  def rating(conn, _params) do
    render(conn, :rating, active_menu: "data-entry-rating")
  end

  def radio(conn, _params) do
    render(conn, :radio, active_menu: "data-entry-radio")
  end

  def select(conn, _params) do
    render(conn, :select, active_menu: "data-entry-select")
  end

  def slider(conn, _params) do
    render(conn, :slider, active_menu: "data-entry-slider")
  end

  def switch(conn, _params) do
    render(conn, :switch, active_menu: "data-entry-switch")
  end

  def textarea(conn, _params) do
    render(conn, :textarea, active_menu: "data-entry-textarea")
  end
end
