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
  * `variant` - Divider color variant: base, primary, secondary, tertiary, accent, info, success, warning, error (default: base)
  * `style` - Divider line style: solid, dashed, dotted (default: solid)
  * `size` - Divider thickness: xs, sm, md, lg (default: md)
  * `class` - Additional CSS classes

  ## Slots

  * `:inner_block` - Optional content to display in the divider
  """

  use Phoenix.Component

  @doc """
  Renders a divider for separating content sections.

  ## Examples

      <.dm_divider />
      <.dm_divider orientation="vertical" />
      <.dm_divider variant="primary">Section</.dm_divider>
  """
  @doc type: :component
  attr(:orientation, :string,
    default: "horizontal",
    values: ["horizontal", "vertical"],
    doc: "divider orientation"
  )

  attr(:variant, :string,
    default: "base",
    values: [
      "base",
      "primary",
      "secondary",
      "light",
      "dark",
      "tertiary",
      "accent",
      "info",
      "success",
      "warning",
      "error"
    ],
    doc: "divider color variant"
  )

  attr(:style, :string,
    default: "solid",
    values: ["solid", "dashed", "dotted"],
    doc: "line style"
  )

  attr(:size, :string,
    default: "md",
    values: ["xs", "sm", "md", "lg", "xl"],
    doc: "divider spacing size"
  )

  attr(:gradient, :boolean, default: false, doc: "use gradient divider style")

  attr(:inset, :string,
    default: nil,
    values: [nil, "left", "right", "both"],
    doc: "inset the divider from edges"
  )

  attr(:text_position, :string,
    default: nil,
    values: [nil, "left", "right"],
    doc: "position of text content within the divider"
  )

  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:rest, :global)

  slot(:inner_block, required: false)

  def dm_divider(assigns) do
    ~H"""
    <div
      role="separator"
      aria-orientation={@orientation}
      class={[
        "divider",
        @orientation == "vertical" && "divider-vertical",
        divider_variant(@variant),
        @style != "solid" && "divider-#{@style}",
        @size != "md" && "divider-#{@size}",
        @gradient && "divider-gradient",
        inset_class(@inset),
        @inner_block != [] && "divider-text",
        @inner_block != [] && text_position_class(@text_position),
        @class
      ]}
      {@rest}
    >
      <span :if={@inner_block != []} class="divider-text-content">
        {render_slot(@inner_block)}
      </span>
    </div>
    """
  end

  defp divider_variant("primary"), do: "divider-primary"
  defp divider_variant("secondary"), do: "divider-secondary"
  defp divider_variant("light"), do: "divider-light"
  defp divider_variant("dark"), do: "divider-dark"
  defp divider_variant(_), do: nil

  defp inset_class("left"), do: "divider-inset"
  defp inset_class("right"), do: "divider-inset-right"
  defp inset_class("both"), do: "divider-inset-both"
  defp inset_class(_), do: nil

  defp text_position_class("left"), do: "divider-text-left"
  defp text_position_class("right"), do: "divider-text-right"
  defp text_position_class(_), do: nil
end
