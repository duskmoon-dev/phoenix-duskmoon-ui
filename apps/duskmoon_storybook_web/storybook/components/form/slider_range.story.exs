defmodule Storybook.Components.Form.SliderRange do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Form.Input.dm_input/1
  def description, do: "A dual-handle range slider for min/max values."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          type: "slider_range",
          label: "Price Range",
          name: "price_range",
          value: [100, 500],
          min: 0,
          max: 1000
        }
      },
      %Variation{
        id: :with_steps,
        attributes: %{
          type: "slider_range",
          label: "Age Range",
          name: "age_range",
          value: [25, 35],
          min: 18,
          max: 65,
          step: 1
        }
      },
      %Variation{
        id: :with_color,
        attributes: %{
          type: "slider_range",
          label: "Score Range",
          name: "score_range",
          value: [70, 90],
          min: 0,
          max: 100,
          color: "info"
        }
      },
      %Variation{
        id: :small_size,
        attributes: %{
          type: "slider_range",
          label: "Zoom Range",
          name: "zoom_range",
          value: [50, 150],
          min: 25,
          max: 200,
          size: "sm"
        }
      },
      %Variation{
        id: :with_errors,
        attributes: %{
          type: "slider_range",
          label: "Budget Range",
          name: "budget_range",
          value: [1000, 5000],
          min: 500,
          max: 10000,
          errors: ["Range must be at least 2000 wide"]
        }
      }
    ]
  end
end
