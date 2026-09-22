defmodule PhoenixDuskmoon.Component.Action.Swap do
  @moduledoc """
  A native checkbox with two non-interactive visual indicators from Core.
  Checkbox state controls the display and participates in normal form submission and reset.

      <.dm_swap name="sound" label="Enable sound">
        <:on>Sound on</:on>
        <:off>Sound off</:off>
      </.dm_swap>
  """
  use Phoenix.Component

  @doc "Renders an accessible native checkbox and checked/unchecked visual slots."
  @doc type: :component
  attr(:id, :any, default: nil)
  attr(:name, :string, default: nil)
  attr(:value, :string, default: "true")
  attr(:label, :string, required: true)
  attr(:checked, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:rotate, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:rest, :global, include: ~w(form required))
  slot(:on, required: true)
  slot(:off, required: true)

  def dm_swap(assigns) do
    ~H"""
    <label class={["swap", @rotate && "swap-rotate", @class]}>
      <input id={@id} type="checkbox" class="swap-input" name={@name} value={@value} checked={@checked} disabled={@disabled} aria-label={@label} {@rest} />
      <span class="swap-on" aria-hidden="true">{render_slot(@on)}</span>
      <span class="swap-off" aria-hidden="true">{render_slot(@off)}</span>
    </label>
    """
  end
end
