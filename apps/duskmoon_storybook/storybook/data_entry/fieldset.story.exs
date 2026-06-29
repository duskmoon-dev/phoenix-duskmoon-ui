defmodule Storybook.DataEntry.Fieldset do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.Form.dm_fieldset/1
  def description, do: "Groups related form fields with an optional legend."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default fieldset with legend",
        attributes: %{
          legend: "Personal Information"
        },
        slots: [
          """
          <div class="space-y-4">
            <div class="form-group">
              <label class="form-label">First Name</label>
              <input type="text" class="input" placeholder="John" />
            </div>
            <div class="form-group">
              <label class="form-label">Last Name</label>
              <input type="text" class="input" placeholder="Doe" />
            </div>
          </div>
          """
        ]
      },
      %Variation{
        id: :filled,
        description: "Filled background variant",
        attributes: %{
          legend: "Filled Variant",
          variant: "filled"
        },
        slots: [
          """
          <div class="form-group">
            <label class="form-label">Email</label>
            <input type="email" class="input" placeholder="user@example.com" />
          </div>
          """
        ]
      },
      %Variation{
        id: :borderless,
        description: "Borderless minimal variant",
        attributes: %{
          legend: "Borderless Variant",
          variant: "borderless"
        },
        slots: [
          """
          <div class="form-group">
            <label class="form-label">Notes</label>
            <textarea class="textarea" placeholder="Enter notes..."></textarea>
          </div>
          """
        ]
      },
      %Variation{
        id: :card,
        description: "Card-style elevated variant",
        attributes: %{
          legend: "Card Variant",
          variant: "card"
        },
        slots: [
          """
          <div class="form-group">
            <label class="form-label">Address</label>
            <input type="text" class="input" placeholder="123 Main St" />
          </div>
          """
        ]
      },
      %Variation{
        id: :no_legend,
        description: "Fieldset without legend text",
        attributes: %{},
        slots: [
          """
          <div class="form-group">
            <label class="form-label">Hidden group</label>
            <input type="text" class="input" placeholder="No legend shown" />
          </div>
          """
        ]
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :variant,
        label: "Variant",
        type: :select,
        options: [
          {nil, "Default"},
          {"filled", "Filled"},
          {"borderless", "Borderless"},
          {"card", "Card"}
        ],
        default: nil
      }
    ]
  end
end
