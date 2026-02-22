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
      %VariationGroup{
        id: :types,
        description: "Snackbar type variants",
        variations: [
          %Variation{
            id: :info,
            attributes: %{
              id: "s-info",
              type: "info",
              open: true
            },
            slots: [
              """
              <:message>Info snackbar</:message>
              """
            ]
          },
          %Variation{
            id: :success,
            attributes: %{
              id: "s-success",
              type: "success",
              open: true
            },
            slots: [
              """
              <:message>Success snackbar</:message>
              """
            ]
          },
          %Variation{
            id: :error,
            attributes: %{
              id: "s-error",
              type: "error",
              open: true
            },
            slots: [
              """
              <:message>Error snackbar</:message>
              <:action>Retry</:action>
              """
            ]
          }
        ]
      }
    ]
  end
end
