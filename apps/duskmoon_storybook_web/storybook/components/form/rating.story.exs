defmodule Storybook.Components.Form.Rating do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Form.Input.dm_input/1
  def description, do: "A star rating component for numerical ratings."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          type: "rating",
          label: "Rating",
          name: "rating",
          value: 3
        }
      },
      %Variation{
        id: :max_10,
        attributes: %{
          type: "rating",
          label: "Score",
          name: "score",
          value: 7,
          max: 10
        }
      },
      %Variation{
        id: :with_color,
        attributes: %{
          type: "rating",
          label: "Experience",
          name: "experience",
          value: 4,
          color: "success"
        }
      },
      %Variation{
        id: :small_size,
        attributes: %{
          type: "rating",
          label: "Priority",
          name: "priority",
          value: 2,
          size: "sm"
        }
      },
      %Variation{
        id: :readonly,
        attributes: %{
          type: "rating",
          label: "Average Rating",
          name: "avg_rating",
          value: 4,
          readonly: true
        }
      },
      %Variation{
        id: :with_errors,
        attributes: %{
          type: "rating",
          label: "Quality",
          name: "quality",
          value: 0,
          errors: ["Rating is required"]
        }
      }
    ]
  end
end
