defmodule Storybook.ArtComponent.Snow do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.ArtComponent.Snow.dm_art_snow/1
  def description, do: "Falling snow art using the el-dm-art-snow custom element."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default snow",
        attributes: %{
          id: "snow-default"
        }
      }
    ]
  end
end
