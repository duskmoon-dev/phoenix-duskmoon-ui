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
        description: "Default top-positioned tooltip",
        attributes: %{content: "Click to save changes"},
        slots: ["<.dm_btn variant=\"primary\">Save</.dm_btn>"]
      },
      %VariationGroup{
        id: :positions,
        description: "Position variants",
        variations: [
          %Variation{
            id: :bottom,
            attributes: %{content: "Appears below", position: "bottom"},
            slots: ["<.dm_btn variant=\"accent\">Bottom</.dm_btn>"]
          },
          %Variation{
            id: :left,
            attributes: %{content: "Appears on the left", position: "left"},
            slots: ["<.dm_btn variant=\"info\">Left</.dm_btn>"]
          },
          %Variation{
            id: :right,
            attributes: %{content: "Appears on the right", position: "right"},
            slots: ["<.dm_btn variant=\"success\">Right</.dm_btn>"]
          }
        ]
      },
      %VariationGroup{
        id: :colors,
        description: "Color variants",
        variations: [
          %Variation{
            id: :primary,
            attributes: %{content: "Primary tooltip", color: "primary"},
            slots: ["<.dm_btn variant=\"primary\">Primary</.dm_btn>"]
          },
          %Variation{
            id: :secondary,
            attributes: %{content: "Secondary tooltip", color: "secondary"},
            slots: ["<.dm_btn variant=\"secondary\">Secondary</.dm_btn>"]
          },
          %Variation{
            id: :tertiary,
            attributes: %{content: "Tertiary tooltip", color: "tertiary"},
            slots: ["<.dm_btn variant=\"ghost\">Tertiary</.dm_btn>"]
          },
          %Variation{
            id: :warning,
            attributes: %{content: "Warning message", color: "warning"},
            slots: ["<.dm_btn variant=\"ghost\">Warning</.dm_btn>"]
          },
          %Variation{
            id: :error,
            attributes: %{content: "Cannot be undone", color: "error", position: "bottom"},
            slots: ["<.dm_btn variant=\"error\">Delete</.dm_btn>"]
          },
          %Variation{
            id: :info,
            attributes: %{content: "Press Ctrl+S to save", color: "info", position: "right"},
            slots: ["<.dm_mdi name=\"information\" />"]
          }
        ]
      },
      %Variation{
        id: :with_icon,
        description: "Tooltip on an icon button",
        attributes: %{content: "Copy to clipboard", color: "success"},
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
        description: "Always visible — open=true",
        attributes: %{content: "This tooltip is always visible", color: "accent", open: true},
        slots: ["<.dm_btn variant=\"ghost\">Always Open</.dm_btn>"]
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :position,
        label: "Position",
        type: :select,
        options: [
          {"top", "Top"},
          {"bottom", "Bottom"},
          {"left", "Left"},
          {"right", "Right"}
        ],
        default: "top"
      },
      %{
        id: :color,
        label: "Color",
        type: :select,
        options: [
          {"primary", "Primary"},
          {"secondary", "Secondary"},
          {"tertiary", "Tertiary"},
          {"accent", "Accent"},
          {"info", "Info"},
          {"success", "Success"},
          {"warning", "Warning"},
          {"error", "Error"}
        ],
        default: "primary"
      },
      %{
        id: :open,
        label: "Always Open",
        type: :boolean,
        default: false
      }
    ]
  end
end