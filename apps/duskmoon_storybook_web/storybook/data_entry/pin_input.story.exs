defmodule Storybook.DataEntry.PinInput do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.PinInput.dm_pin_input/1
  def description, do: "PIN input with circle shape, dots display, and visibility toggle."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          length: 4,
          label: "Enter PIN"
        }
      },
      %Variation{
        id: :circle,
        attributes: %{
          length: 4,
          shape: "circle",
          color: "primary",
          label: "Circle Shape"
        }
      },
      %Variation{
        id: :shapes_and_variants,
        attributes: %{},
        slots: [
          """
          <div class="space-y-4">
            <.dm_pin_input length={4} label="Default" />
            <.dm_pin_input length={4} shape="circle" label="Circle" />
            <.dm_pin_input length={4} variant="filled" label="Filled" />
            <.dm_pin_input length={6} compact={true} label="Compact" />
            <.dm_pin_input length={4} dots={true} label="Dots" />
          </div>
          """
        ]
      },
      %Variation{
        id: :states,
        attributes: %{},
        slots: [
          """
          <div class="space-y-4">
            <.dm_pin_input length={4} error={true} error_message="Invalid PIN" label="Error" />
            <.dm_pin_input length={4} success={true} label="Success" helper="PIN verified!" />
            <.dm_pin_input length={4} disabled={true} label="Disabled" />
          </div>
          """
        ]
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :shape,
        label: "Shape",
        type: :select,
        options: [
          {nil, "Default"},
          {"circle", "Circle"}
        ],
        default: nil
      },
      %{
        id: :variant,
        label: "Variant",
        type: :select,
        options: [
          {nil, "Default"},
          {"filled", "Filled"}
        ],
        default: nil
      },
      %{
        id: :compact,
        label: "Compact",
        type: :boolean,
        default: false
      },
      %{
        id: :dots,
        label: "Dots",
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
