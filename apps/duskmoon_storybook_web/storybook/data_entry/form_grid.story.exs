defmodule Storybook.DataEntry.FormGrid do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.Form.dm_form_grid/1
  def description, do: "Grid layout for organizing form fields in columns."

  def variations do
    [
      %Variation{
        id: :two_columns,
        attributes: %{cols: 2},
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
          <div class="form-group">
            <label class="form-label">Email</label>
            <input type="email" class="input" placeholder="john@example.com" />
          </div>
          <div class="form-group">
            <label class="form-label">Phone</label>
            <input type="tel" class="input" placeholder="+1 234 567 890" />
          </div>
          """
        ]
      },
      %Variation{
        id: :three_columns,
        attributes: %{cols: 3},
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
            <label class="form-label">ZIP Code</label>
            <input type="text" class="input" placeholder="12345" />
          </div>
          """
        ]
      },
      %Variation{
        id: :four_columns,
        attributes: %{cols: 4},
        slots: [
          """
          <div class="form-group">
            <label class="form-label">Q1</label>
            <input type="number" class="input" placeholder="0" />
          </div>
          <div class="form-group">
            <label class="form-label">Q2</label>
            <input type="number" class="input" placeholder="0" />
          </div>
          <div class="form-group">
            <label class="form-label">Q3</label>
            <input type="number" class="input" placeholder="0" />
          </div>
          <div class="form-group">
            <label class="form-label">Q4</label>
            <input type="number" class="input" placeholder="0" />
          </div>
          """
        ]
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :cols,
        label: "Columns",
        type: :select,
        options: [
          {2, "2 columns"},
          {3, "3 columns"},
          {4, "4 columns"}
        ],
        default: 2
      }
    ]
  end
end
