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
        id: :bordered,
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
      }
    ]
  end
end
