defmodule Storybook.Feedback.ToastContainer do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Feedback.Toast.dm_toast_container/1

  def description,
    do: "Positioned container for toast notifications. Wraps one or more dm_toast components."

  def variations do
    [
      %Variation{
        id: :top_right,
        description: "Default top-right position",
        attributes: %{
          id: "toast-top-right",
          position: "top-right"
        },
        slots: ["<p class=\"p-4 text-sm opacity-70\">Toasts appear here (top-right)</p>"]
      },
      %Variation{
        id: :bottom_center,
        description: "Bottom-center position",
        attributes: %{
          id: "toast-bottom-center",
          position: "bottom-center"
        },
        slots: ["<p class=\"p-4 text-sm opacity-70\">Toasts appear here (bottom-center)</p>"]
      },
      %Variation{
        id: :top_left,
        description: "Top-left position",
        attributes: %{
          id: "toast-top-left",
          position: "top-left"
        },
        slots: ["<p class=\"p-4 text-sm opacity-70\">Toasts appear here (top-left)</p>"]
      }
    ]
  end
end
