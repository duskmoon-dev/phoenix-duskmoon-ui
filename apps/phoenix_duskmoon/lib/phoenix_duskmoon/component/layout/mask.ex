defmodule PhoenixDuskmoon.Component.Layout.Mask do
  @moduledoc """
  Clips decorative content to one of Core's six mask shapes.
  Provide alternative text on images and keep interactive content outside the clipped region.

      <.dm_mask shape="hexagon"><img src="/images/avatar.png" alt="Team avatar" /></.dm_mask>
  """
  use Phoenix.Component

  @doc "Renders clipped content without changing its accessibility attributes."
  @doc type: :component
  attr(:id, :any, default: nil)

  attr(:shape, :string,
    default: "squircle",
    values: ~w(circle squircle square diamond hexagon triangle)
  )

  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def dm_mask(assigns) do
    ~H"""
    <div id={@id} class={["mask", "mask-#{@shape}", @class]} {@rest}>{render_slot(@inner_block)}</div>
    """
  end
end
