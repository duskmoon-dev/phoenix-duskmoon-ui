defmodule PhoenixDuskmoon.Component.DataDisplay.Badge do
  @moduledoc """
  Badge component for status indicators and labels.

  Uses the `el-dm-badge` custom element from duskmoon-elements.

  ## Examples

      <.dm_badge>New</.dm_badge>

      <.dm_badge variant="success">Active</.dm_badge>

      <.dm_badge variant="error" size="lg">Error</.dm_badge>

      <.dm_badge variant="warning" outline>Warning</.dm_badge>

  ## Attributes

  * `variant` - Badge variant: primary, secondary, accent, info, success, warning, error, ghost, neutral (default: primary)
  * `size` - Badge size: xs, sm, md, lg (default: md)
  * `outline` - Show outline style (default: false)
  * `class` - Additional CSS classes

  ## Slots

  * `:inner_block` - Badge content (required)
  """

  use Phoenix.Component

  @doc type: :component
  attr(:variant, :string,
    default: "primary",
    values: [
      "primary",
      "secondary",
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
  attr(:pill, :boolean, default: false, doc: "use pill (rounded) shape")
  attr(:dot, :boolean, default: false, doc: "show as a dot indicator only")
  attr(:class, :string, default: nil, doc: "additional CSS classes")
  attr(:rest, :global)

  slot(:inner_block, required: true)

  def dm_badge(assigns) do
    ~H"""
    <el-dm-badge
      variant={@variant}
      size={@size}
      outline={@outline}
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
