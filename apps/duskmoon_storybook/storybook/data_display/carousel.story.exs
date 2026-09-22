defmodule Storybook.DataDisplay.Carousel do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Carousel.dm_carousel/1

  def description,
    do: "Native scroll-snap slides. Focus the region and use the arrow keys or scroll."

  def variations do
    [
      %Variation{
        id: :horizontal,
        attributes: %{label: "Project highlights", class: "w-full max-w-lg"},
        slots: [
          ~s(<:item label="Planning" class="w-72 p-8 bg-primary-container rounded-lg">Plan the next milestone</:item>),
          ~s(<:item label="Building" class="w-72 p-8 bg-secondary-container rounded-lg">Build with native components</:item>),
          ~s(<:item label="Shipping" class="w-72 p-8 bg-tertiary-container rounded-lg">Ship a tested release</:item>)
        ]
      },
      %Variation{
        id: :vertical,
        attributes: %{label: "Release steps", orientation: "vertical", class: "h-48 w-72"},
        slots: [
          ~s(<:item class="h-40 p-8 bg-primary-container">Review</:item>),
          ~s(<:item class="h-40 p-8 bg-secondary-container">Publish</:item>)
        ]
      }
    ]
  end
end
