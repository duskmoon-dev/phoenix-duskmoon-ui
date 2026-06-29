defmodule Storybook.Navigation.Steps do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Navigation.Steps.dm_steps/1
  def description, do: "Stepper component showing progress through a multi-step process."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Basic horizontal steps",
        attributes: %{
          current: 1,
          steps: [
            %{label: "Account"},
            %{label: "Profile"},
            %{label: "Review"},
            %{label: "Complete"}
          ]
        }
      },
      %Variation{
        id: :with_descriptions,
        description: "Steps with sub-labels for extra context",
        attributes: %{
          current: 2,
          steps: [
            %{label: "Sign Up", description: "Create your account"},
            %{label: "Verify", description: "Confirm your email"},
            %{label: "Setup", description: "Configure preferences"},
            %{label: "Done", description: "Start using the app"}
          ]
        }
      },
      %Variation{
        id: :vertical,
        description: "Vertical orientation",
        attributes: %{
          current: 1,
          orientation: "vertical",
          steps: [
            %{label: "Step 1", description: "First step"},
            %{label: "Step 2", description: "Second step"},
            %{label: "Step 3", description: "Third step"}
          ]
        }
      },
      %Variation{
        id: :clickable,
        description: "Clickable steps for navigation",
        attributes: %{
          current: 0,
          clickable: true,
          steps: [
            %{label: "General"},
            %{label: "Appearance"},
            %{label: "Notifications"},
            %{label: "Security"}
          ]
        }
      },
      %VariationGroup{
        id: :colors,
        description: "Color variants",
        variations:
          for color <- ~w(primary secondary tertiary accent info success warning error) do
            %Variation{
              id: String.to_atom(color),
              attributes: %{
                current: 1,
                color: color,
                steps: [
                  %{label: "Plan"},
                  %{label: "Build"},
                  %{label: "Deploy"}
                ]
              }
            }
          end
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :orientation,
        label: "Orientation",
        type: :select,
        options: [
          {"horizontal", "Horizontal"},
          {"vertical", "Vertical"}
        ],
        default: "horizontal"
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
        id: :clickable,
        label: "Clickable",
        type: :boolean,
        default: false
      }
    ]
  end
end
