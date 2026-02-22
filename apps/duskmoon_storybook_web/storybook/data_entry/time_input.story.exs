defmodule Storybook.DataEntry.TimeInput do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.TimeInput.dm_time_input/1
  def description, do: "Segmented time input with hour, minute, second fields."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default hour and minute input",
        attributes: %{
          id: "time-default"
        }
      },
      %Variation{
        id: :with_seconds,
        description: "Time input including seconds field",
        attributes: %{
          id: "time-seconds",
          show_seconds: true
        }
      },
      %Variation{
        id: :with_period,
        description: "Time input with AM/PM toggle",
        attributes: %{
          id: "time-period",
          show_period: true
        }
      },
      %Variation{
        id: :variants,
        description: "Size, variant, color, and error showcase",
        attributes: %{},
        slots: [
          """
          <div class="space-y-4">
            <.dm_time_input id="t-sm" size="sm" />
            <.dm_time_input id="t-def" />
            <.dm_time_input id="t-lg" size="lg" />
            <.dm_time_input id="t-filled" variant="filled" />
            <.dm_time_input id="t-primary" color="primary" />
            <.dm_time_input id="t-error" error={true} />
          </div>
          """
        ]
      }
    ]
  end

  def modifiers do
    [
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
        id: :color,
        label: "Color",
        type: :select,
        options: [
          {nil, "Default"},
          {"primary", "Primary"},
          {"secondary", "Secondary"},
          {"tertiary", "Tertiary"},
          {"accent", "Accent"},
          {"info", "Info"},
          {"success", "Success"},
          {"warning", "Warning"},
          {"error", "Error"}
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
        id: :show_seconds,
        label: "Show Seconds",
        type: :boolean,
        default: false
      },
      %{
        id: :show_period,
        label: "Show Period",
        type: :boolean,
        default: false
      },
      %{
        id: :disabled,
        label: "Disabled",
        type: :boolean,
        default: false
      },
      %{
        id: :error,
        label: "Error",
        type: :boolean,
        default: false
      }
    ]
  end
end
