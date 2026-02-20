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
