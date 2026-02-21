defmodule Storybook.DataDisplay.Avatar do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Avatar.dm_avatar/1
  def description, do: "Avatar component for displaying user images and placeholders."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          src: "https://picsum.photos/seed/user1/100/100.jpg",
          alt: "User Avatar"
        }
      },
      %Variation{
        id: :with_ring,
        attributes: %{
          src: "https://picsum.photos/seed/user2/100/100.jpg",
          alt: "User Avatar",
          ring: true
        }
      },
      %Variation{
        id: :online_status,
        attributes: %{
          src: "https://picsum.photos/seed/user3/100/100.jpg",
          alt: "User Avatar",
          online: true,
          ring: true
        }
      },
      %Variation{
        id: :offline_status,
        attributes: %{
          src: "https://picsum.photos/seed/user4/100/100.jpg",
          alt: "User Avatar",
          offline: true,
          ring: true
        }
      },
      %Variation{
        id: :text_based,
        attributes: %{
          name: "John Doe",
          color: "primary"
        }
      },
      %Variation{
        id: :text_based_colored,
        attributes: %{
          name: "Jane Smith",
          color: "success"
        }
      },
      %Variation{
        id: :size_variants,
        attributes: %{
          src: "https://picsum.photos/seed/user5/100/100.jpg",
          alt: "User Avatar",
          size: "xs"
        }
      },
      %Variation{
        id: :small_avatar,
        attributes: %{
          src: "https://picsum.photos/seed/user6/100/100.jpg",
          alt: "User Avatar",
          size: "sm"
        }
      },
      %Variation{
        id: :large_avatar,
        attributes: %{
          src: "https://picsum.photos/seed/user7/100/100.jpg",
          alt: "User Avatar",
          size: "lg",
          ring: true
        }
      },
      %Variation{
        id: :extra_large_avatar,
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
        attributes: %{
          src: "https://picsum.photos/seed/user9/100/100.jpg",
          alt: "User Avatar",
          shape: "square",
          ring: true
        }
      },
      %Variation{
        id: :rounded_shape,
        attributes: %{
          src: "https://picsum.photos/seed/user10/100/100.jpg",
          alt: "User Avatar",
          shape: "rounded"
        }
      },
      %Variation{
        id: :ring_primary,
        attributes: %{
          name: "Ring",
          ring: true,
          ring_color: "primary"
        }
      },
      %Variation{
        id: :ring_secondary,
        attributes: %{
          name: "Ring",
          ring: true,
          ring_color: "secondary"
        }
      },
      %Variation{
        id: :different_colors,
        attributes: %{
          name: "Alex Johnson",
          color: "accent"
        }
      },
      %Variation{
        id: :warning_color,
        attributes: %{
          name: "Warning User",
          color: "warning"
        }
      },
      %Variation{
        id: :error_color,
        attributes: %{
          name: "Error User",
          color: "error"
        }
      },
      %Variation{
        id: :info_color,
        attributes: %{
          name: "Info User",
          color: "info"
        }
      },
      %Variation{
        id: :short_name,
        attributes: %{
          name: "A",
          color: "secondary"
        }
      },
      %Variation{
        id: :two_initials,
        attributes: %{
          name: "John Smith",
          color: "primary"
        }
      },
      %Variation{
        id: :without_name,
        attributes: %{
          color: "info"
        }
      }
    ]
  end
end
