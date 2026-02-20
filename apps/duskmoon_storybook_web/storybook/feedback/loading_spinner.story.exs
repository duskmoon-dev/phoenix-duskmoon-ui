defmodule Storybook.Feedback.LoadingSpinner do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Feedback.Loading.dm_loading_spinner/1
  def description, do: "Simple spinning loader with optional text."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default spinner (primary, md)",
        attributes: %{}
      },
      %Variation{
        id: :with_text,
        description: "Spinner with loading text",
        attributes: %{text: "Loading..."}
      },
      %Variation{
        id: :sizes,
        description: "All size variants",
        attributes: %{},
        slots: [
          """
          <div class="flex items-end gap-6">
            <.dm_loading_spinner size="xs" />
            <.dm_loading_spinner size="sm" />
            <.dm_loading_spinner size="md" />
            <.dm_loading_spinner size="lg" />
          </div>
          """
        ]
      },
      %Variation{
        id: :colors,
        description: "All color variants",
        attributes: %{},
        slots: [
          """
          <div class="flex items-center gap-6">
            <.dm_loading_spinner variant="primary" text="Primary" />
            <.dm_loading_spinner variant="secondary" text="Secondary" />
            <.dm_loading_spinner variant="accent" text="Accent" />
            <.dm_loading_spinner variant="info" text="Info" />
            <.dm_loading_spinner variant="success" text="Success" />
            <.dm_loading_spinner variant="warning" text="Warning" />
            <.dm_loading_spinner variant="error" text="Error" />
          </div>
          """
        ]
      },
      %Variation{
        id: :large_success,
        description: "Large success spinner with text",
        attributes: %{
          size: "lg",
          variant: "success",
          text: "Saving..."
        }
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :size,
        label: "Size",
        type: :select,
        options: [
          {"xs", "XS"},
          {"sm", "SM"},
          {"md", "MD"},
          {"lg", "LG"}
        ],
        default: "md"
      },
      %{
        id: :variant,
        label: "Variant",
        type: :select,
        options: [
          {"primary", "Primary"},
          {"secondary", "Secondary"},
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
