defmodule Storybook.Components.Form.Datepicker do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Form.dm_input/1
  def description, do: "An advanced date picker with calendar UI."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          type: "datepicker",
          label: "Birth Date",
          name: "birth_date",
          value: nil
        }
      },
      %Variation{
        id: :with_value,
        attributes: %{
          type: "datepicker",
          label: "Start Date",
          name: "start_date",
          value: "2024-01-15"
        }
      },
      %Variation{
        id: :with_color,
        attributes: %{
          type: "datepicker",
          label: "Event Date",
          name: "event_date",
          value: nil,
          color: "info"
        }
      },
      %Variation{
        id: :small_size,
        attributes: %{
          type: "datepicker",
          label: "Deadline",
          name: "deadline",
          value: nil,
          size: "sm"
        }
      },
      %Variation{
        id: :with_errors,
        attributes: %{
          type: "datepicker",
          label: "Appointment",
          name: "appointment",
          value: nil,
          errors: ["Date must be in the future"]
        }
      }
    ]
  end
end
