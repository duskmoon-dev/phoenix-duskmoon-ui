defmodule Storybook.ArtComponent.Moon do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.ArtComponent.Moon.dm_art_moon/1
  def description, do: "Moon art using the el-dm-art-moon custom element."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default moon",
        attributes: %{
          id: "moon-default"
        }
      }
    ]
  end
end
