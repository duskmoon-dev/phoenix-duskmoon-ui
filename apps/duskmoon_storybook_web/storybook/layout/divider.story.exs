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
          variant: "primary"
        },
        slots: [
          "Primary Section"
        ]
      },
      %Variation{
        id: :success_divider,
        attributes: %{
          variant: "success"
        },
        slots: [
          "Success"
        ]
      },
      %Variation{
        id: :warning_divider,
        attributes: %{
          variant: "warning"
        },
        slots: [
          "Warning Area"
        ]
      },
      %Variation{
        id: :error_divider,
        attributes: %{
          variant: "error"
        },
        slots: [
          "Error Section"
        ]
      },
      %Variation{
        id: :info_divider,
        attributes: %{
          variant: "info"
        },
        slots: [
          "Information"
        ]
      },
      %Variation{
        id: :dashed_variant,
        attributes: %{
          style: "dashed",
          variant: "primary"
        },
        slots: [
          "Dashed Divider"
        ]
      },
      %Variation{
        id: :dotted_variant,
        attributes: %{
          style: "dotted",
          variant: "accent"
        },
        slots: [
          "Dotted Divider"
        ]
      },
      %Variation{
        id: :small_divider,
        attributes: %{
          size: "xs",
          variant: "secondary"
        }
      },
      %Variation{
        id: :large_divider,
        attributes: %{
          size: "lg",
          variant: "primary"
        },
        slots: [
          "Large Divider"
        ]
      },
      %Variation{
        id: :settings_section,
        attributes: %{
          variant: "primary",
          style: "dashed"
        },
        slots: [
          "Settings"
        ]
      },
      %Variation{
        id: :vertical_with_color,
        attributes: %{
          orientation: "vertical",
          variant: "success"
        }
      },
      %Variation{
        id: :vertical_large,
        attributes: %{
          orientation: "vertical",
          size: "lg",
          variant: "accent"
        }
      },
      %Variation{
        id: :accent_colored,
        attributes: %{
          variant: "accent"
        },
        slots: [
          "Accent Content"
        ]
      },
      %Variation{
        id: :secondary_colored,
        attributes: %{
          variant: "secondary"
        },
        slots: [
          "Secondary Section"
        ]
      }
    ]
  end
end