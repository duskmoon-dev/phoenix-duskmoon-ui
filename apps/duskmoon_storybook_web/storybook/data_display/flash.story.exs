defmodule Storybook.DataDisplay.Flash do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Flash.dm_flash/1

  def description,
    do: "Flash notification messages for info and error states. Drop-in replacement for Phoenix default flash."

  def variations do
    [
      %Variation{
        id: :info,
        description: "Info flash message",
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
        description: "Error flash message",
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
        description: "Flash without close button",
        attributes: %{
          id: "story-flash-no-close",
          kind: :info,
          title: "Notice",
          close: false,
          autoshow: false
        },
        slots: ["This notification cannot be dismissed."]
      }
    ]
  end
end
