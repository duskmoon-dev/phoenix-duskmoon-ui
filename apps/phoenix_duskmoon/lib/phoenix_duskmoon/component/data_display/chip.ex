defmodule PhoenixDuskmoon.Component.DataDisplay.Chip do
  @moduledoc """
  Chip component for displaying tags, filters, or selections.

  Wraps the `<el-dm-chip>` custom element.

  ## Examples

      <.dm_chip>Default</.dm_chip>

      <.dm_chip color="primary" variant="filled">Primary</.dm_chip>

      <.dm_chip color="error" deletable>Remove me</.dm_chip>

      <.dm_chip color="success" selected>Active</.dm_chip>

  ## Attributes

  * `variant` - Chip variant: filled, outlined, soft (default: filled)
  * `color` - Chip color: primary, secondary, tertiary, success, warning, error, info
  * `size` - Chip size: sm, md, lg (default: md)
  * `deletable` - Whether the chip shows a delete button (default: false)
  * `selected` - Whether the chip is in selected state (default: false)
  * `disabled` - Whether the chip is disabled (default: false)
  * `class` - Additional CSS classes

  ## Slots

  * `:inner_block` - Chip label content (required)
  * `:icon` - Leading icon slot
  """

  use Phoenix.Component

  @doc """
  Renders a chip element.

  ## Examples

      <.dm_chip color="info">Tag</.dm_chip>
      <.dm_chip color="warning" variant="outlined" deletable>Filter</.dm_chip>
  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")

  attr(:variant, :string,
    default: "filled",
    values: ["filled", "outlined", "soft"],
    doc: "chip style variant"
  )

  attr(:color, :string,
    default: nil,
    values: [nil, "primary", "secondary", "tertiary", "success", "warning", "error", "info"],
    doc: "chip color"
  )

  attr(:size, :string, default: "md", values: ["sm", "md", "lg"], doc: "chip size")
  attr(:deletable, :boolean, default: false, doc: "show a delete button on the chip")
  attr(:selected, :boolean, default: false, doc: "mark the chip as selected")
  attr(:disabled, :boolean, default: false, doc: "disable the chip")
  attr(:rest, :global)

  slot(:inner_block, required: true, doc: "chip label text")
  slot(:icon)

  def dm_chip(assigns) do
    ~H"""
    <el-dm-chip
      id={@id}
      variant={@variant}
      color={@color}
      size={@size}
      deletable={@deletable}
      selected={@selected}
      disabled={@disabled}
      aria-disabled={@disabled && "true"}
      class={@class}
      {@rest}
    >
      <span :if={@icon != []} slot="icon">{render_slot(@icon)}</span>
      {render_slot(@inner_block)}
    </el-dm-chip>
    """
  end
end
