defmodule Storybook.Feedback.Dialog do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Feedback.Dialog.dm_modal/1
  def description, do: "Modal dialog for alerts, confirmations, and custom content."

  def imports do
    [{PhoenixDuskmoon.Component.Action.Button, [dm_btn: 1]}]
  end

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default modal with title, body, and footer actions",
        attributes: %{
          id: "dialog-default"
        },
        slots: [
          """
          <:title>Confirm Action</:title>
          <:body>
            <p>Are you sure you want to proceed?</p>
          </:body>
          <:footer>
            <.dm_btn variant="ghost">Cancel</.dm_btn>
            <.dm_btn variant="primary">Confirm</.dm_btn>
          </:footer>
          """
        ]
      },
      %Variation{
        id: :small,
        description: "Small sized modal",
        attributes: %{
          id: "dialog-small",
          size: "sm"
        },
        slots: [
          """
          <:title>Small Dialog</:title>
          <:body>
            <p>This is a small modal.</p>
          </:body>
          """
        ]
      },
      %Variation{
        id: :no_backdrop,
        description: "Modal without backdrop overlay",
        attributes: %{
          id: "dialog-no-backdrop",
          no_backdrop: true
        },
        slots: [
          """
          <:title>No Backdrop</:title>
          <:body>
            <p>This modal has no backdrop overlay.</p>
          </:body>
          """
        ]
      }
    ]
  end
end
