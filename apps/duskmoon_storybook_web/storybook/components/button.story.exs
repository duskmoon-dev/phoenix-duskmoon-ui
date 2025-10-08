defmodule Storybook.Components.Button do
  # :live_component or :page are also available
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Button.dm_btn/1
  def description, do: "Recreate Phoenix.Component.Button with confirm."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          class: "btn-primary"
        },
        slots: [
          """
          Primary Action
          """
        ]
      },
      %Variation{
        id: :remove,
        attributes: %{
          class: "btn-error",
          confirm_title: "Attention!",
          confirm: "Do you really want to remove it?",
          confirm_class: "btn-error btn-sm",
          cancel_class: "btn-ghost btn-sm"
        },
        slots: [
          """
          Remove
          """
        ]
      },
      %Variation{
        id: :export,
        attributes: %{
          class: "btn-info",
          confirm: "Are you sure you want to export?",
          confirm_class: "btn-info btn-sm",
          cancel_class: "btn-ghost btn-sm"
        },
        slots: [
          """
          Export
          <:confirm_action>
          <form method="dialog">
            <button class="btn btn-sm btn-info" phx-click="export">Export CSV</button>
          </form>
          </:confirm_action>
          """
        ]
      },
      %Variation{
        id: :with_noise,
        attributes: %{
          class: "",
          noise: true,
          content: "Waiting for noise"
        },
        slots: [
          """
          Primary Action
          """
        ]
      }
    ]
  end
end
