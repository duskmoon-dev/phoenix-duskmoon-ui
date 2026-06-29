defmodule Storybook.Navigation.BottomNav do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Navigation.BottomNav.dm_bottom_nav/1
  def description, do: "Bottom navigation bar with icon items."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Basic bottom nav with four icon items",
        attributes: %{
          id: "bnav-default",
          items: [
            %{icon: "home", label: "Home", active: true},
            %{icon: "magnify", label: "Search"},
            %{icon: "bell", label: "Alerts"},
            %{icon: "account", label: "Profile"}
          ],
          position: "static"
        }
      },
      %Variation{
        id: :colored,
        description: "Primary colored bottom nav",
        attributes: %{
          id: "bnav-color",
          items: [
            %{icon: "home", label: "Home", active: true},
            %{icon: "magnify", label: "Search"},
            %{icon: "cog", label: "Settings"}
          ],
          color: "primary",
          position: "static"
        }
      },
      %VariationGroup{
        id: :colors,
        description: "Color variants for active item",
        variations: [
          %Variation{
            id: :secondary,
            attributes: %{
              id: "bnav-sec",
              color: "secondary",
              position: "static",
              items: [
                %{icon: "home", label: "Home", active: true},
                %{icon: "magnify", label: "Search"},
                %{icon: "account", label: "Profile"}
              ]
            }
          },
          %Variation{
            id: :success,
            attributes: %{
              id: "bnav-succ",
              color: "success",
              position: "static",
              items: [
                %{icon: "home", label: "Home", active: true},
                %{icon: "magnify", label: "Search"},
                %{icon: "account", label: "Profile"}
              ]
            }
          },
          %Variation{
            id: :warning,
            attributes: %{
              id: "bnav-warn",
              color: "warning",
              position: "static",
              items: [
                %{icon: "home", label: "Home", active: true},
                %{icon: "magnify", label: "Search"},
                %{icon: "account", label: "Profile"}
              ]
            }
          },
          %Variation{
            id: :error,
            attributes: %{
              id: "bnav-err",
              color: "error",
              position: "static",
              items: [
                %{icon: "home", label: "Home", active: true},
                %{icon: "magnify", label: "Search"},
                %{icon: "account", label: "Profile"}
              ]
            }
          }
        ]
      },
      %Variation{
        id: :sticky_position,
        description: "Sticky-positioned navigation",
        attributes: %{
          id: "bnav-sticky",
          position: "sticky",
          color: "primary",
          items: [
            %{icon: "home", label: "Home", active: true},
            %{icon: "magnify", label: "Explore"},
            %{icon: "bell", label: "Alerts"},
            %{icon: "account", label: "Profile"}
          ]
        }
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :color,
        label: "Color",
        type: :select,
        options: [
          {"primary", "Primary"},
          {"secondary", "Secondary"},
          {"success", "Success"},
          {"warning", "Warning"},
          {"error", "Error"}
        ],
        default: "primary"
      },
      %{
        id: :position,
        label: "Position",
        type: :select,
        options: [
          {"static", "Static"},
          {"fixed", "Fixed"},
          {"sticky", "Sticky"}
        ],
        default: "fixed"
      }
    ]
  end
end
