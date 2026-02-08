defmodule Storybook.DataEntry.Form do
  # :live_component or :page are also available
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.Form.dm_form/1
  def description, do: "A form element."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          class: "shadow",
          for: %{},
          as: ""
        },
        slots: [
          """
          <h3>Duskmoon Form</h3>
          """
        ]
      }
    ]
  end
end
