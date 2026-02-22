defmodule Storybook.DataEntry.Slider do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.Slider.dm_slider/1
  def description, do: "Range slider component for numeric inputs."

  def variations do
    [
      %Variation{
        id: :default,
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
        variations: [
          %Variation{
            id: :xs,
            attributes: %{id: "xs", name: "xs", label: "XS slider", size: "xs", value: "50"}
          },
          %Variation{
            id: :sm,
            attributes: %{id: "sm", name: "sm", label: "SM slider", size: "sm", value: "50"}
          },
          %Variation{
            id: :md,
            attributes: %{id: "md", name: "md", label: "MD slider", size: "md", value: "50"}
          },
          %Variation{
            id: :lg,
            attributes: %{id: "lg", name: "lg", label: "LG slider", size: "lg", value: "50"}
          }
        ]
      },
      %VariationGroup{
        id: :colors,
        description: "Color variants",
        variations: [
          %Variation{
            id: :primary,
            attributes: %{
              id: "primary",
              name: "primary",
              label: "Primary",
              color: "primary",
              value: "60"
            }
          },
          %Variation{
            id: :secondary,
            attributes: %{
              id: "secondary",
              name: "secondary",
              label: "Secondary",
              color: "secondary",
              value: "60"
            }
          },
          %Variation{
            id: :accent,
            attributes: %{
              id: "accent",
              name: "accent",
              label: "Accent",
              color: "accent",
              value: "60"
            }
          },
          %Variation{
            id: :success,
            attributes: %{
              id: "success",
              name: "success",
              label: "Success",
              color: "success",
              value: "60"
            }
          },
          %Variation{
            id: :warning,
            attributes: %{
              id: "warning",
              name: "warning",
              label: "Warning",
              color: "warning",
              value: "60"
            }
          },
          %Variation{
            id: :error,
            attributes: %{
              id: "error",
              name: "error",
              label: "Error",
              color: "error",
              value: "60"
            }
          }
        ]
      },
      %Variation{
        id: :vertical,
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
        attributes: %{
          id: "slider-no-label",
          name: "quality",
          label: "Audio Quality",
          min: 0,
          max: 100,
          value: 80,
          show_value: false
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
