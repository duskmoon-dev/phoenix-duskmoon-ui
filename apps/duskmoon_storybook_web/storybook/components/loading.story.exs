defmodule Storybook.Components.Loading do
  # :live_component or :page are also available
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Loading.dm_loading_ex/1
  def description, do: "Loading Effect EX."

  def variations do
    [
      %Variation{
        id: :default,
        slots: []
      },
      %Variation{
        id: :with_attributes,
        attributes: %{
          item_count: 200,
          size: 44,
          speed: "2400ms"
        },
        slots: []
      }
    ]
  end
end
