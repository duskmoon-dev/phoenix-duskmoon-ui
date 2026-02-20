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
          variant: "success"
        },
        slots: [
          "Active"
        ]
      },
      %Variation{
        id: :error_badge,
        attributes: %{
          variant: "error"
        },
        slots: [
          "Error"
        ]
      },
      %Variation{
        id: :warning_badge,
        attributes: %{
          variant: "warning"
        },
        slots: [
          "Warning"
        ]
      },
      %Variation{
        id: :info_badge,
        attributes: %{
          variant: "info"
        },
        slots: [
          "Info"
        ]
      },
      %Variation{
        id: :secondary_badge,
        attributes: %{
          variant: "secondary"
        },
        slots: [
          "Secondary"
        ]
      },
      %Variation{
        id: :accent_badge,
        attributes: %{
          variant: "accent"
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
          variant: "success"
        },
        slots: [
          "Small"
        ]
      },
      %Variation{
        id: :large_badge,
        attributes: %{
          size: "lg",
          variant: "error"
        },
        slots: [
          "Large"
        ]
      },
      %Variation{
        id: :outline_style,
        attributes: %{
          variant: "primary",
          outline: true
        },
        slots: [
          "Outline"
        ]
      },
      %Variation{
        id: :outline_warning,
        attributes: %{
          variant: "warning",
          outline: true
        },
        slots: [
          "Warning"
        ]
      },
      %Variation{
        id: :ghost_style,
        attributes: %{
          variant: "ghost"
        },
        slots: [
          "Ghost"
        ]
      },
      %Variation{
        id: :soft_style,
        attributes: %{
          variant: "primary",
          soft: true
        },
        slots: [
          "Soft"
        ]
      },
      %Variation{
        id: :soft_success,
        attributes: %{
          variant: "success",
          soft: true
        },
        slots: [
          "Soft Success"
        ]
      },
      %Variation{
        id: :soft_error,
        attributes: %{
          variant: "error",
          soft: true
        },
        slots: [
          "Soft Error"
        ]
      },
      %Variation{
        id: :outline_success,
        attributes: %{
          variant: "success",
          outline: true
        },
        slots: [
          "Complete"
        ]
      },
      %Variation{
        id: :status_indicators,
        attributes: %{
          variant: "success",
          size: "sm"
        },
        slots: [
          "✓ Online"
        ]
      },
      %Variation{
        id: :status_offline,
        attributes: %{
          variant: "error",
          size: "sm"
        },
        slots: [
          "✗ Offline"
        ]
      },
      %Variation{
        id: :count_badge,
        attributes: %{
          variant: "accent"
        },
        slots: [
          "42"
        ]
      },
      %Variation{
        id: :notification_badge,
        attributes: %{
          variant: "error",
          size: "xs"
        },
        slots: [
          "5"
        ]
      }
    ]
  end
end