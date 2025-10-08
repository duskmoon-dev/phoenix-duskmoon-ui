defmodule Storybook.Components.Skeleton do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Skeleton.dm_skeleton/1
  def description, do: "Skeleton loading placeholders for better UX."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Basic skeleton loader",
        attributes: %{}
      },
      %Variation{
        id: :circle,
        description: "Circle skeleton (avatar placeholder)",
        attributes: %{variant: "circle", size: "lg"}
      },
      %Variation{
        id: :text,
        description: "Text skeleton placeholder",
        attributes: %{width: "w-48", height: "h-4"}
      },
      %Variation{
        id: :rectangle,
        description: "Rectangle skeleton (image placeholder)",
        attributes: %{width: "w-full", height: "h-32", class: "rounded-lg"}
      }
    ]
  end
end
