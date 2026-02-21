defmodule PhoenixDuskmoon.Component.DataDisplay.Popover do
  @moduledoc """
  Popover component using `el-dm-popover` custom element.

  Displays floating content positioned relative to a trigger element.
  Supports click, hover, and focus triggers, auto-flip positioning,
  and an optional arrow indicator.

  ## Examples

      <.dm_popover>
        <:trigger>
          <button type="button" class="btn btn-primary">Click me</button>
        </:trigger>
        <p>Popover content here.</p>
      </.dm_popover>

      <.dm_popover trigger_mode="hover" placement="top" offset={12}>
        <:trigger>
          <span>Hover for info</span>
        </:trigger>
        <p>Helpful information.</p>
      </.dm_popover>

  """
  use Phoenix.Component

  @doc """
  Renders a popover with trigger and floating content.

  ## Examples

      <.dm_popover placement="right">
        <:trigger><button type="button" class="btn">Open</button></:trigger>
        Content here.
      </.dm_popover>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:open, :boolean, default: false, doc: "whether the popover is initially visible")

  attr(:trigger_mode, :string,
    default: "click",
    values: ["click", "hover", "focus"],
    doc: "how the popover is triggered"
  )

  attr(:placement, :string,
    default: "bottom",
    values: [
      "top",
      "bottom",
      "left",
      "right",
      "top-start",
      "top-end",
      "bottom-start",
      "bottom-end",
      "left-start",
      "left-end",
      "right-start",
      "right-end"
    ],
    doc: "preferred placement of the popover"
  )

  attr(:offset, :integer, default: 8, doc: "distance in pixels between trigger and popover")
  attr(:arrow, :boolean, default: true, doc: "show arrow pointing to trigger")
  attr(:rest, :global)

  slot(:trigger, required: true, doc: "The element that triggers the popover")
  slot(:inner_block, doc: "Popover content")

  def dm_popover(assigns) do
    ~H"""
    <el-dm-popover
      id={@id}
      open={@open}
      trigger={@trigger_mode}
      placement={@placement}
      offset={@offset}
      arrow={@arrow}
      class={@class}
      {@rest}
    >
      <div slot="trigger">
        {render_slot(@trigger)}
      </div>
      {render_slot(@inner_block)}
    </el-dm-popover>
    """
  end
end
