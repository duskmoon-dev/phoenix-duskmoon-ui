defmodule Storybook.Feedback.Dialog do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Feedback.Dialog.dm_modal/1
  def description, do: "Modal dialog for alerts, confirmations, and custom content."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "dialog-default",
          title: "Confirm Action"
        },
        slots: [
          """
          <p>Are you sure you want to proceed?</p>
          <:footer>
            <.dm_btn variant="ghost">Cancel</.dm_btn>
            <.dm_btn variant="primary">Confirm</.dm_btn>
          </:footer>
          """
        ]
      }
    ]
  end
end
