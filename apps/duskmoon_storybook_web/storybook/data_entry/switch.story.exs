defmodule Storybook.DataEntry.Switch do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.Switch.dm_switch/1
  def description, do: "Toggle switch component for boolean inputs."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "switch-default",
          name: "notifications",
          label: "Enable notifications"
        }
      },
      %Variation{
        id: :checked,
        attributes: %{
          id: "switch-checked",
          name: "dark_mode",
          label: "Dark mode",
          checked: true
        }
      },
      %Variation{
        id: :with_color,
        attributes: %{
          id: "switch-color",
          name: "auto_save",
          label: "Auto-save",
          color: "success"
        }
      },
      %VariationGroup{
        id: :sizes,
        description: "Size variants",
        variations: [
          %Variation{
            id: :xs,
            attributes: %{id: "xs", name: "xs", label: "XS switch", size: "xs"}
          },
          %Variation{
            id: :sm,
            attributes: %{id: "sm", name: "sm", label: "SM switch", size: "sm"}
          },
          %Variation{
            id: :md,
            attributes: %{id: "md", name: "md", label: "MD switch", size: "md"}
          },
          %Variation{
            id: :lg,
            attributes: %{id: "lg", name: "lg", label: "LG switch", size: "lg"}
          },
          %Variation{
            id: :xl,
            attributes: %{id: "xl", name: "xl", label: "XL switch", size: "xl"}
          }
        ]
      },
      %VariationGroup{
        id: :colors,
        description: "Color variants",
        variations: [
          %Variation{
            id: :primary,
            attributes: %{id: "primary", name: "primary", label: "Primary", color: "primary"}
          },
          %Variation{
            id: :secondary,
            attributes: %{
              id: "secondary",
              name: "secondary",
              label: "Secondary",
              color: "secondary"
            }
          },
          %Variation{
            id: :tertiary,
            attributes: %{id: "tertiary", name: "tertiary", label: "Tertiary", color: "tertiary"}
          },
          %Variation{
            id: :accent,
            attributes: %{id: "accent", name: "accent", label: "Accent", color: "accent"}
          },
          %Variation{
            id: :info,
            attributes: %{id: "info", name: "info", label: "Info", color: "info"}
          },
          %Variation{
            id: :success,
            attributes: %{id: "success", name: "success", label: "Success", color: "success"}
          },
          %Variation{
            id: :warning,
            attributes: %{id: "warning", name: "warning", label: "Warning", color: "warning"}
          },
          %Variation{
            id: :error,
            attributes: %{id: "error", name: "error", label: "Error", color: "error"}
          }
        ]
      },
      %Variation{
        id: :disabled,
        attributes: %{
          id: "switch-disabled",
          name: "disabled",
          label: "Disabled switch",
          disabled: true
        }
      },
      %Variation{
        id: :horizontal,
        description: "Horizontal layout — label beside switch",
        attributes: %{
          id: "switch-horizontal",
          name: "h_option",
          label: "Horizontal layout",
          horizontal: true
        }
      },
      %Variation{
        id: :with_helper,
        description: "Helper text below switch",
        attributes: %{
          id: "switch-helper",
          name: "auto_backup",
          label: "Enable automatic backups",
          helper: "Backups run every 24 hours when enabled."
        }
      },
      %Variation{
        id: :with_errors,
        description: "Switch with error messages",
        attributes: %{
          id: "switch-errors",
          name: "required_consent",
          label: "I consent to data collection",
          errors: ["Consent is required to proceed."]
        }
      },
      %VariationGroup{
        id: :validation_states,
        description: "Validation states",
        variations: [
          %Variation{
            id: :success_state,
            attributes: %{
              id: "sw-vs-success",
              name: "vs_success",
              label: "Verified (success)",
              state: "success",
              checked: true
            }
          },
          %Variation{
            id: :warning_state,
            attributes: %{
              id: "sw-vs-warning",
              name: "vs_warning",
              label: "Pending review (warning)",
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
