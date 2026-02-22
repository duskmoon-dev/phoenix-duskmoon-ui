defmodule Storybook.Navigation.LeftMenuGroup do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Navigation.LeftMenu.dm_left_menu_group/1
  def description, do: "A grouped menu element with collapsible sections."

  def variations do
    [
      %Variation{
        id: :default_group,
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
        attributes: %{
          class: "w-56",
          collapsible: true,
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
        attributes: %{
          class: "w-56",
          size: "sm"
        },
        slots: [
          "<:title>Quick Links</:title>",
          "<:menu id=\"home\" to=\"#\">Home</:menu>",
          "<:menu id=\"docs\" to=\"#\">Documentation</:menu>"
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
