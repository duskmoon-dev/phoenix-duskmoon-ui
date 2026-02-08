defmodule Storybook.DataEntry.Switch do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.Switch.dm_switch/1
  def description, do: "Toggle switch component for boolean inputs."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "switch-default",
          name: "notifications",
          label: "Enable notifications"
        }
      },
      %Variation{
        id: :checked,
        attributes: %{
          id: "switch-checked",
          name: "dark_mode",
          label: "Dark mode",
          checked: true
        }
      },
      %Variation{
        id: :with_color,
        attributes: %{
          id: "switch-color",
          name: "auto_save",
          label: "Auto-save",
          color: "success"
        }
      },
      %Variation{
        id: :sizes,
        attributes: %{
          id: "switch-sizes",
          name: "size_example",
          label: "Size examples"
        },
        slots: [
          """
          <div class="space-y-4">
            <div>
              <label class="text-xs text-base-content/70">XS Size</label>
              <.dm_switch id="xs" name="xs" label="XS switch" size="xs" />
            </div>
            <div>
              <label class="text-xs text-base-content/70">SM Size</label>
              <.dm_switch id="sm" name="sm" label="SM switch" size="sm" />
            </div>
            <div>
              <label class="text-xs text-base-content/70">MD Size</label>
              <.dm_switch id="md" name="md" label="MD switch" size="md" />
            </div>
            <div>
              <label class="text-xs text-base-content/70">LG Size</label>
              <.dm_switch id="lg" name="lg" label="LG switch" size="lg" />
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
            <.dm_switch id="primary" name="primary" label="Primary" color="primary" />
            <.dm_switch id="secondary" name="secondary" label="Secondary" color="secondary" />
            <.dm_switch id="accent" name="accent" label="Accent" color="accent" />
            <.dm_switch id="success" name="success" label="Success" color="success" />
            <.dm_switch id="warning" name="warning" label="Warning" color="warning" />
            <.dm_switch id="error" name="error" label="Error" color="error" />
          </div>
          """
        ]
      },
      %Variation{
        id: :disabled,
        attributes: %{
          id: "switch-disabled",
          name: "disabled",
          label: "Disabled switch",
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