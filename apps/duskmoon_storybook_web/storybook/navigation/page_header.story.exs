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
        description: "Page header with menus and content",
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
        description: "Page header with custom styling",
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
      }
    ]
  end
end
