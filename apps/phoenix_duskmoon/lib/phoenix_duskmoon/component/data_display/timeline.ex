defmodule PhoenixDuskmoon.Component.DataDisplay.Timeline do
  @moduledoc """
  Timeline component for displaying chronological events.

  Uses CSS classes from `@duskmoon-dev/core` (no custom element).

  ## Examples

      <.dm_timeline>
        <:item title="Order Placed" time="Jan 1, 2026">
          Your order has been placed successfully.
        </:item>
        <:item title="Shipped" time="Jan 3, 2026" color="success">
          Package is on its way.
        </:item>
        <:item title="Delivered" time="Jan 5, 2026" color="success" completed>
          Package delivered.
        </:item>
      </.dm_timeline>

  """
  use Phoenix.Component

  import PhoenixDuskmoon.Component.Icon.Icons
  import PhoenixDuskmoon.Component.Helpers, only: [css_color: 1]

  @doc """
  Renders a timeline with chronological items.

  ## Examples

      <.dm_timeline>
        <:item title="Step 1">First step content.</:item>
        <:item title="Step 2" color="success" active>Current step.</:item>
      </.dm_timeline>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")

  attr(:size, :string,
    default: nil,
    values: [nil, "sm", "lg"],
    doc: "timeline size variant"
  )

  attr(:layout, :string,
    default: nil,
    values: [nil, "alternate", "right", "horizontal"],
    doc: "timeline layout variant"
  )

  attr(:rest, :global)

  slot(:item, required: true, doc: "Timeline item") do
    attr(:title, :string, doc: "Item title text")
    attr(:time, :string, doc: "Item time/date text")
    attr(:icon, :string, doc: "MDI icon name for the marker")

    attr(:color, :string, doc: "Item color: primary, secondary, success, warning, error")

    attr(:completed, :boolean, doc: "Mark item as completed")
    attr(:active, :boolean, doc: "Mark item as the current/active item")
    attr(:loading, :boolean, doc: "Show loading animation on marker")
    attr(:class, :any, doc: "Additional CSS classes for the item")
  end

  def dm_timeline(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "timeline",
        @size && "timeline-#{@size}",
        @layout && "timeline-#{@layout}",
        @class
      ]}
      role="list"
      {@rest}
    >
      <div
        :for={item <- @item}
        role="listitem"
        aria-current={item[:active] && "true"}
        class={[
          "timeline-item",
          item[:color] && "timeline-item-#{css_color(item[:color])}",
          item[:completed] && "completed",
          item[:active] && "active",
          item[:loading] && "loading",
          item[:class]
        ]}
      >
        <div class="timeline-marker">
          <.dm_mdi
            :if={item[:icon]}
            name={item[:icon]}
            class="timeline-marker-icon"
            aria-hidden="true"
          />
          <span :if={!item[:icon]} class="timeline-marker-dot" aria-hidden="true" />
        </div>
        <div class="timeline-content">
          <div :if={item[:title]} class="timeline-title">{item[:title]}</div>
          <div :if={item[:time]} class="timeline-time">{item[:time]}</div>
          <div class="timeline-description">{render_slot(item)}</div>
        </div>
      </div>
    </div>
    """
  end
end
