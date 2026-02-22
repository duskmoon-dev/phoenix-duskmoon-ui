defmodule Storybook.Layout.BottomSheet do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Layout.BottomSheet.dm_bottom_sheet/1
  def description, do: "Bottom sheet overlay with snap points and modal options."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Closed bottom sheet with header and content",
        attributes: %{
          id: "bs-default"
        },
        slots: [
          """
          <:header>Bottom Sheet Title</:header>
          <p>This is the content of the bottom sheet.</p>
          """
        ]
      },
      %Variation{
        id: :open,
        description: "Open modal bottom sheet with backdrop",
        attributes: %{
          id: "bs-open",
          open: true,
          modal: true
        },
        slots: [
          """
          <:header>Open Sheet</:header>
          <p>This sheet is open by default with modal backdrop.</p>
          """
        ]
      },
      %Variation{
        id: :persistent,
        description: "Persistent sheet — cannot be dismissed by clicking backdrop",
        attributes: %{
          id: "bs-persistent",
          open: true,
          persistent: true
        },
        slots: [
          """
          <:header>Persistent Sheet</:header>
          <p>This sheet cannot be dismissed by clicking outside.</p>
          """
        ]
      },
      %Variation{
        id: :snap_points,
        description: "Sheet with snap point heights at 25%, 50%, and 100%",
        attributes: %{
          id: "bs-snap",
          open: true,
          snap_points: "25,50,100"
        },
        slots: [
          """
          <:header>Snap Points</:header>
          <p>Drag to snap at 25%, 50%, or 100% height.</p>
          """
        ]
      },
      %Variation{
        id: :with_label,
        description: "Accessible sheet with aria-label for screen readers",
        attributes: %{
          id: "bs-a11y",
          open: true,
          label: "Action selection sheet"
        },
        slots: [
          """
          <:header>Accessible Sheet</:header>
          <p>Inspect element to see aria-label on the sheet container.</p>
          """
        ]
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :open,
        label: "Open",
        type: :boolean,
        default: false
      },
      %{
        id: :modal,
        label: "Modal",
        type: :boolean,
        default: false
      },
      %{
        id: :persistent,
        label: "Persistent",
        type: :boolean,
        default: false
      }
    ]
  end
end
