defmodule PhoenixDuskmoon.Component.Divider do
  @moduledoc """
  Divider component for separating content sections.

  ## Examples

      <.dm_divider />

      <.dm_divider>Section Title</.dm_divider>

      <.dm_divider orientation="vertical" />

      <.dm_divider color="primary" variant="dashed">
        Settings
      </.dm_divider>

      <.dm_divider size="lg" color="accent" />

  ## Attributes

  * `orientation` - Divider orientation: horizontal, vertical (default: horizontal)
  * `color` - Divider color: primary, secondary, accent, info, success, warning, error (default: base)
  * `variant` - Divider style: solid, dashed, dotted (default: solid)
  * `size` - Divider thickness: xs, sm, md, lg (default: md)
  * `class` - Additional CSS classes

  ## Slots

  * `:inner_block` - Optional content to display in the divider
  """

  use Phoenix.Component

  @doc type: :component
  attr(:orientation, :string, default: "horizontal", values: ["horizontal", "vertical"])

  attr(:color, :string,
    default: "base",
    values: ["base", "primary", "secondary", "accent", "info", "success", "warning", "error"]
  )

  attr(:variant, :string, default: "solid", values: ["solid", "dashed", "dotted"])
  attr(:size, :string, default: "md", values: ["xs", "sm", "md", "lg"])
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:inner_block, required: false)

  def dm_divider(assigns) do
    ~H"""
    <div
      class={[
        "divider",
        orientation_classes(@orientation),
        color_classes(@color),
        variant_classes(@variant),
        size_classes(@size),
        @class
      ]}
      {@rest}
    >
      <slot />
    </div>
    """
  end

  defp orientation_classes("horizontal"), do: "divider-horizontal"
  defp orientation_classes("vertical"), do: "divider-vertical"

  defp color_classes("base"), do: "divider-base"
  defp color_classes("primary"), do: "divider-primary"
  defp color_classes("secondary"), do: "divider-secondary"
  defp color_classes("accent"), do: "divider-accent"
  defp color_classes("info"), do: "divider-info"
  defp color_classes("success"), do: "divider-success"
  defp color_classes("warning"), do: "divider-warning"
  defp color_classes("error"), do: "divider-error"

  defp variant_classes("solid"), do: "divider-solid"
  defp variant_classes("dashed"), do: "divider-dashed"
  defp variant_classes("dotted"), do: "divider-dotted"

  defp size_classes("xs"), do: "divider-xs"
  defp size_classes("sm"), do: "divider-sm"
  defp size_classes("md"), do: "divider-md"
  defp size_classes("lg"), do: "divider-lg"
end
