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
      %Variation{
        id: :primary,
        description: "Primary color",
        attributes: %{color: "primary"},
        slots: ["Primary"]
      },
      %Variation{
        id: :secondary,
        description: "Secondary color",
        attributes: %{color: "secondary"},
        slots: ["Secondary"]
      },
      %Variation{
        id: :tertiary,
        description: "Tertiary color",
        attributes: %{color: "tertiary"},
        slots: ["Tertiary"]
      },
      %Variation{
        id: :success,
        description: "Success color",
        attributes: %{color: "success"},
        slots: ["Success"]
      },
      %Variation{
        id: :warning,
        description: "Warning color",
        attributes: %{color: "warning"},
        slots: ["Warning"]
      },
      %Variation{
        id: :error,
        description: "Error color",
        attributes: %{color: "error"},
        slots: ["Error"]
      },
      %Variation{
        id: :info,
        description: "Info color",
        attributes: %{color: "info"},
        slots: ["Info"]
      },
      %Variation{
        id: :outlined,
        description: "Outlined variant",
        attributes: %{variant: "outlined", color: "primary"},
        slots: ["Outlined"]
      },
      %Variation{
        id: :soft,
        description: "Soft variant",
        attributes: %{variant: "soft", color: "secondary"},
        slots: ["Soft"]
      },
      %Variation{
        id: :small,
        description: "Small size",
        attributes: %{size: "sm", color: "primary"},
        slots: ["Small"]
      },
      %Variation{
        id: :medium,
        description: "Medium size (default)",
        attributes: %{size: "md", color: "primary"},
        slots: ["Medium"]
      },
      %Variation{
        id: :large,
        description: "Large size",
        attributes: %{size: "lg", color: "primary"},
        slots: ["Large"]
      },
      %Variation{
        id: :deletable,
        description: "Deletable chip",
        attributes: %{color: "error", deletable: true},
        slots: ["Remove me"]
      },
      %Variation{
        id: :selected,
        description: "Selected chip",
        attributes: %{color: "success", selected: true},
        slots: ["Active"]
      },
      %Variation{
        id: :disabled,
        description: "Disabled chip",
        attributes: %{color: "info", disabled: true},
        slots: ["Disabled"]
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
