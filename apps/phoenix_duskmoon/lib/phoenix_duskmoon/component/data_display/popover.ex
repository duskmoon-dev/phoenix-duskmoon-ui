defmodule PhoenixDuskmoon.Component.DataDisplay.Popover do
  @moduledoc """
  Popover component using the native HTML Popover and Invoker Commands APIs.

  The trigger slot receives the attributes required to control the popover.
  Spread them onto a native invoker such as `dm_btn/1` or `<button>`.

  ## Examples

      <.dm_popover id="account-popover">
        <:trigger :let={trigger_attrs}>
          <.dm_btn {trigger_attrs}>Account</.dm_btn>
        </:trigger>
        <p>Popover content here.</p>
      </.dm_popover>

  """
  use Phoenix.Component

  @doc """
  Renders a native popover with its invoker attributes.
  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")

  attr(:open, :boolean,
    default: nil,
    doc: "optional server-controlled visibility; omit for browser-owned command state"
  )

  attr(:trigger_mode, :string,
    default: "click",
    values: ["click", "hover", "focus"],
    doc: "click uses command; hover and focus use interestfor"
  )

  attr(:placement, :string,
    default: "bottom",
    values: [
      "top",
      "bottom",
      "left",
      "right",
      "top-start",
      "top-end",
      "bottom-start",
      "bottom-end",
      "left-start",
      "left-end",
      "right-start",
      "right-end"
    ],
    doc: "preferred placement of the popover"
  )

  attr(:offset, :integer, default: 8, doc: "distance in pixels between trigger and popover")
  attr(:arrow, :boolean, default: true, doc: "show arrow pointing to trigger")
  attr(:rest, :global)

  slot(:trigger, required: true, doc: "The element that triggers the popover")
  slot(:inner_block, doc: "Popover content")

  def dm_popover(assigns) do
    id = assigns.id || "popover-#{System.unique_integer([:positive])}"
    anchor_name = "--anchor-#{id}"

    trigger_attrs =
      if assigns.trigger_mode == "click" do
        %{
          "aria-controls" => id,
          "command" => "toggle-popover",
          "commandfor" => id,
          "style" => "anchor-name: #{anchor_name}"
        }
      else
        %{
          "aria-controls" => id,
          "interestfor" => id,
          "style" => "anchor-name: #{anchor_name}"
        }
      end

    assigns =
      assigns
      |> assign(:id, id)
      |> assign(:trigger_attrs, trigger_attrs)
      |> assign(:popover_mode, if(is_nil(assigns.open), do: "auto", else: "manual"))
      |> assign(:controlled_open, controlled_open(assigns.open))
      |> assign(:position_classes, position_classes(assigns.placement))
      |> assign(:surface_style, "position-anchor: #{anchor_name}; margin: #{assigns.offset}px")

    ~H"""
    {render_slot(@trigger, @trigger_attrs)}
    <div
      id={@id}
      popover={@popover_mode}
      phx-hook="DuskmoonPopover"
      data-open={@controlled_open}
      class={[
        "popover",
        @position_classes,
        !@arrow && "popover-no-arrow",
        @class
      ]}
      style={@surface_style}
      {@rest}
    >
      <span :if={@arrow} class="popover-arrow" aria-hidden="true"></span>
      <div class="popover-body">{render_slot(@inner_block)}</div>
    </div>
    """
  end

  defp controlled_open(nil), do: nil
  defp controlled_open(open), do: to_string(open)

  defp position_classes(placement) do
    case String.split(placement, "-", parts: 2) do
      [position, alignment] -> ["popover-#{position}", "popover-#{alignment}"]
      [position] -> ["popover-#{position}"]
    end
  end
end
