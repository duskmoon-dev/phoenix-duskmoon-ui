defmodule PhoenixDuskmoon.Component.DataDisplay.Kbd do
  @moduledoc """
  Semantic keyboard input styled by Core.

      <.dm_kbd>Ctrl</.dm_kbd> + <.dm_kbd>K</.dm_kbd>
  """
  use Phoenix.Component

  @doc "Renders a keyboard key or shortcut in a native kbd element."
  @doc type: :component
  attr(:id, :any, default: nil)
  attr(:size, :string, default: "md", values: ~w(xs sm md lg))
  attr(:ghost, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def dm_kbd(assigns) do
    ~H"""
    <kbd id={@id} class={["kbd", @size != "md" && "kbd-#{@size}", @ghost && "kbd-ghost", @class]} {@rest}>{render_slot(@inner_block)}</kbd>
    """
  end
end
