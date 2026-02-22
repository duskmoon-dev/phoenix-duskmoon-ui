defmodule Storybook.DataDisplay.Chip do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Chip.dm_chip/1
  def description, do: "Compact label for categories, tags, and selections with color, size, and state variants."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default chip (no color)",
        slots: ["Default"]
      },
      %VariationGroup{
        id: :colors,
        description: "Color variants",
        variations:
          for color <- ~w(primary secondary tertiary success warning error info) do
            %Variation{
              id: String.to_atom(color),
              attributes: %{color: color},
              slots: [String.capitalize(color)]
            }
          end
      },
      %VariationGroup{
        id: :variants,
        description: "Fill style variants",
        variations: [
          %Variation{id: :outlined, attributes: %{variant: "outlined", color: "primary"}, slots: ["Outlined"]},
          %Variation{id: :soft, attributes: %{variant: "soft", color: "secondary"}, slots: ["Soft"]}
        ]
      },
      %VariationGroup{
        id: :sizes,
        description: "Size variants",
        variations: [
          %Variation{id: :small, attributes: %{size: "sm", color: "primary"}, slots: ["Small"]},
          %Variation{id: :medium, attributes: %{size: "md", color: "primary"}, slots: ["Medium"]},
          %Variation{id: :large, attributes: %{size: "lg", color: "primary"}, slots: ["Large"]}
        ]
      },
      %VariationGroup{
        id: :states,
        description: "Interactive states",
        variations: [
          %Variation{id: :deletable, attributes: %{color: "error", deletable: true}, slots: ["Remove me"]},
          %Variation{id: :selected, attributes: %{color: "success", selected: true}, slots: ["Active"]},
          %Variation{id: :disabled, attributes: %{color: "info", disabled: true}, slots: ["Disabled"]}
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
          {"filled", "Filled"},
          {"outlined", "Outlined"},
          {"soft", "Soft"}
        ],
        default: "filled"
      },
      %{
        id: :color,
        label: "Color",
        type: :select,
        options: [
          {nil, "Default"},
          {"primary", "Primary"},
          {"secondary", "Secondary"},
          {"tertiary", "Tertiary"},
          {"success", "Success"},
          {"warning", "Warning"},
          {"error", "Error"},
          {"info", "Info"}
        ],
        default: nil
      },
      %{
        id: :size,
        label: "Size",
        type: :select,
        options: [
          {"sm", "SM"},
          {"md", "MD"},
          {"lg", "LG"}
        ],
        default: "md"
      },
      %{
        id: :deletable,
        label: "Deletable",
        type: :boolean,
        default: false
      },
      %{
        id: :selected,
        label: "Selected",
        type: :boolean,
        default: false
      },
      %{
        id: :disabled,
        label: "Disabled",
        type: :boolean,
        default: false
      }
    ]
  end
end
