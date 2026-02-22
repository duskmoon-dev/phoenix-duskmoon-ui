defmodule Storybook.DataDisplay.Avatar do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Avatar.dm_avatar/1
  def description, do: "Avatar component for displaying user images and placeholders."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Image avatar with default size",
        attributes: %{
          src: "https://picsum.photos/seed/user1/100/100.jpg",
          alt: "User Avatar"
        }
      },
      %Variation{
        id: :with_ring,
        description: "Avatar with ring border",
        attributes: %{
          src: "https://picsum.photos/seed/user2/100/100.jpg",
          alt: "User Avatar",
          ring: true
        }
      },
      %Variation{
        id: :online_status,
        description: "Online indicator with ring",
        attributes: %{
          src: "https://picsum.photos/seed/user3/100/100.jpg",
          alt: "User Avatar",
          online: true,
          ring: true
        }
      },
      %Variation{
        id: :offline_status,
        description: "Offline indicator with ring",
        attributes: %{
          src: "https://picsum.photos/seed/user4/100/100.jpg",
          alt: "User Avatar",
          offline: true,
          ring: true
        }
      },
      %Variation{
        id: :text_based,
        description: "Text initials with primary color",
        attributes: %{
          name: "John Doe",
          color: "primary"
        }
      },
      %Variation{
        id: :text_based_colored,
        description: "Text initials with success color",
        attributes: %{
          name: "Jane Smith",
          color: "success"
        }
      },
      %Variation{
        id: :size_variants,
        description: "Extra-small (xs) size",
        attributes: %{
          src: "https://picsum.photos/seed/user5/100/100.jpg",
          alt: "User Avatar",
          size: "xs"
        }
      },
      %Variation{
        id: :small_avatar,
        description: "Small (sm) size",
        attributes: %{
          src: "https://picsum.photos/seed/user6/100/100.jpg",
          alt: "User Avatar",
          size: "sm"
        }
      },
      %Variation{
        id: :large_avatar,
        description: "Large (lg) size with ring",
        attributes: %{
          src: "https://picsum.photos/seed/user7/100/100.jpg",
          alt: "User Avatar",
          size: "lg",
          ring: true
        }
      },
      %Variation{
        id: :extra_large_avatar,
        description: "Extra-large (xl) size with ring and online status",
        attributes: %{
          src: "https://picsum.photos/seed/user8/100/100.jpg",
          alt: "User Avatar",
          size: "xl",
          ring: true,
          online: true
        }
      },
      %Variation{
        id: :square_shape,
        description: "Square shape with ring",
        attributes: %{
          src: "https://picsum.photos/seed/user9/100/100.jpg",
          alt: "User Avatar",
          shape: "square",
          ring: true
        }
      },
      %Variation{
        id: :rounded_shape,
        description: "Rounded-square shape",
        attributes: %{
          src: "https://picsum.photos/seed/user10/100/100.jpg",
          alt: "User Avatar",
          shape: "rounded"
        }
      },
      %Variation{
        id: :ring_primary,
        description: "Primary-colored ring",
        attributes: %{
          name: "Ring",
          ring: true,
          ring_color: "primary"
        }
      },
      %Variation{
        id: :ring_secondary,
        description: "Secondary-colored ring",
        attributes: %{
          name: "Ring",
          ring: true,
          ring_color: "secondary"
        }
      },
      %Variation{
        id: :different_colors,
        description: "Accent background color",
        attributes: %{
          name: "Alex Johnson",
          color: "accent"
        }
      },
      %Variation{
        id: :warning_color,
        description: "Warning background color",
        attributes: %{
          name: "Warning User",
          color: "warning"
        }
      },
      %Variation{
        id: :error_color,
        description: "Error background color",
        attributes: %{
          name: "Error User",
          color: "error"
        }
      },
      %Variation{
        id: :info_color,
        description: "Info background color",
        attributes: %{
          name: "Info User",
          color: "info"
        }
      },
      %Variation{
        id: :short_name,
        description: "Single character name",
        attributes: %{
          name: "A",
          color: "secondary"
        }
      },
      %Variation{
        id: :two_initials,
        description: "Two-word name — shows initials",
        attributes: %{
          name: "John Smith",
          color: "primary"
        }
      },
      %Variation{
        id: :without_name,
        description: "No name or image — placeholder fallback",
        attributes: %{
          color: "info"
        }
      }
    ]
  end
end
