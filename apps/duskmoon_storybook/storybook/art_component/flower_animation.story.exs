defmodule Storybook.ArtComponent.FlowerAnimation do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.ArtComponent.FlowerAnimation.dm_art_flower_animation/1
  def description, do: "Flower animation art using the el-dm-art-flower-animation custom element."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default flower animation",
        attributes: %{
          id: "flower-default"
        }
      }
    ]
  end
end
