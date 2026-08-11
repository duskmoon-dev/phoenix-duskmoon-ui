defmodule Storybook.DataDisplay.Datetime do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Datetime.dm_datetime/1

  def description,
    do: "Display an ISO date or datetime with token-based formatting and time-zone conversion."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default date and 24-hour time format",
        attributes: %{value: "2026-08-11T14:30:45Z"}
      },
      %Variation{
        id: :formatted,
        description: "Custom format with literal text and an IANA time zone",
        attributes: %{
          value: "2026-08-11T14:30:45Z",
          format: "DD/MM/YYYY [at] h:mm A",
          time_zone: "Asia/Shanghai"
        }
      },
      %Variation{
        id: :date_only,
        description: "Date-only wall-clock value",
        attributes: %{value: "2026-08-11", format: "DD/MM/YYYY"}
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :format,
        label: "Format",
        type: :select,
        options: [
          {"YYYY-MM-DD HH:mm", "24-hour"},
          {"DD/MM/YYYY [at] h:mm A", "12-hour with date"},
          {"YYYY.MM.DD HH:mm:ss", "With seconds"}
        ],
        default: "YYYY-MM-DD HH:mm"
      },
      %{
        id: :time_zone,
        label: "Time Zone",
        type: :select,
        options: [
          {nil, "Browser local"},
          {"UTC", "UTC"},
          {"Asia/Shanghai", "Asia/Shanghai"},
          {"America/New_York", "America/New_York"}
        ],
        default: nil
      }
    ]
  end
end
