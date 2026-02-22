defmodule Storybook.DataDisplay.Card do
  # :live_component or :page are also available
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Card.dm_card/1
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
      },
      %Variation{
        id: :interactive_with_image,
        description: "Interactive card with image and actions",
        attributes: %{
          interactive: true,
          shadow: "lg",
          image: "https://picsum.photos/seed/duskmoon/400/200",
          image_alt: "Placeholder landscape"
        },
        slots: [
          """
          <:title>Interactive Card</:title>
          Click this card to see the hover effect.
          <:actions>
            <button type="button" class="btn btn-primary btn-sm">Learn More</button>
          </:actions>
          """
        ]
      }
    ]
  end
end
