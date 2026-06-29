defmodule Storybook.DataDisplay.Badge do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Badge.dm_badge/1
  def description, do: "Badge component for status indicators and labels."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default badge with no variant",
        slots: ["New"]
      },
      %VariationGroup{
        id: :colors,
        description: "Color variants",
        variations:
          for color <- ~w(success error warning info secondary accent) do
            %Variation{
              id: String.to_atom(color),
              attributes: %{variant: color},
              slots: [String.capitalize(color)]
            }
          end
      },
      %VariationGroup{
        id: :sizes,
        description: "Size variants",
        variations: [
          %Variation{id: :xs, attributes: %{size: "xs"}, slots: ["Tiny"]},
          %Variation{id: :sm, attributes: %{size: "sm", variant: "success"}, slots: ["Small"]},
          %Variation{id: :md, attributes: %{size: "md", variant: "primary"}, slots: ["Medium"]},
          %Variation{id: :lg, attributes: %{size: "lg", variant: "error"}, slots: ["Large"]}
        ]
      },
      %VariationGroup{
        id: :outlines,
        description: "Outline style — transparent fill with colored border",
        variations:
          for color <- ~w(primary success warning) do
            %Variation{
              id: String.to_atom("outline_#{color}"),
              attributes: %{variant: color, outline: true},
              slots: [String.capitalize(color)]
            }
          end
      },
      %Variation{
        id: :ghost_style,
        description: "Ghost variant with subtle styling",
        attributes: %{variant: "ghost"},
        slots: ["Ghost"]
      },
      %VariationGroup{
        id: :soft_variants,
        description: "Soft style — muted background with colored text",
        variations:
          for color <- ~w(primary success error) do
            %Variation{
              id: String.to_atom("soft_#{color}"),
              attributes: %{variant: color, soft: true},
              slots: ["Soft #{String.capitalize(color)}"]
            }
          end
      },
      %VariationGroup{
        id: :pills,
        description: "Pill shape — fully rounded corners",
        variations: [
          %Variation{id: :pill_primary, attributes: %{variant: "primary", pill: true}, slots: ["Pill"]},
          %Variation{id: :pill_success, attributes: %{variant: "success", pill: true}, slots: ["Done"]}
        ]
      },
      %VariationGroup{
        id: :dots,
        description: "Dot indicator — small circle without text",
        variations:
          for color <- ~w(error success warning) do
            %Variation{
              id: String.to_atom("dot_#{color}"),
              attributes: %{variant: color, dot: true},
              slots: [""]
            }
          end
      },
      %VariationGroup{
        id: :use_cases,
        description: "Real-world use cases",
        variations: [
          %Variation{id: :status_online, attributes: %{variant: "success", size: "sm"}, slots: ["✓ Online"]},
          %Variation{id: :status_offline, attributes: %{variant: "error", size: "sm"}, slots: ["✗ Offline"]},
          %Variation{id: :count, attributes: %{variant: "accent"}, slots: ["42"]},
          %Variation{id: :notification, attributes: %{variant: "error", size: "xs"}, slots: ["5"]}
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
          {"primary", "Primary"},
          {"secondary", "Secondary"},
          {"tertiary", "Tertiary"},
          {"accent", "Accent"},
          {"info", "Info"},
          {"success", "Success"},
          {"warning", "Warning"},
          {"error", "Error"},
          {"ghost", "Ghost"},
          {"neutral", "Neutral"}
        ],
        default: "primary"
      },
      %{
        id: :size,
        label: "Size",
        type: :select,
        options: [
          {"xs", "XS"},
          {"sm", "SM"},
          {"md", "MD"},
          {"lg", "LG"}
        ],
        default: "md"
      },
      %{
        id: :outline,
        label: "Outline",
        type: :boolean,
        default: false
      },
      %{
        id: :soft,
        label: "Soft",
        type: :boolean,
        default: false
      },
      %{
        id: :pill,
        label: "Pill",
        type: :boolean,
        default: false
      },
      %{
        id: :dot,
        label: "Dot",
        type: :boolean,
        default: false
      }
    ]
  end
end