defmodule DuskmoonStorybookWeb.CssArtController do
  use DuskmoonStorybookWeb, :controller

  plug :put_layout, {DuskmoonStorybookWeb.Layouts, :css_art}

  def index(conn, _params) do
    render(conn, :index, active_menu: "css-art-index")
  end

  def button_noise(conn, _params) do
    render(conn, :button_noise, active_menu: "css-art-button-noise")
  end

  def eclipse(conn, _params) do
    render(conn, :eclipse, active_menu: "css-art-eclipse")
  end

  def plasma_ball(conn, _params) do
    render(conn, :plasma_ball, active_menu: "css-art-plasma-ball")
  end

  def signature(conn, _params) do
    render(conn, :signature, active_menu: "css-art-signature")
  end

  def snow(conn, _params) do
    render(conn, :snow, active_menu: "css-art-snow")
  end

  def spotlight_search(conn, _params) do
    render(conn, :spotlight_search, active_menu: "css-art-spotlight-search")
  end
end
