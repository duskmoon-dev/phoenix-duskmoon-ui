defmodule Storybook.ArtComponent.SynthwaveStarfield do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.ArtComponent.SynthwaveStarfield.dm_art_synthwave_starfield/1

  def description,
    do: "Synthwave starfield art using the el-dm-art-synthwave-starfield custom element."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default synthwave starfield",
        attributes: %{
          id: "starfield-default"
        }
      }
    ]
  end
end
