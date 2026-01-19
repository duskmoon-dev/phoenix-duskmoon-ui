defmodule Storybook.Components.Form.RangeSlider do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Form.Input.dm_input/1
  def description, do: "A range slider input with visual feedback and value display."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          type: "range_slider",
          label: "Volume",
          name: "volume",
          value: 50,
          min: 0,
          max: 100
        }
      },
      %Variation{
        id: :with_steps,
        attributes: %{
          type: "range_slider",
          label: "Rating",
          name: "rating",
          value: 3,
          min: 1,
          max: 5,
          step: 1
        }
      },
      %Variation{
        id: :with_color,
        attributes: %{
          type: "range_slider",
          label: "Progress",
          name: "progress",
          value: 75,
          min: 0,
          max: 100,
          color: "success"
        }
      },
      %Variation{
        id: :small_size,
        attributes: %{
          type: "range_slider",
          label: "Zoom",
          name: "zoom",
          value: 100,
          min: 50,
          max: 200,
          size: "sm"
        }
      },
      %Variation{
        id: :with_errors,
        attributes: %{
          type: "range_slider",
          label: "Threshold",
          name: "threshold",
          value: 10,
          min: 0,
          max: 20,
          errors: ["Value must be between 5 and 15"]
        }
      }
    ]
  end
end
