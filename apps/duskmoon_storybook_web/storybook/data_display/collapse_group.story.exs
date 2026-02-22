defmodule Storybook.DataDisplay.CollapseGroup do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Collapse.dm_collapse_group/1

  def description,
    do: "Container that groups multiple dm_collapse panels. Provides consistent spacing and styling."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Group of collapse panels",
        attributes: %{
          id: "cg-default"
        },
        slots: [
          """
          <PhoenixDuskmoon.Component.DataDisplay.Collapse.dm_collapse variant="bordered">
            <:trigger>Section One</:trigger>
            <:content>Content for section one.</:content>
          </PhoenixDuskmoon.Component.DataDisplay.Collapse.dm_collapse>
          <PhoenixDuskmoon.Component.DataDisplay.Collapse.dm_collapse variant="bordered">
            <:trigger>Section Two</:trigger>
            <:content>Content for section two.</:content>
          </PhoenixDuskmoon.Component.DataDisplay.Collapse.dm_collapse>
          <PhoenixDuskmoon.Component.DataDisplay.Collapse.dm_collapse variant="bordered">
            <:trigger>Section Three</:trigger>
            <:content>Content for section three.</:content>
          </PhoenixDuskmoon.Component.DataDisplay.Collapse.dm_collapse>
          """
        ]
      },
      %Variation{
        id: :with_class,
        description: "Group with custom CSS class",
        attributes: %{
          id: "cg-styled",
          class: "gap-2"
        },
        slots: [
          """
          <PhoenixDuskmoon.Component.DataDisplay.Collapse.dm_collapse variant="card">
            <:trigger>FAQ Item 1</:trigger>
            <:content>Answer to FAQ 1.</:content>
          </PhoenixDuskmoon.Component.DataDisplay.Collapse.dm_collapse>
          <PhoenixDuskmoon.Component.DataDisplay.Collapse.dm_collapse variant="card">
            <:trigger>FAQ Item 2</:trigger>
            <:content>Answer to FAQ 2.</:content>
          </PhoenixDuskmoon.Component.DataDisplay.Collapse.dm_collapse>
          """
        ]
      }
    ]
  end
end
