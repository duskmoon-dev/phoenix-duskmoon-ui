defmodule PhoenixDuskmoon.Component.Layout.Join do
  @moduledoc """
  Joins adjacent controls with Core CSS. Add `join-item` to each direct child;
  their native form and interaction semantics remain unchanged.
  Vertical joining is deferred until the upstream corner styling is corrected.

      <.dm_join label="Actions">
        <button type="button" class="btn join-item">Save</button>
        <button type="button" class="btn join-item">Preview</button>
      </.dm_join>
  """
  use Phoenix.Component

  @doc "Renders a labeled group of directly adjacent controls."
  @doc type: :component
  attr(:id, :any, default: nil)
  attr(:label, :string, required: true)
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  # TODO(upstream): duskmoon-dev/duskmoonui#63
  def dm_join(assigns) do
    ~H"""
    <div id={@id} class={["join join-horizontal", @class]} role="group" aria-label={@label} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end
end
