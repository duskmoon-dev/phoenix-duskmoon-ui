defmodule Storybook.DataEntry.TreeSelect do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.TreeSelect.dm_tree_select/1
  def description, do: "Hierarchical tree select with expandable nodes."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "ts-default",
          placeholder: "Select item...",
          options: [
            %{value: "fruits", label: "Fruits", children: [
              %{value: "apple", label: "Apple"},
              %{value: "banana", label: "Banana"}
            ]},
            %{value: "vegs", label: "Vegetables", children: [
              %{value: "carrot", label: "Carrot"}
            ]}
          ]
        }
      },
      %Variation{
        id: :expanded,
        attributes: %{
          id: "ts-expanded",
          options: [
            %{value: "fruits", label: "Fruits", children: [
              %{value: "apple", label: "Apple"},
              %{value: "banana", label: "Banana"}
            ]},
            %{value: "vegs", label: "Vegetables", children: [
              %{value: "carrot", label: "Carrot"}
            ]}
          ],
          selected: ["apple"],
          expanded: ["fruits"],
          open: true,
          show_path: true
        }
      },
      %Variation{
        id: :multiple,
        attributes: %{
          id: "ts-multi",
          options: [
            %{value: "a", label: "Alpha"},
            %{value: "b", label: "Beta"},
            %{value: "c", label: "Gamma"}
          ],
          selected: ["a", "b"],
          multiple: true
        }
      }
    ]
  end
end
