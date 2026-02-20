defmodule PhoenixDuskmoon.Component.Action.Menu do
  @moduledoc """
  Menu component using `el-dm-menu` and `el-dm-menu-item` custom elements.

  Renders a dropdown/context menu anchored to a trigger element with full
  keyboard navigation, proper ARIA roles, and click-outside dismissal.

  ## Examples

      <button id="actions-trigger" type="button" class="btn btn-primary">
        Actions
      </button>
      <.dm_menu anchor="#actions-trigger">
        <.dm_menu_item value="edit">Edit</.dm_menu_item>
        <.dm_menu_item value="copy">Copy</.dm_menu_item>
        <.dm_menu_item value="delete">Delete</.dm_menu_item>
      </.dm_menu>

      <button id="ctx-trigger" type="button" class="btn">
        Options
      </button>
      <.dm_menu anchor="#ctx-trigger" placement="bottom-end">
        <.dm_menu_item value="profile" icon="account">Profile</.dm_menu_item>
        <.dm_menu_item value="settings" icon="cog">Settings</.dm_menu_item>
        <.dm_menu_item value="logout" icon="logout" disabled>Logout</.dm_menu_item>
      </.dm_menu>

  """
  use Phoenix.Component

  import PhoenixDuskmoon.Component.Icon.Icons

  @doc """
  Renders a menu container using the `el-dm-menu` custom element.

  The menu is positioned relative to an anchor element specified by
  a CSS selector. Open/close is managed by the element's JS API
  (`show()`, `hide()`, `toggle()`) or the `open` attribute.

  ## Examples

      <button id="my-btn" type="button" class="btn">Open</button>
      <.dm_menu anchor="#my-btn" placement="bottom-start">
        <.dm_menu_item value="one">Item 1</.dm_menu_item>
        <.dm_menu_item value="two">Item 2</.dm_menu_item>
      </.dm_menu>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :string, default: nil, doc: "additional CSS classes")
  attr(:open, :boolean, default: false, doc: "whether the menu is initially visible")

  attr(:anchor, :string,
    default: nil,
    doc: "CSS selector of the anchor/trigger element"
  )

  attr(:placement, :string,
    default: "bottom-start",
    values: [
      "top",
      "bottom",
      "left",
      "right",
      "top-start",
      "top-end",
      "bottom-start",
      "bottom-end"
    ],
    doc: "preferred placement of the menu"
  )

  attr(:rest, :global)
  slot(:inner_block, required: true, doc: "Menu items")

  def dm_menu(assigns) do
    ~H"""
    <el-dm-menu
      id={@id}
      open={@open}
      anchor={@anchor}
      placement={@placement}
      class={@class}
      {@rest}
    >
      {render_slot(@inner_block)}
    </el-dm-menu>
    """
  end

  @doc """
  Renders an individual menu item using the `el-dm-menu-item` custom element.

  ## Examples

      <.dm_menu_item value="edit">Edit</.dm_menu_item>
      <.dm_menu_item value="settings" icon="cog">Settings</.dm_menu_item>
      <.dm_menu_item value="delete" disabled>Delete</.dm_menu_item>

  """
  @doc type: :component
  attr(:value, :string, default: nil, doc: "value emitted in the select event")
  attr(:disabled, :boolean, default: false, doc: "whether the item is disabled")
  attr(:icon, :string, default: nil, doc: "MDI icon name shown before content")
  attr(:class, :string, default: nil, doc: "additional CSS classes")
  attr(:rest, :global)
  slot(:inner_block, required: true, doc: "Item label content")

  def dm_menu_item(assigns) do
    ~H"""
    <el-dm-menu-item
      value={@value}
      disabled={@disabled}
      class={@class}
      {@rest}
    >
      <.dm_mdi :if={@icon} name={@icon} class="w-5 h-5" slot="icon" />
      {render_slot(@inner_block)}
    </el-dm-menu-item>
    """
  end
end
