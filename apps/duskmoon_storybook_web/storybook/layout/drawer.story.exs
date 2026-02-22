defmodule Storybook.Layout.Drawer do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Layout.Drawer.dm_drawer/1
  def description, do: "Drawer component — a sliding panel from the side."

  def variations do
    [
      %Variation{
        id: :default_left,
        attributes: %{
          id: "drawer-left",
          open: true,
          position: "left"
        },
        slots: [
          ~s(<:header>Navigation</:header>),
          "Drawer content goes here.",
          ~s(<:footer>Footer actions</:footer>)
        ]
      },
      %Variation{
        id: :right_position,
        attributes: %{
          id: "drawer-right",
          open: true,
          position: "right"
        },
        slots: [
          ~s(<:header>Settings</:header>),
          "Settings panel content."
        ]
      },
      %Variation{
        id: :modal_drawer,
        attributes: %{
          id: "drawer-modal",
          open: true,
          modal: true
        },
        slots: [
          ~s(<:header>Modal Drawer</:header>),
          "This drawer has a backdrop overlay."
        ]
      },
      %Variation{
        id: :custom_width,
        attributes: %{
          id: "drawer-wide",
          open: true,
          width: "400px"
        },
        slots: [
          ~s(<:header>Wide Drawer</:header>),
          "This drawer is 400px wide."
        ]
      },
      %Variation{
        id: :with_label,
        description: "Accessible drawer with aria-label for screen readers",
        attributes: %{
          id: "drawer-a11y",
          open: true,
          label: "Navigation sidebar"
        },
        slots: [
          ~s(<:header>Accessible Drawer</:header>),
          "Inspect element to see aria-label on the drawer container."
        ]
      },
      %Variation{
        id: :right_modal,
        description: "Right-side modal drawer with footer actions",
        attributes: %{
          id: "drawer-right-modal",
          open: true,
          position: "right",
          modal: true,
          width: "320px"
        },
        slots: [
          ~s(<:header>Filters</:header>),
          "Apply filters to narrow your results.",
          ~s(<:footer><button type="button" class="btn btn-primary btn-sm">Apply</button></:footer>)
        ]
      }
    ]
  end
end
