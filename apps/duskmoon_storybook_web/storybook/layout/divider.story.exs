defmodule Storybook.Layout.Divider do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Layout.Divider.dm_divider/1
  def description, do: "Divider component for separating content sections."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{}
      },
      %Variation{
        id: :with_text,
        slots: [
          "Section Title"
        ]
      },
      %Variation{
        id: :vertical_divider,
        attributes: %{
          orientation: "vertical"
        }
      },
      %Variation{
        id: :primary_color,
        attributes: %{
          variant: "primary"
        },
        slots: [
          "Primary Section"
        ]
      },
      %Variation{
        id: :secondary_colored,
        attributes: %{
          variant: "secondary"
        },
        slots: [
          "Secondary Section"
        ]
      },
      %Variation{
        id: :light_divider,
        attributes: %{
          variant: "light"
        },
        slots: [
          "Light Divider"
        ]
      },
      %Variation{
        id: :dark_divider,
        attributes: %{
          variant: "dark"
        },
        slots: [
          "Dark Divider"
        ]
      },
      %Variation{
        id: :dashed_variant,
        attributes: %{
          style: "dashed",
          variant: "primary"
        },
        slots: [
          "Dashed Divider"
        ]
      },
      %Variation{
        id: :dotted_variant,
        attributes: %{
          style: "dotted",
          variant: "secondary"
        },
        slots: [
          "Dotted Divider"
        ]
      },
      %Variation{
        id: :small_divider,
        attributes: %{
          size: "xs",
          variant: "secondary"
        }
      },
      %Variation{
        id: :large_divider,
        attributes: %{
          size: "lg",
          variant: "primary"
        },
        slots: [
          "Large Divider"
        ]
      },
      %Variation{
        id: :settings_section,
        attributes: %{
          variant: "primary",
          style: "dashed"
        },
        slots: [
          "Settings"
        ]
      },
      %Variation{
        id: :vertical_with_color,
        attributes: %{
          orientation: "vertical",
          variant: "primary"
        }
      },
      %Variation{
        id: :vertical_large,
        attributes: %{
          orientation: "vertical",
          size: "lg",
          variant: "dark"
        }
      },
      %Variation{
        id: :size_sm,
        attributes: %{
          size: "sm",
          variant: "primary"
        },
        slots: [
          "Small"
        ]
      },
      %Variation{
        id: :size_xl,
        attributes: %{
          size: "xl",
          variant: "secondary"
        },
        slots: [
          "Extra Large"
        ]
      },
      %Variation{
        id: :gradient,
        description: "Gradient divider",
        attributes: %{
          variant: "primary",
          gradient: true
        }
      },
      %Variation{
        id: :inset_left,
        description: "Left-inset divider",
        attributes: %{
          inset: "left"
        },
        slots: [
          "Left Inset"
        ]
      },
      %Variation{
        id: :inset_right,
        description: "Right-inset divider",
        attributes: %{
          inset: "right"
        },
        slots: [
          "Right Inset"
        ]
      },
      %Variation{
        id: :inset_both,
        description: "Both-sides inset divider",
        attributes: %{
          inset: "both",
          variant: "secondary"
        },
        slots: [
          "Both Inset"
        ]
      },
      %Variation{
        id: :text_left,
        description: "Left-aligned text",
        attributes: %{
          text_position: "left",
          variant: "primary"
        },
        slots: [
          "Left Text"
        ]
      },
      %Variation{
        id: :text_right,
        description: "Right-aligned text",
        attributes: %{
          text_position: "right",
          variant: "secondary"
        },
        slots: [
          "Right Text"
        ]
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :orientation,
        label: "Orientation",
        type: :select,
        options: [
          {"horizontal", "Horizontal"},
          {"vertical", "Vertical"}
        ],
        default: "horizontal"
      },
      %{
        id: :variant,
        label: "Variant",
        type: :select,
        options: [
          {nil, "Default"},
          {"base", "Base"},
          {"primary", "Primary"},
          {"secondary", "Secondary"},
          {"light", "Light"},
          {"dark", "Dark"}
        ],
        default: nil
      },
      %{
        id: :style,
        label: "Style",
        type: :select,
        options: [
          {"solid", "Solid"},
          {"dashed", "Dashed"},
          {"dotted", "Dotted"}
        ],
        default: "solid"
      },
      %{
        id: :size,
        label: "Size",
        type: :select,
        options: [
          {nil, "Default"},
          {"xs", "XS"},
          {"sm", "SM"},
          {"md", "MD"},
          {"lg", "LG"},
          {"xl", "XL"}
        ],
        default: nil
      },
      %{
        id: :gradient,
        label: "Gradient",
        type: :boolean,
        default: false
      }
    ]
  end
end
