defmodule PhoenixDuskmoon.Component.Layout.BottomSheet do
  @moduledoc """
  Bottom sheet component using `el-dm-bottom-sheet` custom element.

  Renders a sliding panel from the bottom of the screen, commonly used for
  mobile-style action sheets, menus, or expandable content.

  ## Examples

      <.dm_bottom_sheet id="actions-sheet" modal>
        <:header>Select Action</:header>
        <p>Choose an option below.</p>
      </.dm_bottom_sheet>

      <.dm_bottom_sheet id="snap-sheet" snap_points="25,50,100">
        <p>Draggable content with snap points.</p>
      </.dm_bottom_sheet>

  """
  use Phoenix.Component

  @doc """
  Renders a bottom sheet panel.

  ## Examples

      <.dm_bottom_sheet id="my-sheet" open modal>
        <:header>Title</:header>
        Content here.
      </.dm_bottom_sheet>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :string, default: nil, doc: "additional CSS classes")
  attr(:open, :boolean, default: false, doc: "whether the sheet is visible")
  attr(:modal, :boolean, default: false, doc: "show backdrop and trap focus")
  attr(:persistent, :boolean, default: false, doc: "prevent dismiss via outside click or swipe")

  attr(:snap_points, :string,
    default: nil,
    doc: "comma-separated snap point heights in percentages (e.g., \"25,50,100\")"
  )

  attr(:rest, :global)
  slot(:header, doc: "Header content above the drag handle")
  slot(:inner_block, doc: "Main sheet content")

  def dm_bottom_sheet(assigns) do
    ~H"""
    <el-dm-bottom-sheet
      id={@id}
      open={@open}
      modal={@modal}
      persistent={@persistent}
      snap-points={@snap_points}
      class={@class}
      {@rest}
    >
      <div :if={@header != []} slot="header">
        {render_slot(@header)}
      </div>
      {render_slot(@inner_block)}
    </el-dm-bottom-sheet>
    """
  end
end
