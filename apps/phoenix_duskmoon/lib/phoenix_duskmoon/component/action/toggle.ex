defmodule PhoenixDuskmoon.Component.Action.Toggle do
  @moduledoc """
  Toggle button component using `@duskmoon-dev/core` CSS classes.

  Renders toggle buttons that can be used individually or in groups
  for selecting one or multiple options. Different from `dm_switch`
  (which is a form on/off control) — toggle buttons are action buttons
  with an active/inactive visual state.

  ## Examples

      <.dm_toggle_group>
        <:item active>Bold</:item>
        <:item>Italic</:item>
        <:item>Underline</:item>
      </.dm_toggle_group>

      <.dm_toggle_group variant="segmented" color="secondary">
        <:item active value="left" icon="format-align-left" />
        <:item value="center" icon="format-align-center" />
        <:item value="right" icon="format-align-right" />
      </.dm_toggle_group>

  """

  use Phoenix.Component
  import PhoenixDuskmoon.Component.Icon.Icons

  @doc """
  Renders a group of toggle buttons.

  ## Examples

      <.dm_toggle_group>
        <:item active>Option A</:item>
        <:item>Option B</:item>
      </.dm_toggle_group>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")

  attr(:variant, :string,
    default: nil,
    values: [nil, "segmented", "outlined", "filled", "chip"],
    doc: "Visual style variant"
  )

  attr(:color, :string,
    default: nil,
    values: [nil, "secondary", "tertiary", "accent"],
    doc: "Color variant"
  )

  attr(:size, :string,
    default: nil,
    values: [nil, "sm", "lg"],
    doc: "Size variant"
  )

  attr(:vertical, :boolean, default: false, doc: "Vertical layout")
  attr(:exclusive, :boolean, default: false, doc: "Only one item can be active (radio-like)")
  attr(:full, :boolean, default: false, doc: "Full width")
  attr(:label, :string, default: nil, doc: "Accessible label for the toggle group (aria-label)")
  attr(:rest, :global)

  slot(:item, required: true, doc: "Toggle button items") do
    attr(:active, :boolean, doc: "Whether this item is active/selected")
    attr(:disabled, :boolean, doc: "Whether this item is disabled")
    attr(:value, :string, doc: "Value for this toggle")
    attr(:icon, :string, doc: "MDI icon name")
    attr(:icon_only, :boolean, doc: "Icon-only button (no text)")
    attr(:class, :string, doc: "Additional CSS classes")
  end

  def dm_toggle_group(assigns) do
    assigns = assign(assigns, :color, css_color(assigns.color))

    ~H"""
    <div
      id={@id}
      class={[
        "toggle-group",
        @vertical && "toggle-group-vertical",
        @exclusive && "toggle-group-exclusive",
        @full && "toggle-group-full",
        @variant && "toggle-#{@variant}",
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
          "toggle-btn",
          item[:active] && "toggle-btn-active",
          item[:disabled] && "toggle-btn-disabled",
          item[:icon_only] && "toggle-btn-icon-only",
          @color && "toggle-btn-#{@color}",
          @size && "toggle-btn-#{@size}",
          item[:class]
        ]}
        disabled={item[:disabled]}
        value={item[:value]}
        aria-pressed={to_string(item[:active] || false)}
      >
        <.dm_mdi :if={item[:icon]} name={item[:icon]} class="toggle-icon" />
        {render_slot(item)}
      </button>
    </div>
    """
  end

  defp css_color("accent"), do: "tertiary"
  defp css_color(color), do: color
end
