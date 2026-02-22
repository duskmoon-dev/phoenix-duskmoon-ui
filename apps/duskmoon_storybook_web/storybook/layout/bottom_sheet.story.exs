defmodule Storybook.Layout.BottomSheet do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Layout.BottomSheet.dm_bottom_sheet/1
  def description, do: "Bottom sheet overlay with snap points and modal options."

  def variations do
    [
      %Variation{
        id: :default,
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
      }
    ]
  end
end
