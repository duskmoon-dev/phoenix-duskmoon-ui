defmodule Storybook.Components.Card do
  # :live_component or :page are also available
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Card.dm_card/1
  def description, do: "A card element."

  def variations do
    [
      %Variation{
        id: :default,
        slots: [
          """
          <:title>
          Star Wars
          </:title>
          Star Wars is an American epic space opera multimedia
          franchise created by George Lucas,
          which began with the eponymous 1977 film and
          quickly became a worldwide pop-culture phenomenon.
          """
        ]
      },
      %Variation{
        id: :card_second,
        attributes: %{
          class: "w-full shadow-xl"
        },
        slots: [
          """
          <:title>
          Star Wars
          </:title>
          <div class="skeleton w-full min-h-32">

          </div>
          """
        ]
      }
    ]
  end
end
