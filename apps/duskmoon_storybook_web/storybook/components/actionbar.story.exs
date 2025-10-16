defmodule Storybook.Components.Actionbar do
  # :live_component or :page are also available
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Actionbar.dm_actionbar/1
  def description, do: "A actionbar element."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          class: "shadow"
        },
        slots: [
          """
          <:left>
            Star Wars
          </:left>
          <:right>
            <button>action</button>
          </:right>
          """
        ]
      }
    ]
  end
end
