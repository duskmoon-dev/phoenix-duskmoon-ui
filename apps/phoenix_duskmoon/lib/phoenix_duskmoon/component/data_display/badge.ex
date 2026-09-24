defmodule PhoenixDuskmoon.Component.DataDisplay.Badge do
  @moduledoc """
  Badge component for status indicators and labels.

  Uses native markup and `@duskmoon-dev/core` badge classes.
  `xs` retains the legacy default size; Core badges are already pill-shaped.

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

  slot(:inner_block, required: true, doc: "badge text or content")

  def dm_badge(assigns) do
    assigns = assign(assigns, :color, css_color(assigns.variant))

    ~H"""
    <span
      role="status"
      class={[
        "badge",
        if(@color == "ghost", do: "bg-transparent border border-transparent text-inherit", else: "badge-#{@color}"),
        "badge-#{if @size == "xs", do: "md", else: @size}",
        @soft && "badge-soft",
        !@soft && @outline && "badge-outlined",
        @pill && "rounded-full",
        @dot && "badge-dot",
        @class
      ]}
      {@rest}
    >
      <span :if={@dot} class="sr-only">{render_slot(@inner_block)}</span>
      <%= if !@dot do %>{render_slot(@inner_block)}<% end %>
    </span>
    """
  end
end
