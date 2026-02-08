defmodule Storybook.Navigation.LeftMenu do
  # :live_component or :page are also available
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Navigation.LeftMenu.dm_left_menu/1
  def description, do: "A left menu element using daisyUI menu system."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          class: "w-56",
          active: "dashboard"
        },
        slots: [
          "<:title>Navigation</:title>",
          "<:menu id=\"dashboard\">Dashboard</:menu>",
          "<:menu id=\"components\">Components</:menu>",
          "<:menu id=\"settings\">Settings</:menu>"
        ]
      },
      %Variation{
        id: :with_active_state,
        attributes: %{
          class: "w-56",
          active: "components"
        },
        slots: [
          "<:title>Menu with Active State</:title>",
          "<:menu id=\"dashboard\">Dashboard</:menu>",
          "<:menu id=\"components\">Components (Active)</:menu>",
          "<:menu id=\"settings\">Settings</:menu>"
        ]
      },
      %Variation{
        id: :with_disabled_items,
        attributes: %{
          class: "w-56"
        },
        slots: [
          "<:title>Menu with Disabled Items</:title>",
          "<:menu>Enabled Item</:menu>",
          "<:menu disabled>Disabled Item</:menu>",
          "<:menu>Another Enabled Item</:menu>"
        ]
      },
      %Variation{
        id: :sizes,
        attributes: %{
          size: "sm",
          class: "w-56"
        },
        slots: [
          "<:title>Small Menu</:title>",
          "<:menu>Small Item 1</:menu>",
          "<:menu>Small Item 2</:menu>"
        ]
      },
      %Variation{
        id: :horizontal,
        attributes: %{
          horizontal: true,
          class: "w-full"
        },
        slots: [
          "<:menu>Home</:menu>",
          "<:menu>Components</:menu>",
          "<:menu>Documentation</:menu>",
          "<:menu>About</:menu>"
        ]
      }
    ]
  end
end
