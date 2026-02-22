defmodule Storybook.DataDisplay.Avatar do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Avatar.dm_avatar/1
  def description, do: "Avatar component for displaying user images and placeholders."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Image avatar with default size",
        attributes: %{src: "https://picsum.photos/seed/user1/100/100.jpg", alt: "User Avatar"}
      },
      %VariationGroup{
        id: :status,
        description: "Online/offline status indicators",
        variations: [
          %Variation{
            id: :ring,
            attributes: %{src: "https://picsum.photos/seed/user2/100/100.jpg", alt: "User", ring: true}
          },
          %Variation{
            id: :online,
            attributes: %{src: "https://picsum.photos/seed/user3/100/100.jpg", alt: "User", online: true, ring: true}
          },
          %Variation{
            id: :offline,
            attributes: %{src: "https://picsum.photos/seed/user4/100/100.jpg", alt: "User", offline: true, ring: true}
          }
        ]
      },
      %VariationGroup{
        id: :sizes,
        description: "Size variants",
        variations: [
          %Variation{id: :xs, attributes: %{src: "https://picsum.photos/seed/user5/100/100.jpg", alt: "User", size: "xs"}},
          %Variation{id: :sm, attributes: %{src: "https://picsum.photos/seed/user6/100/100.jpg", alt: "User", size: "sm"}},
          %Variation{
            id: :lg,
            attributes: %{src: "https://picsum.photos/seed/user7/100/100.jpg", alt: "User", size: "lg", ring: true}
          },
          %Variation{
            id: :xl,
            attributes: %{
              src: "https://picsum.photos/seed/user8/100/100.jpg",
              alt: "User",
              size: "xl",
              ring: true,
              online: true
            }
          }
        ]
      },
      %VariationGroup{
        id: :shapes,
        description: "Shape variants",
        variations: [
          %Variation{
            id: :square,
            attributes: %{src: "https://picsum.photos/seed/user9/100/100.jpg", alt: "User", shape: "square", ring: true}
          },
          %Variation{
            id: :rounded,
            attributes: %{src: "https://picsum.photos/seed/user10/100/100.jpg", alt: "User", shape: "rounded"}
          }
        ]
      },
      %VariationGroup{
        id: :ring_colors,
        description: "Ring color variants",
        variations: [
          %Variation{id: :ring_primary, attributes: %{name: "Ring", ring: true, ring_color: "primary"}},
          %Variation{id: :ring_secondary, attributes: %{name: "Ring", ring: true, ring_color: "secondary"}}
        ]
      },
      %VariationGroup{
        id: :text_colors,
        description: "Text-based avatar color variants",
        variations: [
          %Variation{id: :primary, attributes: %{name: "John Doe", color: "primary"}},
          %Variation{id: :success, attributes: %{name: "Jane Smith", color: "success"}},
          %Variation{id: :accent, attributes: %{name: "Alex Johnson", color: "accent"}},
          %Variation{id: :warning, attributes: %{name: "Warning User", color: "warning"}},
          %Variation{id: :error, attributes: %{name: "Error User", color: "error"}},
          %Variation{id: :info, attributes: %{name: "Info User", color: "info"}}
        ]
      },
      %VariationGroup{
        id: :text_content,
        description: "Text/initials rendering edge cases",
        variations: [
          %Variation{id: :single_char, attributes: %{name: "A", color: "secondary"}},
          %Variation{id: :two_initials, attributes: %{name: "John Smith", color: "primary"}},
          %Variation{id: :no_name, attributes: %{color: "info"}}
        ]
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :size,
        label: "Size",
        type: :select,
        options: [
          {"xs", "XS"},
          {"sm", "SM"},
          {"md", "MD"},
          {"lg", "LG"},
          {"xl", "XL"}
        ],
        default: "md"
      },
      %{
        id: :shape,
        label: "Shape",
        type: :select,
        options: [
          {"circle", "Circle"},
          {"square", "Square"},
          {"rounded", "Rounded"}
        ],
        default: "circle"
      },
      %{
        id: :color,
        label: "Color",
        type: :select,
        options: [
          {"primary", "Primary"},
          {"secondary", "Secondary"},
          {"tertiary", "Tertiary"},
          {"accent", "Accent"},
          {"info", "Info"},
          {"success", "Success"},
          {"warning", "Warning"},
          {"error", "Error"}
        ],
        default: "primary"
      },
      %{
        id: :ring,
        label: "Ring",
        type: :boolean,
        default: false
      },
      %{
        id: :online,
        label: "Online",
        type: :boolean,
        default: false
      },
      %{
        id: :offline,
        label: "Offline",
        type: :boolean,
        default: false
      }
    ]
  end
end
