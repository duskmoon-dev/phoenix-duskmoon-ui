defmodule Storybook.Action.Toggle do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Action.Toggle.dm_toggle_group/1
  def description, do: "Toggle button group for selecting between options."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "toggle-default"
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
        id: :with_icons,
        attributes: %{
          id: "toggle-icons"
        },
        slots: [
          """
          <:item active={true} icon="format-bold" icon_only={true}></:item>
          <:item icon="format-italic" icon_only={true}></:item>
          <:item icon="format-underline" icon_only={true}></:item>
          """
        ]
      },
      %VariationGroup{
        id: :variants,
        description: "Style variants",
        variations: [
          %Variation{
            id: :segmented,
            attributes: %{id: "seg", variant: "segmented"},
            slots: [
              """
              <:item active={true}>Segmented</:item>
              <:item>Style</:item>
              """
            ]
          },
          %Variation{
            id: :outlined,
            attributes: %{id: "out", variant: "outlined"},
            slots: [
              """
              <:item active={true}>Outlined</:item>
              <:item>Style</:item>
              """
            ]
          },
          %Variation{
            id: :filled,
            attributes: %{id: "fill", variant: "filled"},
            slots: [
              """
              <:item active={true}>Filled</:item>
              <:item>Style</:item>
              """
            ]
          },
          %Variation{
            id: :chip,
            attributes: %{id: "chip", variant: "chip"},
            slots: [
              """
              <:item active={true}>Chip</:item>
              <:item>Style</:item>
              """
            ]
          }
        ]
      }
    ]
  end
end
