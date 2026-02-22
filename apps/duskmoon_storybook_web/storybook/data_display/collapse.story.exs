defmodule Storybook.DataDisplay.Collapse do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Collapse.dm_collapse/1
  def description, do: "Collapsible content panel with trigger and content slots."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "col-default"
        },
        slots: [
          """
          <:trigger>Click to expand</:trigger>
          <:content>This is the collapsible content area.</:content>
          """
        ]
      },
      %Variation{
        id: :card_variant,
        attributes: %{
          id: "col-card",
          variant: "card"
        },
        slots: [
          """
          <:trigger>Card style collapse</:trigger>
          <:content>Content inside a card-styled collapse panel.</:content>
          """
        ]
      },
      %Variation{
        id: :open,
        attributes: %{
          id: "col-open",
          open: true,
          variant: "bordered",
          color: "primary"
        },
        slots: [
          """
          <:trigger>Open by default</:trigger>
          <:content>This panel starts open with primary color border.</:content>
          """
        ]
      },
      %VariationGroup{
        id: :variants,
        description: "Style variants",
        variations: [
          %Variation{
            id: :ghost,
            attributes: %{
              id: "c-ghost",
              variant: "ghost"
            },
            slots: [
              """
              <:trigger>Ghost variant</:trigger>
              <:content>Ghost content</:content>
              """
            ]
          },
          %Variation{
            id: :divider,
            attributes: %{
              id: "c-divider",
              variant: "divider"
            },
            slots: [
              """
              <:trigger>Divider variant</:trigger>
              <:content>Divider content</:content>
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
            attributes: %{id: "c-secondary", variant: "bordered", color: "secondary"},
            slots: [
              """
              <:trigger>Secondary color</:trigger>
              <:content>Secondary colored border.</:content>
              """
            ]
          },
          %Variation{
            id: :tertiary,
            attributes: %{id: "c-tertiary", variant: "bordered", color: "tertiary"},
            slots: [
              """
              <:trigger>Tertiary color</:trigger>
              <:content>Tertiary colored border.</:content>
              """
            ]
          },
          %Variation{
            id: :accent,
            attributes: %{id: "c-accent", variant: "card", color: "accent"},
            slots: [
              """
              <:trigger>Accent color</:trigger>
              <:content>Accent colored card collapse.</:content>
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
            id: :size_sm,
            attributes: %{id: "c-sm", variant: "card", size: "sm"},
            slots: [
              """
              <:trigger>Small collapse</:trigger>
              <:content>Compact small-sized collapse.</:content>
              """
            ]
          },
          %Variation{
            id: :size_lg,
            attributes: %{id: "c-lg", variant: "card", size: "lg"},
            slots: [
              """
              <:trigger>Large collapse</:trigger>
              <:content>Spacious large-sized collapse.</:content>
              """
            ]
          }
        ]
      },
      %VariationGroup{
        id: :animations,
        description: "Animation styles",
        variations: [
          %Variation{
            id: :fade,
            attributes: %{id: "c-fade", variant: "card", animation: "fade"},
            slots: [
              """
              <:trigger>Fade animation</:trigger>
              <:content>Content fades in and out.</:content>
              """
            ]
          },
          %Variation{
            id: :slide,
            attributes: %{id: "c-slide", variant: "card", animation: "slide"},
            slots: [
              """
              <:trigger>Slide animation</:trigger>
              <:content>Content slides in and out.</:content>
              """
            ]
          },
          %Variation{
            id: :fast,
            attributes: %{id: "c-fast", variant: "card", animation: "slide", speed: "fast"},
            slots: [
              """
              <:trigger>Fast slide</:trigger>
              <:content>Fast animation speed.</:content>
              """
            ]
          },
          %Variation{
            id: :slow,
            attributes: %{id: "c-slow", variant: "card", animation: "fade", speed: "slow"},
            slots: [
              """
              <:trigger>Slow fade</:trigger>
              <:content>Slow animation speed.</:content>
              """
            ]
          }
        ]
      },
      %Variation{
        id: :nested,
        description: "Nested collapse with indentation",
        attributes: %{id: "c-nested", variant: "bordered", nested: true},
        slots: [
          """
          <:trigger>Nested panel</:trigger>
          <:content>Indented content with left border accent.</:content>
          """
        ]
      },
      %Variation{
        id: :disabled,
        description: "Disabled collapse",
        attributes: %{id: "c-disabled", variant: "card", disabled: true},
        slots: [
          """
          <:trigger>Disabled (cannot open)</:trigger>
          <:content>This content should not be accessible.</:content>
          """
        ]
      }
    ]
  end
end
