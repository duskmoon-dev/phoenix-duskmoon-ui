defmodule PhoenixDuskmoon.Component.Badge do
  @moduledoc """
  Badge component for status indicators and labels.

  ## Examples

      <.dm_badge>New</.dm_badge>

      <.dm_badge color="success">Active</.dm_badge>

      <.dm_badge color="error" size="lg">Error</.dm_badge>

      <.dm_badge color="warning" outline>Warning</.dm_badge>

      <.dm_badge color="info" ghost>Info</.dm_badge>

  ## Attributes

  * `color` - Badge color: primary, secondary, accent, info, success, warning, error, ghost (default: primary)
  * `size` - Badge size: xs, sm, md, lg (default: md)
  * `outline` - Show outline style (default: false)
  * `ghost` - Show ghost style (default: false)
  * `class` - Additional CSS classes

  ## Slots

  * `:inner_block` - Badge content (required)
  """

  use Phoenix.Component

  @doc type: :component
  attr :color, :string, default: "primary", values: ["primary", "secondary", "accent", "info", "success", "warning", "error", "ghost"]
  attr :size, :string, default: "md", values: ["xs", "sm", "md", "lg"]
  attr :outline, :boolean, default: false
  attr :ghost, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  def dm_badge(assigns) do
    ~H"""
    <span
      class={[
        "badge",
        size_classes(@size),
        color_classes(@color, @outline, @ghost),
        @class
      ]}
      {@rest}
    >
      <slot />
    </span>
    """
  end

  defp size_classes("xs"), do: "badge-xs"
  defp size_classes("sm"), do: "badge-sm"
  defp size_classes("md"), do: "badge-md"
  defp size_classes("lg"), do: "badge-lg"

  defp color_classes(color, outline, ghost) when outline or ghost do
    cond do
      outline -> "badge-outline badge-#{color}"
      ghost -> "badge-ghost"
      true -> "badge-#{color}"
    end
  end

  defp color_classes("ghost", _outline, _ghost), do: "badge-ghost"
  defp color_classes(color, _outline, _ghost), do: "badge-#{color}"
end