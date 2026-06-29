defmodule Storybook.Feedback.Loading do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Feedback.Loading.dm_loading_ex/1
  def description, do: "Advanced animated particle loading effect with colorful rotating particles."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default particle loader (88 particles, 21em, 4s)",
      },
      %Variation{
        id: :large_fast,
        description: "Large loader with more particles and faster speed",
        attributes: %{
          item_count: 200,
          size: 44,
          speed: "2400ms"
        },
      },
      %Variation{
        id: :small_slow,
        description: "Small compact loader with fewer particles",
        attributes: %{
          item_count: 30,
          size: 10,
          speed: "6s"
        },
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :item_count,
        label: "Particles",
        type: :number,
        default: 88
      },
      %{
        id: :size,
        label: "Size (em)",
        type: :number,
        default: 21
      },
      %{
        id: :speed,
        label: "Speed",
        type: :select,
        options: [
          {"2s", "Fast (2s)"},
          {"4s", "Normal (4s)"},
          {"6s", "Slow (6s)"},
          {"8s", "Very Slow (8s)"}
        ],
        default: "4s"
      }
    ]
  end
end
