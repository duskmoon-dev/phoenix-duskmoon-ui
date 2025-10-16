defmodule Storybook.Components.Form.Switch do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Form.dm_input/1
  def description, do: "An iOS-style switch toggle component."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          type: "switch",
          label: "Notifications",
          name: "notifications",
          value: true
        }
      },
      %Variation{
        id: :unchecked,
        attributes: %{
          type: "switch",
          label: "Dark Mode",
          name: "dark_mode",
          value: false
        }
      },
      %Variation{
        id: :with_color,
        attributes: %{
          type: "switch",
          label: "Auto-save",
          name: "auto_save",
          value: true,
          color: "success"
        }
      },
      %Variation{
        id: :small_size,
        attributes: %{
          type: "switch",
          label: "Compact View",
          name: "compact_view",
          value: false,
          size: "sm"
        }
      },
      %Variation{
        id: :with_errors,
        attributes: %{
          type: "switch",
          label: "Terms Accepted",
          name: "terms_accepted",
          value: false,
          errors: ["You must accept the terms"]
        }
      }
    ]
  end
end
