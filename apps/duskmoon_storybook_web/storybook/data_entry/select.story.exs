defmodule Storybook.DataEntry.Select do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.Select.dm_select/1
  def description, do: "Select dropdown component for single or multiple selection from predefined options."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "select-default",
          name: "country",
          label: "Country",
          options: [{"us", "United States"}, {"ca", "Canada"}, {"mx", "Mexico"}],
          prompt: "Select a country"
        }
      },
      %Variation{
        id: :with_value,
        attributes: %{
          id: "select-value",
          name: "priority",
          label: "Priority",
          options: [{"low", "Low"}, {"medium", "Medium"}, {"high", "High"}, {"urgent", "Urgent"}],
          value: "medium"
        }
      },
      %Variation{
        id: :no_prompt,
        attributes: %{
          id: "select-no-prompt",
          name: "status",
          label: "Status",
          options: [{"active", "Active"}, {"inactive", "Inactive"}, {"pending", "Pending"}],
          value: "active"
        }
      },
      %VariationGroup{
        id: :sizes,
        description: "Size variants",
        variations: [
          %Variation{
            id: :xs,
            attributes: %{
              id: "xs",
              name: "xs",
              label: "XS Select",
              size: "xs",
              options: [{"a", "Option A"}, {"b", "Option B"}]
            }
          },
          %Variation{
            id: :sm,
            attributes: %{
              id: "sm",
              name: "sm",
              label: "SM Select",
              size: "sm",
              options: [{"a", "Option A"}, {"b", "Option B"}]
            }
          },
          %Variation{
            id: :md,
            attributes: %{
              id: "md",
              name: "md",
              label: "MD Select",
              size: "md",
              options: [{"a", "Option A"}, {"b", "Option B"}]
            }
          },
          %Variation{
            id: :lg,
            attributes: %{
              id: "lg",
              name: "lg",
              label: "LG Select",
              size: "lg",
              options: [{"a", "Option A"}, {"b", "Option B"}]
            }
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
              options: [{"a", "Option A"}, {"b", "Option B"}],
              prompt: "Select primary"
            }
          },
          %Variation{
            id: :secondary,
            attributes: %{
              id: "secondary",
              name: "secondary",
              label: "Secondary",
              color: "secondary",
              options: [{"a", "Option A"}, {"b", "Option B"}],
              prompt: "Select secondary"
            }
          },
          %Variation{
            id: :accent,
            attributes: %{
              id: "accent",
              name: "accent",
              label: "Accent",
              color: "accent",
              options: [{"a", "Option A"}, {"b", "Option B"}],
              prompt: "Select accent"
            }
          },
          %Variation{
            id: :success,
            attributes: %{
              id: "success",
              name: "success",
              label: "Success",
              color: "success",
              options: [{"a", "Option A"}, {"b", "Option B"}],
              prompt: "Select success"
            }
          },
          %Variation{
            id: :warning,
            attributes: %{
              id: "warning",
              name: "warning",
              label: "Warning",
              color: "warning",
              options: [{"a", "Option A"}, {"b", "Option B"}],
              prompt: "Select warning"
            }
          },
          %Variation{
            id: :error,
            attributes: %{
              id: "error",
              name: "error",
              label: "Error",
              color: "error",
              options: [{"a", "Option A"}, {"b", "Option B"}],
              prompt: "Select error"
            }
          },
          %Variation{
            id: :tertiary,
            attributes: %{
              id: "tertiary",
              name: "tertiary",
              label: "Tertiary",
              color: "tertiary",
              options: [{"a", "Option A"}, {"b", "Option B"}],
              prompt: "Select tertiary"
            }
          },
          %Variation{
            id: :info,
            attributes: %{
              id: "info",
              name: "info",
              label: "Info",
              color: "info",
              options: [{"a", "Option A"}, {"b", "Option B"}],
              prompt: "Select info"
            }
          }
        ]
      },
      %VariationGroup{
        id: :variants,
        description: "Style variants",
        variations: [
          %Variation{
            id: :ghost,
            attributes: %{
              id: "variant-ghost",
              name: "variant_ghost",
              label: "Ghost Select",
              variant: "ghost",
              options: [{"a", "Option A"}, {"b", "Option B"}]
            }
          },
          %Variation{
            id: :filled,
            attributes: %{
              id: "variant-filled",
              name: "variant_filled",
              label: "Filled Select",
              variant: "filled",
              options: [{"a", "Option A"}, {"b", "Option B"}]
            }
          },
          %Variation{
            id: :bordered,
            attributes: %{
              id: "variant-bordered",
              name: "variant_bordered",
              label: "Bordered Select",
              variant: "bordered",
              options: [{"a", "Option A"}, {"b", "Option B"}]
            }
          }
        ]
      },
      %Variation{
        id: :disabled,
        attributes: %{
          id: "select-disabled",
          name: "disabled",
          label: "Disabled Select",
          options: [{"option1", "Option 1"}, {"option2", "Option 2"}],
          disabled: true
        }
      },
      %Variation{
        id: :multiple,
        attributes: %{
          id: "select-multiple",
          name: "tags",
          label: "Tags (Multiple)",
          options: [
            {"tech", "Technology"},
            {"design", "Design"},
            {"business", "Business"},
            {"marketing", "Marketing"}
          ],
          multiple: true,
          value: ["tech", "design"]
        }
      },
      %Variation{
        id: :option_groups,
        description: "Select with option groups using inner_block slot",
        attributes: %{
          id: "groups",
          name: "category",
          label: "Category"
        },
        slots: [
          """
          <option value="">Select a category</option>
          <optgroup label="Fruits">
            <option value="apple">Apple</option>
            <option value="orange">Orange</option>
            <option value="banana">Banana</option>
          </optgroup>
          <optgroup label="Vegetables">
            <option value="carrot">Carrot</option>
            <option value="broccoli">Broccoli</option>
            <option value="spinach">Spinach</option>
          </optgroup>
          <optgroup label="Grains">
            <option value="wheat">Wheat</option>
            <option value="rice">Rice</option>
            <option value="corn">Corn</option>
          </optgroup>
          """
        ]
      },
      %Variation{
        id: :many_options,
        attributes: %{
          id: "select-many",
          name: "timezone",
          label: "Timezone",
          options: [
            {"utc", "UTC"},
            {"est", "Eastern Time"},
            {"cst", "Central Time"},
            {"mst", "Mountain Time"},
            {"pst", "Pacific Time"},
            {"akst", "Alaska Time"},
            {"hst", "Hawaii Time"}
          ],
          prompt: "Select timezone"
        }
      },
      %VariationGroup{
        id: :validation_states,
        description: "Validation states",
        variations: [
          %Variation{
            id: :success_state,
            attributes: %{
              id: "sel-vs-success",
              name: "sel_vs_success",
              label: "Status (success)",
              state: "success",
              options: [{"active", "Active"}, {"inactive", "Inactive"}],
              value: "active"
            }
          },
          %Variation{
            id: :warning_state,
            attributes: %{
              id: "sel-vs-warning",
              name: "sel_vs_warning",
              label: "Category (warning)",
              state: "warning",
              options: [{"a", "Option A"}, {"b", "Option B"}],
              prompt: "Select a category"
            }
          }
        ]
      },
      %Variation{
        id: :horizontal,
        description: "Horizontal layout — label beside select",
        attributes: %{
          id: "sel-horizontal",
          name: "sel_horizontal",
          label: "Role",
          horizontal: true,
          options: [{"admin", "Admin"}, {"editor", "Editor"}, {"viewer", "Viewer"}]
        }
      },
      %Variation{
        id: :with_helper,
        description: "Helper text below select",
        attributes: %{
          id: "sel-helper",
          name: "sel_helper",
          label: "Plan",
          helper: "You can change your plan at any time.",
          options: [{"free", "Free"}, {"pro", "Pro"}, {"enterprise", "Enterprise"}]
        }
      },
      %Variation{
        id: :with_errors,
        description: "Select with error messages",
        attributes: %{
          id: "sel-errors",
          name: "sel_errors",
          label: "Country",
          errors: ["Please select a country."],
          options: [{"us", "United States"}, {"ca", "Canada"}],
          prompt: "Select country"
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
        id: :multiple,
        label: "Multiple",
        type: :boolean,
        default: false
      }
    ]
  end
end
