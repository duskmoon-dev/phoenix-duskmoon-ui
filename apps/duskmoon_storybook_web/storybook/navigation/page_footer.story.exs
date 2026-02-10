defmodule Storybook.Navigation.PageFooter do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Navigation.PageFooter.dm_page_footer/1

  def description, do: "Page footer with sections and copyright. Uses a grid layout for footer content."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Footer with sections and copyright",
        slots: [
          """
          <:section title="Product">
            <a href="#" class="hover:underline">Features</a>
            <a href="#" class="hover:underline">Pricing</a>
            <a href="#" class="hover:underline">Changelog</a>
          </:section>
          <:section title="Resources">
            <a href="#" class="hover:underline">Documentation</a>
            <a href="#" class="hover:underline">Guides</a>
            <a href="#" class="hover:underline">API Reference</a>
          </:section>
          <:copyright title="Duskmoon UI">
            <p class="text-sm opacity-70">MIT License</p>
          </:copyright>
          """
        ]
      },
      %Variation{
        id: :minimal,
        description: "Simple footer with copyright only",
        slots: [
          """
          <:copyright>
            <p class="text-sm opacity-70">2024 Duskmoon UI. All rights reserved.</p>
          </:copyright>
          """
        ]
      },
      %Variation{
        id: :with_class,
        description: "Styled footer",
        attributes: %{
          class: "bg-surface-container"
        },
        slots: [
          """
          <:section title="Company" title_class="text-primary">
            <a href="#" class="hover:underline">About</a>
            <a href="#" class="hover:underline">Blog</a>
          </:section>
          <:section title="Legal" title_class="text-primary">
            <a href="#" class="hover:underline">Privacy</a>
            <a href="#" class="hover:underline">Terms</a>
          </:section>
          <:copyright title="Built with Phoenix">
            <p class="text-xs opacity-60">Powered by Elixir</p>
          </:copyright>
          """
        ]
      }
    ]
  end
end
