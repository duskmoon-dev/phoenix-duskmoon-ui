defmodule Storybook.Action.Menu do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Action.Menu.dm_menu/1
  def description, do: "Context menu with items, keyboard navigation, and ARIA roles."

  def imports do
    [{PhoenixDuskmoon.Component.Action.Menu, [dm_menu_item: 1]}]
  end

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
          <.dm_menu_item value="edit">Edit</.dm_menu_item>
          <.dm_menu_item value="copy">Copy</.dm_menu_item>
          <.dm_menu_item value="delete">Delete</.dm_menu_item>
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
          <.dm_menu_item value="edit" icon="pencil">Edit</.dm_menu_item>
          <.dm_menu_item value="copy" icon="content-copy">Copy</.dm_menu_item>
          <.dm_menu_item value="delete" icon="delete" disabled={true}>Delete</.dm_menu_item>
          """
        ]
      },
      %VariationGroup{
        id: :placements,
        description: "Placement variants",
        variations: [
          %Variation{
            id: :top,
            attributes: %{id: "menu-top", open: true, placement: "top"},
            slots: [
              """
              <.dm_menu_item value="a">Option A</.dm_menu_item>
              <.dm_menu_item value="b">Option B</.dm_menu_item>
              """
            ]
          },
          %Variation{
            id: :bottom,
            attributes: %{id: "menu-bot", open: true, placement: "bottom"},
            slots: [
              """
              <.dm_menu_item value="a">Option A</.dm_menu_item>
              <.dm_menu_item value="b">Option B</.dm_menu_item>
              """
            ]
          },
          %Variation{
            id: :right,
            attributes: %{id: "menu-right", open: true, placement: "right"},
            slots: [
              """
              <.dm_menu_item value="a">Option A</.dm_menu_item>
              <.dm_menu_item value="b">Option B</.dm_menu_item>
              """
            ]
          },
          %Variation{
            id: :bottom_end,
            attributes: %{id: "menu-bend", open: true, placement: "bottom-end"},
            slots: [
              """
              <.dm_menu_item value="a">Option A</.dm_menu_item>
              <.dm_menu_item value="b">Option B</.dm_menu_item>
              """
            ]
          }
        ]
      }
    ]
  end
end
