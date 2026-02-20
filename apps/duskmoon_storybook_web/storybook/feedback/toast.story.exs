defmodule Storybook.Feedback.Toast do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Feedback.Toast.dm_toast/1
  def description, do: "Toast notification with type variants and positions."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "toast-default"
        },
        slots: ["Default toast message"]
      },
      %Variation{
        id: :types,
        attributes: %{},
        slots: [
          """
          <div class="space-y-4">
            <.dm_toast id="t-info" type="info">Info message</.dm_toast>
            <.dm_toast id="t-success" type="success">Success message</.dm_toast>
            <.dm_toast id="t-warning" type="warning">Warning message</.dm_toast>
            <.dm_toast id="t-error" type="error">Error message</.dm_toast>
          </div>
          """
        ]
      },
      %Variation{
        id: :filled,
        attributes: %{},
        slots: [
          """
          <div class="space-y-4">
            <.dm_toast id="tf-info" type="info" filled={true}>Filled info</.dm_toast>
            <.dm_toast id="tf-success" type="success" filled={true}>Filled success</.dm_toast>
          </div>
          """
        ]
      }
    ]
  end
end
