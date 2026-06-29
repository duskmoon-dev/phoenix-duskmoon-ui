defmodule Storybook.ArtComponent.PlasmaBall do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.ArtComponent.PlasmaBall.dm_art_plasma_ball/1
  def description, do: "Interactive plasma ball art using the el-dm-art-plasma-ball custom element."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default plasma ball with base",
        attributes: %{
          id: "plasma-default"
        }
      },
      %Variation{
        id: :no_base,
        description: "Plasma ball without base",
        attributes: %{
          id: "plasma-no-base",
          "no-base": true
        }
      }
    ]
  end
end
