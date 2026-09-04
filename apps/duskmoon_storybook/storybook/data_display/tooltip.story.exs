defmodule Storybook.DataDisplay.Tooltip do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Tooltip.dm_tooltip/1

  def description,
    do: "Native hint popover linked to its trigger with the Interest Invokers API."

  def imports do
    [
      {PhoenixDuskmoon.Component.Action.Button, [dm_btn: 1]},
      {PhoenixDuskmoon.Component.Icon.Icons, [dm_mdi: 1]}
    ]
  end

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default top-positioned tooltip",
        attributes: %{content: "Click to save changes"},
        let: :trigger_attrs,
        slots: ["<.dm_btn variant=\"primary\" {trigger_attrs}>Save</.dm_btn>"]
      },
      %VariationGroup{
        id: :positions,
        description: "Position variants",
        variations: [
          %Variation{
            id: :bottom,
            attributes: %{content: "Appears below", position: "bottom"},
            let: :trigger_attrs,
            slots: ["<.dm_btn variant=\"accent\" {trigger_attrs}>Bottom</.dm_btn>"]
          },
          %Variation{
            id: :left,
            attributes: %{content: "Appears on the left", position: "left"},
            let: :trigger_attrs,
            slots: ["<.dm_btn variant=\"info\" {trigger_attrs}>Left</.dm_btn>"]
          },
          %Variation{
            id: :right,
            attributes: %{content: "Appears on the right", position: "right"},
            let: :trigger_attrs,
            slots: ["<.dm_btn variant=\"success\" {trigger_attrs}>Right</.dm_btn>"]
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
            let: :trigger_attrs,
            slots: ["<.dm_btn variant=\"primary\" {trigger_attrs}>Primary</.dm_btn>"]
          },
          %Variation{
            id: :secondary,
            attributes: %{content: "Secondary tooltip", color: "secondary"},
            let: :trigger_attrs,
            slots: ["<.dm_btn variant=\"secondary\" {trigger_attrs}>Secondary</.dm_btn>"]
          },
          %Variation{
            id: :tertiary,
            attributes: %{content: "Tertiary tooltip", color: "tertiary"},
            let: :trigger_attrs,
            slots: ["<.dm_btn variant=\"ghost\" {trigger_attrs}>Tertiary</.dm_btn>"]
          },
          %Variation{
            id: :warning,
            attributes: %{content: "Warning message", color: "warning"},
            let: :trigger_attrs,
            slots: ["<.dm_btn variant=\"ghost\" {trigger_attrs}>Warning</.dm_btn>"]
          },
          %Variation{
            id: :error,
            attributes: %{content: "Cannot be undone", color: "error", position: "bottom"},
            let: :trigger_attrs,
            slots: ["<.dm_btn variant=\"error\" {trigger_attrs}>Delete</.dm_btn>"]
          },
          %Variation{
            id: :info,
            attributes: %{content: "Press Ctrl+S to save", color: "info", position: "right"},
            let: :trigger_attrs,
            slots: [
              "<.dm_btn variant=\"ghost\" shape=\"square\" {trigger_attrs}><.dm_mdi name=\"information\" /></.dm_btn>"
            ]
          }
        ]
      },
      %Variation{
        id: :with_icon,
        description: "Tooltip on an icon button",
        attributes: %{content: "Copy to clipboard", color: "success"},
        let: :trigger_attrs,
        slots: [
          """
          <.dm_btn variant="outline" shape="square" {trigger_attrs}>
            <.dm_mdi name="content-copy" />
          </.dm_btn>
          """
        ]
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
      }
    ]
  end
end
