defmodule PhoenixDuskmoon.Component.Navigation.Megamenu do
  @moduledoc """
  Native popover navigation composition styled by Core's megamenu contract.
  Use ordinary links inside groups; the browser owns opening, Escape dismissal
  and light dismissal. No application hook or menu keyboard model is required.
  """
  use Phoenix.Component

  @doc """
  Renders a trigger and an anchored navigation panel with responsive columns.

  Each instance requires a unique `id`. Trigger content must not contain other
  interactive elements. Panel content remains reachable in browsers without
  Popover API support through the upstream CSS fallback.

      <.dm_megamenu id="products">
        <:trigger>Products</:trigger>
        <:group title="Workspace">
          <ul class="menu"><li><a class="link" href="/projects">Projects</a></li></ul>
        </:group>
      </.dm_megamenu>
  """
  @doc type: :component
  attr(:id, :string, required: true)
  attr(:class, :any, default: nil)
  attr(:full, :boolean, default: false)
  attr(:panel_class, :any, default: nil)
  attr(:rest, :global)
  slot(:trigger, required: true)

  slot :group, required: true do
    attr(:title, :string, required: true)
  end

  def dm_megamenu(assigns) do
    assigns = assign(assigns, :anchor, "--dm-megamenu-" <> Base.encode16(assigns.id))

    ~H"""
    <div id={@id} class={["megamenu", @class]} {@rest}>
      <button
        id={"#{@id}-trigger"}
        type="button"
        class="megamenu-trigger"
        popovertarget={"#{@id}-panel"}
        popovertargetaction="toggle"
        aria-controls={"#{@id}-panel"}
        style={"--megamenu-anchor: #{@anchor}"}
      >
        {render_slot(@trigger)}
      </button>
      <nav
        id={"#{@id}-panel"}
        popover="auto"
        class={["megamenu-panel", @full && "megamenu-panel-full", @panel_class]}
        aria-labelledby={"#{@id}-trigger"}
        style={"--megamenu-anchor: #{@anchor}"}
      >
        <div class="megamenu-grid">
          <div :for={group <- @group} class="megamenu-group">
            <h2 class="megamenu-heading">{group.title}</h2>
            {render_slot(group)}
          </div>
        </div>
      </nav>
    </div>
    """
  end
end
