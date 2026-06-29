defmodule Storybook.ArtComponent.CatStargazer do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.ArtComponent.CatStargazer.dm_art_cat_stargazer/1
  def description, do: "Cat stargazer art using the el-dm-art-cat-stargazer custom element."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default cat stargazer",
        attributes: %{
          id: "cat-default"
        }
      }
    ]
  end
end
