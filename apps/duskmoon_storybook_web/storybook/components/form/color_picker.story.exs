defmodule Storybook.Components.Form.ColorPicker do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Form.dm_input/1
  def description, do: "An advanced color picker with swatches."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          type: "color_picker",
          label: "Theme Color",
          name: "theme_color",
          value: "#3b82f6"
        }
      },
      %Variation{
        id: :with_swatches,
        attributes: %{
          type: "color_picker",
          label: "Brand Color",
          name: "brand_color",
          value: "#10b981",
          swatches: ["#ef4444", "#f59e0b", "#10b981", "#3b82f6", "#8b5cf6", "#ec4899"]
        }
      },
      %Variation{
        id: :with_color,
        attributes: %{
          type: "color_picker",
          label: "Accent Color",
          name: "accent_color",
          value: "#f59e0b",
          color: "warning"
        }
      },
      %Variation{
        id: :small_size,
        attributes: %{
          type: "color_picker",
          label: "Background",
          name: "background",
          value: "#6b7280",
          size: "sm"
        }
      },
      %Variation{
        id: :with_errors,
        attributes: %{
          type: "color_picker",
          label: "Primary Color",
          name: "primary_color",
          value: nil,
          errors: ["Color is required"]
        }
      }
    ]
  end
end
