defmodule PhoenixDuskmoon.Component.Navigation.LeftMenu do
  @moduledoc """
  Menu component for navigation sidebars.

  Uses the `nested-menu` CSS component from `@duskmoon-dev/core` for styling.
  Supports collapsible groups via native `<details>`/`<summary>` elements.

  Set `collapsible` with a stable `id` to enable the `DuskmoonLeftMenu` hook,
  an icon rail, a separate scrolling menu body and a bottom toggle. For shared
  navigation, `sticky socket={@socket} groups={@groups} active={@active}` also
  owns the persistent child LiveView and active-page synchronization. See the
  [left menu guide](left-menu.html) for CSS sticky positioning, sticky child
  LiveViews and preserving scroll position across navigation.

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
  import PhoenixDuskmoon.Component.DataDisplay.Tooltip, only: [dm_tooltip: 1]
  import PhoenixDuskmoon.Component.Icon.Icons, only: [dm_mdi: 1]

  @doc """
  Generates a left menu container using the nested-menu CSS component.

  This component provides the `<nav>` wrapper and `<ul class="nested-menu">`
  container. Use `dm_left_menu_group/1` inside the `:menu` slots for
  collapsible group sections.

  `collapsible` requires a stable `id` and registration of `DuskmoonLeftMenu`
  from `phoenix_duskmoon/hooks`. Its client owns collapse and group state after
  mounting; `collapsed` supplies the initial state. `storage_key` optionally
  persists collapse across reloads. Use `class="sticky top-0 h-dvh"` for a
  viewport-height sidebar; only the menu body scrolls. Customize widths through
  `--dm-left-menu-width` (18rem) and `--dm-left-menu-collapsed-width` (4.5rem).
  Mark custom header/footer text with `data-left-menu-label` to hide it in the
  rail. Menu items with `icon` and `label` hide their text automatically.

  For persistent navigation, pass `sticky`, `socket={@socket}`, `groups` and
  `active` from a shared LiveView layout. The component owns the sticky child
  LiveView, active-item synchronization, collapse and scroll restoration:

      <.dm_left_menu id="admin-sidebar" sticky socket={@socket}
        groups={@menu_groups} active={@active_nav}
        brand={%{label: "Administration", icon: "view-dashboard"}}
        class="sticky top-0 h-dvh" />

  Data-driven menus require a stable `id`. Groups are maps with string `id`,
  `label`, optional `open`, and `items`.
  Items use string `id`, `label`, `to`, and optional `icon`, `disabled`, `class`
  and `rest`. Filter this data on the server before passing it to the component.
  `brand` accepts `label`, `icon`, `to` and `version`; `footer_text` supplies a
  fixed footer. These data attributes also work without `sticky`.

  Sticky mode enables the collapsible layout and requires data instead of slots.
  A stable menu configuration keeps the same child across navigation. Changes
  to the groups, brand or presentation configuration remount it, so stale menu
  permissions are not retained. Changing `active` only updates the highlight.
  No application-owned sidebar LiveView, event handler or navigation hook is
  required. See the [complete example](left-menu.html).

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

  attr(:active, :string,
    default: "",
    doc: "Active data item id; pass explicitly to slotted groups"
  )

  attr(:groups, :list, default: [], doc: "Menu group maps with id, label, open and items")
  attr(:brand, :map, default: nil, doc: "Brand map with label, icon, to and version")
  attr(:footer_text, :string, default: nil, doc: "Fixed footer text hidden in the icon rail")
  attr(:sticky, :boolean, default: false, doc: "Own a persistent, collapsible child LiveView")
  attr(:socket, :any, default: nil, doc: "Parent LiveView socket, required in sticky mode")
  attr(:nav_label, :string, default: "Navigation menu", doc: "Accessible label for the menu nav")

  attr(:collapsible, :boolean,
    default: false,
    doc: "Enable the client-owned icon rail and toggle"
  )

  attr(:collapsed, :boolean,
    default: false,
    doc: "Initial collapsed state before the hook mounts"
  )

  attr(:storage_key, :string, default: nil, doc: "Optional localStorage key for collapse state")

  attr(:expand_label, :string,
    default: "Expand navigation",
    doc: "Accessible expand button label"
  )

  attr(:collapse_label, :string,
    default: "Collapse navigation",
    doc: "Accessible collapse button label"
  )

  attr(:rest, :global)

  slot(:header, doc: "Fixed brand/header area outside the scrolling menu")
  slot(:footer, doc: "Fixed footer content above the built-in collapse toggle")

  slot(:title, required: false, doc: "Menu title displayed as a section heading") do
    attr(:class, :any, doc: "title CSS classes")
  end

  slot(:menu, required: false, doc: "Menu content, typically dm_left_menu_group components")

  def dm_left_menu(assigns) do
    if (assigns.collapsible || assigns.sticky || assigns.groups != []) &&
         assigns.id in [nil, ""] do
      raise ArgumentError, "collapsible, sticky or data-driven dm_left_menu requires a stable id"
    end

    if assigns.groups != [] && assigns.menu != [] do
      raise ArgumentError, "dm_left_menu accepts either groups or :menu slots, not both"
    end

    assigns =
      assigns
      |> assign(:groups, normalize_groups(assigns.groups))
      |> assign(:brand, normalize_brand(assigns.brand))

    if assigns.sticky, do: sticky_menu(assigns), else: inline_menu(assigns)
  end

  defp sticky_menu(assigns) do
    unless is_struct(assigns.socket, Phoenix.LiveView.Socket) do
      raise ArgumentError, "sticky dm_left_menu requires socket={@socket} in a LiveView layout"
    end

    if Enum.any?([assigns.header, assigns.footer, assigns.title, assigns.menu], &(&1 != [])) do
      raise ArgumentError,
            "sticky dm_left_menu accepts groups, brand and footer_text instead of slots"
    end

    config =
      assigns
      |> Map.take([
        :id,
        :class,
        :size,
        :groups,
        :brand,
        :footer_text,
        :collapsed,
        :storage_key,
        :nav_label,
        :expand_label,
        :collapse_label,
        :rest
      ])
      |> Map.put(:collapsible, true)

    digest =
      config
      |> :erlang.term_to_binary([:deterministic])
      |> then(&:crypto.hash(:sha256, &1))
      |> Base.encode16(case: :lower)
      |> binary_part(0, 16)

    assigns =
      assigns
      |> assign(:config, config)
      |> assign(:child_id, "#{assigns.id}-live-#{digest}")

    ~H"""
    {live_render(@socket, PhoenixDuskmoon.Live.LeftMenu,
      id: @child_id,
      sticky: true,
      container: {:div, class: "contents"},
      session: %{"config" => @config, "active" => @active}
    )}
    <span
      id={"#{@id}-navigation"}
      hidden
      phx-hook="DuskmoonLeftMenuNavigation"
      data-sidebar-id={@id}
      data-active-nav={@active}
    ></span>
    """
  end

  defp inline_menu(assigns) do
    ~H"""
    <nav
      id={@id}
      class={[
        @collapsible && [
          "group/left-menu flex min-h-0 shrink-0 flex-col self-start",
          "w-[var(--dm-left-menu-width,18rem)] data-[collapsed=true]:w-[var(--dm-left-menu-collapsed-width,4.5rem)]",
          "data-[collapsed=true]:[&_[data-left-menu-label]]:sr-only",
          "data-[collapsed=true]:[&_.nested-menu-title]:hidden data-[collapsed=true]:[&_summary]:hidden",
          "data-[collapsed=true]:[&_.nested-menu_details>ul]:ps-0",
          "data-[collapsed=true]:[&_.nested-menu_li>a]:justify-center data-[collapsed=true]:[&_.nested-menu_li>a]:px-2"
        ],
        @class
      ]}
      aria-label={@nav_label}
      phx-hook={@collapsible && "DuskmoonLeftMenu"}
      data-collapsed={@collapsible && to_string(@collapsed)}
      data-storage-key={@collapsible && @storage_key}
      data-expand-label={@collapsible && @expand_label}
      data-collapse-label={@collapsible && @collapse_label}
      {@rest}
    >
      <div :if={@header != [] || @brand != nil} class="flex shrink-0 items-center justify-center gap-3 p-4">
        <.link :if={@brand && @brand[:to]} navigate={@brand.to} class="flex min-w-0 items-center gap-3">
          <.brand_content brand={@brand} />
        </.link>
        <div :if={@brand && !@brand[:to]} class="flex min-w-0 items-center gap-3">
          <.brand_content brand={@brand} />
        </div>
        {render_slot(@header)}
      </div>
      <div
        :if={@collapsible}
        id={"#{@id}-scroll"}
        data-left-menu-scroll
        class="min-h-0 flex-1 overflow-x-hidden overflow-y-auto overscroll-contain"
      >
        <.menu_list title={@title} menu={@menu} size={@size} groups={@groups} active={@active} id={@id} />
      </div>
      <.menu_list :if={!@collapsible} title={@title} menu={@menu} size={@size} groups={@groups} active={@active} id={@id} />
      <div :if={@footer != [] || @footer_text != nil} class="shrink-0">
        <p :if={@footer_text} data-left-menu-label class="px-4 py-2 text-xs">{@footer_text}</p>
        {render_slot(@footer)}
      </div>
      <div :if={@collapsible} class="flex shrink-0 justify-end p-0 group-data-[collapsed=true]/left-menu:justify-center">
        <button
          type="button"
          data-left-menu-toggle
          class="btn btn-ghost btn-square"
          aria-controls={"#{@id}-scroll"}
          aria-expanded={to_string(!@collapsed)}
          aria-label={if @collapsed, do: @expand_label, else: @collapse_label}
          title={if @collapsed, do: @expand_label, else: @collapse_label}
        >
          <.dm_mdi name="chevron-double-left" class="size-5 group-data-[collapsed=true]/left-menu:hidden" aria-hidden="true" />
          <.dm_mdi name="chevron-double-right" class="hidden size-5 group-data-[collapsed=true]/left-menu:block" aria-hidden="true" />
        </button>
      </div>
    </nav>
    """
  end

  defp brand_content(assigns) do
    ~H"""
    <.dm_mdi :if={@brand[:icon]} name={@brand.icon} class="size-7 shrink-0" aria-hidden="true" />
    <span data-left-menu-label class="min-w-0 truncate font-semibold">{@brand.label}</span>
    <span :if={@brand[:version]} data-left-menu-label class="text-xs">{@brand.version}</span>
    """
  end

  defp menu_list(assigns) do
    ~H"""
    <ul role="list" class={["nested-menu", nested_menu_size(@size)]}>
      <li :for={title <- @title} class={["nested-menu-title", title[:class]]}>
        {render_slot(title)}
      </li>
      <li :for={menu <- @menu}>{render_slot(menu)}</li>
      <li :for={group <- @groups}>
        <.dm_left_menu_group id={"#{@id}-group-#{group.id}"} active={@active} open={group.open}>
          <:title>{group.label}</:title>
          <:menu
            :for={item <- group.items}
            id={item.id}
            to={item.to}
            label={item.label}
            icon={item.icon}
            disabled={item.disabled}
            class={item.class}
            rest={item.rest}
          >
            {item.label}
          </:menu>
        </.dm_left_menu_group>
      </li>
    </ul>
    """
  end

  defp normalize_groups(groups) do
    groups =
      Enum.map(groups, fn group ->
        %{
          id: required_text!(group, :id),
          label: required_text!(group, :label),
          open: Map.get(group, :open, true),
          items:
            Enum.map(Map.fetch!(group, :items), fn item ->
              %{
                id: required_text!(item, :id),
                label: required_text!(item, :label),
                to: required_text!(item, :to),
                icon: Map.get(item, :icon),
                disabled: Map.get(item, :disabled, false),
                class: Map.get(item, :class),
                rest: Map.get(item, :rest, %{})
              }
            end)
        }
      end)

    unique_ids!(Enum.map(groups, & &1.id), "group")
    unique_ids!(for(group <- groups, item <- group.items, do: item.id), "item")
    groups
  end

  defp normalize_brand(nil), do: nil

  defp normalize_brand(brand) do
    brand
    |> Map.take([:icon, :to, :version])
    |> Map.put(:label, required_text!(brand, :label))
  end

  defp required_text!(data, key) do
    case Map.get(data, key) do
      value when is_binary(value) and value != "" -> value
      _ -> raise ArgumentError, "dm_left_menu data requires a non-empty string for #{key}"
    end
  end

  defp unique_ids!(ids, kind) do
    if length(Enum.uniq(ids)) != length(ids) do
      raise ArgumentError, "dm_left_menu #{kind} ids must be unique"
    end
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

  For an icon rail, give each item `icon="home"` (an MDI icon name) and
  `label="Home"` (its accessible name). The slot content is its visible text.
  A stable group `id` and item `id` also enable native right-side tooltips when
  the parent menu is collapsed. Give every group a stable `id` so the hook can
  restore its open state after patches and re-expansion.

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
    attr(:icon, :string, doc: "MDI icon name displayed before the item text")
    attr(:label, :string, doc: "Accessible link name and collapsed tooltip text")
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
          <.dm_tooltip
            :if={menu_tooltip?(@id, m)}
            :let={trigger_attrs}
            id={"#{@id}-#{m[:id]}-hint"}
            content={m[:label]}
            position="right"
          >
            <.menu_link menu={m} active={@active} tooltip_attrs={trigger_attrs} />
          </.dm_tooltip>
          <.menu_link :if={!menu_tooltip?(@id, m)} menu={m} active={@active} tooltip_attrs={%{}} />
        </li>
      </ul>
    </details>
    """
  end

  defp menu_tooltip?(id, menu), do: !!(id && menu[:id] && menu[:icon] && menu[:label])

  defp menu_link(assigns) do
    assigns = assign(assigns, :attrs, menu_link_attrs(assigns.menu, assigns.tooltip_attrs))

    ~H"""
    <.link
      {@attrs}
      navigate={@menu[:to]}
      class={[@menu[:class], @menu[:id] == @active && @active != "" && "active"]}
      aria-current={@menu[:id] == @active && @active != "" && "page"}
      aria-disabled={@menu[:disabled] && "true"}
    >
      <.dm_mdi :if={@menu[:icon]} name={@menu[:icon]} class="size-5 shrink-0" aria-hidden="true" />
      <span :if={@menu[:icon]} data-left-menu-label>{render_slot(@menu)}</span>
      <%= if !@menu[:icon] do %>{render_slot(@menu)}<% end %>
    </.link>
    """
  end

  defp menu_link_attrs(menu, tooltip_attrs) do
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
        :icon,
        :label,
        :rest
      ])
      |> Map.new(fn {key, value} -> {to_string(key), value} end)
      |> Map.merge(Map.new(menu[:rest] || %{}, fn {key, value} -> {to_string(key), value} end))
      |> Map.drop(
        ~w(class navigate patch href aria-current aria-disabled data-phx-link data-phx-link-state)
      )

    attrs = if menu[:label], do: Map.put_new(attrs, "aria-label", menu[:label]), else: attrs

    attrs =
      if map_size(tooltip_attrs) > 0 do
        Map.merge(tooltip_attrs, attrs)
        |> Map.put("style", Enum.join([attrs["style"], tooltip_attrs["style"]], "; "))
        |> Map.put(
          "aria-describedby",
          Enum.join(
            Enum.reject(
              [attrs["aria-describedby"], tooltip_attrs["aria-describedby"]],
              &is_nil/1
            ),
            " "
          )
        )
        |> Map.put("data-left-menu-tooltip", tooltip_attrs["interestfor"])
        |> Map.put(
          "data-left-menu-anchor",
          String.replace_prefix(tooltip_attrs["style"], "anchor-name: ", "")
        )
        |> Map.put("data-left-menu-tooltip-title", tooltip_attrs["title"])
      else
        attrs
      end

    if menu[:disabled], do: Map.put(attrs, "tabindex", "-1"), else: attrs
  end
end
