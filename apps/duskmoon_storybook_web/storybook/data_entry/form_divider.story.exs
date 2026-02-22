defmodule Storybook.DataEntry.FormDivider do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.Form.dm_form_divider/1
  def description, do: "Visual separator between form sections, optionally with text."

  def variations do
    [
      %Variation{
        id: :plain,
        description: "Plain divider line",
        attributes: %{}
      },
      %Variation{
        id: :with_text,
        description: "Divider with centered text",
        attributes: %{
          text: "or"
        }
      },
      %Variation{
        id: :with_label,
        description: "Divider with section label",
        attributes: %{
          text: "Additional Options"
        }
      }
    ]
  end
end
