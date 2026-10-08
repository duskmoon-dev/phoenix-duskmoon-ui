defmodule PhoenixDuskmoon.Component.DataDisplay.Tooltip do
  @moduledoc """
  Tooltip component using a native hint popover and interest invoker.

  The inner block receives attributes that must be spread onto the trigger.

  ## CSS compatibility and migration

  The current package pins `@duskmoon-dev/core` 1.20.3 and renders the native
  `.tooltip[popover]` contract. Use the bundled CSS or the Core version declared
  by the installed package. Legacy 9.12.x tooltip wrappers and `.tooltip-content`
  markup are incompatible with this CSS; upgrade the component and CSS together.

  Replace a text-only inner block with a native button or anchor and spread the
  slot attributes onto it. Put trigger attributes such as `tabindex` on that
  element, not on `dm_tooltip`: global attributes on the component belong to the
  tooltip surface. A closed hint popover stays outside normal layout; the
  browser owns hover and keyboard-focus visibility. The slot's `title` provides
  a native fallback in browsers without interest-invoker support.

  ## Examples

      <.dm_tooltip id="save-help" content="Click to save changes" :let={trigger_attrs}>
        <.dm_btn {trigger_attrs}>Save</.dm_btn>
      </.dm_tooltip>

      <.dm_tooltip id="ttft-help" content="Time until the first generated token." :let={attrs}>
        <button type="button" {attrs}>TTFT</button>
      </.dm_tooltip>

      <.dm_tooltip id="delete-help" content="Delete" :let={attrs}>
        <.dm_btn id="delete-record" {attrs} aria-label="Delete record"
          confirm="Delete this record?" phx-click="delete" phx-value-id="123">
          Delete
        </.dm_btn>
      </.dm_tooltip>

  Confirmation buttons keep tooltip targeting and anchor styles on the visible
  trigger, while `phx-click` and `phx-value-*` stay on the confirmed action.

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
