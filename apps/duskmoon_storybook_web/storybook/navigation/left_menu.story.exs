defmodule Storybook.Navigation.LeftMenu do
  # :live_component or :page are also available
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Navigation.LeftMenu.dm_left_menu/1
  def description, do: "A left menu element using @duskmoon-dev/core menu system."

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
      %VariationGroup{
        id: :sizes,
        description: "Size variants",
        variations: [
          %Variation{
            id: :xs,
            attributes: %{size: "xs", class: "w-48"},
            slots: [
              "<:title>XS Menu</:title>",
              "<:menu>Item A</:menu>",
              "<:menu>Item B</:menu>",
              "<:menu>Item C</:menu>"
            ]
          },
          %Variation{
            id: :sm,
            attributes: %{size: "sm", class: "w-52"},
            slots: [
              "<:title>Small Menu</:title>",
              "<:menu>Item A</:menu>",
              "<:menu>Item B</:menu>",
              "<:menu>Item C</:menu>"
            ]
          },
          %Variation{
            id: :lg,
            attributes: %{size: "lg", class: "w-64"},
            slots: [
              "<:title>Large Menu</:title>",
              "<:menu>Item A</:menu>",
              "<:menu>Item B</:menu>",
              "<:menu>Item C</:menu>"
            ]
          }
        ]
      }
    ]
  end
end
