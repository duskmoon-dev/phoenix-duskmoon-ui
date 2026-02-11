defmodule PhoenixDuskmoon.Component.Navigation.Navbar do
  @moduledoc """
  Navbar component for layout navigation.

  ## Examples

      <.dm_navbar>
        <:start_part>Logo</:start_part>
        <:center_part>Navigation</:center_part>
        <:end_part>Actions</:end_part>
      </.dm_navbar>

  """
  use Phoenix.Component

  @doc """
  Generates a navbar.

  ## Example

      <.dm_navbar>
        <:start_part>Logo</:start_part>
        <:center_part>Navigation</:center_part>
        <:end_part>User Menu</:end_part>
      </.dm_navbar>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "Additional CSS classes")
  attr(:start_class, :any, default: nil, doc: "Navbar left part container class")
  attr(:center_class, :any, default: nil, doc: "Navbar center part container class")
  attr(:end_class, :any, default: nil, doc: "Navbar right part container class")
  attr(:rest, :global)

  slot(:start_part, required: false, doc: "Navbar left part")
  slot(:center_part, required: false, doc: "Navbar center part")
  slot(:end_part, required: false, doc: "Navbar right part")

  def dm_navbar(assigns) do
    ~H"""
    <nav id={@id} class={["dm-navbar", @class]} aria-label="Main navigation" {@rest}>
      <div class={["dm-navbar__start", @start_class]}>
        {render_slot(@start_part)}
      </div>
      <div class={["dm-navbar__center", @center_class]}>
        {render_slot(@center_part)}
      </div>
      <div class={["dm-navbar__end", @end_class]}>
        {render_slot(@end_part)}
      </div>
    </nav>
    """
  end
end
