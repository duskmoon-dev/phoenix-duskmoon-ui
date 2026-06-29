defmodule Storybook.Action.Toggle do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Action.Toggle.dm_toggle_group/1
  def description, do: "Toggle button group for selecting between options."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default toggle group with text items",
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
        description: "Icon-only toggle items for text formatting",
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
      },
      %VariationGroup{
        id: :colors,
        description: "Color variants",
        variations: [
          %Variation{
            id: :secondary,
            attributes: %{id: "tg-sec", variant: "filled", color: "secondary"},
            slots: [
              """
              <:item active={true}>A</:item>
              <:item>B</:item>
              <:item>C</:item>
              """
            ]
          },
          %Variation{
            id: :tertiary,
            attributes: %{id: "tg-tert", variant: "filled", color: "tertiary"},
            slots: [
              """
              <:item active={true}>A</:item>
              <:item>B</:item>
              <:item>C</:item>
              """
            ]
          },
          %Variation{
            id: :accent,
            attributes: %{id: "tg-acc", variant: "filled", color: "accent"},
            slots: [
              """
              <:item active={true}>A</:item>
              <:item>B</:item>
              <:item>C</:item>
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
            id: :small,
            attributes: %{id: "tg-sm", size: "sm"},
            slots: [
              """
              <:item active={true}>S</:item>
              <:item>M</:item>
              <:item>L</:item>
              """
            ]
          },
          %Variation{
            id: :large,
            attributes: %{id: "tg-lg", size: "lg"},
            slots: [
              """
              <:item active={true}>Small</:item>
              <:item>Medium</:item>
              <:item>Large</:item>
              """
            ]
          }
        ]
      },
      %Variation{
        id: :vertical,
        description: "Vertical orientation",
        attributes: %{
          id: "tg-vert",
          vertical: true
        },
        slots: [
          """
          <:item active={true}>Top</:item>
          <:item>Middle</:item>
          <:item>Bottom</:item>
          """
        ]
      },
      %Variation{
        id: :exclusive,
        description: "Exclusive (radio-like) selection",
        attributes: %{
          id: "tg-excl",
          exclusive: true
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
        id: :full_width,
        description: "Full-width toggle group",
        attributes: %{
          id: "tg-full",
          full: true,
          variant: "segmented"
        },
        slots: [
          """
          <:item active={true}>Left</:item>
          <:item>Center</:item>
          <:item>Right</:item>
          """
        ]
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :variant,
        label: "Variant",
        type: :select,
        options: [
          {nil, "Default"},
          {"segmented", "Segmented"},
          {"outlined", "Outlined"},
          {"filled", "Filled"},
          {"chip", "Chip"}
        ],
        default: nil
      },
      %{
        id: :color,
        label: "Color",
        type: :select,
        options: [
          {nil, "Default"},
          {"secondary", "Secondary"},
          {"tertiary", "Tertiary"},
          {"accent", "Accent"}
        ],
        default: nil
      },
      %{
        id: :size,
        label: "Size",
        type: :select,
        options: [
          {nil, "Default"},
          {"sm", "SM"},
          {"lg", "LG"}
        ],
        default: nil
      },
      %{
        id: :vertical,
        label: "Vertical",
        type: :boolean,
        default: false
      },
      %{
        id: :exclusive,
        label: "Exclusive",
        type: :boolean,
        default: false
      },
      %{
        id: :full,
        label: "Full Width",
        type: :boolean,
        default: false
      }
    ]
  end
end
