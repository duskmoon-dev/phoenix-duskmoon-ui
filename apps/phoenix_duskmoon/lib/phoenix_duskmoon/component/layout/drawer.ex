defmodule PhoenixDuskmoon.Component.Layout.Drawer do
  @moduledoc """
  Drawer component using el-dm-drawer custom element.

  A sliding panel that can appear from the left or right side.

  ## Examples

      <.dm_drawer id="nav-drawer" open={@drawer_open}>
        <:header>Navigation</:header>
        <nav>Drawer content</nav>
        <:footer>
          <.dm_btn variant="ghost" phx-click="close_drawer">Close</.dm_btn>
        </:footer>
      </.dm_drawer>

      <.dm_drawer id="settings" position="right" modal>
        <:header>Settings</:header>
        Settings content here.
      </.dm_drawer>

  """

  use Phoenix.Component

  @doc """
  Renders a drawer panel.

  ## Examples

      <.dm_drawer id="my-drawer">
        <:header>Title</:header>
        Content
      </.dm_drawer>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "Additional CSS classes")
  attr(:open, :boolean, default: false, doc: "Whether the drawer is open")

  attr(:position, :string,
    default: "left",
    values: ["left", "right"],
    doc: "Side the drawer slides in from"
  )

  attr(:modal, :boolean, default: false, doc: "Show backdrop overlay and trap focus")
  attr(:width, :string, default: nil, doc: "Custom CSS width (e.g., '360px', '30vw')")
  attr(:label, :string, default: nil, doc: "Accessible label for the drawer (aria-label)")
  attr(:rest, :global)

  slot(:header, doc: "Drawer header content")
  slot(:inner_block, required: true, doc: "Drawer body content")
  slot(:footer, doc: "Drawer footer content")

  def dm_drawer(assigns) do
    ~H"""
    <el-dm-drawer
      id={@id}
      open={@open}
      position={@position}
      modal={@modal}
      width={@width}
      class={@class}
      role="complementary"
      aria-label={@label}
      {@rest}
    >
      <span :if={@header != []} slot="header">
        {render_slot(@header)}
      </span>
      {render_slot(@inner_block)}
      <span :if={@footer != []} slot="footer">
        {render_slot(@footer)}
      </span>
    </el-dm-drawer>
    """
  end
end
