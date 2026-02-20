defmodule DuskmoonStorybookWeb.Components.DataEntryController do
  use DuskmoonStorybookWeb, :controller

  def autocomplete(conn, _params) do
    render(conn, :autocomplete, active_menu: "data-entry-autocomplete")
  end

  def checkbox(conn, _params) do
    render(conn, :checkbox, active_menu: "data-entry-checkbox")
  end

  def compact_input(conn, _params) do
    render(conn, :compact_input, active_menu: "data-entry-compact-input")
  end

  def file_upload(conn, _params) do
    render(conn, :file_upload, active_menu: "data-entry-file-upload")
  end

  def form(conn, _params) do
    render(conn, :form, active_menu: "data-entry-form")
  end

  def input(conn, _params) do
    render(conn, :input, active_menu: "data-entry-input")
  end

  def otp_input(conn, _params) do
    render(conn, :otp_input, active_menu: "data-entry-otp-input")
  end

  def rating(conn, _params) do
    render(conn, :rating, active_menu: "data-entry-rating")
  end

  def radio(conn, _params) do
    render(conn, :radio, active_menu: "data-entry-radio")
  end

  def segment_control(conn, _params) do
    render(conn, :segment_control, active_menu: "data-entry-segment-control")
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
