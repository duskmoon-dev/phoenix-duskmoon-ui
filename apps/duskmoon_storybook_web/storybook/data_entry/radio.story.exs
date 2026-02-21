defmodule Storybook.DataEntry.Radio do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.Radio.dm_radio/1
  def description, do: "Radio button component for single selection from multiple options."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "radio-default",
          name: "theme",
          value: "light",
          label: "Light theme"
        }
      },
      %Variation{
        id: :checked,
        attributes: %{
          id: "radio-checked",
          name: "theme",
          value: "dark",
          label: "Dark theme",
          checked: true
        }
      },
      %Variation{
        id: :radio_group,
        attributes: %{},
        slots: [
          """
          <div class="space-y-3">
            <div>
              <label class="text-sm font-medium text-base-content/90 mb-2 block">Choose your plan</label>
              <.dm_radio id="free" name="plan" value="free" label="Free Plan" />
              <.dm_radio id="pro" name="plan" value="pro" label="Pro Plan" checked={true} />
              <.dm_radio id="enterprise" name="plan" value="enterprise" label="Enterprise Plan" />
            </div>
          </div>
          """
        ]
      },
      %Variation{
        id: :sizes,
        attributes: %{},
        slots: [
          """
          <div class="space-y-4">
            <div>
              <label class="text-xs text-base-content/70">XS Size</label>
              <.dm_radio id="xs" name="xs" value="xs" label="XS option" size="xs" />
            </div>
            <div>
              <label class="text-xs text-base-content/70">SM Size</label>
              <.dm_radio id="sm" name="sm" value="sm" label="SM option" size="sm" />
            </div>
            <div>
              <label class="text-xs text-base-content/70">MD Size</label>
              <.dm_radio id="md" name="md" value="md" label="MD option" size="md" />
            </div>
            <div>
              <label class="text-xs text-base-content/70">LG Size</label>
              <.dm_radio id="lg" name="lg" value="lg" label="LG option" size="lg" />
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
            <.dm_radio id="primary" name="primary" value="primary" label="Primary option" color="primary" />
            <.dm_radio id="secondary" name="secondary" value="secondary" label="Secondary option" color="secondary" />
            <.dm_radio id="accent" name="accent" value="accent" label="Accent option" color="accent" />
            <.dm_radio id="success" name="success" value="success" label="Success option" color="success" />
            <.dm_radio id="warning" name="warning" value="warning" label="Warning option" color="warning" />
            <.dm_radio id="error" name="error" value="error" label="Error option" color="error" />
          </div>
          """
        ]
      },
      %Variation{
        id: :disabled,
        attributes: %{
          id: "radio-disabled",
          name: "disabled",
          value: "disabled",
          label: "Disabled option",
          disabled: true
        }
      },
      %Variation{
        id: :mixed_states,
        attributes: %{},
        slots: [
          """
          <div class="space-y-3">
            <div>
              <label class="text-sm font-medium text-base-content/90 mb-2 block">Notification Settings</label>
              <.dm_radio id="all" name="notifications" value="all" label="All notifications" checked={true} />
              <.dm_radio id="important" name="notifications" value="important" label="Important only" color="warning" />
              <.dm_radio id="none" name="notifications" value="none" label="None" disabled={true} />
            </div>
          </div>
          """
        ]
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
          {"xs", "XS"},
          {"sm", "SM"},
          {"md", "MD"},
          {"lg", "LG"}
        ],
        default: "md"
      },
      %{
        id: :color,
        label: "Color",
        type: :select,
        options: [
          {"primary", "Primary"},
          {"secondary", "Secondary"},
          {"accent", "Accent"},
          {"info", "Info"},
          {"success", "Success"},
          {"warning", "Warning"},
          {"error", "Error"}
        ],
        default: "primary"
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