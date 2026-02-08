defmodule PhoenixDuskmoon.Component.Navigation.LeftMenu do
  @moduledoc """
  Menu component for navigation sidebars.

  ## Examples

      <.dm_left_menu active="item1">
        <:title>Menu Title</:title>
        <:menu id="item1">Item 1</:menu>
        <:menu id="item2">Item 2</:menu>
      </.dm_left_menu>

  """
  use Phoenix.Component

  @doc """
  Generates a left menu using the dm-menu styling system.

  ## Examples

      <.dm_left_menu class="dm-menu--bg" active="actionbar">
        <:title class="uppercase">Phx WebComponents</:title>
        <:menu id="actionbar">Actionbar</:menu>
        <:menu id="appbar">Appbar</:menu>
      </.dm_left_menu>

      <.dm_left_menu size="sm">
        <:menu>Active Item</:menu>
        <:menu>Regular Item</:menu>
        <:menu disabled>Disabled Item</:menu>
      </.dm_left_menu>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "Additional CSS classes")

  attr(:size, :string,
    default: "md",
    values: ["xs", "sm", "md", "lg", "xl"],
    doc: "Menu size variant"
  )

  attr(:horizontal, :boolean, default: false, doc: "Render menu horizontally")
  attr(:active, :string, default: "", doc: "Active menu id")
  attr(:rest, :global)

  slot(:title, required: false, doc: "Menu title") do
    attr(:class, :any)
  end

  slot(:menu, required: false, doc: "Menu item") do
    attr(:id, :string)
    attr(:class, :any)
    attr(:disabled, :boolean)
  end

  def dm_left_menu(assigns) do
    assigns =
      assigns
      |> assign_new(:title, fn -> [] end)
      |> assign_new(:menu, fn -> [] end)

    ~H"""
    <nav id={@id} class={@class} {@rest}>
      <ul class={[
        "dm-menu",
        "dm-menu--#{@size}",
        @horizontal && "dm-menu--horizontal"
      ]}>
        <li
          :for={title <- @title}
          class={["dm-menu__title", Map.get(title, :class)]}
        >
          {render_slot(title)}
        </li>
        <li
          :for={m <- @menu}
          class={[
            "dm-menu__item",
            Map.get(m, :class),
            Map.get(m, :disabled) && "dm-menu__item--disabled",
            Map.get(m, :id) == @active && "dm-menu__item--active"
          ]}
        >
          {render_slot(m)}
        </li>
      </ul>
    </nav>
    """
  end

  @doc """
  Generates a left menu group with collapsible support.

  ## Examples

      <.dm_left_menu_group active="mdi">
        <:title>Icons</:title>
        <:menu id="mdi" to={~p"/icons/mdi"}>MD Icon</:menu>
        <:menu id="bsi" to={~p"/icons/bsi"}>BS Icon</:menu>
      </.dm_left_menu_group>

      <.dm_left_menu_group size="sm" collapsible>
        <:title>Settings</:title>
        <:menu id="profile" to={~p"/settings/profile"}>Profile</:menu>
        <:menu id="security" to={~p"/settings/security"}>Security</:menu>
      </.dm_left_menu_group>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "Additional CSS classes")

  attr(:size, :string,
    default: "md",
    values: ["xs", "sm", "md", "lg", "xl"],
    doc: "Menu size variant"
  )

  attr(:collapsible, :boolean, default: false, doc: "Make the group collapsible")
  attr(:open, :boolean, default: true, doc: "Initial state of collapsible group")
  attr(:active, :string, default: "", doc: "Active menu id")
  attr(:rest, :global)

  slot(:title, required: true, doc: "Menu title") do
    attr(:class, :any)
  end

  slot(:menu, required: false, doc: "Menu item") do
    attr(:id, :string)
    attr(:class, :any)
    attr(:to, :string)
    attr(:disabled, :boolean)
  end

  def dm_left_menu_group(assigns) do
    assigns =
      assigns
      |> assign_new(:menu, fn -> [] end)

    ~H"""
    <div id={@id} class={@class} {@rest}>
      <ul class={["dm-menu", "dm-menu--#{@size}"]}>
        <%= if @collapsible do %>
          <li class="dm-menu__group">
            <details open={@open}>
              <summary class={["dm-menu__title", Map.get(List.first(@title), :class)]}>
                {render_slot(List.first(@title))}
              </summary>
              <ul>
                <li
                  :for={m <- @menu}
                  class={[
                    "dm-menu__item",
                    Map.get(m, :class),
                    Map.get(m, :disabled) && "dm-menu__item--disabled",
                    Map.get(m, :id) == @active && "dm-menu__item--active"
                  ]}
                >
                  <.link navigate={Map.get(m, :to, "#")}>
                    {render_slot(m)}
                  </.link>
                </li>
              </ul>
            </details>
          </li>
        <% else %>
          <li class={["dm-menu__title", Map.get(List.first(@title), :class)]}>
            {render_slot(List.first(@title))}
          </li>
          <li
            :for={m <- @menu}
            class={[
              "dm-menu__item",
              Map.get(m, :class),
              Map.get(m, :disabled) && "dm-menu__item--disabled",
              Map.get(m, :id) == @active && "dm-menu__item--active"
            ]}
          >
            <.link navigate={Map.get(m, :to, "#")}>
              {render_slot(m)}
            </.link>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end
end
