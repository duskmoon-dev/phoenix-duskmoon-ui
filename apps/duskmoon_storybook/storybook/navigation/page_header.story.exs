defmodule Storybook.Navigation.PageHeader do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Navigation.PageHeader.dm_page_header/1

  def description,
    do:
      "Page header with sticky nav on scroll. Uses PageHeader LiveView hook for intersection observer behavior."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Page header with menus, user profile, and hero content",
        attributes: %{
          id: "story-page-header",
          nav_id: "story-page-header-nav"
        },
        slots: [
          """
          <:menu to="#home">Home</:menu>
          <:menu to="#about">About</:menu>
          <:menu to="#docs">Docs</:menu>
          <:user_profile>
            <span class="text-sm px-4">(^_^)</span>
          </:user_profile>
          <div class="py-12 text-center">
            <h1 class="text-4xl font-bold">Welcome to Duskmoon UI</h1>
            <p class="text-lg mt-4 opacity-70">A component library for Phoenix LiveView</p>
          </div>
          """
        ]
      },
      %Variation{
        id: :with_custom_class,
        description: "Custom background on header and nav bar",
        attributes: %{
          id: "story-page-header-styled",
          nav_id: "story-page-header-nav-styled",
          class: "bg-surface-container",
          nav_class: "bg-surface-container-high"
        },
        slots: [
          """
          <:menu to="#features" class="text-primary">Features</:menu>
          <:menu to="#pricing" class="text-primary">Pricing</:menu>
          <div class="py-8 text-center">
            <h2 class="text-3xl font-bold">Styled Page Header</h2>
          </div>
          """
        ]
      },
      %Variation{
        id: :with_active_menu,
        description: "Menu item with active state highlighted",
        attributes: %{
          id: "story-page-header-active",
          nav_id: "story-page-header-nav-active"
        },
        slots: [
          """
          <:menu to="#home" active={true}>Home</:menu>
          <:menu to="#about">About</:menu>
          <:menu to="#contact">Contact</:menu>
          <div class="py-8 text-center">
            <h2 class="text-3xl font-bold">Active Menu Demo</h2>
          </div>
          """
        ]
      },
      %Variation{
        id: :with_nav_label,
        description: "Custom accessible nav label and toggle label for screen readers",
        attributes: %{
          id: "story-page-header-a11y",
          nav_id: "story-page-header-nav-a11y",
          nav_label: "Main site navigation",
          toggle_menu_label: "Open navigation menu"
        },
        slots: [
          """
          <:menu to="#docs">Documentation</:menu>
          <:menu to="#api">API Reference</:menu>
          <div class="py-8 text-center">
            <h2 class="text-3xl font-bold">Accessible Header</h2>
            <p class="mt-2 opacity-70">Inspect element to see aria-label on nav</p>
          </div>
          """
        ]
      }
    ]
  end
end
