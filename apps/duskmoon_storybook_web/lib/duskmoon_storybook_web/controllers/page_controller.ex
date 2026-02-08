defmodule DuskmoonStorybookWeb.PageController do
  use DuskmoonStorybookWeb, :controller

  def page(conn, _params) do
    render(conn, :page, layout: false, active_menu: "page")
  end

  def hook(conn, %{"mode" => mode} = _params) do
    render(conn, :hook, mode: mode, active_menu: "darkmoon-hook")
  end

  def hook(conn, _params) do
    render(conn, :hook, mode: "app", active_menu: "darkmoon-hook")
  end

  def mdi(conn, %{"filter" => filter}) do
    icons =
      PhoenixDuskmoon.Component.Icons.mdi_icons()
      |> Enum.filter(fn n ->
        reg = Regex.compile!("#{filter}", [:caseless])
        Regex.match?(reg, n)
      end)

    render(conn, :mdi, mdi_icons: icons, active_menu: "mdi", filter: filter)
  end

  def mdi(conn, _params) do
    icons = PhoenixDuskmoon.Component.Icons.mdi_icons()
    render(conn, :mdi, mdi_icons: icons, active_menu: "mdi", filter: "")
  end

  def bsi(conn, %{"filter" => filter}) do
    icons =
      PhoenixDuskmoon.Component.Icons.bsi_icons()
      |> Enum.filter(fn n ->
        reg = Regex.compile!("#{filter}", [:caseless])
        Regex.match?(reg, n)
      end)

    render(conn, :bsi, bsi_icons: icons, active_menu: "bsi", filter: filter)
  end

  def bsi(conn, _params) do
    icons = PhoenixDuskmoon.Component.Icons.bsi_icons()
    render(conn, :bsi, bsi_icons: icons, active_menu: "bsi", filter: "")
  end
end
