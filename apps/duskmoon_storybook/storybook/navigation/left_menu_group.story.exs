defmodule Storybook.Navigation.LeftMenuGroup do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Navigation.LeftMenu.dm_left_menu_group/1
  def description, do: "A grouped menu element with collapsible sections."

  def variations do
    [
      %Variation{
        id: :default_group,
        description: "Basic menu group with active item",
        attributes: %{
          class: "w-56",
          active: "profile"
        },
        slots: [
          "<:title>User Settings</:title>",
          "<:menu id=\"profile\" to=\"#\">Profile</:menu>",
          "<:menu id=\"security\" to=\"#\">Security</:menu>",
          "<:menu id=\"notifications\" to=\"#\">Notifications</:menu>"
        ]
      },
      %Variation{
        id: :collapsible_group,
        description: "Native details group; toggle its summary to expand or close",
        attributes: %{
          class: "w-56",
          open: true
        },
        slots: [
          "<:title>Advanced Settings</:title>",
          "<:menu id=\"api\" to=\"#\">API Keys</:menu>",
          "<:menu id=\"webhooks\" to=\"#\">Webhooks</:menu>",
          "<:menu id=\"logs\" to=\"#\">Activity Logs</:menu>"
        ]
      },
      %Variation{
        id: :small_group,
        description: "Icon links with explicit accessible labels",
        attributes: %{
          id: "storybook-icon-menu-group",
          class: "w-56"
        },
        slots: [
          "<:title>Quick Links</:title>",
          "<:menu id=\"home\" to=\"#home\" icon=\"home\" label=\"Home\">Home</:menu>",
          "<:menu id=\"docs\" to=\"#docs\" icon=\"book-open\" label=\"Documentation\">Documentation</:menu>"
        ]
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :open,
        label: "Open",
        type: :boolean,
        default: true
      }
    ]
  end
end
