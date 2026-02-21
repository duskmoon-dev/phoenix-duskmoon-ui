defmodule PhoenixDuskmoon.Component.Action.Dropdown do
  @moduledoc """
  Dropdown menu component using the `popover` CSS from `@duskmoon-dev/core`.

  Uses the native HTML Popover API with CSS anchor positioning for
  click-to-toggle behavior without requiring JavaScript.

  ## Examples

      <.dm_dropdown>
        <:trigger>Menu</:trigger>
        <:content>
          <button class="popover-menu-item">Profile</button>
          <button class="popover-menu-item">Settings</button>
          <div class="popover-menu-divider"></div>
          <button class="popover-menu-item">Logout</button>
        </:content>
      </.dm_dropdown>

      <.dm_dropdown position="right" color="primary">
        <:trigger>Actions</:trigger>
        <:content>
          <button class="popover-menu-item" phx-click="edit">Edit</button>
          <button class="popover-menu-item" phx-click="delete">Delete</button>
        </:content>
      </.dm_dropdown>

  """

  use Phoenix.Component

  @doc """
  Renders a dropdown menu using the native Popover API with
  `@duskmoon-dev/core` popover CSS classes.

  The trigger is rendered as a `<button>` with `popovertarget`,
  providing native click-to-toggle and click-outside-to-dismiss
  behavior without JavaScript.

  ## Examples

      <.dm_dropdown>
        <:trigger>Click me</:trigger>
        <:content>
          <button class="popover-menu-item">Item 1</button>
        </:content>
      </.dm_dropdown>
  """
  @doc type: :component
  attr(:id, :any, default: false, doc: "HTML id attribute")

  attr(:position, :string,
    default: "bottom",
    values: ["left", "right", "top", "bottom"],
    doc: "Popover position relative to trigger"
  )

  attr(:color, :string,
    default: nil,
    doc: "Popover color variant (primary, secondary, tertiary)"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes on the wrapper")
  attr(:dropdown_class, :string, default: nil, doc: "Additional CSS classes on the popover panel")
  attr(:rest, :global)

  slot :trigger, required: true, doc: "Trigger content that toggles the dropdown" do
    attr(:class, :string)
  end

  slot :content, required: true, doc: "Dropdown panel content" do
    attr(:class, :string)
  end

  def dm_dropdown(assigns) do
    assigns = assign_new(assigns, :rid, fn -> Enum.random(0..999_999) end)

    popover_id =
      if assigns[:id] && assigns[:id] != false,
        do: "#{assigns[:id]}-popover",
        else: "dropdown-#{assigns.rid}"

    anchor_name = "--anchor-#{popover_id}"

    assigns =
      assigns
      |> assign(:popover_id, popover_id)
      |> assign(:anchor_name, anchor_name)

    ~H"""
    <div class={@class} {@rest}>
      <button
        :for={trigger <- @trigger}
        type="button"
        popovertarget={@popover_id}
        style={"anchor-name: #{@anchor_name}; appearance: none; background: none; border: none; padding: 0; margin: 0; cursor: pointer; display: inline-flex; font: inherit; color: inherit;"}
        class={trigger[:class]}
        aria-haspopup="menu"
        aria-expanded="false"
        aria-controls={@popover_id}
      >
        {render_slot(trigger)}
      </button>
      <div
        :for={content <- @content}
        id={@popover_id}
        popover
        ontoggle="this.classList.toggle('popover-show', this.matches(':popover-open')); var b=this.previousElementSibling; if(b) b.setAttribute('aria-expanded', this.matches(':popover-open'))"
        class={[
          "popover popover-menu",
          popover_position(@position),
          popover_color(@color),
          content[:class],
          @dropdown_class
        ]}
        style={"position-anchor: #{@anchor_name}"}
        role="menu"
      >
        {render_slot(content)}
      </div>
    </div>
    """
  end

  defp popover_position("bottom"), do: "popover-bottom"
  defp popover_position("top"), do: "popover-top"
  defp popover_position("left"), do: "popover-left"
  defp popover_position("right"), do: "popover-right"
  defp popover_position(_), do: "popover-bottom"

  defp popover_color("primary"), do: "popover-primary"
  defp popover_color("secondary"), do: "popover-secondary"
  defp popover_color("tertiary"), do: "popover-tertiary"
  defp popover_color(_), do: nil
end
