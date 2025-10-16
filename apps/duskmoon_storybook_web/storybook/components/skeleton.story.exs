defmodule Storybook.Components.Skeleton do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Skeleton.dm_skeleton/1
  def description, do: "Skeleton loading placeholders for better UX."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Basic skeleton loader",
        attributes: %{class: " h-16 w-16"}
      },
      %Variation{
        id: :circle,
        description: "Circle skeleton (avatar placeholder)",
        attributes: %{class: "skeleton h-16 w-16 shrink-0 rounded-full"}
      },
      %Variation{
        id: :text,
        description: "Text skeleton placeholder",
        attributes: %{class:  "h-16 w-16"}
      },
      %Variation{
        id: :rectangle,
        description: "Rectangle skeleton (image placeholder)",
        attributes: %{class: "h-16 w-16 rounded-lg"}
      }
    ]
  end
end
