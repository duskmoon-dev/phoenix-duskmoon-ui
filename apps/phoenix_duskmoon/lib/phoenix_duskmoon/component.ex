defmodule PhoenixDuskmoon.Component do
  @moduledoc """
  Provides `Duskmoon UI` component for phoenix.

  This library adds a list of Phoenix components.

  """

  @doc """
  Generate a random id format `random-8DFBEE211780394A`
  """

  @spec generate_id() :: String.t()
  def generate_id() do
    "random-#{:crypto.strong_rand_bytes(8) |> Base.encode16()}"
  end

  @doc false
  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  @doc false
  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS
    end
  end

  @doc false
  def component do
    quote do
      # Action components
      import PhoenixDuskmoon.Component.Action.Button
      import PhoenixDuskmoon.Component.Action.Link
      import PhoenixDuskmoon.Component.Action.Dropdown
      import PhoenixDuskmoon.Component.Action.Menu
      import PhoenixDuskmoon.Component.Action.Toggle

      # Data Display components
      import PhoenixDuskmoon.Component.DataDisplay.Accordion
      import PhoenixDuskmoon.Component.DataDisplay.Collapse
      import PhoenixDuskmoon.Component.DataDisplay.Avatar
      import PhoenixDuskmoon.Component.DataDisplay.Chip
      import PhoenixDuskmoon.Component.DataDisplay.Stat
      import PhoenixDuskmoon.Component.DataDisplay.Badge
      import PhoenixDuskmoon.Component.DataDisplay.Card
      import PhoenixDuskmoon.Component.DataDisplay.Flash
      import PhoenixDuskmoon.Component.DataDisplay.List
      import PhoenixDuskmoon.Component.DataDisplay.Markdown
      import PhoenixDuskmoon.Component.DataDisplay.Pagination
      import PhoenixDuskmoon.Component.DataDisplay.Popover
      import PhoenixDuskmoon.Component.DataDisplay.Progress
      import PhoenixDuskmoon.Component.DataDisplay.Skeleton
      import PhoenixDuskmoon.Component.DataDisplay.Table
      import PhoenixDuskmoon.Component.DataDisplay.Timeline
      import PhoenixDuskmoon.Component.DataDisplay.Tooltip

      # Data Entry components
      import PhoenixDuskmoon.Component.DataEntry.Autocomplete
      import PhoenixDuskmoon.Component.DataEntry.Cascader
      import PhoenixDuskmoon.Component.DataEntry.FileUpload
      import PhoenixDuskmoon.Component.DataEntry.Form
      import PhoenixDuskmoon.Component.DataEntry.Checkbox
      import PhoenixDuskmoon.Component.DataEntry.CompactInput
      import PhoenixDuskmoon.Component.DataEntry.Input
      import PhoenixDuskmoon.Component.DataEntry.MultiSelect
      import PhoenixDuskmoon.Component.DataEntry.OtpInput
      import PhoenixDuskmoon.Component.DataEntry.PinInput
      import PhoenixDuskmoon.Component.DataEntry.Rating
      import PhoenixDuskmoon.Component.DataEntry.Radio
      import PhoenixDuskmoon.Component.DataEntry.SegmentControl
      import PhoenixDuskmoon.Component.DataEntry.Select
      import PhoenixDuskmoon.Component.DataEntry.Slider
      import PhoenixDuskmoon.Component.DataEntry.Switch
      import PhoenixDuskmoon.Component.DataEntry.Textarea
      import PhoenixDuskmoon.Component.DataEntry.TreeSelect
      import PhoenixDuskmoon.Component.DataEntry.TimeInput

      # Feedback components
      import PhoenixDuskmoon.Component.Feedback.Dialog
      import PhoenixDuskmoon.Component.Feedback.Loading
      import PhoenixDuskmoon.Component.Feedback.Toast
      import PhoenixDuskmoon.Component.Feedback.Snackbar

      # Navigation components
      import PhoenixDuskmoon.Component.Navigation.Actionbar
      import PhoenixDuskmoon.Component.Navigation.Appbar
      import PhoenixDuskmoon.Component.Navigation.BottomNav
      import PhoenixDuskmoon.Component.Navigation.Breadcrumb
      import PhoenixDuskmoon.Component.Navigation.LeftMenu
      import PhoenixDuskmoon.Component.Navigation.Navbar
      import PhoenixDuskmoon.Component.Navigation.NestedMenu
      import PhoenixDuskmoon.Component.Navigation.PageFooter
      import PhoenixDuskmoon.Component.Navigation.PageHeader
      import PhoenixDuskmoon.Component.Navigation.Steps
      import PhoenixDuskmoon.Component.Navigation.Stepper
      import PhoenixDuskmoon.Component.Navigation.Tab

      # Layout components
      import PhoenixDuskmoon.Component.Layout.BottomSheet
      import PhoenixDuskmoon.Component.Layout.Divider
      import PhoenixDuskmoon.Component.Layout.Drawer
      import PhoenixDuskmoon.Component.Layout.ThemeSwitcher

      # Icon components
      import PhoenixDuskmoon.Component.Icon.Icons

      # CSS Art components
      import PhoenixDuskmoon.CssArt.ButtonNoise
      import PhoenixDuskmoon.CssArt.Eclipse
      import PhoenixDuskmoon.CssArt.PlasmaBall
      import PhoenixDuskmoon.CssArt.Signature
      import PhoenixDuskmoon.CssArt.Snow
      import PhoenixDuskmoon.CssArt.SpotlightSearch
    end
  end

  @doc false
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  defmacro __using__(_) do
    quote do
      unquote(component())
    end
  end
end
