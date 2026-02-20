defmodule Storybook.Navigation.Steps do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Navigation.Steps.dm_steps/1
  def description, do: "Stepper component showing progress through a multi-step process."

  def variations do
    [
      %Variation{
        id: :default,
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
        id: :primary_color,
        description: "Primary color (default)",
        attributes: %{
          current: 1,
          color: "primary",
          steps: [
            %{label: "Plan"},
            %{label: "Build"},
            %{label: "Deploy"}
          ]
        }
      },
      %Variation{
        id: :secondary_color,
        description: "Secondary color",
        attributes: %{
          current: 1,
          color: "secondary",
          steps: [
            %{label: "Draft"},
            %{label: "Review"},
            %{label: "Publish"}
          ]
        }
      },
      %Variation{
        id: :tertiary_color,
        description: "Tertiary color",
        attributes: %{
          current: 2,
          color: "tertiary",
          steps: [
            %{label: "Input"},
            %{label: "Process"},
            %{label: "Output"}
          ]
        }
      },
      %Variation{
        id: :success_color,
        attributes: %{
          current: 2,
          color: "success",
          steps: [
            %{label: "Order Placed"},
            %{label: "Processing"},
            %{label: "Shipped"},
            %{label: "Delivered"}
          ]
        }
      },
      %Variation{
        id: :warning_color,
        description: "Warning color",
        attributes: %{
          current: 1,
          color: "warning",
          steps: [
            %{label: "Check"},
            %{label: "Review"},
            %{label: "Approve"}
          ]
        }
      },
      %Variation{
        id: :error_color,
        description: "Error color",
        attributes: %{
          current: 0,
          color: "error",
          steps: [
            %{label: "Detect"},
            %{label: "Diagnose"},
            %{label: "Fix"}
          ]
        }
      },
      %Variation{
        id: :info_color,
        description: "Info color",
        attributes: %{
          current: 2,
          color: "info",
          steps: [
            %{label: "Welcome"},
            %{label: "Tutorial"},
            %{label: "Complete"}
          ]
        }
      },
      %Variation{
        id: :clickable,
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
      }
    ]
  end
end
