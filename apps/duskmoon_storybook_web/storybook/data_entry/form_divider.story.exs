defmodule Storybook.DataEntry.FormDivider do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.Form.dm_form_divider/1
  def description, do: "Visual separator between form sections, optionally with text."

  def variations do
    [
      %Variation{
        id: :plain,
        attributes: %{}
      },
      %Variation{
        id: :with_text,
        attributes: %{
          text: "or"
        }
      },
      %Variation{
        id: :with_label,
        attributes: %{
          text: "Additional Options"
        }
      }
    ]
  end
end
