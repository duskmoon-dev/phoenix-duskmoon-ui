defmodule Storybook.DataDisplay.Diff do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Diff.dm_diff/1
  def description, do: "CSS comparison panels with an application-controlled reveal percentage."

  def variations do
    [
      %Variation{
        id: :reveal,
        attributes: %{
          label: "Before and after comparison",
          position: 40,
          class: "w-full max-w-lg"
        },
        slots: [
          ~s(<:before_content><div class="grid h-full place-items-center bg-primary-container text-on-primary-container p-8">Original</div></:before_content>),
          ~s(<:after_content><div class="grid h-full place-items-center bg-tertiary-container text-on-tertiary-container p-8">Updated</div></:after_content>)
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
