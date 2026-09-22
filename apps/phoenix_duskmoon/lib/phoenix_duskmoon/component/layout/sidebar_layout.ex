defmodule PhoenixDuskmoon.Component.Layout.SidebarLayout do
  @moduledoc """
  Persistent responsive sidebar composition backed by Core CSS.

  The sidebar is visible when the layout container is at least 48rem wide.
  Applications own mobile navigation, collapsed state and toggle controls.
  """
  use Phoenix.Component

  @doc """
  Renders a sidebar beside a flexible content region.

  `compact` uses the upstream compact width; `hidden` hides the sidebar at every
  size. Customize widths with `--sidebar-layout-width` and
  `--sidebar-layout-compact-width` on the root's `style` attribute.

      <.dm_sidebar_layout>
        <:sidebar><nav aria-label="Workspace">Navigation</nav></:sidebar>
        <main>Workspace content</main>
      </.dm_sidebar_layout>
  """
  @doc type: :component
  attr(:id, :string, default: nil)
  attr(:class, :any, default: nil)
  attr(:position, :string, default: "start", values: ["start", "end"])
  attr(:compact, :boolean, default: false)
  attr(:hidden, :boolean, default: false)
  attr(:sidebar_class, :any, default: nil)
  attr(:content_class, :any, default: nil)
  attr(:rest, :global)
  slot(:sidebar, required: true)
  slot(:inner_block, required: true)

  def dm_sidebar_layout(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "sidebar-layout",
        "sidebar-layout-#{@position}",
        @compact && "sidebar-layout-compact",
        @hidden && "sidebar-layout-hidden",
        @class
      ]}
      {@rest}
    >
      <aside class={["sidebar-layout-sidebar", @sidebar_class]}>
        {render_slot(@sidebar)}
      </aside>
      <div class={["sidebar-layout-content", @content_class]}>
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end
end
