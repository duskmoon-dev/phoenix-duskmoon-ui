defmodule Storybook.DataEntry.Checkbox do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.Checkbox.dm_checkbox/1
  def description, do: "Checkbox component for boolean selections."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "checkbox-default",
          name: "agree",
          label: "I agree to the terms and conditions"
        }
      },
      %Variation{
        id: :checked,
        attributes: %{
          id: "checkbox-checked",
          name: "newsletter",
          label: "Subscribe to newsletter",
          checked: true
        }
      },
      %Variation{
        id: :sizes,
        attributes: %{},
        slots: [
          """
          <div class="space-y-4">
            <div>
              <label class="text-xs text-base-content/70">XS Size</label>
              <.dm_checkbox id="xs" name="xs" label="XS checkbox" size="xs" />
            </div>
            <div>
              <label class="text-xs text-base-content/70">SM Size</label>
              <.dm_checkbox id="sm" name="sm" label="SM checkbox" size="sm" />
            </div>
            <div>
              <label class="text-xs text-base-content/70">MD Size</label>
              <.dm_checkbox id="md" name="md" label="MD checkbox" size="md" />
            </div>
            <div>
              <label class="text-xs text-base-content/70">LG Size</label>
              <.dm_checkbox id="lg" name="lg" label="LG checkbox" size="lg" />
            </div>
          </div>
          """
        ]
      },
      %Variation{
        id: :colors,
        attributes: %{},
        slots: [
          """
          <div class="space-y-4">
            <.dm_checkbox id="primary" name="primary" label="Primary option" color="primary" />
            <.dm_checkbox id="secondary" name="secondary" label="Secondary option" color="secondary" />
            <.dm_checkbox id="accent" name="accent" label="Accent option" color="accent" />
            <.dm_checkbox id="success" name="success" label="Success option" color="success" />
            <.dm_checkbox id="warning" name="warning" label="Warning option" color="warning" />
            <.dm_checkbox id="error" name="error" label="Error option" color="error" />
          </div>
          """
        ]
      },
      %Variation{
        id: :disabled,
        attributes: %{
          id: "checkbox-disabled",
          name: "disabled",
          label: "Disabled checkbox",
          disabled: true
        }
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :size,
        label: "Size",
        type: :select,
        options: [
          {nil, "Default"},
          {"xs", "XS"},
          {"sm", "SM"},
          {"md", "MD"},
          {"lg", "LG"}
        ],
        default: nil
      },
      %{
        id: :color,
        label: "Color",
        type: :select,
        options: [
          {nil, "Default"},
          {"primary", "Primary"},
          {"secondary", "Secondary"},
          {"accent", "Accent"},
          {"info", "Info"},
          {"success", "Success"},
          {"warning", "Warning"},
          {"error", "Error"}
        ],
        default: nil
      },
      %{
        id: :disabled,
        label: "Disabled",
        type: :boolean,
        default: false
      },
      %{
        id: :checked,
        label: "Checked",
        type: :boolean,
        default: false
      }
    ]
  end
end