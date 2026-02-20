defmodule Storybook.Navigation.Stepper do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Navigation.Stepper.dm_stepper/1
  def description, do: "Multi-step progress indicator."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "stepper-default"
        },
        slots: [
          """
          <:step label="Account" completed={true} />
          <:step label="Profile" active={true} />
          <:step label="Review" />
          <:step label="Complete" />
          """
        ]
      },
      %Variation{
        id: :with_descriptions,
        attributes: %{
          id: "stepper-desc"
        },
        slots: [
          """
          <:step label="Sign Up" description="Create account" completed={true} />
          <:step label="Details" description="Fill in info" active={true} />
          <:step label="Confirm" description="Verify email" />
          """
        ]
      },
      %Variation{
        id: :vertical,
        attributes: %{
          id: "stepper-vert",
          vertical: true
        },
        slots: [
          """
          <:step label="Step 1" completed={true} />
          <:step label="Step 2" active={true} />
          <:step label="Step 3" />
          """
        ]
      },
      %Variation{
        id: :error_state,
        attributes: %{
          id: "stepper-error"
        },
        slots: [
          """
          <:step label="Upload" completed={true} />
          <:step label="Process" error={true} />
          <:step label="Complete" />
          """
        ]
      }
    ]
  end
end
