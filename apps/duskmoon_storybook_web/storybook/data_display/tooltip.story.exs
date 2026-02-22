defmodule Storybook.DataDisplay.Tooltip do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Tooltip.dm_tooltip/1
  def description, do: "Tooltip component for displaying additional information on hover."

  def imports do
    [{PhoenixDuskmoon.Component.Action.Button, [dm_btn: 1]},
     {PhoenixDuskmoon.Component.Icon.Icons, [dm_mdi: 1]}]
  end

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          content: "Click to save changes"
        },
        slots: [
          """
          <.dm_btn variant="primary">Save</.dm_btn>
          """
        ]
      },
      %Variation{
        id: :positions,
        attributes: %{
          content: "This is a top tooltip"
        },
        slots: [
          """
          <.dm_btn variant="secondary">Top</.dm_btn>
          """
        ]
      },
      %Variation{
        id: :bottom_position,
        attributes: %{
          content: "This appears below",
          position: "bottom"
        },
        slots: [
          """
          <.dm_btn variant="accent">Bottom</.dm_btn>
          """
        ]
      },
      %Variation{
        id: :left_position,
        attributes: %{
          content: "Appears on the left",
          position: "left"
        },
        slots: [
          """
          <.dm_btn variant="info">Left</.dm_btn>
          """
        ]
      },
      %Variation{
        id: :right_position,
        attributes: %{
          content: "Appears on the right",
          position: "right"
        },
        slots: [
          """
          <.dm_btn variant="success">Right</.dm_btn>
          """
        ]
      },
      %Variation{
        id: :color_variants,
        attributes: %{
          content: "Warning message",
          color: "warning"
        },
        slots: [
          """
          <.dm_btn variant="ghost">Warning</.dm_btn>
          """
        ]
      },
      %Variation{
        id: :error_tooltip,
        attributes: %{
          content: "This action cannot be undone",
          color: "error",
          position: "bottom"
        },
        slots: [
          """
          <.dm_btn variant="error">Delete</.dm_btn>
          """
        ]
      },
      %Variation{
        id: :info_tooltip,
        attributes: %{
          content: "Press Ctrl+S to save",
          color: "info",
          position: "right"
        },
        slots: [
          """
          <.dm_mdi name="information" />
          """
        ]
      },
      %Variation{
        id: :with_icon,
        attributes: %{
          content: "Copy to clipboard",
          color: "success"
        },
        slots: [
          """
          <.dm_btn variant="outline" shape="square">
            <.dm_mdi name="content-copy" />
          </.dm_btn>
          """
        ]
      },
      %Variation{
        id: :always_open,
        attributes: %{
          content: "This tooltip is always visible",
          color: "accent",
          open: true
        },
        slots: [
          """
          <.dm_btn variant="ghost">Always Open</.dm_btn>
          """
        ]
      }
    ]
  end
end