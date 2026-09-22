defmodule Storybook.Layout.Mask do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Layout.Mask.dm_mask/1

  def description,
    do: "Decorative clipping shapes from Core; content keeps its original semantics."

  def variations do
    [
      %Variation{
        id: :hexagon,
        attributes: %{shape: "hexagon", class: "w-32 h-32"},
        slots: [
          ~s(<div class="grid h-full place-items-center bg-primary-container" role="img" aria-label="Hexagonal team emblem">DM</div>)
        ]
      },
      %Variation{
        id: :circle,
        attributes: %{shape: "circle", class: "w-32 h-32"},
        slots: [
          ~s(<div class="grid h-full place-items-center bg-secondary-container" role="img" aria-label="Circular team emblem">UI</div>)
        ]
      }
    ]
  end
end
