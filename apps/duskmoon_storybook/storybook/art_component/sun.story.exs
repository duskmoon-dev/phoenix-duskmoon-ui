defmodule Storybook.ArtComponent.Sun do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.ArtComponent.Sun.dm_art_sun/1
  def description, do: "Sun art using the el-dm-art-sun custom element."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default sun",
        attributes: %{
          id: "sun-default"
        }
      }
    ]
  end
end
