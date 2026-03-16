defmodule Storybook.ArtComponent.ColorSpin do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.ArtComponent.ColorSpin.dm_art_color_spin/1
  def description, do: "Color spin art using the el-dm-art-color-spin custom element."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default color spin",
        attributes: %{
          id: "spin-default"
        }
      }
    ]
  end
end
