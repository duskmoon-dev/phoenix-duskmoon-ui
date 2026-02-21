defmodule Storybook.DataEntry.FormSection do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.Form.dm_form_section/1
  def description, do: "Groups form fields under a titled section with optional description."

  def variations do
    [
      %Variation{
        id: :with_title,
        attributes: %{
          title: "Contact Information"
        },
        slots: [
          """
          <div class="form-group">
            <label class="form-label">Email</label>
            <input type="email" class="input" placeholder="user@example.com" />
          </div>
          <div class="form-group">
            <label class="form-label">Phone</label>
            <input type="tel" class="input" placeholder="+1 234 567 890" />
          </div>
          """
        ]
      },
      %Variation{
        id: :with_description,
        attributes: %{
          title: "Account Settings",
          description: "Configure your account preferences and security options."
        },
        slots: [
          """
          <div class="form-group">
            <label class="form-label">Username</label>
            <input type="text" class="input" placeholder="johndoe" />
          </div>
          <div class="form-group">
            <label class="form-label">Password</label>
            <input type="password" class="input" placeholder="********" />
          </div>
          """
        ]
      },
      %Variation{
        id: :no_title,
        attributes: %{},
        slots: [
          """
          <div class="form-group">
            <label class="form-label">Notes</label>
            <textarea class="textarea" placeholder="Additional notes..."></textarea>
          </div>
          """
        ]
      }
    ]
  end
end
