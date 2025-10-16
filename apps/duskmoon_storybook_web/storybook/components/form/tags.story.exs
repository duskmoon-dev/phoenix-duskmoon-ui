defmodule Storybook.Components.Form.Tags do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Form.dm_input/1
  def description, do: "A tags input component for multiple values."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          type: "tags",
          label: "Skills",
          name: "skills",
          value: ["Elixir", "Phoenix", "LiveView"]
        }
      },
      %Variation{
        id: :empty,
        attributes: %{
          type: "tags",
          label: "Interests",
          name: "interests",
          value: []
        }
      },
      %Variation{
        id: :with_color,
        attributes: %{
          type: "tags",
          label: "Categories",
          name: "categories",
          value: ["Technology", "Design", "Business"],
          color: "success"
        }
      },
      %Variation{
        id: :small_size,
        attributes: %{
          type: "tags",
          label: "Labels",
          name: "labels",
          value: ["urgent", "important"],
          size: "sm"
        }
      },
      %Variation{
        id: :with_errors,
        attributes: %{
          type: "tags",
          label: "Keywords",
          name: "keywords",
          value: [],
          errors: ["At least one keyword is required"]
        }
      }
    ]
  end
end
