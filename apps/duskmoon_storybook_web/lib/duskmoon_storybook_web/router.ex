defmodule DuskmoonStorybookWeb.Router do
  use DuskmoonStorybookWeb, :router
  import PhoenixStorybook.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {DuskmoonStorybookWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    storybook_assets()
  end

  scope "/", DuskmoonStorybookWeb do
    pipe_through :browser

    get "/", PageController, :page
    get "/neumorphic", PageController, :neumorphic

    get "/hook", PageController, :hook

    get "/mdi", PageController, :mdi
    get "/bsi", PageController, :bsi

    get "/fun", FunController, :page

    live_storybook("/storybook", backend_module: DuskmoonStorybookWeb.Storybook)
  end
end
