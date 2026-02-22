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
          <:title>Star Wars</:title>
          Star Wars is an American epic space opera multimedia
          franchise created by George Lucas,
          which began with the eponymous 1977 film and
          quickly became a worldwide pop-culture phenomenon.
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
      },
      %VariationGroup{
        id: :variants,
        description: "Layout and style variants",
        variations: [
          %Variation{
            id: :compact,
            attributes: %{variant: "compact"},
            slots: ["<:title>Compact</:title>Reduced internal spacing."]
          },
          %Variation{
            id: :side,
            attributes: %{
              variant: "side",
              image: "https://picsum.photos/seed/side/120/120",
              image_alt: "Side image"
            },
            slots: ["<:title>Side</:title>Content beside the image."]
          },
          %Variation{
            id: :bordered,
            attributes: %{variant: "bordered"},
            slots: ["<:title>Bordered</:title>Visible border outline."]
          },
          %Variation{
            id: :glass,
            attributes: %{variant: "glass"},
            slots: ["<:title>Glass</:title>Translucent glass morphism."]
          }
        ]
      },
      %VariationGroup{
        id: :shadows,
        description: "Shadow elevation levels",
        variations:
          for shadow <- ~w(sm md lg xl) do
            %Variation{
              id: String.to_atom("shadow_#{shadow}"),
              attributes: %{shadow: shadow},
              slots: ["<:title>#{String.upcase(shadow)} Shadow</:title>Shadow elevation demo."]
            }
          end
      },
      %VariationGroup{
        id: :paddings,
        description: "Internal padding options",
        variations:
          for {padding, label} <- [{"none", "None"}, {"sm", "SM"}, {"md", "MD"}, {"lg", "LG"}] do
            %Variation{
              id: String.to_atom("padding_#{padding}"),
              attributes: %{padding: padding},
              slots: ["<:title>#{label} Padding</:title>Padding level demo."]
            }
          end
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :variant,
        label: "Variant",
        type: :select,
        options: [
          {nil, "Default"},
          {"compact", "Compact"},
          {"side", "Side"},
          {"bordered", "Bordered"},
          {"glass", "Glass"}
        ],
        default: nil
      },
      %{
        id: :shadow,
        label: "Shadow",
        type: :select,
        options: [
          {nil, "Default"},
          {"none", "None"},
          {"sm", "SM"},
          {"md", "MD"},
          {"lg", "LG"},
          {"xl", "XL"},
          {"2xl", "2XL"}
        ],
        default: nil
      },
      %{
        id: :padding,
        label: "Padding",
        type: :select,
        options: [
          {nil, "Default"},
          {"none", "None"},
          {"sm", "SM"},
          {"md", "MD"},
          {"lg", "LG"}
        ],
        default: nil
      },
      %{
        id: :interactive,
        label: "Interactive",
        type: :boolean,
        default: false
      }
    ]
  end
end
