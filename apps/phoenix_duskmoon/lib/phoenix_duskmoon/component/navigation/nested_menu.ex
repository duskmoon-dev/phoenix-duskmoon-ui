defmodule PhoenixDuskmoon.Component.Navigation.NestedMenu do
  @moduledoc """
  Nested menu component using `@duskmoon-dev/core` CSS classes.

  Renders a vertical navigation menu with collapsible sub-menus using
  native HTML `<details>/<summary>` elements. Supports titles, links,
  active states, and disabled items.

  ## Examples

      <.dm_nested_menu>
        <:title>Navigation</:title>
        <:item to="/dashboard" active>Dashboard</:item>
        <:item to="/settings">Settings</:item>
        <:group title="Reports">
          <:item to="/reports/sales">Sales</:item>
          <:item to="/reports/users">Users</:item>
        </:group>
      </.dm_nested_menu>

  """

  use Phoenix.Component

  @doc """
  Renders a nested navigation menu.

  ## Examples

      <.dm_nested_menu>
        <:item to="/">Home</:item>
        <:item to="/about">About</:item>
      </.dm_nested_menu>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")

  attr(:size, :string,
    default: nil,
    values: [nil, "xs", "sm", "lg"],
    doc: "Size variant"
  )

  attr(:bordered, :boolean, default: false, doc: "Bordered panel style")
  attr(:compact, :boolean, default: false, doc: "Compact padding")

  attr(:nav_label, :string,
    default: "Navigation menu",
    doc: "Accessible label for the nav element"
  )

  attr(:rest, :global)

  slot(:title, doc: "Menu section title")

  slot(:item, doc: "Menu items") do
    attr(:to, :string, doc: "Navigation link href")
    attr(:active, :boolean, doc: "Whether this item is active")
    attr(:disabled, :boolean, doc: "Whether this item is disabled")
  end

  slot(:group, doc: "Collapsible sub-menu groups") do
    attr(:title, :string, required: true, doc: "Group title")
    attr(:open, :boolean, doc: "Whether the group is initially open")
  end

  def dm_nested_menu(assigns) do
    ~H"""
    <nav
      id={@id}
      class={[
        "nested-menu",
        @size && "nested-menu-#{@size}",
        @bordered && "nested-menu-bordered",
        @compact && "nested-menu-compact",
        @class
      ]}
      aria-label={@nav_label}
      {@rest}
    >
      <ul>
        <li :for={t <- @title} class="nested-menu-title">{render_slot(t)}</li>
        <li :for={item <- @item} class={[item[:disabled] && "disabled"]}>
          <a
            href={item[:to]}
            class={[item[:active] && "active"]}
            aria-current={item[:active] && "page"}
          >
            {render_slot(item)}
          </a>
        </li>
        <li :for={group <- @group}>
          <details open={group[:open]}>
            <summary>{group[:title]}</summary>
            <ul>
              {render_slot(group)}
            </ul>
          </details>
        </li>
      </ul>
    </nav>
    """
  end

  @doc """
  Renders a nested menu item inside a group slot.

  Use inside the `:group` slot of `dm_nested_menu`.

  ## Examples

      <:group title="Section">
        <.dm_nested_menu_item to="/page">Page</.dm_nested_menu_item>
      </:group>

  """
  @doc type: :component
  attr(:to, :string, default: nil, doc: "Navigation link href")
  attr(:active, :boolean, default: false, doc: "Whether this item is active")
  attr(:disabled, :boolean, default: false, doc: "Whether this item is disabled")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def dm_nested_menu_item(assigns) do
    ~H"""
    <li class={[@disabled && "disabled"]}>
      <a href={@to} class={[@active && "active"]} aria-current={@active && "page"} {@rest}>
        {render_slot(@inner_block)}
      </a>
    </li>
    """
  end
end
