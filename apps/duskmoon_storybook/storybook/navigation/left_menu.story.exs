defmodule Storybook.Navigation.LeftMenu do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Navigation.LeftMenu.dm_left_menu/1

  def description,
    do: "Sidebar navigation with native groups and an optional collapsible icon rail."

  def imports do
    [{PhoenixDuskmoon.Component.Navigation.LeftMenu, [dm_left_menu_group: 1]}]
  end

  def variations do
    [
      %Variation{
        id: :default,
        description: "Basic left menu with active item",
        attributes: %{class: "w-56", active: "dashboard"},
        slots: menu_slots("Navigation", "dashboard")
      },
      %Variation{
        id: :with_active_state,
        description: "Pass the active item to each group",
        attributes: %{class: "w-56", active: "components"},
        slots: menu_slots("Menu with Active State", "components")
      },
      %Variation{
        id: :with_disabled_items,
        description: "Menu with enabled and disabled items",
        attributes: %{class: "w-56"},
        slots: [
          "<:title>Menu with Disabled Items</:title>",
          """
          <:menu>
            <.dm_left_menu_group id="storybook-unavailable-items">
              <:title>Items</:title>
              <:menu id="enabled" to="#enabled">Enabled Item</:menu>
              <:menu id="services" disabled icon="cog" label="Services">
                Services <span>Requires scope</span>
              </:menu>
              <:menu id="disabled" to="#disabled" disabled>Disabled destination</:menu>
              <:menu id="another" to="#another">Another Enabled Item</:menu>
            </.dm_left_menu_group>
          </:menu>
          """
        ]
      },
      %Variation{
        id: :disabled_data_items,
        description: "Disabled data entries can omit a destination.",
        attributes: %{
          id: "storybook-disabled-data-menu",
          groups: [
            %{
              id: "workers",
              label: "Workers",
              items: [
                %{id: "overview", label: "Overview", to: "#overview", icon: "view-dashboard"},
                %{id: "services", label: "Services", disabled: true, icon: "cog"}
              ]
            }
          ]
        }
      },
      %Variation{
        id: :collapsible,
        description:
          "Use the bottom button to collapse to an icon rail. Group state returns when expanded; hover or focus icons for labels.",
        attributes: %{
          id: "storybook-collapsible-left-menu",
          collapsible: true,
          class: "h-80 bg-base-200"
        },
        slots: [
          "<:header><strong data-left-menu-label>Workspace</strong></:header>",
          """
          <:menu>
            <.dm_left_menu_group id="storybook-left-overview" active="dashboard">
              <:title>Overview</:title>
              <:menu id="dashboard" to="#dashboard" icon="view-dashboard" label="Dashboard">Dashboard</:menu>
              <:menu id="projects" to="#projects" icon="folder" label="Projects">Projects</:menu>
              <:menu id="team" to="#team" icon="account-group" label="Team">Team</:menu>
              <:menu id="services" disabled icon="cog" label="Services">Services <span>Requires scope</span></:menu>
            </.dm_left_menu_group>
            <.dm_left_menu_group id="storybook-left-settings" open={false}>
              <:title>Settings</:title>
              <:menu id="profile" to="#profile" icon="account" label="Profile">Profile</:menu>
              <:menu id="security" to="#security" icon="shield-lock" label="Security">Security</:menu>
              <:menu id="billing" to="#billing" icon="credit-card" label="Billing">Billing</:menu>
            </.dm_left_menu_group>
          </:menu>
          """,
          "<:footer><span data-left-menu-label>Account settings</span></:footer>"
        ]
      },
      %VariationGroup{
        id: :sizes,
        description: "Size variants",
        variations: [
          %Variation{
            id: :xs,
            attributes: %{size: "xs", class: "w-48"},
            slots: menu_slots("XS Menu", "")
          },
          %Variation{
            id: :sm,
            attributes: %{size: "sm", class: "w-52"},
            slots: menu_slots("Small Menu", "")
          },
          %Variation{
            id: :lg,
            attributes: %{size: "lg", class: "w-64"},
            slots: menu_slots("Large Menu", "")
          }
        ]
      }
    ]
  end

  defp menu_slots(title, active) do
    [
      "<:title>#{title}</:title>",
      """
      <:menu>
        <.dm_left_menu_group active="#{active}">
          <:title>Pages</:title>
          <:menu id="dashboard" to="#dashboard">Dashboard</:menu>
          <:menu id="components" to="#components">Components</:menu>
          <:menu id="settings" to="#settings">Settings</:menu>
        </.dm_left_menu_group>
      </:menu>
      """
    ]
  end

  def modifiers do
    [
      %{
        id: :size,
        label: "Size",
        type: :select,
        options: [
          {"xs", "XS"},
          {"sm", "SM"},
          {"md", "MD"},
          {"lg", "LG"}
        ],
        default: "md"
      }
    ]
  end
end
