defmodule Storybook.Navigation.Breadcrumb do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Navigation.Breadcrumb.dm_breadcrumb/1
  def description, do: "Breadcrumb navigation trail with customizable separators and aria-current on the last crumb."

  def imports do
    [{PhoenixDuskmoon.Component.Icon.Icons, [dm_mdi: 1]}]
  end

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          class: "shadow px-8"
        },
        slots: [
          """
          <:crumb class="flex gap-2">
            <.dm_mdi name="home" class="w-4 h-4" />
            <a href="/">Home</a>
          </:crumb>
          <:crumb>
            <button type="button">Page</button>
          </:crumb>
          """
        ]
      },
      %Variation{
        id: :custom_icon,
        attributes: %{
          class: "shadow w-full px-2"
        },
        slots: [
          """
          <:crumb>
            <a href="/">Home</a>
          </:crumb>
          <:crumb>
            <button type="button">Page</button>
          </:crumb>
          """
        ]
      },
      %Variation{
        id: :deep_path,
        description: "Breadcrumb with many levels",
        attributes: %{
          class: "shadow px-4"
        },
        slots: [
          """
          <:crumb><a href="/">Home</a></:crumb>
          <:crumb><a href="/docs">Documentation</a></:crumb>
          <:crumb><a href="/docs/components">Components</a></:crumb>
          <:crumb>Breadcrumb</:crumb>
          """
        ]
      },
      %Variation{
        id: :custom_separator,
        description: "Breadcrumb with custom separator character",
        attributes: %{
          class: "shadow px-4",
          separator: ">"
        },
        slots: [
          """
          <:crumb><a href="/">Home</a></:crumb>
          <:crumb><a href="/products">Products</a></:crumb>
          <:crumb>Detail</:crumb>
          """
        ]
      },
      %Variation{
        id: :with_nav_label,
        description: "Custom accessible nav label for screen readers",
        attributes: %{
          class: "shadow px-4",
          nav_label: "Product navigation path"
        },
        slots: [
          """
          <:crumb><a href="/">Home</a></:crumb>
          <:crumb><a href="/shop">Shop</a></:crumb>
          <:crumb>Checkout</:crumb>
          """
        ]
      }
    ]
  end
end
