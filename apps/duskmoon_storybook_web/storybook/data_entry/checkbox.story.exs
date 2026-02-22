defmodule Storybook.DataEntry.Checkbox do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.Checkbox.dm_checkbox/1
  def description, do: "Checkbox component for boolean selections."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default unchecked checkbox",
        attributes: %{
          id: "checkbox-default",
          name: "agree",
          label: "I agree to the terms and conditions"
        }
      },
      %Variation{
        id: :checked,
        description: "Pre-checked checkbox",
        attributes: %{
          id: "checkbox-checked",
          name: "newsletter",
          label: "Subscribe to newsletter",
          checked: true
        }
      },
      %VariationGroup{
        id: :sizes,
        description: "Size variants",
        variations:
          for size <- ~w(xs sm md lg xl) do
            %Variation{
              id: String.to_atom(size),
              attributes: %{id: size, name: size, label: "#{String.upcase(size)} checkbox", size: size}
            }
          end
      },
      %VariationGroup{
        id: :colors,
        description: "Color variants",
        variations:
          for color <- ~w(primary secondary tertiary accent info success warning error) do
            %Variation{
              id: String.to_atom(color),
              attributes: %{
                id: color,
                name: color,
                label: "#{String.capitalize(color)} option",
                color: color
              }
            }
          end
      },
      %Variation{
        id: :disabled,
        description: "Disabled checkbox",
        attributes: %{
          id: "checkbox-disabled",
          name: "disabled",
          label: "Disabled checkbox",
          disabled: true
        }
      },
      %Variation{
        id: :indeterminate,
        description: "Indeterminate (partial) state",
        attributes: %{
          id: "checkbox-indet",
          name: "indeterminate",
          label: "Indeterminate state",
          indeterminate: true
        }
      },
      %Variation{
        id: :horizontal,
        description: "Horizontal layout — label beside checkbox",
        attributes: %{
          id: "checkbox-horizontal",
          name: "h_option",
          label: "Horizontal layout",
          horizontal: true
        }
      },
      %Variation{
        id: :with_helper,
        description: "Helper text below checkbox",
        attributes: %{
          id: "checkbox-helper",
          name: "terms",
          label: "Accept terms of service",
          helper: "You must accept the terms to create an account."
        }
      },
      %Variation{
        id: :with_errors,
        description: "Checkbox with error messages",
        attributes: %{
          id: "checkbox-errors",
          name: "required_agree",
          label: "I agree to the privacy policy",
          errors: ["This field is required."]
        }
      },
      %VariationGroup{
        id: :validation_states,
        description: "Validation states",
        variations: [
          %Variation{
            id: :success_state,
            attributes: %{
              id: "cb-vs-success",
              name: "vs_success",
              label: "Confirmed (success)",
              state: "success",
              checked: true
            }
          },
          %Variation{
            id: :warning_state,
            attributes: %{
              id: "cb-vs-warning",
              name: "vs_warning",
              label: "Needs review (warning)",
              state: "warning"
            }
          }
        ]
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
