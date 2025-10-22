defmodule Storybook.Components.Form.Textarea do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Form.Textarea.dm_textarea/1
  def description, do: "Textarea component for multi-line text input with customizable sizing and resize behavior."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "textarea-default",
          name: "description",
          label: "Description",
          placeholder: "Enter a description...",
          rows: 4
        }
      },
      %Variation{
        id: :with_value,
        attributes: %{
          id: "textarea-value",
          name: "notes",
          label: "Notes",
          value: "These are some pre-filled notes that demonstrate how the textarea looks with content.",
          rows: 3
        }
      },
      %Variation{
        id: :no_label,
        attributes: %{
          id: "textarea-no-label",
          name: "comment",
          placeholder: "Leave a comment...",
          rows: 5
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
              <.dm_textarea id="xs" name="xs" label="XS Textarea" size="xs" rows="2" placeholder="XS textarea" />
            </div>
            <div>
              <label class="text-xs text-base-content/70">SM Size</label>
              <.dm_textarea id="sm" name="sm" label="SM Textarea" size="sm" rows="2" placeholder="SM textarea" />
            </div>
            <div>
              <label class="text-xs text-base-content/70">MD Size</label>
              <.dm_textarea id="md" name="md" label="MD Textarea" size="md" rows="2" placeholder="MD textarea" />
            </div>
            <div>
              <label class="text-xs text-base-content/70">LG Size</label>
              <.dm_textarea id="lg" name="lg" label="LG Textarea" size="lg" rows="2" placeholder="LG textarea" />
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
            <.dm_textarea id="primary" name="primary" label="Primary" color="primary" rows="2" placeholder="Primary textarea" />
            <.dm_textarea id="secondary" name="secondary" label="Secondary" color="secondary" rows="2" placeholder="Secondary textarea" />
            <.dm_textarea id="accent" name="accent" label="Accent" color="accent" rows="2" placeholder="Accent textarea" />
            <.dm_textarea id="success" name="success" label="Success" color="success" rows="2" placeholder="Success textarea" />
            <.dm_textarea id="warning" name="warning" label="Warning" color="warning" rows="2" placeholder="Warning textarea" />
            <.dm_textarea id="error" name="error" label="Error" color="error" rows="2" placeholder="Error textarea" />
          </div>
          """
        ]
      },
      %Variation{
        id: :resize_options,
        attributes: %{},
        slots: [
          """
          <div class="space-y-4">
            <div>
              <label class="text-xs text-base-content/70">No Resize</label>
              <.dm_textarea id="no-resize" name="no-resize" label="Fixed Size" resize="none" rows="3" placeholder="This textarea cannot be resized" />
            </div>
            <div>
              <label class="text-xs text-base-content/70">Vertical Resize</label>
              <.dm_textarea id="vertical-resize" name="vertical-resize" label="Vertical Only" resize="vertical" rows="3" placeholder="This textarea can only be resized vertically" />
            </div>
            <div>
              <label class="text-xs text-base-content/70">Horizontal Resize</label>
              <.dm_textarea id="horizontal-resize" name="horizontal-resize" label="Horizontal Only" resize="horizontal" rows="3" placeholder="This textarea can only be resized horizontally" />
            </div>
            <div>
              <label class="text-xs text-base-content/70">Both Directions</label>
              <.dm_textarea id="both-resize" name="both-resize" label="Free Resize" resize="both" rows="3" placeholder="This textarea can be resized in both directions" />
            </div>
          </div>
          """
        ]
      },
      %Variation{
        id: :states,
        attributes: %{},
        slots: [
          """
          <div class="space-y-4">
            <div>
              <label class="text-xs text-base-content/70">Disabled</label>
              <.dm_textarea id="disabled" name="disabled" label="Disabled Textarea" disabled="true" rows="3" value="This textarea is disabled and cannot be edited" />
            </div>
            <div>
              <label class="text-xs text-base-content/70">Readonly</label>
              <.dm_textarea id="readonly" name="readonly" label="Readonly Textarea" readonly="true" rows="3" value="This textarea is readonly but can be focused" />
            </div>
            <div>
              <label class="text-xs text-base-content/70">Required</label>
              <.dm_textarea id="required" name="required" label="Required Textarea" required="true" rows="3" placeholder="This field is required" />
            </div>
          </div>
          """
        ]
      },
      %Variation{
        id: :with_constraints,
        attributes: %{
          id: "textarea-constraints",
          name: "bio",
          label: "Bio (Max 200 characters)",
          placeholder: "Tell us about yourself...",
          rows: 4,
          maxlength: 200
        }
      },
      %Variation{
        id: :different_rows,
        attributes: %{},
        slots: [
          """
          <div class="space-y-4">
            <div>
              <label class="text-xs text-base-content/70">2 Rows</label>
              <.dm_textarea id="rows-2" name="rows2" label="Short Text" rows="2" placeholder="Short input area" />
            </div>
            <div>
              <label class="text-xs text-base-content/70">5 Rows</label>
              <.dm_textarea id="rows-5" name="rows5" label="Medium Text" rows="5" placeholder="Medium input area with more space" />
            </div>
            <div>
              <label class="text-xs text-base-content/70">10 Rows</label>
              <.dm_textarea id="rows-10" name="rows10" label="Long Text" rows="10" placeholder="Large input area for long content" />
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
        id: :resize,
        label: "Resize",
        type: :select,
        options: [
          {"none", "None"},
          {"vertical", "Vertical"},
          {"horizontal", "Horizontal"},
          {"both", "Both"}
        ],
        default: "vertical"
      },
      %{
        id: :disabled,
        label: "Disabled",
        type: :boolean,
        default: false
      },
      %{
        id: :readonly,
        label: "Readonly",
        type: :boolean,
        default: false
      },
      %{
        id: :required,
        label: "Required",
        type: :boolean,
        default: false
      },
      %{
        id: :rows,
        label: "Rows",
        type: :number,
        default: 3
      }
    ]
  end
end