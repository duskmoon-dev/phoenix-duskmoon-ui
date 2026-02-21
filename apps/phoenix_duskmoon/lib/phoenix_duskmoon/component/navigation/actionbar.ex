defmodule PhoenixDuskmoon.Component.Navigation.Actionbar do
  @moduledoc """
  Actionbar component for toolbar layouts.

  ## Examples

      <.dm_actionbar>
        <:left>Title</:left>
        <:right><button type="button">Action</button></:right>
      </.dm_actionbar>

  """
  use Phoenix.Component

  @doc """
  Generates an actionbar.

  ## Examples

      <.dm_actionbar class="shadow">
        <:left>Star Wars</:left>
        <:right><button type="button">open</button></:right>
        <:right><button type="button">show</button></:right>
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
    attr(:id, :any, doc: "left section HTML id")
    attr(:class, :any, doc: "left section CSS classes")
  end

  slot(:right, required: false, doc: "Right part of action bar") do
    attr(:id, :any, doc: "right section HTML id")
    attr(:class, :any, doc: "right section CSS classes")
  end

  def dm_actionbar(assigns) do
    ~H"""
    <div
      id={@id}
      role="toolbar"
      aria-label={@toolbar_label}
      class={["appbar", @class]}
      {@rest}
    >
      <div class={["appbar-brand", @left_class]}>
        <div
          :for={left <- @left}
          id={left[:id]}
          class={left[:class]}
        >
          {render_slot(left)}
        </div>
      </div>
      <div class={["appbar-trailing", @right_class]}>
        <div
          :for={right <- @right}
          id={right[:id]}
          class={right[:class]}
        >
          {render_slot(right)}
        </div>
      </div>
    </div>
    """
  end
end
