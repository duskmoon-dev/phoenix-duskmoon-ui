defmodule PhoenixDuskmoon.Component.Layout.Stack do
  @moduledoc """
  Overlaps arbitrary children using Core's intrinsic grid stack.
  The first child is foremost. Mark decorative copies `aria-hidden` and `inert` when appropriate.

      <.dm_stack direction="end">
        <div class="card">Current card</div>
        <div class="card" aria-hidden="true" inert>Decorative card</div>
      </.dm_stack>
  """
  use Phoenix.Component

  @doc "Renders overlapping children in their original document order."
  @doc type: :component
  attr(:id, :any, default: nil)
  attr(:direction, :string, default: "bottom", values: ~w(top bottom start end))
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def dm_stack(assigns) do
    ~H"""
    <div id={@id} class={["stack", "stack-#{@direction}", @class]} {@rest}>{render_slot(@inner_block)}</div>
    """
  end
end
