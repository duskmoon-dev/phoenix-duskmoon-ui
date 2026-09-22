defmodule PhoenixDuskmoon.Component.DataDisplay.Carousel do
  @moduledoc """
  Native scroll-snap carousel styled by Core. Scrolling and focus remain browser-owned.

      <.dm_carousel label="Highlights">
        <:item label="First highlight">First slide</:item>
        <:item label="Second highlight">Second slide</:item>
      </.dm_carousel>
  """
  use Phoenix.Component

  @doc "Renders a keyboard-focusable scroll region with directly nested slide items."
  @doc type: :component
  attr(:id, :any, default: nil)
  attr(:label, :string, required: true)
  attr(:orientation, :string, default: "horizontal", values: ~w(horizontal vertical))
  attr(:align, :string, default: "start", values: ~w(start center end))
  attr(:class, :any, default: nil)
  attr(:rest, :global)

  slot :item, required: true do
    attr(:id, :string)
    attr(:label, :string)
    attr(:class, :any)
  end

  def dm_carousel(assigns) do
    ~H"""
    <div id={@id} class={["carousel", "carousel-#{@orientation}", "carousel-#{@align}", @class]} role="region" aria-roledescription="carousel" aria-label={@label} tabindex="0" {@rest}>
      <div :for={item <- @item} id={item[:id]} class={["carousel-item", item[:class]]} role="group" aria-roledescription="slide" aria-label={item[:label]}>
        {render_slot(item)}
      </div>
    </div>
    """
  end
end
