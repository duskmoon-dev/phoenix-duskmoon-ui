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
        description: "Basic context menu with text-only items",
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
        description: "Menu items with icons and a disabled item",
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
        variations:
          for placement <- ~w(top bottom right bottom-end) do
            %Variation{
              id: String.to_atom(String.replace(placement, "-", "_")),
              attributes: %{
                id: "menu-#{String.replace(placement, "-", "_")}",
                open: true,
                placement: placement
              },
              slots: [
                """
                <.dm_menu_item value="a">Option A</.dm_menu_item>
                <.dm_menu_item value="b">Option B</.dm_menu_item>
                """
              ]
            }
          end
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :placement,
        label: "Placement",
        type: :select,
        options: [
          {nil, "Default"},
          {"top", "Top"},
          {"bottom", "Bottom"},
          {"left", "Left"},
          {"right", "Right"},
          {"bottom-end", "Bottom End"}
        ],
        default: nil
      },
      %{
        id: :open,
        label: "Open",
        type: :boolean,
        default: false
      }
    ]
  end
end
