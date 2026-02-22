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
      },
      %VariationGroup{
        id: :variants,
        description: "Visual variants",
        variations: [
          %Variation{
            id: :dots,
            attributes: %{id: "stepper-dots", variant: "dots"},
            slots: [
              """
              <:step label="Step 1" completed={true} />
              <:step label="Step 2" active={true} />
              <:step label="Step 3" />
              """
            ]
          },
          %Variation{
            id: :alt_labels,
            attributes: %{id: "stepper-alt", variant: "alt-labels"},
            slots: [
              """
              <:step label="Start" completed={true} />
              <:step label="In Progress" active={true} />
              <:step label="Done" />
              """
            ]
          },
          %Variation{
            id: :icons,
            attributes: %{id: "stepper-icons", variant: "icons"},
            slots: [
              """
              <:step label="Upload" completed={true} />
              <:step label="Process" active={true} />
              <:step label="Review" />
              <:step label="Finish" />
              """
            ]
          }
        ]
      },
      %VariationGroup{
        id: :colors,
        description: "Color variants",
        variations: [
          %Variation{
            id: :secondary,
            attributes: %{id: "stepper-sec", color: "secondary"},
            slots: [
              """
              <:step label="Step A" completed={true} />
              <:step label="Step B" active={true} />
              <:step label="Step C" />
              """
            ]
          },
          %Variation{
            id: :tertiary,
            attributes: %{id: "stepper-tert", color: "tertiary"},
            slots: [
              """
              <:step label="Step A" completed={true} />
              <:step label="Step B" active={true} />
              <:step label="Step C" />
              """
            ]
          },
          %Variation{
            id: :accent,
            attributes: %{id: "stepper-accent", color: "accent"},
            slots: [
              """
              <:step label="Step A" completed={true} />
              <:step label="Step B" active={true} />
              <:step label="Step C" />
              """
            ]
          }
        ]
      },
      %VariationGroup{
        id: :sizes,
        description: "Size variants",
        variations: [
          %Variation{
            id: :small,
            attributes: %{id: "stepper-sm", size: "sm"},
            slots: [
              """
              <:step label="Step 1" completed={true} />
              <:step label="Step 2" active={true} />
              <:step label="Step 3" />
              """
            ]
          },
          %Variation{
            id: :large,
            attributes: %{id: "stepper-lg", size: "lg"},
            slots: [
              """
              <:step label="Step 1" completed={true} />
              <:step label="Step 2" active={true} />
              <:step label="Step 3" />
              """
            ]
          }
        ]
      },
      %Variation{
        id: :clickable,
        description: "Clickable steps",
        attributes: %{
          id: "stepper-click",
          clickable: true
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
        id: :step_states,
        description: "All step slot states: disabled and optional",
        attributes: %{
          id: "stepper-states"
        },
        slots: [
          """
          <:step label="Completed" completed={true} />
          <:step label="Active" active={true} />
          <:step label="Optional (skip)" optional={true} />
          <:step label="Disabled" disabled={true} />
          <:step label="Pending" />
          """
        ]
      }
    ]
  end
end
