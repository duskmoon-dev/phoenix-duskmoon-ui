defmodule Storybook.Action.Button do
  # :live_component or :page are also available
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Action.Button.dm_btn/1
  def description, do: "Recreate Phoenix.Component.Button with confirm."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          variant: "primary"
        },
        slots: [
          """
          Primary Action
          """
        ]
      },
      %Variation{
        id: :secondary,
        attributes: %{
          variant: "secondary"
        },
        slots: ["Secondary Action"]
      },
      %Variation{
        id: :sizes,
        description: "Button size variants",
        attributes: %{
          variant: "primary",
          size: "lg"
        },
        slots: ["Large Button"]
      },
      %Variation{
        id: :remove,
        attributes: %{
          variant: "error",
          confirm_title: "Attention!",
          confirm: "Do you really want to remove it?"
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
          variant: "info",
          confirm: "Are you sure you want to export?"
        },
        slots: [
          """
          Export
          <:confirm_action>
          <form method="dialog">
            <el-dm-button variant="info" size="sm" phx-click="export">Export CSV</el-dm-button>
          </form>
          </:confirm_action>
          """
        ]
      },
      %Variation{
        id: :with_noise,
        attributes: %{
          noise: true,
          content: "Waiting for noise"
        },
        slots: [
          """
          Primary Action
          """
        ]
      },
      %Variation{
        id: :loading,
        attributes: %{
          variant: "primary",
          loading: true
        },
        slots: ["Loading..."]
      },
      %Variation{
        id: :disabled,
        attributes: %{
          variant: "primary",
          disabled: true
        },
        slots: ["Disabled"]
      }
    ]
  end
end
