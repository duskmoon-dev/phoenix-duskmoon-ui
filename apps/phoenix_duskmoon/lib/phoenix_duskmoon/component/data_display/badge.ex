defmodule PhoenixDuskmoon.Component.DataDisplay.Badge do
  @moduledoc """
  Badge component for status indicators and labels.

  Uses the `el-dm-badge` custom element from duskmoon-elements.

  ## Examples

      <.dm_badge>New</.dm_badge>

      <.dm_badge variant="success">Active</.dm_badge>

      <.dm_badge variant="error" size="lg">Error</.dm_badge>

      <.dm_badge variant="warning" outline>Warning</.dm_badge>

      <.dm_badge variant="success" soft>Success</.dm_badge>

  ## Attributes

  * `variant` - Badge color: primary, secondary, tertiary, accent, info, success, warning, error, ghost, neutral (default: primary)
  * `size` - Badge size: xs, sm, md, lg (default: md)
  * `outline` - Show outline style (default: false)
  * `soft` - Show soft style with muted background (default: false)
  * `dot` - Show as a dot indicator only (default: false)
  * `class` - Additional CSS classes

  ## Slots

  * `:inner_block` - Badge content (required)
  """

  use Phoenix.Component
  import PhoenixDuskmoon.Component.Helpers, only: [css_color: 1]

  @doc """
  Renders a badge for status indicators and labels.

  ## Examples

      <.dm_badge>New</.dm_badge>
      <.dm_badge variant="success" size="sm">Active</.dm_badge>

  """
  @doc type: :component
  attr(:variant, :string,
    default: "primary",
    values: [
      "primary",
      "secondary",
      "tertiary",
      "accent",
      "info",
      "success",
      "warning",
      "error",
      "ghost",
      "neutral"
    ],
    doc: "badge color variant"
  )

  attr(:size, :string, default: "md", values: ["xs", "sm", "md", "lg"], doc: "badge size")
  attr(:outline, :boolean, default: false, doc: "show outline style")
  attr(:soft, :boolean, default: false, doc: "show soft style with muted background")
  attr(:pill, :boolean, default: false, doc: "use pill (rounded) shape")
  attr(:dot, :boolean, default: false, doc: "show as a dot indicator only")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:rest, :global)

  slot(:inner_block, required: true)

  def dm_badge(assigns) do
    element_variant =
      cond do
        assigns.soft -> "soft"
        assigns.outline -> "outlined"
        true -> nil
      end

    assigns =
      assigns
      |> assign(:element_color, css_color(assigns.variant))
      |> assign(:element_variant, element_variant)

    ~H"""
    <el-dm-badge
      color={@element_color}
      variant={@element_variant}
      size={@size}
      pill={@pill}
      dot={@dot}
      class={@class}
      {@rest}
    >
      {render_slot(@inner_block)}
    </el-dm-badge>
    """
  end
end
