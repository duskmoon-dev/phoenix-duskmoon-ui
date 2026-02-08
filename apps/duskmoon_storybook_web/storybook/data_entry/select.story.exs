defmodule Storybook.DataEntry.Select do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.Select.dm_select/1
  def description, do: "Select dropdown component for single or multiple selection from predefined options."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "select-default",
          name: "country",
          label: "Country",
          options: [{"us", "United States"}, {"ca", "Canada"}, {"mx", "Mexico"}],
          prompt: "Select a country"
        }
      },
      %Variation{
        id: :with_value,
        attributes: %{
          id: "select-value",
          name: "priority",
          label: "Priority",
          options: [{"low", "Low"}, {"medium", "Medium"}, {"high", "High"}, {"urgent", "Urgent"}],
          value: "medium"
        }
      },
      %Variation{
        id: :no_prompt,
        attributes: %{
          id: "select-no-prompt",
          name: "status",
          label: "Status",
          options: [{"active", "Active"}, {"inactive", "Inactive"}, {"pending", "Pending"}],
          value: "active"
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
              <.dm_select id="xs" name="xs" label="XS Select" size="xs" options={[{"a", "Option A"}, {"b", "Option B"}]} />
            </div>
            <div>
              <label class="text-xs text-base-content/70">SM Size</label>
              <.dm_select id="sm" name="sm" label="SM Select" size="sm" options={[{"a", "Option A"}, {"b", "Option B"}]} />
            </div>
            <div>
              <label class="text-xs text-base-content/70">MD Size</label>
              <.dm_select id="md" name="md" label="MD Select" size="md" options={[{"a", "Option A"}, {"b", "Option B"}]} />
            </div>
            <div>
              <label class="text-xs text-base-content/70">LG Size</label>
              <.dm_select id="lg" name="lg" label="LG Select" size="lg" options={[{"a", "Option A"}, {"b", "Option B"}]} />
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
            <.dm_select id="primary" name="primary" label="Primary" color="primary" options={[{"a", "Option A"}, {"b", "Option B"}]} prompt="Select primary" />
            <.dm_select id="secondary" name="secondary" label="Secondary" color="secondary" options={[{"a", "Option A"}, {"b", "Option B"}]} prompt="Select secondary" />
            <.dm_select id="accent" name="accent" label="Accent" color="accent" options={[{"a", "Option A"}, {"b", "Option B"}]} prompt="Select accent" />
            <.dm_select id="success" name="success" label="Success" color="success" options={[{"a", "Option A"}, {"b", "Option B"}]} prompt="Select success" />
            <.dm_select id="warning" name="warning" label="Warning" color="warning" options={[{"a", "Option A"}, {"b", "Option B"}]} prompt="Select warning" />
            <.dm_select id="error" name="error" label="Error" color="error" options={[{"a", "Option A"}, {"b", "Option B"}]} prompt="Select error" />
          </div>
          """
        ]
      },
      %Variation{
        id: :disabled,
        attributes: %{
          id: "select-disabled",
          name: "disabled",
          label: "Disabled Select",
          options: [{"option1", "Option 1"}, {"option2", "Option 2"}],
          disabled: true
        }
      },
      %Variation{
        id: :multiple,
        attributes: %{
          id: "select-multiple",
          name: "tags",
          label: "Tags (Multiple)",
          options: [{"tech", "Technology"}, {"design", "Design"}, {"business", "Business"}, {"marketing", "Marketing"}],
          multiple: true,
          value: ["tech", "design"]
        }
      },
      %Variation{
        id: :option_groups,
        attributes: %{},
        slots: [
          """
          <div class="w-full max-w-xs">
            <.dm_select id="groups" name="category" label="Category">
              <option value="">Select a category</option>
              <optgroup label="Fruits">
                <option value="apple">Apple</option>
                <option value="orange">Orange</option>
                <option value="banana">Banana</option>
              </optgroup>
              <optgroup label="Vegetables">
                <option value="carrot">Carrot</option>
                <option value="broccoli">Broccoli</option>
                <option value="spinach">Spinach</option>
              </optgroup>
              <optgroup label="Grains">
                <option value="wheat">Wheat</option>
                <option value="rice">Rice</option>
                <option value="corn">Corn</option>
              </optgroup>
            </.dm_select>
          </div>
          """
        ]
      },
      %Variation{
        id: :many_options,
        attributes: %{
          id: "select-many",
          name: "timezone",
          label: "Timezone",
          options: [
            {"utc", "UTC"},
            {"est", "Eastern Time"},
            {"cst", "Central Time"},
            {"mst", "Mountain Time"},
            {"pst", "Pacific Time"},
            {"akst", "Alaska Time"},
            {"hst", "Hawaii Time"}
          ],
          prompt: "Select timezone"
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
        id: :multiple,
        label: "Multiple",
        type: :boolean,
        default: false
      }
    ]
  end
end