defmodule Storybook.DataDisplay.Kbd do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Kbd.dm_kbd/1
  def description, do: "Semantic keyboard key labels styled by Core."

  def variations do
    [
      %Variation{id: :key, slots: ["Ctrl"]},
      %Variation{id: :large, attributes: %{size: "lg"}, slots: ["Enter"]},
      %Variation{id: :ghost, attributes: %{ghost: true}, slots: ["Esc"]}
    ]
  end
end
