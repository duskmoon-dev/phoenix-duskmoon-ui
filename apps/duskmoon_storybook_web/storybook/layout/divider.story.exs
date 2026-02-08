defmodule Storybook.Layout.Divider do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Layout.Divider.dm_divider/1
  def description, do: "Divider component for separating content sections."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{}
      },
      %Variation{
        id: :with_text,
        slots: [
          "Section Title"
        ]
      },
      %Variation{
        id: :vertical_divider,
        attributes: %{
          orientation: "vertical"
        }
      },
      %Variation{
        id: :primary_color,
        attributes: %{
          color: "primary"
        },
        slots: [
          "Primary Section"
        ]
      },
      %Variation{
        id: :success_divider,
        attributes: %{
          color: "success"
        },
        slots: [
          "Success"
        ]
      },
      %Variation{
        id: :warning_divider,
        attributes: %{
          color: "warning"
        },
        slots: [
          "Warning Area"
        ]
      },
      %Variation{
        id: :error_divider,
        attributes: %{
          color: "error"
        },
        slots: [
          "Error Section"
        ]
      },
      %Variation{
        id: :info_divider,
        attributes: %{
          color: "info"
        },
        slots: [
          "Information"
        ]
      },
      %Variation{
        id: :dashed_variant,
        attributes: %{
          variant: "dashed",
          color: "primary"
        },
        slots: [
          "Dashed Divider"
        ]
      },
      %Variation{
        id: :dotted_variant,
        attributes: %{
          variant: "dotted",
          color: "accent"
        },
        slots: [
          "Dotted Divider"
        ]
      },
      %Variation{
        id: :small_divider,
        attributes: %{
          size: "xs",
          color: "secondary"
        }
      },
      %Variation{
        id: :large_divider,
        attributes: %{
          size: "lg",
          color: "primary"
        },
        slots: [
          "Large Divider"
        ]
      },
      %Variation{
        id: :settings_section,
        attributes: %{
          color: "primary",
          variant: "dashed"
        },
        slots: [
          "Settings"
        ]
      },
      %Variation{
        id: :vertical_with_color,
        attributes: %{
          orientation: "vertical",
          color: "success"
        }
      },
      %Variation{
        id: :vertical_large,
        attributes: %{
          orientation: "vertical",
          size: "lg",
          color: "accent"
        }
      },
      %Variation{
        id: :accent_colored,
        attributes: %{
          color: "accent"
        },
        slots: [
          "Accent Content"
        ]
      },
      %Variation{
        id: :secondary_colored,
        attributes: %{
          color: "secondary"
        },
        slots: [
          "Secondary Section"
        ]
      }
    ]
  end
end