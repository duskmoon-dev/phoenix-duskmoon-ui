defmodule Storybook.DataEntry.FormHint do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.Form.dm_form_hint/1
  def description, do: "Hint text displayed above a form field to guide input."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{},
        slots: [
          "Must be at least 8 characters"
        ]
      },
      %Variation{
        id: :with_field,
        attributes: %{},
        template: """
        <div class="form-group">
          <label class="form-label">Password</label>
          <.dm_form_hint>Include uppercase, lowercase, and a number</.dm_form_hint>
          <input type="password" class="input" placeholder="Enter password" />
        </div>
        """
      }
    ]
  end
end
