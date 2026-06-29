defmodule Storybook.ArtComponent.GeminiInput do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.ArtComponent.GeminiInput.dm_art_gemini_input/1
  def description, do: "Gemini-style animated gradient input using the el-dm-art-gemini-input custom element."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default Gemini input (md size)",
        attributes: %{
          id: "gemini-default"
        }
      },
      %Variation{
        id: :small,
        description: "Small size",
        attributes: %{
          id: "gemini-sm",
          size: "sm"
        }
      },
      %Variation{
        id: :large,
        description: "Large size",
        attributes: %{
          id: "gemini-lg",
          size: "lg"
        }
      },
      %Variation{
        id: :custom_placeholder,
        description: "Custom placeholder",
        attributes: %{
          id: "gemini-placeholder",
          placeholder: "Search or ask anything..."
        }
      }
    ]
  end
end
