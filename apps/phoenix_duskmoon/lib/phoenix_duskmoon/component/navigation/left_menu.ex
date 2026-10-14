defmodule PhoenixDuskmoon.Component.Navigation.LeftMenu do
  @moduledoc """
  Menu component for navigation sidebars.

  Uses the `nested-menu` CSS component from `@duskmoon-dev/core` for styling.
  Supports collapsible groups via native `<details>`/`<summary>` elements.

  ## Examples

      <.dm_left_menu active="item1">
        <:title>Menu Title</:title>
        <:menu>
          <.dm_left_menu_group active="item1">
            <:title>Section</:title>
            <:menu id="item1" to="/page1">Page 1</:menu>
            <:menu id="item2" to="/page2">Page 2</:menu>
          </.dm_left_menu_group>
        </:menu>
      </.dm_left_menu>

  """
  use Phoenix.Component

  @doc """
  Generates a left menu container using the nested-menu CSS component.

  This component provides the `<nav>` wrapper and `<ul class="nested-menu">`
  container. Use `dm_left_menu_group/1` inside the `:menu` slots for
  collapsible group sections.

  ## Examples

      <.dm_left_menu class="w-64" active="actionbar">
        <:title class="uppercase">Phx WebComponents</:title>
        <:menu>
          <.dm_left_menu_group active="actionbar">
            <:title>Navigation</:title>
            <:menu id="actionbar" to="/actionbar">Actionbar</:menu>
            <:menu id="appbar" to="/appbar">Appbar</:menu>
          </.dm_left_menu_group>
        </:menu>
      </.dm_left_menu>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "Additional CSS classes")

  attr(:size, :string,
    default: "md",
    values: ["xs", "sm", "md", "lg"],
    doc: "Menu size variant"
  )

  attr(:active, :string, default: "", doc: "Active menu id (passed to child groups)")
  attr(:nav_label, :string, default: "Navigation menu", doc: "Accessible label for the menu nav")
  attr(:rest, :global)

  slot(:title, required: false, doc: "Menu title displayed as a section heading") do
    attr(:class, :any, doc: "title CSS classes")
  end

  slot(:menu, required: false, doc: "Menu content, typically dm_left_menu_group components")

  def dm_left_menu(assigns) do
    ~H"""
    <nav id={@id} class={@class} aria-label={@nav_label} {@rest}>
      <ul role="list" class={[
        "nested-menu",
        nested_menu_size(@size)
      ]}>
        <li
          :for={title <- @title}
          class={["nested-menu-title", title[:class]]}
        >
          {render_slot(title)}
        </li>
        {render_slot(@menu)}
      </ul>
    </nav>
    """
  end

  defp nested_menu_size("xs"), do: "nested-menu-xs"
  defp nested_menu_size("sm"), do: "nested-menu-sm"
  defp nested_menu_size("lg"), do: "nested-menu-lg"
  defp nested_menu_size(_), do: nil

  @doc """
  Generates a collapsible menu group using `<details>`/`<summary>`.

  Renders as a `<details>` element with menu items as links inside.
  Designed to be used inside `dm_left_menu/1`.

  Menu slots forward dynamically spread attributes to their navigation anchors,
  including the trigger attributes yielded by `dm_tooltip/1`. For explicit global
  attributes, use `rest={%{"aria-label" => "Dashboard"}}` on the menu slot.
  Values in `rest` take precedence over equivalent dynamically spread attributes.
  The slot's `id` identifies the active item; an HTML id can be supplied in `rest`.
  Navigation, classes, active/disabled ARIA state, and disabled keyboard behavior
  remain controlled by the menu component.

  ## Examples

      <.dm_left_menu_group active="mdi">
        <:title>Icons</:title>
        <:menu id="mdi" to={~p"/icons/mdi"}>MD Icon</:menu>
        <:menu id="bsi" to={~p"/icons/bsi"}>BS Icon</:menu>
      </.dm_left_menu_group>

      <.dm_tooltip id="dashboard-hint" content="Dashboard" position="right" :let={trigger_attrs}>
        <.dm_left_menu_group active="dashboard">
          <:title>Overview</:title>
          <:menu id="dashboard" to="/admin/dashboard" {trigger_attrs}>Dashboard</:menu>
        </.dm_left_menu_group>
      </.dm_tooltip>

      <.dm_left_menu_group open={false}>
        <:title>Settings</:title>
        <:menu id="profile" to={~p"/settings/profile"}>Profile</:menu>
        <:menu id="security" to={~p"/settings/security"}>Security</:menu>
      </.dm_left_menu_group>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "Additional CSS classes")
  attr(:open, :boolean, default: true, doc: "Whether the group is expanded")
  attr(:active, :string, default: "", doc: "Active menu item id")
  attr(:rest, :global)

  slot(:title, required: true, doc: "Group title shown in the summary element") do
    attr(:class, :any, doc: "title CSS classes")
  end

  slot(:menu, required: false, doc: "Menu item") do
    attr(:id, :string, doc: "menu item identifier for active matching")
    attr(:class, :any, doc: "menu item CSS classes")
    attr(:to, :string, doc: "navigation path")
    attr(:disabled, :boolean, doc: "disable the menu item")
    attr(:rest, :map, doc: "Global HTML attributes for the navigation anchor")
  end

  def dm_left_menu_group(assigns) do
    ~H"""
    <details id={@id} class={@class} open={@open} {@rest}>
      <summary class={List.first(@title)[:class]}>
        {render_slot(List.first(@title))}
      </summary>
      <ul role="list">
        <li
          :for={m <- @menu}
          class={[m[:disabled] && "disabled"]}
        >
          <.link
            {menu_link_attrs(m)}
            navigate={m[:to]}
            class={[
              m[:class],
              m[:id] == @active && @active != "" && "active"
            ]}
            aria-current={m[:id] == @active && @active != "" && "page"}
            aria-disabled={m[:disabled] && "true"}
          >
            {render_slot(m)}
          </.link>
        </li>
      </ul>
    </details>
    """
  end

  defp menu_link_attrs(menu) do
    attrs =
      menu
      |> Map.drop([
        :__changed__,
        :__slot__,
        :__given__,
        :inner_block,
        :id,
        :class,
        :to,
        :disabled,
        :rest
      ])
      |> Map.new(fn {key, value} -> {to_string(key), value} end)
      |> Map.merge(Map.new(menu[:rest] || %{}, fn {key, value} -> {to_string(key), value} end))
      |> Map.drop(
        ~w(class navigate patch href aria-current aria-disabled data-phx-link data-phx-link-state)
      )

    if menu[:disabled], do: Map.put(attrs, "tabindex", "-1"), else: attrs
  end
end
