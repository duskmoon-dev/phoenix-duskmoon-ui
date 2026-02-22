defmodule Storybook.DataEntry.Rating do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.Rating.dm_rating/1
  def description, do: "Star rating input component."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default 3-star rating",
        attributes: %{
          id: "rating-default",
          name: "rating",
          value: 3
        }
      },
      %VariationGroup{
        id: :sizes,
        description: "Size variants",
        variations:
          for size <- ~w(xs sm lg xl) do
            %Variation{
              id: String.to_atom(size),
              attributes: %{id: size, name: size, value: 3, size: size}
            }
          end
      },
      %VariationGroup{
        id: :colors,
        description: "Color variants",
        variations:
          for color <- ~w(primary secondary success error) do
            %Variation{
              id: String.to_atom(color),
              attributes: %{id: color, name: color, value: 4, color: color}
            }
          end
      },
      %Variation{
        id: :readonly,
        description: "Read-only rating display",
        attributes: %{
          id: "rating-readonly",
          name: "readonly",
          value: 4,
          readonly: true
        }
      },
      %Variation{
        id: :disabled,
        description: "Disabled rating input",
        attributes: %{
          id: "rating-disabled",
          name: "disabled",
          value: 2,
          disabled: true
        }
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
          {"xs", "XS"},
          {"sm", "SM"},
          {"lg", "LG"},
          {"xl", "XL"}
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
        id: :readonly,
        label: "Readonly",
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
        id: :compact,
        label: "Compact",
        type: :boolean,
        default: false
      }
    ]
  end
end
