defmodule PhoenixDuskmoon.Component.Navigation.Actionbar do
  @moduledoc """
  Actionbar component for toolbar layouts.

  ## Examples

      <.dm_actionbar>
        <:left>Title</:left>
        <:right><button>Action</button></:right>
      </.dm_actionbar>

  """
  use Phoenix.Component

  @doc """
  Generates an actionbar.

  ## Examples

      <.dm_actionbar class="shadow">
        <:left>Star Wars</:left>
        <:right><button>open</button></:right>
        <:right><button>show</button></:right>
      </.dm_actionbar>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "Additional CSS classes")
  attr(:left_class, :any, default: nil, doc: "Left part CSS class")
  attr(:right_class, :any, default: nil, doc: "Right part CSS class")
  attr(:toolbar_label, :string, default: "Actions", doc: "Accessible label for the toolbar")
  attr(:rest, :global)

  slot(:left, required: false, doc: "Left part of action bar") do
    attr(:id, :any)
    attr(:class, :any)
  end

  slot(:right, required: false, doc: "Right part of action bar") do
    attr(:id, :any)
    attr(:class, :any)
  end

  def dm_actionbar(assigns) do
    ~H"""
    <div id={@id} role="toolbar" aria-label={@toolbar_label} class={["dm-actionbar", @class]} {@rest}>
      <div class={["dm-actionbar__left", @left_class]}>
        <div
          :for={left <- @left}
          id={Map.get(left, :id)}
          class={Map.get(left, :class)}
        >
          {render_slot(left)}
        </div>
      </div>
      <div class={["dm-actionbar__right", @right_class]}>
        <div
          :for={right <- @right}
          id={Map.get(right, :id)}
          class={Map.get(right, :class)}
        >
          {render_slot(right)}
        </div>
      </div>
    </div>
    """
  end
end
