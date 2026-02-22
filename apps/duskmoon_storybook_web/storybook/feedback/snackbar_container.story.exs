defmodule Storybook.Feedback.SnackbarContainer do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Feedback.Snackbar.dm_snackbar_container/1

  def description,
    do: "Positioned container for snackbar notifications. Wraps one or more dm_snackbar components."

  def variations do
    [
      %Variation{
        id: :bottom,
        description: "Default bottom-center position",
        attributes: %{
          id: "snack-bottom",
          position: "bottom"
        },
        slots: ["<p class=\"p-4 text-sm opacity-70\">Snackbars appear here (bottom)</p>"]
      },
      %Variation{
        id: :top_right,
        description: "Top-right corner position",
        attributes: %{
          id: "snack-top-right",
          position: "top-right"
        },
        slots: ["<p class=\"p-4 text-sm opacity-70\">Snackbars appear here (top-right)</p>"]
      },
      %Variation{
        id: :bottom_left,
        description: "Bottom-left corner position",
        attributes: %{
          id: "snack-bottom-left",
          position: "bottom-left"
        },
        slots: ["<p class=\"p-4 text-sm opacity-70\">Snackbars appear here (bottom-left)</p>"]
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :position,
        label: "Position",
        type: :select,
        options: [
          {"bottom", "Bottom"},
          {"bottom-left", "Bottom Left"},
          {"bottom-right", "Bottom Right"},
          {"top", "Top"},
          {"top-left", "Top Left"},
          {"top-right", "Top Right"}
        ],
        default: "bottom"
      }
    ]
  end
end
