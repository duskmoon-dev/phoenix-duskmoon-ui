defmodule PhoenixDuskmoon.Component.DataEntry.SegmentControl do
  @moduledoc """
  Segment control component using CSS classes from `@duskmoon-dev/core`.

  Renders a group of mutually exclusive toggle buttons, commonly used for
  switching between views, filters, or modes.

  ## Examples

      <.dm_segment_control>
        <:item active>Day</:item>
        <:item>Week</:item>
        <:item>Month</:item>
      </.dm_segment_control>

      <.dm_segment_control color="primary" size="lg" full>
        <:item active icon="view-list">List</:item>
        <:item icon="view-grid">Grid</:item>
      </.dm_segment_control>

  """
  use Phoenix.Component

  import PhoenixDuskmoon.Component.Icon.Icons
  import PhoenixDuskmoon.Component.Helpers, only: [css_color: 1]

  @doc """
  Renders a segmented control group.

  ## Examples

      <.dm_segment_control variant="outlined">
        <:item active>Active</:item>
        <:item>Other</:item>
      </.dm_segment_control>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")

  attr(:size, :string,
    default: nil,
    values: [nil, "sm", "lg"],
    doc: "size variant"
  )

  attr(:color, :string,
    default: nil,
    values: [
      nil,
      "primary",
      "secondary",
      "tertiary",
      "accent",
      "info",
      "success",
      "warning",
      "error"
    ],
    doc: "color variant for active item"
  )

  attr(:variant, :string,
    default: nil,
    values: [nil, "outlined", "ghost"],
    doc: "visual style variant"
  )

  attr(:full, :boolean, default: false, doc: "expand to full width")
  attr(:icon_only, :boolean, default: false, doc: "icon-only mode (no text labels)")
  attr(:multi, :boolean, default: false, doc: "allow multiple selection")
  attr(:label, :string, default: nil, doc: "accessible label for the segment group (aria-label)")
  attr(:rest, :global)

  slot :item, required: true, doc: "Segment items" do
    attr(:active, :boolean)
    attr(:disabled, :boolean)
    attr(:icon, :string)
    attr(:value, :string)
    attr(:class, :any)
  end

  def dm_segment_control(assigns) do
    assigns = assign(assigns, :color, css_color(assigns.color))

    ~H"""
    <div
      id={@id}
      class={[
        "segment-control",
        @size && "segment-control-#{@size}",
        @color && "segment-control-#{@color}",
        @variant && "segment-control-#{@variant}",
        @full && "segment-control-full",
        @icon_only && "segment-control-icon-only",
        @multi && "segment-control-multi",
        @class
      ]}
      role="group"
      aria-label={@label}
      {@rest}
    >
      <button
        :for={item <- @item}
        type="button"
        class={[
          "segment-item",
          item[:active] && "segment-item-active",
          item[:disabled] && "segment-item-disabled",
          item[:class]
        ]}
        disabled={item[:disabled]}
        aria-disabled={item[:disabled] && "true"}
        value={item[:value]}
        aria-pressed={to_string(item[:active] || false)}
      >
        <.dm_mdi :if={item[:icon]} name={item[:icon]} class="segment-icon" />
        {render_slot(item)}
      </button>
    </div>
    """
  end
end
