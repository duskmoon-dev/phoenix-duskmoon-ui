defmodule Storybook.ArtComponent.Snow do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.ArtComponent.Snow.dm_art_snow/1
  def description, do: "Falling snow art using the el-dm-art-snow custom element."

  def variations do
    [
      %Variation{
        id: :static,
        description: "Static snowflakes (no animation)",
        attributes: %{
          id: "snow-static"
        }
      },
      %Variation{
        id: :unicode,
        description: "Unicode snowflake character variant",
        attributes: %{
          id: "snow-unicode",
          unicode: true
        }
      },
      %Variation{
        id: :fall,
        description: "Animated falling snowflakes",
        attributes: %{
          id: "snow-fall",
          fall: true
        }
      }
    ]
  end
end
