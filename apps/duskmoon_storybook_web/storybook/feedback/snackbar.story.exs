defmodule Storybook.Feedback.Snackbar do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Feedback.Snackbar.dm_snackbar/1
  def description, do: "Snackbar notification with action and close buttons."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "snack-default",
          open: true
        },
        slots: [
          """
          <:message>File saved successfully</:message>
          """
        ]
      },
      %Variation{
        id: :with_action,
        attributes: %{
          id: "snack-action",
          open: true,
          type: "info"
        },
        slots: [
          """
          <:message>Email archived</:message>
          <:action>Undo</:action>
          <:close />
          """
        ]
      },
      %Variation{
        id: :types,
        attributes: %{},
        slots: [
          """
          <div class="space-y-4">
            <.dm_snackbar id="s-info" type="info" open={true}>
              <:message>Info snackbar</:message>
            </.dm_snackbar>
            <.dm_snackbar id="s-success" type="success" open={true}>
              <:message>Success snackbar</:message>
            </.dm_snackbar>
            <.dm_snackbar id="s-error" type="error" open={true}>
              <:message>Error snackbar</:message>
              <:action>Retry</:action>
            </.dm_snackbar>
          </div>
          """
        ]
      }
    ]
  end
end
