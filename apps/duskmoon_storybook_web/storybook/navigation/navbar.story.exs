defmodule Storybook.Navigation.Navbar do
  # :live_component or :page are also available
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Navigation.Navbar.dm_navbar/1
  def description, do: "Horizontal navigation bar with start, center, and end slots for logo, links, and actions."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default navbar with start and end parts",
        attributes: %{
          class: "shadow"
        },
        slots: [
          """
          <:start_part>
            Star Wars
          </:start_part>
          <:end_part>
            <button type="button">action</button>
          </:end_part>
          """
        ]
      },
      %Variation{
        id: :with_center,
        description: "Navbar with all three parts including center navigation",
        attributes: %{
          class: "shadow"
        },
        slots: [
          """
          <:start_part>
            <span class="font-bold text-lg">MyApp</span>
          </:start_part>
          <:center_part>
            <a href="#" class="px-3">Home</a>
            <a href="#" class="px-3">About</a>
            <a href="#" class="px-3">Contact</a>
          </:center_part>
          <:end_part>
            <button type="button" class="btn btn-sm">Sign In</button>
          </:end_part>
          """
        ]
      },
      %Variation{
        id: :start_only,
        description: "Minimal navbar with start part only",
        attributes: %{
          class: "shadow"
        },
        slots: [
          """
          <:start_part>
            <span class="font-bold text-xl">Duskmoon UI</span>
          </:start_part>
          """
        ]
      },
      %Variation{
        id: :with_section_classes,
        description: "Custom CSS classes on start, center, and end containers",
        attributes: %{
          class: "shadow",
          start_class: "gap-2",
          center_class: "font-semibold",
          end_class: "gap-4"
        },
        slots: [
          """
          <:start_part>
            <span class="font-bold">Brand</span>
          </:start_part>
          <:center_part>
            <a href="#">Docs</a>
            <a href="#">Blog</a>
          </:center_part>
          <:end_part>
            <button type="button" class="btn btn-sm btn-ghost">Login</button>
            <button type="button" class="btn btn-sm btn-primary">Sign Up</button>
          </:end_part>
          """
        ]
      },
      %Variation{
        id: :with_nav_label,
        description: "Custom accessible nav label for screen readers",
        attributes: %{
          class: "shadow",
          nav_label: "Primary site navigation"
        },
        slots: [
          """
          <:start_part>
            <span class="font-bold">App</span>
          </:start_part>
          <:center_part>
            <a href="#">Home</a>
            <a href="#">Features</a>
          </:center_part>
          """
        ]
      }
    ]
  end
end
