defmodule Storybook.Layout.ThemeSwitcher do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Layout.ThemeSwitcher.dm_theme_switcher/1

  def description,
    do:
      "Theme switcher dropdown with sunshine/moonlight themes. Uses ThemeSwitcher LiveView hook for localStorage persistence."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default theme switcher (auto-detect)"
      },
      %Variation{
        id: :sunshine,
        description: "Pre-selected sunshine (light) theme",
        attributes: %{
          theme: "sunshine"
        }
      },
      %Variation{
        id: :moonlight,
        description: "Pre-selected moonlight (dark) theme",
        attributes: %{
          theme: "moonlight"
        }
      }
    ]
  end
end
