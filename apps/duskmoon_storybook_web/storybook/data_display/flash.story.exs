defmodule Storybook.DataDisplay.Flash do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Flash.dm_flash/1

  def description,
    do: "Flash notification messages for info and error states. Drop-in replacement for Phoenix default flash."

  def variations do
    [
      %Variation{
        id: :info,
        description: "Info flash message (green checkmark icon)",
        attributes: %{
          id: "story-flash-info",
          kind: :info,
          title: "Success!",
          autoshow: false
        },
        slots: ["Your changes have been saved successfully."]
      },
      %Variation{
        id: :error,
        description: "Error flash message (red warning icon)",
        attributes: %{
          id: "story-flash-error",
          kind: :error,
          title: "Error!",
          autoshow: false
        },
        slots: ["Something went wrong. Please try again."]
      },
      %Variation{
        id: :no_close,
        description: "Flash without close button (non-dismissible)",
        attributes: %{
          id: "story-flash-no-close",
          kind: :info,
          title: "Notice",
          close: false,
          autoshow: false
        },
        slots: ["This notification cannot be dismissed."]
      },
      %Variation{
        id: :custom_close_label,
        description: "Custom accessible label on close button",
        attributes: %{
          id: "story-flash-a11y",
          kind: :info,
          title: "Accessible Flash",
          close_label: "Dismiss notification",
          autoshow: false
        },
        slots: ["Close button has custom aria-label for screen readers."]
      },
      %Variation{
        id: :no_title,
        description: "Flash message with body only (no title)",
        attributes: %{
          id: "story-flash-notitle",
          kind: :error,
          autoshow: false
        },
        slots: ["A flash message without a title heading."]
      }
    ]
  end
end
