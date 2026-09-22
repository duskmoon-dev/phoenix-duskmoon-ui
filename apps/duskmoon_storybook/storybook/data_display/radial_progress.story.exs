defmodule Storybook.DataDisplay.RadialProgress do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.RadialProgress.dm_radial_progress/1

  def description,
    do: "A determinate CSS progress ring with synchronized accessible and visible values."

  def variations do
    [
      %Variation{id: :upload, attributes: %{value: 72, label: "Upload progress"}},
      %Variation{
        id: :complete,
        attributes: %{value: 100, label: "Migration progress", color: "success", size: "xl"}
      },
      %Variation{
        id: :without_text,
        attributes: %{value: 30, label: "Processing progress", show_label: false, size: "sm"}
      }
    ]
  end
end
