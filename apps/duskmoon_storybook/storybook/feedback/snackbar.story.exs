defmodule Storybook.Feedback.Snackbar do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Feedback.Snackbar.dm_snackbar/1
  def description, do: "Snackbar notification with action and close buttons."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Plain snackbar with message only",
        attributes: %{
          id: "snack-default",
          open: true
        },
        slots: [
          """
          <:message>File saved successfully</:message>
          """
        ]
      },
      %Variation{
        id: :with_action,
        description: "Snackbar with action button and close icon",
        attributes: %{
          id: "snack-action",
          open: true,
          type: "info"
        },
        slots: [
          """
          <:message>Email archived</:message>
          <:action>Undo</:action>
          <:close />
          """
        ]
      },
      %VariationGroup{
        id: :types,
        description: "Semantic type variants — info, success, warning, error",
        variations: [
          %Variation{
            id: :info,
            attributes: %{id: "s-info", type: "info", open: true},
            slots: ["<:message>Info snackbar</:message>"]
          },
          %Variation{
            id: :success,
            attributes: %{id: "s-success", type: "success", open: true},
            slots: ["<:message>Success snackbar</:message>"]
          },
          %Variation{
            id: :error,
            attributes: %{id: "s-error", type: "error", open: true},
            slots: ["<:message>Error snackbar</:message>\n<:action>Retry</:action>"]
          },
          %Variation{
            id: :warning,
            attributes: %{id: "s-warning", type: "warning", open: true},
            slots: ["<:message>Warning: disk space low</:message>"]
          }
        ]
      },
      %VariationGroup{
        id: :color_types,
        description: "Color type variants — primary, secondary, tertiary, dark",
        variations:
          for type <- ~w(primary secondary tertiary dark) do
            %Variation{
              id: String.to_atom(type),
              attributes: %{id: "s-#{type}", type: type, open: true},
              slots: ["<:message>#{String.capitalize(type)} snackbar</:message>"]
            }
          end
      },
      %Variation{
        id: :multiline,
        description: "Multi-line message layout",
        attributes: %{
          id: "snack-multiline",
          open: true,
          type: "info",
          multiline: true
        },
        slots: [
          """
          <:message>This is a longer notification message that wraps to multiple lines for extra context.</:message>
          <:action>Details</:action>
          <:close />
          """
        ]
      },
      %Variation{
        id: :top_right,
        description: "Top-right positioned snackbar",
        attributes: %{
          id: "snack-top-right",
          open: true,
          type: "success",
          position: "top-right"
        },
        slots: [
          """
          <:message>Saved to cloud</:message>
          """
        ]
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :type,
        label: "Type",
        type: :select,
        options: [
          {nil, "Default"},
          {"info", "Info"},
          {"success", "Success"},
          {"warning", "Warning"},
          {"error", "Error"},
          {"primary", "Primary"},
          {"secondary", "Secondary"},
          {"tertiary", "Tertiary"},
          {"dark", "Dark"}
        ],
        default: nil
      },
      %{
        id: :open,
        label: "Open",
        type: :boolean,
        default: false
      },
      %{
        id: :multiline,
        label: "Multiline",
        type: :boolean,
        default: false
      }
    ]
  end
end
