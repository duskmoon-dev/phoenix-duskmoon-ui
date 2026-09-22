defmodule PhoenixDuskmoon.Component.Layout.Indicator do
  @moduledoc """
  Positions indicators around arbitrary content using logical Core CSS positions.

      <.dm_indicator>
        <:indicator><span class="badge">3</span></:indicator>
        <button type="button" class="btn">Inbox</button>
      </.dm_indicator>
  """
  use Phoenix.Component

  @doc "Renders an anchor and positioned indicator slots, preserving their supplied semantics."
  @doc type: :component
  attr(:id, :any, default: nil)
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  slot :indicator, required: true do
    attr(:vertical, :string, values: ~w(top middle bottom))
    attr(:horizontal, :string, values: ~w(start center end))
    attr(:class, :any)
  end

  def dm_indicator(assigns) do
    ~H"""
    <div id={@id} class={["indicator", @class]} {@rest}>
      {render_slot(@inner_block)}
      <span :for={item <- @indicator} class={["indicator-item", "indicator-#{item[:vertical] || "top"}", "indicator-#{item[:horizontal] || "end"}", item[:class]]}>
        {render_slot(item)}
      </span>
    </div>
    """
  end
end
