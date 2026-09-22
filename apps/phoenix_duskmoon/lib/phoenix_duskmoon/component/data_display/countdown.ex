defmodule PhoenixDuskmoon.Component.DataDisplay.Countdown do
  @moduledoc """
  Displays an application-supplied countdown value using Core CSS.
  The application owns scheduling, units, and updates; this component creates no timer.

      <.dm_countdown value={42} label="Seconds remaining" />
  """
  use Phoenix.Component

  @doc "Renders a countdown value without announcing each tick to assistive technology."
  @doc type: :component
  attr(:id, :any, default: nil)
  attr(:value, :integer, required: true)
  attr(:label, :string, required: true)
  attr(:size, :string, default: "md", values: ~w(sm md lg))
  attr(:class, :any, default: nil)
  attr(:rest, :global)

  def dm_countdown(assigns) do
    ~H"""
    <span id={@id} class={["countdown", @size != "md" && "countdown-#{@size}", @class]} role="timer" aria-live="off" aria-label={@label} {@rest}>
      <span class="countdown-value">{@value}</span>
    </span>
    """
  end
end
