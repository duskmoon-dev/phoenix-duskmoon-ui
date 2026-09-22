defmodule PhoenixDuskmoon.Component.Action.Fab do
  @moduledoc """
  Floating speed dial with a native popover and Invoker Commands trigger.
  Browser popover state owns opening, Escape, and light dismissal.
  Supply native buttons or links as actions; they retain application-owned behavior.

      <.dm_fab id="create-actions" label="Create">
        <:trigger>+</:trigger>
        <button type="button" class="btn btn-primary" phx-click="create">New document</button>
      </.dm_fab>
  """
  use Phoenix.Component

  @doc "Renders a floating trigger and a native popover containing related actions."
  @doc type: :component
  attr(:id, :string, required: true)
  attr(:label, :string, required: true)
  attr(:position, :string, default: "end", values: ~w(start end))
  attr(:extended, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:trigger_class, :any, default: nil)
  attr(:rest, :global)
  slot(:trigger, required: true)
  slot(:inner_block, required: true)

  def dm_fab(assigns) do
    ~H"""
    <div class={["fab fab-speed-dial", @position == "start" && "fab-start", @class]} {@rest}>
      <button id={"#{@id}-trigger"} type="button" class={["btn btn-primary fab-trigger", @extended && "fab-extended", @trigger_class]} command="toggle-popover" commandfor={@id} aria-label={@label} aria-controls={@id}>
        {render_slot(@trigger)}
      </button>
      <div id={@id} class="fab-actions" popover="auto" role="group" aria-label={@label}>
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end
end
