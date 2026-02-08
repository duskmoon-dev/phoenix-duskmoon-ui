defmodule Storybook.Navigation.Navbar do
  # :live_component or :page are also available
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Navigation.Navbar.dm_navbar/1
  def description, do: "A navbar element."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          class: "shadow"
        },
        slots: [
          """
          <:left>
            Star Wars
          </:left>
          <:right>
            <button>action</button>
          </:right>
          """
        ]
      }
    ]
  end
end
