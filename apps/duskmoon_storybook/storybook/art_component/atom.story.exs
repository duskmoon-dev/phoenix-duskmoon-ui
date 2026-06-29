defmodule Storybook.ArtComponent.Atom do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.ArtComponent.Atom.dm_art_atom/1
  def description, do: "Atom art using the el-dm-art-atom custom element."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default atom",
        attributes: %{
          id: "atom-default"
        }
      }
    ]
  end
end
