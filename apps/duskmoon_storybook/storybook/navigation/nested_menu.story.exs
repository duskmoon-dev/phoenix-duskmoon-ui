defmodule Storybook.Navigation.NestedMenu do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Navigation.NestedMenu.dm_nested_menu/1
  def description, do: "Vertical navigation menu with collapsible sub-menus."

  def imports do
    [{PhoenixDuskmoon.Component.Navigation.NestedMenu, [dm_nested_menu_item: 1]}]
  end

  def variations do
    [
      %Variation{
        id: :default,
        description: "Menu with title, items, and collapsible groups",
        attributes: %{
          id: "nmenu-default"
        },
        slots: [
          """
          <:title>Navigation</:title>
          <:item to="#" active={true}>Dashboard</:item>
          <:item to="#">Settings</:item>
          <:group title="Resources" open={true}>
            <.dm_nested_menu_item to="#" active={false}>Documents</.dm_nested_menu_item>
            <.dm_nested_menu_item to="#" active={false}>Media</.dm_nested_menu_item>
          </:group>
          <:group title="Admin">
            <.dm_nested_menu_item to="#" active={false}>Users</.dm_nested_menu_item>
          </:group>
          """
        ]
      },
      %Variation{
        id: :bordered_compact,
        description: "Bordered panel with compact padding and disabled item",
        attributes: %{
          id: "nmenu-bordered",
          bordered: true,
          compact: true
        },
        slots: [
          """
          <:item to="#" active={true}>Home</:item>
          <:item to="#">About</:item>
          <:item to="#" disabled={true}>Disabled</:item>
          """
        ]
      },
      %VariationGroup{
        id: :sizes,
        description: "Size variants",
        variations:
          for size <- ~w(sm md lg) do
            %Variation{
              id: String.to_atom(size),
              attributes: %{
                id: "nmenu-#{size}",
                size: size
              },
              slots: [
                """
                <:title>#{String.upcase(size)} Menu</:title>
                <:item to="#" active={true}>Item A</:item>
                <:item to="#">Item B</:item>
                """
              ]
            }
          end
      },
      %Variation{
        id: :with_nav_label,
        description: "Accessible nav label for screen readers",
        attributes: %{
          id: "nmenu-a11y",
          nav_label: "Sidebar navigation"
        },
        slots: [
          """
          <:title>Sidebar</:title>
          <:item to="#" active={true}>Overview</:item>
          <:item to="#">Reports</:item>
          <:group title="Tools" open={true}>
            <.dm_nested_menu_item to="#">Editor</.dm_nested_menu_item>
            <.dm_nested_menu_item to="#">Console</.dm_nested_menu_item>
          </:group>
          """
        ]
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :size,
        label: "Size",
        type: :select,
        options: [
          {nil, "Default"},
          {"xs", "XS"},
          {"sm", "SM"},
          {"lg", "LG"}
        ],
        default: nil
      },
      %{
        id: :bordered,
        label: "Bordered",
        type: :boolean,
        default: false
      },
      %{
        id: :compact,
        label: "Compact",
        type: :boolean,
        default: false
      }
    ]
  end
end
