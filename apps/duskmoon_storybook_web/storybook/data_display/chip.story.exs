defmodule Storybook.DataDisplay.Chip do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Chip.dm_chip/1

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default chip",
        slots: ["Default"]
      },
      %Variation{
        id: :colors,
        description: "Color variants",
        attributes: %{color: "primary"},
        slots: ["Primary"]
      },
      %Variation{
        id: :outlined,
        description: "Outlined variant",
        attributes: %{variant: "outlined", color: "secondary"},
        slots: ["Outlined"]
      },
      %Variation{
        id: :soft,
        description: "Soft variant",
        attributes: %{variant: "soft", color: "tertiary"},
        slots: ["Soft"]
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
      },
      %Variation{
        id: :sizes,
        description: "Small size",
        attributes: %{size: "sm", color: "warning"},
        slots: ["Small"]
      }
    ]
  end
end
