defmodule Storybook.Navigation.Actionbar do
  # :live_component or :page are also available
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Navigation.Actionbar.dm_actionbar/1
  def description, do: "An actionbar element."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default actionbar with left and right slots",
        attributes: %{
          class: "shadow"
        },
        slots: [
          """
          <:left>
            Star Wars
          </:left>
          <:right>
            <button type="button">action</button>
          </:right>
          """
        ]
      },
      %Variation{
        id: :multiple_actions,
        description: "Actionbar with multiple right-side actions",
        attributes: %{
          class: "shadow"
        },
        slots: [
          """
          <:left>
            <span class="font-bold text-lg">Dashboard</span>
          </:left>
          <:right>
            <button type="button" class="btn btn-sm">Edit</button>
          </:right>
          <:right>
            <button type="button" class="btn btn-sm btn-primary">Save</button>
          </:right>
          """
        ]
      },
      %Variation{
        id: :custom_label,
        description: "Actionbar with custom toolbar label for accessibility",
        attributes: %{
          class: "shadow",
          toolbar_label: "Document actions"
        },
        slots: [
          """
          <:left>
            <span class="font-bold">Document.pdf</span>
          </:left>
          <:right>
            <button type="button">Download</button>
          </:right>
          """
        ]
      }
    ]
  end
end
