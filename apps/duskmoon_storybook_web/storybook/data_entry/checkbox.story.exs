defmodule Storybook.DataEntry.Checkbox do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.Checkbox.dm_checkbox/1
  def description, do: "Checkbox component for boolean selections."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "checkbox-default",
          name: "agree",
          label: "I agree to the terms and conditions"
        }
      },
      %Variation{
        id: :checked,
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
        variations: [
          %Variation{
            id: :xs,
            attributes: %{id: "xs", name: "xs", label: "XS checkbox", size: "xs"}
          },
          %Variation{
            id: :sm,
            attributes: %{id: "sm", name: "sm", label: "SM checkbox", size: "sm"}
          },
          %Variation{
            id: :md,
            attributes: %{id: "md", name: "md", label: "MD checkbox", size: "md"}
          },
          %Variation{
            id: :lg,
            attributes: %{id: "lg", name: "lg", label: "LG checkbox", size: "lg"}
          },
          %Variation{
            id: :xl,
            attributes: %{id: "xl", name: "xl", label: "XL checkbox", size: "xl"}
          }
        ]
      },
      %VariationGroup{
        id: :colors,
        description: "Color variants",
        variations: [
          %Variation{
            id: :primary,
            attributes: %{id: "primary", name: "primary", label: "Primary option", color: "primary"}
          },
          %Variation{
            id: :secondary,
            attributes: %{
              id: "secondary",
              name: "secondary",
              label: "Secondary option",
              color: "secondary"
            }
          },
          %Variation{
            id: :tertiary,
            attributes: %{
              id: "tertiary",
              name: "tertiary",
              label: "Tertiary option",
              color: "tertiary"
            }
          },
          %Variation{
            id: :accent,
            attributes: %{id: "accent", name: "accent", label: "Accent option", color: "accent"}
          },
          %Variation{
            id: :info,
            attributes: %{id: "info", name: "info", label: "Info option", color: "info"}
          },
          %Variation{
            id: :success,
            attributes: %{
              id: "success",
              name: "success",
              label: "Success option",
              color: "success"
            }
          },
          %Variation{
            id: :warning,
            attributes: %{
              id: "warning",
              name: "warning",
              label: "Warning option",
              color: "warning"
            }
          },
          %Variation{
            id: :error,
            attributes: %{id: "error", name: "error", label: "Error option", color: "error"}
          }
        ]
      },
      %Variation{
        id: :disabled,
        attributes: %{
          id: "checkbox-disabled",
          name: "disabled",
          label: "Disabled checkbox",
          disabled: true
        }
      },
      %Variation{
        id: :indeterminate,
        attributes: %{
          id: "checkbox-indet",
          name: "indeterminate",
          label: "Indeterminate state",
          indeterminate: true
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
