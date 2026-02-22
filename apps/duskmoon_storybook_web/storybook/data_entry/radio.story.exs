defmodule Storybook.DataEntry.Radio do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.Radio.dm_radio/1
  def description, do: "Radio button component for single selection from multiple options."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default unselected radio button",
        attributes: %{
          id: "radio-default",
          name: "theme",
          value: "light",
          label: "Light theme"
        }
      },
      %Variation{
        id: :checked,
        description: "Pre-selected radio button",
        attributes: %{
          id: "radio-checked",
          name: "theme",
          value: "dark",
          label: "Dark theme",
          checked: true
        }
      },
      %VariationGroup{
        id: :radio_group,
        description: "Choose your plan",
        variations: [
          %Variation{
            id: :free,
            attributes: %{id: "free", name: "plan", value: "free", label: "Free Plan"}
          },
          %Variation{
            id: :pro,
            attributes: %{
              id: "pro",
              name: "plan",
              value: "pro",
              label: "Pro Plan",
              checked: true
            }
          },
          %Variation{
            id: :enterprise,
            attributes: %{
              id: "enterprise",
              name: "plan",
              value: "enterprise",
              label: "Enterprise Plan"
            }
          }
        ]
      },
      %VariationGroup{
        id: :sizes,
        description: "Size variants",
        variations:
          for size <- ~w(xs sm md lg xl) do
            %Variation{
              id: String.to_atom(size),
              attributes: %{
                id: size,
                name: size,
                value: size,
                label: "#{String.upcase(size)} option",
                size: size
              }
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
                value: color,
                label: "#{String.capitalize(color)} option",
                color: color
              }
            }
          end
      },
      %Variation{
        id: :disabled,
        description: "Disabled radio button",
        attributes: %{
          id: "radio-disabled",
          name: "disabled",
          value: "disabled",
          label: "Disabled option",
          disabled: true
        }
      },
      %VariationGroup{
        id: :mixed_states,
        description: "Notification settings",
        variations: [
          %Variation{
            id: :all,
            attributes: %{
              id: "all",
              name: "notifications",
              value: "all",
              label: "All notifications",
              checked: true
            }
          },
          %Variation{
            id: :important,
            attributes: %{
              id: "important",
              name: "notifications",
              value: "important",
              label: "Important only",
              color: "warning"
            }
          },
          %Variation{
            id: :none,
            attributes: %{
              id: "none",
              name: "notifications",
              value: "none",
              label: "None",
              disabled: true
            }
          }
        ]
      },
      %VariationGroup{
        id: :validation_states,
        description: "Validation states",
        variations: [
          %Variation{
            id: :success_state,
            attributes: %{
              id: "radio-vs-success",
              name: "vs_success",
              value: "yes",
              label: "Confirmed (success)",
              state: "success",
              checked: true
            }
          },
          %Variation{
            id: :warning_state,
            attributes: %{
              id: "radio-vs-warning",
              name: "vs_warning",
              value: "maybe",
              label: "Uncertain (warning)",
              state: "warning"
            }
          }
        ]
      },
      %Variation{
        id: :horizontal,
        description: "Horizontal layout — label beside radio",
        attributes: %{
          id: "radio-horizontal",
          name: "h_option",
          value: "h_value",
          label: "Horizontal layout",
          horizontal: true
        }
      },
      %Variation{
        id: :with_helper,
        description: "Helper text below radio",
        attributes: %{
          id: "radio-helper",
          name: "terms",
          value: "agree",
          label: "I agree to the terms",
          helper: "You must agree to the terms of service to continue."
        }
      },
      %Variation{
        id: :with_errors,
        description: "Radio with error messages",
        attributes: %{
          id: "radio-errors",
          name: "required_choice",
          value: "option_a",
          label: "Option A",
          errors: ["Please select an option to continue."]
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
          {"xs", "XS"},
          {"sm", "SM"},
          {"md", "MD"},
          {"lg", "LG"}
        ],
        default: "md"
      },
      %{
        id: :color,
        label: "Color",
        type: :select,
        options: [
          {"primary", "Primary"},
          {"secondary", "Secondary"},
          {"accent", "Accent"},
          {"info", "Info"},
          {"success", "Success"},
          {"warning", "Warning"},
          {"error", "Error"}
        ],
        default: "primary"
      },
      %{
        id: :disabled,
        label: "Disabled",
        type: :boolean,
        default: false
      },
      %{
        id: :checked,
        label: "Checked",
        type: :boolean,
        default: false
      }
    ]
  end
end
