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
          <:start_part>
            Star Wars
          </:start_part>
          <:end_part>
            <button type="button">action</button>
          </:end_part>
          """
        ]
      }
    ]
  end
end
