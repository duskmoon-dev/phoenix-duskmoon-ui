defmodule Storybook.DataDisplay.Card do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Card.dm_card/1
  def description, do: "Card container with title, body, image, and action slots. Uses el-dm-card custom element."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default card with title and body text",
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
        id: :compact_variant,
        description: "Compact layout — reduced padding",
        attributes: %{
          variant: "compact"
        },
        slots: [
          """
          <:title>Compact Card</:title>
          Compact layout with reduced internal spacing.
          """
        ]
      },
      %Variation{
        id: :side_variant,
        description: "Side layout — image and content side by side",
        attributes: %{
          variant: "side",
          image: "https://picsum.photos/seed/side/120/120",
          image_alt: "Side image"
        },
        slots: [
          """
          <:title>Side Card</:title>
          Content laid out beside the image.
          """
        ]
      },
      %Variation{
        id: :bordered_variant,
        description: "Bordered style",
        attributes: %{
          variant: "bordered"
        },
        slots: [
          """
          <:title>Bordered Card</:title>
          Card with a visible border outline.
          """
        ]
      },
      %Variation{
        id: :glass_variant,
        description: "Glass morphism effect",
        attributes: %{
          variant: "glass"
        },
        slots: [
          """
          <:title>Glass Card</:title>
          Translucent glass morphism style.
          """
        ]
      },
      %Variation{
        id: :shadow_sm,
        description: "Small shadow elevation",
        attributes: %{
          shadow: "sm"
        },
        slots: [
          """
          <:title>Small Shadow</:title>
          Card with a small shadow.
          """
        ]
      },
      %Variation{
        id: :shadow_xl,
        description: "Extra-large shadow elevation",
        attributes: %{
          shadow: "xl"
        },
        slots: [
          """
          <:title>XL Shadow</:title>
          Card with an extra-large shadow.
          """
        ]
      },
      %Variation{
        id: :padding_none,
        description: "No internal padding — full-bleed content",
        attributes: %{
          padding: "none"
        },
        slots: [
          """
          <:title>No Padding</:title>
          Card with no internal padding.
          """
        ]
      },
      %Variation{
        id: :padding_lg,
        description: "Large internal padding",
        attributes: %{
          padding: "lg"
        },
        slots: [
          """
          <:title>Large Padding</:title>
          Card with generous internal padding.
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
          <:action>
            <button type="button" class="btn btn-primary btn-sm">Learn More</button>
          </:action>
          """
        ]
      }
    ]
  end
end
