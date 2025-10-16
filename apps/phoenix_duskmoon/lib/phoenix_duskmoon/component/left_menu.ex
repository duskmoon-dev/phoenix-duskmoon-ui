defmodule PhoenixDuskmoon.Component.LeftMenu do
  @moduledoc """
  Duskmoon UI LeftMenu Component

  Uses daisyUI menu classes for consistent styling and functionality.
  """
  use PhoenixDuskmoon.Component, :html

  @doc """
  Generates left menu using daisyUI menu system

  ## Examples

      <.dm_left_menu class="bg-base-200 rounded-box w-56" active="actionbar">
        <:title class="menu-title">Phx WebComponents</:title>
        <:menu id="actionbar">Actionbar</:menu>
        <:menu id="appbar">Appbar</:menu>
      </.dm_left_menu>
      
      <.dm_left_menu size="sm" class="bg-base-200 rounded-box">
        <:menu class="menu-active">Active Item</:menu>
        <:menu>Regular Item</:menu>
        <:menu class="menu-disabled">Disabled Item</:menu>
      </.dm_left_menu>
  """
  @doc type: :component
  attr(:id, :any,
    default: false,
    doc: "html attribute id"
  )

  attr(:class, :any,
    default: "",
    doc: "html attribute class"
  )

  attr(:size, :string,
    default: "md",
    values: ["xs", "sm", "md", "lg", "xl"],
    doc: "menu size variant"
  )

  attr(:horizontal, :boolean,
    default: false,
    doc: "render menu horizontally instead of vertically"
  )

  attr(:active, :string,
    default: "",
    doc: "active menu id"
  )

  slot(:title,
    required: false,
    doc: "Render menu title"
  ) do
    attr(:class, :any)
  end

  slot(:menu,
    required: false,
    doc: "Render menu item"
  ) do
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
    <nav id={@id} class={[@class]}>
      <ul class={[
        "menu",
        "menu-#{@size}",
        @horizontal && "menu-horizontal",
        "bg-base-200",
        "rounded-box",
        "w-full"
      ]}>
        <li
          :for={title <- @title}
          class={[
            "menu-title",
            Map.get(title, :class, "")
          ]}
        >
          <%= render_slot(title) %>
        </li>
        <li
          :for={m <- @menu}
          class={[
            Map.get(m, :class, ""),
            Map.get(m, :disabled) && "menu-disabled",
            Map.get(m, :id, nil) == @active && "menu-active"
          ]}
        >
          <%= render_slot(m) %>
        </li>
      </ul>
    </nav>
    """
  end

  @doc """
  Generates left menu group with daisyUI menu structure

  ## Examples

      <.dm_left_menu_group active="mdi" class="bg-base-200 rounded-box">
        <:title>Icons</:title>
        <:menu id="mdi" to={~p"/icons/mdi"}>MD Icon</:menu>
        <:menu id="bsi" to={~p"/icons/bsi"}>BS Icon</:menu>
      </.dm_left_menu_group>
      
      <.dm_left_menu_group size="sm" collapsible=true>
        <:title>Settings</:title>
        <:menu id="profile" to={~p"/settings/profile"}>Profile</:menu>
        <:menu id="security" to={~p"/settings/security"}>Security</:menu>
      </.dm_left_menu_group>
  """
  @doc type: :component
  attr(:id, :any,
    default: false,
    doc: "html attribute id"
  )

  attr(:class, :any,
    default: "",
    doc: "html attribute class"
  )

  attr(:size, :string,
    default: "md",
    values: ["xs", "sm", "md", "lg", "xl"],
    doc: "menu size variant"
  )

  attr(:collapsible, :boolean,
    default: false,
    doc: "make the group collapsible using details/summary"
  )

  attr(:open, :boolean,
    default: true,
    doc: "initial state of collapsible group"
  )

  attr(:active, :string,
    default: "",
    doc: "active menu id"
  )

  slot(:title,
    required: true,
    doc: "Render menu title"
  ) do
    attr(:class, :any)
  end

  slot(:menu,
    required: false,
    doc: "Render menu item"
  ) do
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
    <div id={@id} class={[@class]}>
      <ul class={[
        "menu",
        "menu-#{@size}",
        "bg-base-200",
        "rounded-box",
        "w-full"
      ]}>
        <%= if @collapsible do %>
          <li>
            <details open={@open}>
              <summary class={[
                "menu-title",
                Map.get(List.first(@title), :class, "")
              ]}>
                <%= render_slot(List.first(@title)) %>
              </summary>
              <ul>
                <li
                  :for={m <- @menu}
                  class={[
                    Map.get(m, :class, ""),
                    Map.get(m, :disabled) && "menu-disabled",
                    Map.get(m, :id, nil) == @active && "menu-active"
                  ]}
                >
                  <.link navigate={Map.get(m, :to, "#")}>
                    <%= render_slot(m) %>
                  </.link>
                </li>
              </ul>
            </details>
          </li>
        <% else %>
          <li class={[
            "menu-title",
            Map.get(List.first(@title), :class, "")
          ]}>
            <%= render_slot(List.first(@title)) %>
          </li>
          <li
            :for={m <- @menu}
            class={[
              Map.get(m, :class, ""),
              Map.get(m, :disabled, false) && "menu-disabled",
              Map.get(m, :id, nil) == @active && "menu-active"
            ]}
          >
            <.link navigate={Map.get(m, :to, "#")}>
              <%= render_slot(m) %>
            </.link>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end
end
