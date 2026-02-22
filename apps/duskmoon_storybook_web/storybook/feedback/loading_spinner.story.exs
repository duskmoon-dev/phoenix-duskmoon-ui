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
      %VariationGroup{
        id: :sizes,
        description: "Size variants",
        variations:
          for size <- ~w(xs sm md lg) do
            %Variation{
              id: String.to_atom(size),
              attributes: %{size: size}
            }
          end
      },
      %VariationGroup{
        id: :colors,
        description: "Color variants",
        variations:
          for variant <- ~w(primary secondary accent tertiary info success warning error) do
            %Variation{
              id: String.to_atom(variant),
              attributes: %{variant: variant, text: String.capitalize(variant)}
            }
          end
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
          {"tertiary", "Tertiary"},
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
