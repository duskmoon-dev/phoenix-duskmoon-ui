defmodule Storybook.Feedback.Toast do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Feedback.Toast.dm_toast/1
  def description, do: "Toast notification with type variants and positions."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default toast with no type",
        attributes: %{
          id: "toast-default",
          open: true
        },
        slots: ["Default toast message"]
      },
      %VariationGroup{
        id: :types,
        description: "Type color variants",
        variations: [
          %Variation{
            id: :info,
            attributes: %{id: "t-info", type: "info", open: true},
            slots: ["Info message"]
          },
          %Variation{
            id: :success,
            attributes: %{id: "t-success", type: "success", open: true},
            slots: ["Success message"]
          },
          %Variation{
            id: :warning,
            attributes: %{id: "t-warning", type: "warning", open: true},
            slots: ["Warning message"]
          },
          %Variation{
            id: :error,
            attributes: %{id: "t-error", type: "error", open: true},
            slots: ["Error message"]
          }
        ]
      },
      %Variation{
        id: :filled,
        description: "Filled background style",
        attributes: %{
          id: "toast-filled",
          type: "info",
          filled: true,
          open: true
        },
        slots: ["Filled info toast"]
      },
      %Variation{
        id: :with_title,
        description: "Toast with title text",
        attributes: %{
          id: "toast-title",
          type: "success",
          title: "Upload Complete",
          open: true
        },
        slots: ["Your file has been uploaded successfully."]
      },
      %Variation{
        id: :with_icon,
        description: "Toast with custom MDI icon",
        attributes: %{
          id: "toast-icon",
          type: "warning",
          icon: "alert-circle",
          open: true
        },
        slots: ["Disk space running low."]
      },
      %Variation{
        id: :with_close,
        description: "Toast with close button",
        attributes: %{
          id: "toast-close",
          type: "error",
          show_close: true,
          open: true
        },
        slots: ["Connection lost. Check your network."]
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
          {"error", "Error"}
        ],
        default: nil
      },
      %{
        id: :filled,
        label: "Filled",
        type: :boolean,
        default: false
      },
      %{
        id: :open,
        label: "Open",
        type: :boolean,
        default: false
      },
      %{
        id: :show_close,
        label: "Show Close",
        type: :boolean,
        default: false
      }
    ]
  end
end
