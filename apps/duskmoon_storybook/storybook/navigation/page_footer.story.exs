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
        description: "Styled footer with colored section titles",
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
      },
      %Variation{
        id: :with_label,
        description: "Accessible footer with aria-label for screen readers",
        attributes: %{
          label: "Site footer navigation"
        },
        slots: [
          """
          <:section title="Help">
            <a href="#" class="hover:underline">FAQ</a>
            <a href="#" class="hover:underline">Support</a>
          </:section>
          <:copyright>
            <p class="text-sm opacity-70">Inspect element to see aria-label on footer</p>
          </:copyright>
          """
        ]
      },
      %Variation{
        id: :multi_section,
        description: "Footer with many sections and body_class customization",
        slots: [
          """
          <:section title="Product" body_class="gap-1">
            <a href="#" class="hover:underline text-sm">Features</a>
            <a href="#" class="hover:underline text-sm">Pricing</a>
            <a href="#" class="hover:underline text-sm">Integrations</a>
            <a href="#" class="hover:underline text-sm">Enterprise</a>
          </:section>
          <:section title="Developers" body_class="gap-1">
            <a href="#" class="hover:underline text-sm">Documentation</a>
            <a href="#" class="hover:underline text-sm">API Reference</a>
            <a href="#" class="hover:underline text-sm">SDKs</a>
          </:section>
          <:section title="Company" body_class="gap-1">
            <a href="#" class="hover:underline text-sm">About</a>
            <a href="#" class="hover:underline text-sm">Blog</a>
            <a href="#" class="hover:underline text-sm">Careers</a>
          </:section>
          <:copyright title="Duskmoon UI" title_class="text-lg font-bold">
            <p class="text-xs opacity-60">2026 All rights reserved. MIT License.</p>
          </:copyright>
          """
        ]
      }
    ]
  end
end
