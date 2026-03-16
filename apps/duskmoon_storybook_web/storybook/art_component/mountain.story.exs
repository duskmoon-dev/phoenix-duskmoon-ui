defmodule Storybook.ArtComponent.Mountain do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.ArtComponent.Mountain.dm_art_mountain/1
  def description, do: "Mountain landscape art using the el-dm-art-mountain custom element."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default mountain",
        attributes: %{
          id: "mountain-default"
        }
      }
    ]
  end
end
