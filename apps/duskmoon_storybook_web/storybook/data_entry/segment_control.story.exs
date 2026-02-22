defmodule Storybook.DataEntry.SegmentControl do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.SegmentControl.dm_segment_control/1
  def description, do: "Segmented control for choosing between options."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "seg-default"
        },
        slots: [
          """
          <:item active={true}>Day</:item>
          <:item>Week</:item>
          <:item>Month</:item>
          """
        ]
      },
      %VariationGroup{
        id: :colors,
        description: "Color variants",
        variations: [
          %Variation{
            id: :primary,
            attributes: %{
              id: "seg-primary",
              color: "primary"
            },
            slots: [
              """
              <:item active={true}>One</:item>
              <:item>Two</:item>
              <:item>Three</:item>
              """
            ]
          },
          %Variation{
            id: :secondary,
            attributes: %{
              id: "seg-secondary",
              color: "secondary"
            },
            slots: [
              """
              <:item active={true}>One</:item>
              <:item>Two</:item>
              """
            ]
          }
        ]
      },
      %VariationGroup{
        id: :sizes,
        description: "Size variants",
        variations: [
          %Variation{
            id: :sm,
            attributes: %{
              id: "seg-sm",
              size: "sm"
            },
            slots: [
              """
              <:item active={true}>Small</:item>
              <:item>Options</:item>
              """
            ]
          },
          %Variation{
            id: :lg,
            attributes: %{
              id: "seg-lg",
              size: "lg"
            },
            slots: [
              """
              <:item active={true}>Large</:item>
              <:item>Options</:item>
              """
            ]
          }
        ]
      }
    ]
  end
end
