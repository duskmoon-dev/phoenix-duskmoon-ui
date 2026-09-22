defmodule Storybook.Navigation.Megamenu do
  use PhoenixStorybook.Story, :component
  def function, do: &PhoenixDuskmoon.Component.Navigation.Megamenu.dm_megamenu/1

  def description,
    do:
      "Native popover navigation with responsive link groups. Open with the trigger; dismiss with Escape or a click outside."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{id: "products-menu"},
        slots: [
          ~s|<:trigger>Explore the workspace</:trigger>|,
          ~s|<:group title="Create"><ul class="menu"><li><a class="link" href="#projects">Projects</a></li><li><a class="link" href="#documents">Documents</a></li></ul></:group>|,
          ~s|<:group title="Collaborate"><p class="megamenu-supporting">Work together across time zones.</p><ul class="menu"><li><a class="link" href="#team">Team directory</a></li></ul></:group>|
        ]
      },
      %Variation{
        id: :full,
        attributes: %{id: "resources-menu", full: true},
        slots: [
          ~s|<:trigger>Resources</:trigger>|,
          ~s|<:group title="Learn"><ul class="menu"><li><a class="link" href="#guides">Guides</a></li></ul></:group>|,
          ~s|<:group title="Support"><ul class="menu"><li><a class="link" href="#help">Help center</a></li></ul></:group>|
        ]
      }
    ]
  end
end
