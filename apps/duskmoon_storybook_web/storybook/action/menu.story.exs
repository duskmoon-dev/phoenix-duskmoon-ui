defmodule Storybook.Action.Menu do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Action.Menu.dm_menu/1
  def description, do: "Context menu with items, keyboard navigation, and ARIA roles."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "menu-default",
          open: true
        },
        slots: [
          """
          <:item value="edit">Edit</:item>
          <:item value="copy">Copy</:item>
          <:item value="delete">Delete</:item>
          """
        ]
      },
      %Variation{
        id: :with_icons,
        attributes: %{
          id: "menu-icons",
          open: true
        },
        slots: [
          """
          <:item value="edit" icon="pencil">Edit</:item>
          <:item value="copy" icon="content-copy">Copy</:item>
          <:item value="delete" icon="delete" disabled={true}>Delete</:item>
          """
        ]
      }
    ]
  end
end
