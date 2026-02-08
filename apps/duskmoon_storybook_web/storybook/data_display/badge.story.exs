defmodule Storybook.DataDisplay.Badge do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Badge.dm_badge/1
  def description, do: "Badge component for status indicators and labels."

  def variations do
    [
      %Variation{
        id: :default,
        slots: [
          "New"
        ]
      },
      %Variation{
        id: :color_variants,
        attributes: %{
          color: "success"
        },
        slots: [
          "Active"
        ]
      },
      %Variation{
        id: :error_badge,
        attributes: %{
          color: "error"
        },
        slots: [
          "Error"
        ]
      },
      %Variation{
        id: :warning_badge,
        attributes: %{
          color: "warning"
        },
        slots: [
          "Warning"
        ]
      },
      %Variation{
        id: :info_badge,
        attributes: %{
          color: "info"
        },
        slots: [
          "Info"
        ]
      },
      %Variation{
        id: :secondary_badge,
        attributes: %{
          color: "secondary"
        },
        slots: [
          "Secondary"
        ]
      },
      %Variation{
        id: :accent_badge,
        attributes: %{
          color: "accent"
        },
        slots: [
          "Accent"
        ]
      },
      %Variation{
        id: :size_variants,
        attributes: %{
          size: "xs"
        },
        slots: [
          "Tiny"
        ]
      },
      %Variation{
        id: :small_badge,
        attributes: %{
          size: "sm",
          color: "success"
        },
        slots: [
          "Small"
        ]
      },
      %Variation{
        id: :large_badge,
        attributes: %{
          size: "lg",
          color: "error"
        },
        slots: [
          "Large"
        ]
      },
      %Variation{
        id: :outline_style,
        attributes: %{
          color: "primary",
          outline: true
        },
        slots: [
          "Outline"
        ]
      },
      %Variation{
        id: :outline_warning,
        attributes: %{
          color: "warning",
          outline: true
        },
        slots: [
          "Warning"
        ]
      },
      %Variation{
        id: :ghost_style,
        attributes: %{
          color: "ghost"
        },
        slots: [
          "Ghost"
        ]
      },
      %Variation{
        id: :outline_success,
        attributes: %{
          color: "success",
          outline: true
        },
        slots: [
          "Complete"
        ]
      },
      %Variation{
        id: :status_indicators,
        attributes: %{
          color: "success",
          size: "sm"
        },
        slots: [
          "✓ Online"
        ]
      },
      %Variation{
        id: :status_offline,
        attributes: %{
          color: "error",
          size: "sm"
        },
        slots: [
          "✗ Offline"
        ]
      },
      %Variation{
        id: :count_badge,
        attributes: %{
          color: "accent"
        },
        slots: [
          "42"
        ]
      },
      %Variation{
        id: :notification_badge,
        attributes: %{
          color: "error",
          size: "xs"
        },
        slots: [
          "5"
        ]
      }
    ]
  end
end