defmodule Storybook.Layout.Divider do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Layout.Divider.dm_divider/1
  def description, do: "Divider component for separating content sections."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Plain horizontal divider",
        attributes: %{}
      },
      %Variation{
        id: :with_text,
        description: "Divider with centered text label",
        slots: ["Section Title"]
      },
      %VariationGroup{
        id: :colors,
        description: "Color variants with text",
        variations: [
          %Variation{id: :primary, attributes: %{variant: "primary"}, slots: ["Primary"]},
          %Variation{id: :secondary, attributes: %{variant: "secondary"}, slots: ["Secondary"]},
          %Variation{id: :light, attributes: %{variant: "light"}, slots: ["Light"]},
          %Variation{id: :dark, attributes: %{variant: "dark"}, slots: ["Dark"]}
        ]
      },
      %VariationGroup{
        id: :styles,
        description: "Line style variants",
        variations: [
          %Variation{id: :dashed, attributes: %{style: "dashed", variant: "primary"}, slots: ["Dashed"]},
          %Variation{id: :dotted, attributes: %{style: "dotted", variant: "secondary"}, slots: ["Dotted"]}
        ]
      },
      %VariationGroup{
        id: :sizes,
        description: "Thickness variants",
        variations: [
          %Variation{id: :xs, attributes: %{size: "xs", variant: "secondary"}},
          %Variation{id: :sm, attributes: %{size: "sm", variant: "primary"}, slots: ["Small"]},
          %Variation{id: :lg, attributes: %{size: "lg", variant: "primary"}, slots: ["Large"]},
          %Variation{id: :xl, attributes: %{size: "xl", variant: "secondary"}, slots: ["Extra Large"]}
        ]
      },
      %VariationGroup{
        id: :vertical,
        description: "Vertical orientation variants",
        variations: [
          %Variation{id: :vertical_default, attributes: %{orientation: "vertical"}},
          %Variation{id: :vertical_primary, attributes: %{orientation: "vertical", variant: "primary"}},
          %Variation{id: :vertical_large, attributes: %{orientation: "vertical", size: "lg", variant: "dark"}}
        ]
      },
      %Variation{
        id: :gradient,
        description: "Gradient divider",
        attributes: %{variant: "primary", gradient: true}
      },
      %VariationGroup{
        id: :insets,
        description: "Inset variants — margin from container edges",
        variations: [
          %Variation{id: :inset_left, attributes: %{inset: "left"}, slots: ["Left Inset"]},
          %Variation{id: :inset_right, attributes: %{inset: "right"}, slots: ["Right Inset"]},
          %Variation{id: :inset_both, attributes: %{inset: "both", variant: "secondary"}, slots: ["Both Inset"]}
        ]
      },
      %VariationGroup{
        id: :text_positions,
        description: "Text alignment within the divider",
        variations: [
          %Variation{id: :text_left, attributes: %{text_position: "left", variant: "primary"}, slots: ["Left"]},
          %Variation{
            id: :text_right,
            attributes: %{text_position: "right", variant: "secondary"},
            slots: ["Right"]
          }
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
