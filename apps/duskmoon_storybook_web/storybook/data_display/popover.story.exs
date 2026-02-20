defmodule Storybook.DataDisplay.Popover do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Popover.dm_popover/1
  def description, do: "Popover component for contextual overlays."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "pop-default",
          trigger_mode: "click"
        },
        slots: [
          """
          <:trigger>Click me</:trigger>
          <:content>Popover content here</:content>
          """
        ]
      },
      %Variation{
        id: :hover,
        attributes: %{
          id: "pop-hover",
          trigger_mode: "hover",
          placement: "top"
        },
        slots: [
          """
          <:trigger>Hover me</:trigger>
          <:content>Appears on hover</:content>
          """
        ]
      },
      %Variation{
        id: :with_arrow,
        attributes: %{
          id: "pop-arrow",
          trigger_mode: "click",
          placement: "bottom",
          arrow: true
        },
        slots: [
          """
          <:trigger>With arrow</:trigger>
          <:content>This popover has an arrow pointing to the trigger.</:content>
          """
        ]
      }
    ]
  end
end
