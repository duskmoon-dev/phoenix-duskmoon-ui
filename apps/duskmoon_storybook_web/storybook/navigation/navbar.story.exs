defmodule Storybook.Navigation.Navbar do
  # :live_component or :page are also available
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Navigation.Navbar.dm_navbar/1
  def description, do: "A navbar element."

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
      }
    ]
  end
end
