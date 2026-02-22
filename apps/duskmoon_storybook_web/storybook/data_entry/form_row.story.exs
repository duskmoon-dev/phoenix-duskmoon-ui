defmodule Storybook.DataEntry.FormRow do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.Form.dm_form_row/1
  def description, do: "Horizontal row layout for side-by-side form fields."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{},
        slots: [
          """
          <div class="form-group">
            <label class="form-label">First Name</label>
            <input type="text" class="input" placeholder="John" />
          </div>
          <div class="form-group">
            <label class="form-label">Last Name</label>
            <input type="text" class="input" placeholder="Doe" />
          </div>
          """
        ]
      },
      %Variation{
        id: :three_fields,
        attributes: %{},
        slots: [
          """
          <div class="form-group">
            <label class="form-label">City</label>
            <input type="text" class="input" placeholder="City" />
          </div>
          <div class="form-group">
            <label class="form-label">State</label>
            <input type="text" class="input" placeholder="State" />
          </div>
          <div class="form-group">
            <label class="form-label">ZIP</label>
            <input type="text" class="input" placeholder="12345" />
          </div>
          """
        ]
      },
      %Variation{
        id: :with_class,
        description: "Row with custom class",
        attributes: %{
          class: "gap-6"
        },
        slots: [
          """
          <div class="form-group">
            <label class="form-label">Phone</label>
            <input type="tel" class="input" placeholder="+1 (555) 000-0000" />
          </div>
          <div class="form-group">
            <label class="form-label">Extension</label>
            <input type="text" class="input" placeholder="1234" />
          </div>
          """
        ]
      }
    ]
  end
end
