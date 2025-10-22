defmodule Storybook.Components.Form.Slider do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Form.Slider.dm_slider/1
  def description, do: "Range slider component for numeric inputs."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "slider-default",
          name: "volume",
          label: "Volume",
          min: 0,
          max: 100,
          value: 75
        }
      },
      %Variation{
        id: :with_steps,
        attributes: %{
          id: "slider-steps",
          name: "brightness",
          label: "Brightness",
          min: 0,
          max: 10,
          step: 1,
          value: 5
        }
      },
      %Variation{
        id: :sizes,
        attributes: %{},
        slots: [
          """
          <div class="space-y-8">
            <div>
              <label class="text-xs text-base-content/70">XS Size</label>
              <.dm_slider id="xs" name="xs" label="XS slider" size="xs" value="50" />
            </div>
            <div>
              <label class="text-xs text-base-content/70">SM Size</label>
              <.dm_slider id="sm" name="sm" label="SM slider" size="sm" value="50" />
            </div>
            <div>
              <label class="text-xs text-base-content/70">MD Size</label>
              <.dm_slider id="md" name="md" label="MD slider" size="md" value="50" />
            </div>
            <div>
              <label class="text-xs text-base-content/70">LG Size</label>
              <.dm_slider id="lg" name="lg" label="LG slider" size="lg" value="50" />
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
            <.dm_slider id="primary" name="primary" label="Primary" color="primary" value="60" />
            <.dm_slider id="secondary" name="secondary" label="Secondary" color="secondary" value="60" />
            <.dm_slider id="accent" name="accent" label="Accent" color="accent" value="60" />
            <.dm_slider id="success" name="success" label="Success" color="success" value="60" />
            <.dm_slider id="warning" name="warning" label="Warning" color="warning" value="60" />
            <.dm_slider id="error" name="error" label="Error" color="error" value="60" />
          </div>
          """
        ]
      },
      %Variation{
        id: :no_value_label,
        attributes: %{
          id: "slider-no-label",
          name: "quality",
          label: "Audio Quality",
          min: 0,
          max: 100,
          value: 80,
          show_value: false
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
        id: :show_value,
        label: "Show Value",
        type: :boolean,
        default: true
      },
      %{
        id: :disabled,
        label: "Disabled",
        type: :boolean,
        default: false
      }
    ]
  end
end