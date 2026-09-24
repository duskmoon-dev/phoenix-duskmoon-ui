defmodule Storybook.DataDisplay.Diff do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Diff.dm_diff/1

  def description,
    do: "Core CSS comparison with a native slider: drag or use arrow keys to reveal each version."

  def variations do
    [
      %Variation{
        id: :reveal,
        description: "Drag the slider or use arrow keys to compare versions (starts at 40%)",
        attributes: %{
          label: "Before and after comparison",
          position: 40,
          class: "w-full max-w-lg"
        },
        slots: [
          ~s(<:before_content><div class="h-full bg-primary-container"><span class="diff-label">Original</span></div></:before_content>),
          ~s(<:after_content><div class="h-full bg-tertiary-container"><span class="diff-label">Updated</span></div></:after_content>)
        ]
      },
      %Variation{
        id: :side_by_side,
        attributes: %{label: "Both versions", static: true, class: "w-full max-w-lg"},
        slots: [
          ~s(<:before_content><div class="bg-primary-container p-8">Original</div></:before_content>),
          ~s(<:after_content><div class="bg-tertiary-container p-8">Updated</div></:after_content>)
        ]
      }
    ]
  end
end
