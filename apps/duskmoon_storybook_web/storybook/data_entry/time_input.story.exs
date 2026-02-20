defmodule Storybook.DataEntry.TimeInput do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.TimeInput.dm_time_input/1
  def description, do: "Segmented time input with hour, minute, second fields."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "time-default"
        }
      },
      %Variation{
        id: :with_seconds,
        attributes: %{
          id: "time-seconds",
          show_seconds: true
        }
      },
      %Variation{
        id: :with_period,
        attributes: %{
          id: "time-period",
          show_period: true
        }
      },
      %Variation{
        id: :variants,
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
end
