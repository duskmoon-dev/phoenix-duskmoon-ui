defmodule Storybook.Navigation.Breadcrumb do
  # :live_component or :page are also available
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Navigation.Breadcrumb.dm_breadcrumb/1
  def description, do: "A breadcrumb element."

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
            <PhoenixDuskmoon.Component.Icon.Icons.dm_mdi name="home" class="w-4 h-4" />
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
      }
    ]
  end
end
