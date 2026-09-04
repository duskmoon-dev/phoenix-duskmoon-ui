defmodule PhoenixDuskmoon.Component.DataDisplay.Tooltip do
  @moduledoc """
  Tooltip component using a native hint popover and interest invoker.

  The inner block receives attributes that must be spread onto the trigger.

  ## Examples

      <.dm_tooltip id="save-help" content="Click to save changes" :let={trigger_attrs}>
        <.dm_btn {trigger_attrs}>Save</.dm_btn>
      </.dm_tooltip>

  """

  use Phoenix.Component
  import PhoenixDuskmoon.Component.Helpers, only: [css_color: 1]

  @doc """
  Renders a native tooltip associated with an interest invoker.
  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id used as the tooltip id prefix")
  attr(:content, :string, required: true, doc: "tooltip text content")

  attr(:position, :string,
    default: "top",
    values: ["top", "bottom", "left", "right"],
    doc: "tooltip position relative to trigger"
  )

  attr(:color, :string,
    default: "primary",
    values: ["primary", "secondary", "tertiary", "accent", "info", "success", "warning", "error"],
    doc: "tooltip color variant"
  )

  attr(:open, :boolean,
    default: nil,
    doc: "optional server-controlled visibility; omit for browser-owned interest state"
  )

  attr(:class, :any, default: nil, doc: "additional CSS classes on the tooltip surface")
  attr(:rest, :global)

  slot(:inner_block, required: true, doc: "element the tooltip is attached to")

  def dm_tooltip(assigns) do
    id = assigns.id || "tooltip-#{System.unique_integer([:positive])}"
    tooltip_id = if assigns.id, do: "#{id}-tooltip", else: id
    anchor_name = "--anchor-#{tooltip_id}"

    assigns =
      assigns
      |> assign(:color, css_color(assigns.color))
      |> assign(:tooltip_id, tooltip_id)
      |> assign(:popover_mode, if(is_nil(assigns.open), do: "hint", else: "manual"))
      |> assign(:controlled_open, controlled_open(assigns.open))
      |> assign(:trigger_attrs, %{
        "aria-describedby" => tooltip_id,
        "interestfor" => tooltip_id,
        "style" => "anchor-name: #{anchor_name}",
        "title" => assigns.content
      })
      |> assign(:surface_style, "position-anchor: #{anchor_name}")

    ~H"""
    {render_slot(@inner_block, @trigger_attrs)}
    <span
      id={@tooltip_id}
      popover={@popover_mode}
      phx-hook="DuskmoonPopover"
      data-open={@controlled_open}
      class={["tooltip", "tooltip-#{@position}", "tooltip-#{@color}", @class]}
      style={@surface_style}
      role="tooltip"
      {@rest}
    >
      {@content}
    </span>
    """
  end

  defp controlled_open(nil), do: nil
  defp controlled_open(open), do: to_string(open)
end
