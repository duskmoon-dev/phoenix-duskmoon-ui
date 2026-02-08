defmodule PhoenixDuskmoon.Component.Layout.Divider do
  @moduledoc """
  Divider component for separating content sections.

  This is a HEEX component using CSS custom properties from the theme.

  ## Examples

      <.dm_divider />

      <.dm_divider>Section Title</.dm_divider>

      <.dm_divider orientation="vertical" />

      <.dm_divider variant="primary" style="dashed">
        Settings
      </.dm_divider>

      <.dm_divider size="lg" variant="accent" />

  ## Attributes

  * `orientation` - Divider orientation: horizontal, vertical (default: horizontal)
  * `variant` - Divider color variant: base, primary, secondary, accent, info, success, warning, error (default: base)
  * `style` - Divider line style: solid, dashed, dotted (default: solid)
  * `size` - Divider thickness: xs, sm, md, lg (default: md)
  * `class` - Additional CSS classes

  ## Slots

  * `:inner_block` - Optional content to display in the divider
  """

  use Phoenix.Component

  @doc type: :component
  attr(:orientation, :string, default: "horizontal", values: ["horizontal", "vertical"])

  attr(:variant, :string,
    default: "base",
    values: ["base", "primary", "secondary", "accent", "info", "success", "warning", "error"]
  )

  attr(:style, :string, default: "solid", values: ["solid", "dashed", "dotted"])
  attr(:size, :string, default: "md", values: ["xs", "sm", "md", "lg"])
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:inner_block, required: false)

  def dm_divider(assigns) do
    ~H"""
    <div
      role="separator"
      aria-orientation={@orientation}
      class={[
        "dm-divider",
        "dm-divider--#{@orientation}",
        "dm-divider--#{@variant}",
        "dm-divider--#{@style}",
        "dm-divider--#{@size}",
        @class
      ]}
      {@rest}
    >
      <span :if={@inner_block != []} class="dm-divider__content">
        {render_slot(@inner_block)}
      </span>
    </div>
    """
  end
end
