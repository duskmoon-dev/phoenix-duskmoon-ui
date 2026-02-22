defmodule Storybook.Navigation.Appbar do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Navigation.Appbar.dm_appbar/1

  def description,
    do: "Application bar with logo, navigation menus, and user profile. Uses <app-bar> custom element."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Basic appbar with logo, title, menus, and user profile",
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
        description: "Appbar with logo and title only (no menus)",
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
        id: :with_active_menu,
        description: "Menu item with active state",
        attributes: %{
          title: "Active Menu"
        },
        slots: [
          """
          <:logo>
            <span class="text-xl font-bold">DM</span>
          </:logo>
          <:menu to="#" active={true}>Dashboard</:menu>
          <:menu to="#">Settings</:menu>
          <:menu to="#">Reports</:menu>
          """
        ]
      },
      %Variation{
        id: :non_sticky,
        description: "Non-sticky appbar (scrolls with page content)",
        attributes: %{
          title: "Scrollable",
          sticky: false
        },
        slots: [
          """
          <:logo>
            <span class="text-xl font-bold">DM</span>
          </:logo>
          <:menu to="#">Page 1</:menu>
          <:menu to="#">Page 2</:menu>
          """
        ]
      },
      %Variation{
        id: :with_title_link,
        description: "Brand area (logo + title) links to a URL",
        attributes: %{
          title: "Linked Brand",
          title_to: "/"
        },
        slots: [
          """
          <:logo>
            <span class="text-2xl font-bold">DM</span>
          </:logo>
          <:menu to="#">Docs</:menu>
          """
        ]
      },
      %Variation{
        id: :with_nav_label,
        description: "Custom accessible nav label for screen readers",
        attributes: %{
          title: "Accessible App",
          nav_label: "Main application navigation"
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
