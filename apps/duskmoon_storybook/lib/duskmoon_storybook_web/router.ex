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

  scope "/" do
    storybook_assets()
  end

  scope "/", DuskmoonStorybookWeb do
    pipe_through :browser

    get "/", PageController, :page
    get "/examples/hologram", PageController, :hologram_redirect
    live "/components", Components.PageLive
    live "/hologram", HologramLive, :overview, container: {:div, class: "container"}
    live "/hologram/playground", HologramLive, :playground, container: {:div, class: "container"}
    live "/hologram/tasks", HologramLive, :tasks, container: {:div, class: "container"}

    live "/hologram/preferences", HologramLive, :preferences,
      container: {:div, class: "container"}

    live_storybook("/storybook", backend_module: DuskmoonStorybookWeb.Storybook)
  end

  scope "/components", DuskmoonStorybookWeb.Components do
    pipe_through :browser

    live "/data-display/react-chat", ReactChatLive
    live "/data-entry/react-form", ReactFormLive

    # Action
    live "/action/button", PageLive
    live "/action/link", PageLive
    live "/action/dropdown", PageLive
    live "/action/menu", PageLive
    live "/action/toggle", PageLive

    # Data Display
    live "/data-display/accordion", PageLive
    live "/data-display/avatar", PageLive
    live "/data-display/badge", PageLive
    live "/data-display/card", PageLive
    live "/data-display/chat", PageLive
    live "/data-display/chip", PageLive
    live "/data-display/datetime", PageLive
    live "/data-display/flash", PageLive
    live "/data-display/markdown", PageLive
    live "/data-display/markdown-body", PageLive
    live "/data-display/pagination", PageLive
    live "/data-display/progress", PageLive
    live "/data-display/skeleton", PageLive
    live "/data-display/stat", PageLive
    live "/data-display/table", PageLive
    live "/data-display/timeline", PageLive
    live "/data-display/tooltip", PageLive
    live "/data-display/popover", PageLive
    live "/data-display/list", PageLive
    live "/data-display/collapse", PageLive

    # Data Entry
    live "/data-entry/autocomplete", PageLive
    live "/data-entry/checkbox", PageLive
    live "/data-entry/compact-input", PageLive
    live "/data-entry/file-upload", PageLive
    live "/data-entry/form", PageLive
    live "/data-entry/input", PageLive
    live "/data-entry/otp-input", PageLive
    live "/data-entry/rating", PageLive
    live "/data-entry/radio", PageLive
    live "/data-entry/segment-control", PageLive
    live "/data-entry/select", PageLive
    live "/data-entry/slider", PageLive
    live "/data-entry/switch", PageLive
    live "/data-entry/textarea", PageLive
    live "/data-entry/time-input", PageLive
    live "/data-entry/pin-input", PageLive
    live "/data-entry/multi-select", PageLive
    live "/data-entry/tree-select", PageLive
    live "/data-entry/cascader", PageLive
    live "/data-entry/markdown-input", PageLive
    live "/data-entry/code-engine", PageLive

    # Feedback
    live "/feedback/dialog", PageLive
    live "/feedback/loading", PageLive
    live "/feedback/toast", PageLive
    live "/feedback/snackbar", PageLive

    # Navigation
    live "/navigation/left-menu/live/:page", LeftMenuLive
    live "/navigation/actionbar", PageLive
    live "/navigation/appbar", PageLive
    live "/navigation/bottom-nav", PageLive
    live "/navigation/breadcrumb", PageLive
    live "/navigation/left-menu", PageLive
    live "/navigation/navbar", PageLive
    live "/navigation/page-footer", PageLive
    live "/navigation/page-header", PageLive
    live "/navigation/stepper", PageLive
    live "/navigation/tab", PageLive

    # Layout
    live "/layout/bottom-sheet", PageLive
    live "/layout/divider", PageLive
    live "/layout/drawer", PageLive
    live "/layout/theme-switcher", PageLive

    # Icon
    live "/icon/icons", PageLive
  end

  scope "/art-component", DuskmoonStorybookWeb do
    pipe_through :browser

    get "/", ArtComponentController, :index
    get "/atom", ArtComponentController, :atom
    get "/cat-stargazer", ArtComponentController, :cat_stargazer
    get "/circular-gallery", ArtComponentController, :circular_gallery
    get "/color-spin", ArtComponentController, :color_spin
    get "/eclipse", ArtComponentController, :eclipse
    get "/flower-animation", ArtComponentController, :flower_animation
    get "/gemini-input", ArtComponentController, :gemini_input
    get "/moon", ArtComponentController, :moon
    get "/mountain", ArtComponentController, :mountain
    get "/plasma-ball", ArtComponentController, :plasma_ball
    get "/snow", ArtComponentController, :snow
    get "/sun", ArtComponentController, :sun
    get "/synthwave-starfield", ArtComponentController, :synthwave_starfield
    get "/button-noise", ArtComponentController, :button_noise
    get "/signature", ArtComponentController, :signature
    get "/spotlight-search", ArtComponentController, :spotlight_search
  end
end
