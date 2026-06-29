defmodule Storybook.DataEntry.Slider do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.Slider.dm_slider/1
  def description, do: "Range slider component for numeric inputs."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default range slider",
        attributes: %{
          id: "slider-default",
          name: "volume",
          label: "Volume",
          min: 0,
          max: 100,
          value: 75
        }
      },
      %Variation{
        id: :with_steps,
        description: "Slider with discrete step increments",
        attributes: %{
          id: "slider-steps",
          name: "brightness",
          label: "Brightness",
          min: 0,
          max: 10,
          step: 1,
          value: 5
        }
      },
      %VariationGroup{
        id: :sizes,
        description: "Size variants",
        variations:
          for size <- ~w(xs sm md lg) do
            %Variation{
              id: String.to_atom(size),
              attributes: %{id: size, name: size, label: "#{String.upcase(size)} slider", size: size, value: "50"}
            }
          end
      },
      %VariationGroup{
        id: :colors,
        description: "Color variants",
        variations:
          for color <- ~w(primary secondary accent success warning error tertiary info) do
            %Variation{
              id: String.to_atom(color),
              attributes: %{
                id: color,
                name: color,
                label: String.capitalize(color),
                color: color,
                value: "60"
              }
            }
          end
      },
      %Variation{
        id: :vertical,
        description: "Vertically oriented slider",
        attributes: %{
          id: "slider-vertical",
          name: "vertical",
          label: "Vertical",
          min: 0,
          max: 100,
          value: 60,
          vertical: true
        }
      },
      %Variation{
        id: :no_value_label,
        description: "Slider with hidden value label",
        attributes: %{
          id: "slider-no-label",
          name: "quality",
          label: "Audio Quality",
          min: 0,
          max: 100,
          value: 80,
          show_value: false
        }
      },
      %Variation{
        id: :disabled,
        description: "Disabled slider",
        attributes: %{
          id: "slider-disabled",
          name: "slider_disabled",
          label: "Disabled Slider",
          min: 0,
          max: 100,
          value: 50,
          disabled: true
        }
      },
      %VariationGroup{
        id: :validation_states,
        description: "Validation states",
        variations: [
          %Variation{
            id: :success_state,
            attributes: %{
              id: "sl-vs-success",
              name: "sl_vs_success",
              label: "Valid Range",
              state: "success",
              value: 75
            }
          },
          %Variation{
            id: :warning_state,
            attributes: %{
              id: "sl-vs-warning",
              name: "sl_vs_warning",
              label: "Review Range",
              state: "warning",
              value: 25
            }
          }
        ]
      },
      %Variation{
        id: :with_helper,
        description: "Helper text below slider",
        attributes: %{
          id: "slider-helper",
          name: "slider_helper",
          label: "Opacity",
          helper: "Adjust the opacity level (0–100%)",
          min: 0,
          max: 100,
          value: 80
        }
      },
      %Variation{
        id: :with_errors,
        description: "Slider with error messages",
        attributes: %{
          id: "slider-errors",
          name: "slider_errors",
          label: "Priority",
          errors: ["Value must be between 10 and 90."],
          min: 0,
          max: 100,
          value: 50
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
          {"md", "MD"},
          {"lg", "LG"}
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
          {"accent", "Accent"},
          {"info", "Info"},
          {"success", "Success"},
          {"warning", "Warning"},
          {"error", "Error"}
        ],
        default: nil
      },
      %{
        id: :show_value,
        label: "Show Value",
        type: :boolean,
        default: true
      },
      %{
        id: :disabled,
        label: "Disabled",
        type: :boolean,
        default: false
      }
    ]
  end
end
