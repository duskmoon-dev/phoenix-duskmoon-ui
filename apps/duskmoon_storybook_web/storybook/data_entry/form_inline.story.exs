defmodule Storybook.DataEntry.FormInline do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.Form.dm_form_inline/1
  def description, do: "Inline form layout placing fields and actions on a single row."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Search field with action button",
        attributes: %{},
        slots: [
          """
          <div class="form-group">
            <label class="form-label">Search</label>
            <input type="text" class="input" placeholder="Search..." />
          </div>
          <button type="button" class="btn btn-primary">Go</button>
          """
        ]
      },
      %Variation{
        id: :multiple_fields,
        description: "Date range filter with two fields",
        attributes: %{},
        slots: [
          """
          <div class="form-group">
            <label class="form-label">From</label>
            <input type="date" class="input" />
          </div>
          <div class="form-group">
            <label class="form-label">To</label>
            <input type="date" class="input" />
          </div>
          <button type="button" class="btn btn-primary">Filter</button>
          """
        ]
      },
      %Variation{
        id: :with_class,
        description: "Inline layout with custom gap",
        attributes: %{
          class: "gap-6"
        },
        slots: [
          """
          <div class="form-group">
            <label class="form-label">Email</label>
            <input type="email" class="input" placeholder="user@example.com" />
          </div>
          <button type="button" class="btn btn-primary">Subscribe</button>
          """
        ]
      }
    ]
  end
end
