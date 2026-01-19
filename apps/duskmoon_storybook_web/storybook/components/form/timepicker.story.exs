defmodule Storybook.Components.Form.Timepicker do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Form.Input.dm_input/1
  def description, do: "An enhanced time picker with dropdown interface."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          type: "timepicker",
          label: "Meeting Time",
          name: "meeting_time",
          value: nil
        }
      },
      %Variation{
        id: :with_value,
        attributes: %{
          type: "timepicker",
          label: "Alarm Time",
          name: "alarm_time",
          value: "09:30"
        }
      },
      %Variation{
        id: :with_color,
        attributes: %{
          type: "timepicker",
          label: "Break Time",
          name: "break_time",
          value: nil,
          color: "warning"
        }
      },
      %Variation{
        id: :small_size,
        attributes: %{
          type: "timepicker",
          label: "Reminder",
          name: "reminder",
          value: nil,
          size: "sm"
        }
      },
      %Variation{
        id: :with_errors,
        attributes: %{
          type: "timepicker",
          label: "Appointment Time",
          name: "appointment_time",
          value: nil,
          errors: ["Time must be during business hours"]
        }
      }
    ]
  end
end
