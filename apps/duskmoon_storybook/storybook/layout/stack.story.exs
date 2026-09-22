defmodule Storybook.Layout.Stack do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Layout.Stack.dm_stack/1

  def description,
    do:
      "The first child is foreground content. Decorative copies are inert and hidden from assistive technology."

  def variations do
    [
      %Variation{
        id: :cards,
        attributes: %{class: "m-4"},
        slots: [
          ~s(<div class="card bg-primary-container p-8 w-48">Current project</div><div class="card bg-secondary-container p-8 w-48" aria-hidden="true" inert>Card</div><div class="card bg-tertiary-container p-8 w-48" aria-hidden="true" inert>Card</div>)
        ]
      },
      %Variation{
        id: :inline_end,
        attributes: %{direction: "end", class: "m-4"},
        slots: [
          ~s(<div class="card bg-primary-container p-8">Latest</div><div class="card bg-secondary-container p-8" aria-hidden="true" inert>Previous</div>)
        ]
      }
    ]
  end
end
