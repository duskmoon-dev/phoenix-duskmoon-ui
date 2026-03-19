defmodule DuskmoonStorybookWeb.ArtComponentController do
  use DuskmoonStorybookWeb, :controller

  plug :put_layout, {DuskmoonStorybookWeb.Layouts, :art_component}

  def index(conn, _params) do
    render(conn, :index, active_menu: "art-index")
  end

  def atom(conn, _params) do
    render(conn, :atom, active_menu: "art-atom")
  end

  def cat_stargazer(conn, _params) do
    render(conn, :cat_stargazer, active_menu: "art-cat-stargazer")
  end

  def circular_gallery(conn, _params) do
    render(conn, :circular_gallery, active_menu: "art-circular-gallery")
  end

  def color_spin(conn, _params) do
    render(conn, :color_spin, active_menu: "art-color-spin")
  end

  def eclipse(conn, _params) do
    render(conn, :eclipse, active_menu: "art-eclipse")
  end

  def gemini_input(conn, _params) do
    render(conn, :gemini_input, active_menu: "art-gemini-input")
  end

  def flower_animation(conn, _params) do
    render(conn, :flower_animation, active_menu: "art-flower-animation")
  end

  def moon(conn, _params) do
    render(conn, :moon, active_menu: "art-moon")
  end

  def mountain(conn, _params) do
    render(conn, :mountain, active_menu: "art-mountain")
  end

  def plasma_ball(conn, _params) do
    render(conn, :plasma_ball, active_menu: "art-plasma-ball")
  end

  def snow(conn, _params) do
    render(conn, :snow, active_menu: "art-snow")
  end

  def sun(conn, _params) do
    render(conn, :sun, active_menu: "art-sun")
  end

  def synthwave_starfield(conn, _params) do
    render(conn, :synthwave_starfield, active_menu: "art-synthwave-starfield")
  end
end
