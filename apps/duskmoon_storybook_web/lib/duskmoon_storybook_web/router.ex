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

    live_storybook("/storybook", backend_module: DuskmoonStorybookWeb.Storybook)
  end

  scope "/components", DuskmoonStorybookWeb.Components do
    pipe_through :browser

    # Action
    get "/action/button", ActionController, :button
    get "/action/link", ActionController, :link
    get "/action/dropdown", ActionController, :dropdown
    get "/action/menu", ActionController, :menu
    get "/action/toggle", ActionController, :toggle

    # Data Display
    get "/data-display/accordion", DataDisplayController, :accordion
    get "/data-display/avatar", DataDisplayController, :avatar
    get "/data-display/badge", DataDisplayController, :badge
    get "/data-display/card", DataDisplayController, :card
    get "/data-display/chip", DataDisplayController, :chip
    get "/data-display/flash", DataDisplayController, :flash
    get "/data-display/markdown", DataDisplayController, :markdown
    get "/data-display/pagination", DataDisplayController, :pagination
    get "/data-display/progress", DataDisplayController, :progress
    get "/data-display/skeleton", DataDisplayController, :skeleton
    get "/data-display/stat", DataDisplayController, :stat
    get "/data-display/table", DataDisplayController, :table
    get "/data-display/timeline", DataDisplayController, :timeline
    get "/data-display/tooltip", DataDisplayController, :tooltip
    get "/data-display/popover", DataDisplayController, :popover
    get "/data-display/list", DataDisplayController, :list
    get "/data-display/collapse", DataDisplayController, :collapse

    # Data Entry
    get "/data-entry/autocomplete", DataEntryController, :autocomplete
    get "/data-entry/checkbox", DataEntryController, :checkbox
    get "/data-entry/compact-input", DataEntryController, :compact_input
    get "/data-entry/file-upload", DataEntryController, :file_upload
    get "/data-entry/form", DataEntryController, :form
    get "/data-entry/input", DataEntryController, :input
    get "/data-entry/otp-input", DataEntryController, :otp_input
    get "/data-entry/rating", DataEntryController, :rating
    get "/data-entry/radio", DataEntryController, :radio
    get "/data-entry/segment-control", DataEntryController, :segment_control
    get "/data-entry/select", DataEntryController, :select
    get "/data-entry/slider", DataEntryController, :slider
    get "/data-entry/switch", DataEntryController, :switch
    get "/data-entry/textarea", DataEntryController, :textarea
    get "/data-entry/time-input", DataEntryController, :time_input
    get "/data-entry/pin-input", DataEntryController, :pin_input
    get "/data-entry/multi-select", DataEntryController, :multi_select
    get "/data-entry/tree-select", DataEntryController, :tree_select
    get "/data-entry/cascader", DataEntryController, :cascader

    # Feedback
    get "/feedback/dialog", FeedbackController, :dialog
    get "/feedback/loading", FeedbackController, :loading
    get "/feedback/toast", FeedbackController, :toast
    get "/feedback/snackbar", FeedbackController, :snackbar

    # Navigation
    get "/navigation/actionbar", NavigationController, :actionbar
    get "/navigation/appbar", NavigationController, :appbar
    get "/navigation/bottom-nav", NavigationController, :bottom_nav
    get "/navigation/breadcrumb", NavigationController, :breadcrumb
    get "/navigation/left-menu", NavigationController, :left_menu
    get "/navigation/navbar", NavigationController, :navbar
    get "/navigation/page-footer", NavigationController, :page_footer
    get "/navigation/page-header", NavigationController, :page_header
    get "/navigation/steps", NavigationController, :steps
    get "/navigation/stepper", NavigationController, :stepper
    get "/navigation/tab", NavigationController, :tab
    get "/navigation/nested-menu", NavigationController, :nested_menu

    # Layout
    get "/layout/bottom-sheet", LayoutController, :bottom_sheet
    get "/layout/divider", LayoutController, :divider
    get "/layout/drawer", LayoutController, :drawer
    get "/layout/theme-switcher", LayoutController, :theme_switcher

    # Icon
    get "/icon/icons", IconController, :icons

    # Fun
    get "/fun/button-noise", FunComponentController, :button_noise
    get "/fun/eclipse", FunComponentController, :eclipse
    get "/fun/plasma-ball", FunComponentController, :plasma_ball
    get "/fun/signature", FunComponentController, :signature
    get "/fun/snow", FunComponentController, :snow
    get "/fun/spotlight-search", FunComponentController, :spotlight_search
  end
end
