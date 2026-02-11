defmodule PhoenixDuskmoon.Component.DataDisplay.Tooltip do
  @moduledoc """
  Tooltip component for displaying additional information on hover.

  ## Examples

      <.dm_tooltip content="Click to save changes">
        <.dm_btn variant="primary">Save</.dm_btn>
      </.dm_tooltip>

      <.dm_tooltip content="This action cannot be undone" position="bottom" color="warning">
        <.dm_btn variant="error">Delete</.dm_btn>
      </.dm_tooltip>

      <.dm_tooltip content="Press Ctrl+S to save" position="right" color="info">
        <.dm_mdi name="information" />
      </.dm_tooltip>

  ## Attributes

  * `content` - Tooltip text content (required)
  * `position` - Tooltip position: top, bottom, left, right (default: top)
  * `color` - Tooltip color: primary, secondary, accent, info, success, warning, error (default: primary)
  * `open` - Force tooltip to be open
  * `class` - Additional CSS classes

  ## Slots

  * `:inner_block` - Content that triggers the tooltip (required)
  """

  use Phoenix.Component

  @doc """
  Renders a tooltip that appears on hover over the child element.

  ## Examples

      <.dm_tooltip content="Save changes"><.dm_btn>Save</.dm_btn></.dm_tooltip>
      <.dm_tooltip content="Warning" position="bottom" color="warning">Hover me</.dm_tooltip>
  """
  @doc type: :component
  attr(:content, :string, required: true)
  attr(:position, :string, default: "top", values: ["top", "bottom", "left", "right"])

  attr(:color, :string,
    default: "primary",
    values: ["primary", "secondary", "accent", "info", "success", "warning", "error"]
  )

  attr(:open, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:inner_block, required: true)

  def dm_tooltip(assigns) do
    ~H"""
    <div
      class={[
        "tooltip",
        "tooltip-#{@position}",
        "tooltip-#{@color}",
        @open && "tooltip-open",
        @class
      ]}
      role="tooltip"
      data-tip={@content}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
