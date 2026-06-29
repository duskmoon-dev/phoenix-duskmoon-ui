defmodule Storybook.Navigation.SimpleAppbar do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Navigation.Appbar.dm_simple_appbar/1

  def description,
    do: "Responsive HTML appbar with mobile menu toggle. Menus collapse behind a hamburger icon on small screens."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Basic responsive appbar with logo, menus, and user profile",
        attributes: %{
          title: "MyApp"
        },
        slots: [
          """
          <:logo>
            <span class="text-2xl font-bold">DM</span>
          </:logo>
          <:menu to="#dashboard">Dashboard</:menu>
          <:menu to="#settings">Settings</:menu>
          <:user_profile>
            <span class="text-sm">(^_^)</span>
          </:user_profile>
          """
        ]
      },
      %Variation{
        id: :with_active_menu,
        description: "Menu item with active state highlighted",
        attributes: %{
          title: "Active Nav"
        },
        slots: [
          """
          <:logo>
            <span class="text-xl font-bold">DM</span>
          </:logo>
          <:menu to="#" active={true}>Dashboard</:menu>
          <:menu to="#">Reports</:menu>
          <:menu to="#">Settings</:menu>
          """
        ]
      },
      %Variation{
        id: :minimal,
        description: "Logo and title only (no menus or user profile)",
        attributes: %{
          title: "Duskmoon UI"
        },
        slots: [
          """
          <:logo>
            <span class="text-xl font-bold">DM</span>
          </:logo>
          """
        ]
      },
      %Variation{
        id: :with_nav_label,
        description: "Custom accessible nav and toggle labels for screen readers",
        attributes: %{
          title: "Accessible App",
          nav_label: "Primary application navigation",
          toggle_menu_label: "Open navigation menu"
        },
        slots: [
          """
          <:logo>
            <span class="text-xl font-bold">DM</span>
          </:logo>
          <:menu to="#">Home</:menu>
          <:menu to="#">About</:menu>
          <:user_profile>
            <button type="button" class="btn btn-sm btn-ghost">Login</button>
          </:user_profile>
          """
        ]
      }
    ]
  end
end
