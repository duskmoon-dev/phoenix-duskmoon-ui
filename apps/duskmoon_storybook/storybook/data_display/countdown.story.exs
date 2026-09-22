defmodule Storybook.DataDisplay.Countdown do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Countdown.dm_countdown/1

  def description,
    do: "Application-owned countdown values; no client timer or per-tick live announcement."

  def variations do
    [
      %Variation{id: :seconds, attributes: %{value: 42, label: "Seconds remaining"}},
      %Variation{id: :large, attributes: %{value: 8, label: "Days until launch", size: "lg"}}
    ]
  end
end
