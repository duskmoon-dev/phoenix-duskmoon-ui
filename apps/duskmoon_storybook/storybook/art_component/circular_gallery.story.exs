defmodule Storybook.ArtComponent.CircularGallery do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.ArtComponent.CircularGallery.dm_art_circular_gallery/1

  def description,
    do: "Circular gallery art using the el-dm-art-circular-gallery custom element."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default circular gallery",
        attributes: %{
          id: "gallery-default"
        }
      }
    ]
  end
end
