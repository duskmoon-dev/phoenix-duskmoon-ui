defmodule DuskmoonStorybookWeb.Components.FunComponentController do
  use DuskmoonStorybookWeb, :controller

  def button_noise(conn, _params) do
    render(conn, :button_noise, active_menu: "fun-button-noise")
  end

  def eclipse(conn, _params) do
    render(conn, :eclipse, active_menu: "fun-eclipse")
  end

  def plasma_ball(conn, _params) do
    render(conn, :plasma_ball, active_menu: "fun-plasma-ball")
  end

  def signature(conn, _params) do
    render(conn, :signature, active_menu: "fun-signature")
  end

  def snow(conn, _params) do
    render(conn, :snow, active_menu: "fun-snow")
  end

  def spotlight_search(conn, _params) do
    render(conn, :spotlight_search, active_menu: "fun-spotlight-search")
  end
end
