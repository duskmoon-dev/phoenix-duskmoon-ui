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
      %Variation{
        id: :colors,
        attributes: %{},
        slots: [
          """
          <div class="space-y-4">
            <.dm_segment_control id="seg-primary" color="primary">
              <:item active={true}>One</:item>
              <:item>Two</:item>
              <:item>Three</:item>
            </.dm_segment_control>
            <.dm_segment_control id="seg-secondary" color="secondary">
              <:item active={true}>One</:item>
              <:item>Two</:item>
            </.dm_segment_control>
          </div>
          """
        ]
      },
      %Variation{
        id: :sizes,
        attributes: %{},
        slots: [
          """
          <div class="space-y-4">
            <.dm_segment_control id="seg-sm" size="sm">
              <:item active={true}>Small</:item>
              <:item>Options</:item>
            </.dm_segment_control>
            <.dm_segment_control id="seg-lg" size="lg">
              <:item active={true}>Large</:item>
              <:item>Options</:item>
            </.dm_segment_control>
          </div>
          """
        ]
      }
    ]
  end
end
