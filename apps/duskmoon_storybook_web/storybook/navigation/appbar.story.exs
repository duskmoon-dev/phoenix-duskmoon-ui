defmodule Storybook.Navigation.Appbar do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Navigation.Appbar.dm_appbar/1

  def description,
    do: "Application bar with logo, navigation menus, and user profile. Uses <app-bar> custom element."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Basic appbar with title and menus",
        attributes: %{
          title: "MyApp"
        },
        slots: [
          """
          <:logo>
            <span class="text-2xl font-bold">DM</span>
          </:logo>
          <:menu to="/dashboard">Dashboard</:menu>
          <:menu to="/settings">Settings</:menu>
          <:user_profile>
            <span class="text-sm">(^_^)</span>
          </:user_profile>
          """
        ]
      },
      %Variation{
        id: :minimal,
        description: "Appbar with title only",
        attributes: %{
          title: "Duskmoon UI"
        },
        slots: [
          """
          <:logo>
            <span class="text-xl">🌙</span>
          </:logo>
          """
        ]
      },
      %Variation{
        id: :with_class,
        description: "Appbar with custom styling",
        attributes: %{
          title: "Styled App",
          class: "shadow-lg"
        },
        slots: [
          """
          <:logo>
            <span class="text-2xl">⭐</span>
          </:logo>
          <:menu to="/home">Home</:menu>
          <:menu to="/about">About</:menu>
          <:menu to="/contact">Contact</:menu>
          <:user_profile>
            <button class="btn btn-sm btn-ghost">Login</button>
          </:user_profile>
          """
        ]
      }
    ]
  end
end
