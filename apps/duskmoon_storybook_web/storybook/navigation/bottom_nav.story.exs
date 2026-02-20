defmodule Storybook.Navigation.BottomNav do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Navigation.BottomNav.dm_bottom_nav/1
  def description, do: "Bottom navigation bar with icon items."

  def variations do
    [
      %Variation{
        id: :default,
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
      }
    ]
  end
end
