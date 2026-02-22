defmodule Storybook.DataDisplay.Progress do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Progress.dm_progress/1
  def description, do: "Progress bar component for showing completion status."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          value: 75,
          max: 100
        }
      },
      %Variation{
        id: :with_label,
        attributes: %{
          value: 60,
          max: 100,
          show_label: true
        }
      },
      %Variation{
        id: :color_variants,
        attributes: %{
          value: 30,
          max: 100,
          color: "success"
        }
      },
      %Variation{
        id: :warning_progress,
        attributes: %{
          value: 85,
          max: 100,
          color: "warning"
        }
      },
      %Variation{
        id: :error_progress,
        attributes: %{
          value: 95,
          max: 100,
          color: "error"
        }
      },
      %Variation{
        id: :size_variants,
        attributes: %{
          value: 50,
          max: 100,
          size: "xs",
          color: "info"
        }
      },
      %Variation{
        id: :large_progress,
        attributes: %{
          value: 40,
          max: 100,
          size: "lg",
          color: "accent",
          show_label: true
        }
      },
      %Variation{
        id: :animated_progress,
        attributes: %{
          value: 70,
          max: 100,
          color: "primary",
          animated: true
        }
      },
      %Variation{
        id: :indeterminate_progress,
        attributes: %{
          color: "secondary",
          indeterminate: true
        }
      },
      %Variation{
        id: :upload_progress,
        attributes: %{
          value: 45,
          max: 100,
          color: "primary",
          animated: true,
          show_label: true
        }
      },
      %Variation{
        id: :small_with_label,
        attributes: %{
          value: 25,
          max: 100,
          size: "sm",
          color: "success",
          show_label: true
        }
      },
      %Variation{
        id: :complete_progress,
        attributes: %{
          value: 100,
          max: 100,
          color: "success",
          show_label: true
        }
      },
      %Variation{
        id: :circular_default,
        attributes: %{
          type: "circular",
          value: 75,
          max: 100,
          color: "primary"
        }
      },
      %Variation{
        id: :circular_with_label,
        attributes: %{
          type: "circular",
          value: 60,
          max: 100,
          color: "success",
          show_label: true
        }
      },
      %Variation{
        id: :circular_indeterminate,
        attributes: %{
          type: "circular",
          color: "secondary",
          indeterminate: true
        }
      },
      %Variation{
        id: :circular_large,
        attributes: %{
          type: "circular",
          value: 85,
          max: 100,
          color: "warning",
          size: "lg",
          show_label: true
        }
      },
      %Variation{
        id: :striped_progress,
        attributes: %{
          value: 65,
          max: 100,
          color: "primary",
          striped: true
        }
      },
      %Variation{
        id: :striped_animated,
        attributes: %{
          value: 55,
          max: 100,
          color: "success",
          striped: true,
          animated: true
        }
      },
      %Variation{
        id: :inline_label,
        attributes: %{
          value: 72,
          max: 100,
          color: "accent",
          inline_label: true
        }
      },
      %Variation{
        id: :inline_label_striped,
        attributes: %{
          value: 80,
          max: 100,
          color: "info",
          inline_label: true,
          striped: true
        }
      },
      %VariationGroup{
        id: :label_customization,
        description: "Custom label text and complete text",
        variations: [
          %Variation{
            id: :custom_label_text,
            description: "Custom progress label text",
            attributes: %{
              value: 3,
              max: 5,
              color: "primary",
              show_label: true,
              label_text: "Steps"
            }
          },
          %Variation{
            id: :custom_complete_text,
            description: "Custom completion text appended to percentage",
            attributes: %{
              value: 100,
              max: 100,
              color: "success",
              show_label: true,
              complete_text: "Done"
            }
          }
        ]
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :type,
        label: "Type",
        type: :select,
        options: [
          {"linear", "Linear"},
          {"circular", "Circular"}
        ],
        default: "linear"
      },
      %{
        id: :color,
        label: "Color",
        type: :select,
        options: [
          {"primary", "Primary"},
          {"secondary", "Secondary"},
          {"tertiary", "Tertiary"},
          {"accent", "Accent"},
          {"info", "Info"},
          {"success", "Success"},
          {"warning", "Warning"},
          {"error", "Error"}
        ],
        default: "primary"
      },
      %{
        id: :size,
        label: "Size",
        type: :select,
        options: [
          {"xs", "XS"},
          {"sm", "SM"},
          {"md", "MD"},
          {"lg", "LG"},
          {"xl", "XL"}
        ],
        default: "md"
      },
      %{
        id: :striped,
        label: "Striped",
        type: :boolean,
        default: false
      },
      %{
        id: :animated,
        label: "Animated",
        type: :boolean,
        default: false
      },
      %{
        id: :indeterminate,
        label: "Indeterminate",
        type: :boolean,
        default: false
      },
      %{
        id: :show_label,
        label: "Show Label",
        type: :boolean,
        default: false
      }
    ]
  end
end