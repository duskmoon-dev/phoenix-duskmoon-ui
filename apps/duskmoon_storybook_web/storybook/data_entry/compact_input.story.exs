defmodule Storybook.DataEntry.CompactInput do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.CompactInput.dm_compact_input/1
  def description, do: "Compact input combining label and field in a single row. Ideal for dense forms and settings panels."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default compact text input",
        attributes: %{
          type: "text",
          label: "Username",
          name: "name",
          value: nil
        }
      },
      %Variation{
        id: :password,
        description: "Compact password input",
        attributes: %{
          type: "password",
          label: "Password",
          name: "password",
          value: nil
        }
      },
      %Variation{
        id: :email,
        description: "Compact email with badge slot",
        attributes: %{
          type: "email",
          label: "Email",
          name: "email",
          value: nil,
          class: "input-sm"
        },
        slots: [
          """
          <span class="badge badge-soft badge-info">@gsmlg.dev</span>
          """
        ]
      },
      %Variation{
        id: :input_error,
        description: "Compact input with validation error",
        attributes: %{
          type: "search",
          label: "Search",
          name: "search",
          value: nil,
          errors: ["Search is required"]
        }
      },
      %Variation{
        id: :select,
        description: "Compact select dropdown with groups",
        attributes: %{
          type: "select",
          label: "Location",
          name: "location",
          value: nil,
          options: [
            {"New York", "new_york"},
            {"California",
             [
               {"San Diego", "san_diego"},
               {"San Francisco", "san_francisco"},
               {"Los Angeles", "los_angeles"}
             ]}
          ]
        }
      },
      %Variation{
        id: :with_helper,
        description: "Helper text below compact input",
        attributes: %{
          type: "text",
          label: "API Key",
          name: "api_key",
          value: nil,
          helper: "Find your API key in Settings > Developer."
        }
      },
      %Variation{
        id: :horizontal,
        description: "Horizontal layout — label beside input",
        attributes: %{
          type: "text",
          label: "Display Name",
          name: "display_name",
          value: nil,
          horizontal: true
        }
      },
      %VariationGroup{
        id: :validation_states,
        description: "Validation states",
        variations: [
          %Variation{
            id: :success_state,
            attributes: %{
              type: "text",
              label: "Username",
              name: "ci_vs_success",
              value: nil,
              state: "success"
            }
          },
          %Variation{
            id: :warning_state,
            attributes: %{
              type: "text",
              label: "Password",
              name: "ci_vs_warning",
              value: nil,
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
        id: :variant,
        label: "Variant",
        type: :select,
        options: [
          {nil, "Default"},
          {"ghost", "Ghost"},
          {"filled", "Filled"},
          {"bordered", "Bordered"}
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
        id: :horizontal,
        label: "Horizontal",
        type: :boolean,
        default: false
      }
    ]
  end
end
