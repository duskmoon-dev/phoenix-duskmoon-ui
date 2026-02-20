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

  attr(:size, :string, default: "md", values: ["xs", "sm", "md", "lg"], doc: "divider thickness")
  attr(:class, :string, default: nil, doc: "additional CSS classes")
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
        @inner_block != [] && "divider-text",
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
  defp divider_variant(_), do: nil
end
