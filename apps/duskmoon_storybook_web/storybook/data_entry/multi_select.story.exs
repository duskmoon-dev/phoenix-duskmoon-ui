defmodule Storybook.DataEntry.MultiSelect do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.MultiSelect.dm_multi_select/1
  def description, do: "Multi-select input with tags, dropdown, and search."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Basic multi-select with options",
        attributes: %{
          id: "ms-default",
          placeholder: "Select items...",
          options: [
            %{value: "elixir", label: "Elixir"},
            %{value: "phoenix", label: "Phoenix"},
            %{value: "liveview", label: "LiveView"},
            %{value: "ecto", label: "Ecto"}
          ]
        }
      },
      %Variation{
        id: :with_selected,
        description: "Pre-selected items with counter and clear button",
        attributes: %{
          id: "ms-selected",
          options: [
            %{value: "elixir", label: "Elixir"},
            %{value: "phoenix", label: "Phoenix"},
            %{value: "liveview", label: "LiveView"}
          ],
          selected: ["elixir", "phoenix"],
          clearable: true,
          show_counter: true
        }
      },
      %Variation{
        id: :open_dropdown,
        description: "Expanded dropdown with grouped search",
        attributes: %{
          id: "ms-open",
          options: [
            %{value: "a", label: "Apple", group: "Fruits"},
            %{value: "b", label: "Banana", group: "Fruits"},
            %{value: "c", label: "Carrot", group: "Vegetables"}
          ],
          selected: ["a"],
          open: true,
          searchable: true,
          show_actions: true
        }
      },
      %Variation{
        id: :states,
        description: "Error, disabled, and loading states",
        attributes: %{},
        slots: [
          """
          <div class="space-y-4">
            <.dm_multi_select id="ms-error"
              options={[%{value: "a", label: "Error"}]}
              selected={["a"]} error={true} />
            <.dm_multi_select id="ms-disabled"
              options={[%{value: "a", label: "Disabled"}]}
              selected={["a"]} disabled={true} />
            <.dm_multi_select id="ms-loading"
              options={[]} loading={true} placeholder="Loading..." />
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
          {nil, "Default"},
          {"sm", "SM"},
          {"lg", "LG"}
        ],
        default: nil
      },
      %{
        id: :variant,
        label: "Variant",
        type: :select,
        options: [
          {nil, "Default"},
          {"outlined", "Outlined"},
          {"filled", "Filled"}
        ],
        default: nil
      },
      %{
        id: :tag_variant,
        label: "Tag Variant",
        type: :select,
        options: [
          {nil, "Default"},
          {"primary", "Primary"},
          {"outlined", "Outlined"}
        ],
        default: nil
      },
      %{
        id: :searchable,
        label: "Searchable",
        type: :boolean,
        default: false
      },
      %{
        id: :clearable,
        label: "Clearable",
        type: :boolean,
        default: false
      },
      %{
        id: :show_counter,
        label: "Show Counter",
        type: :boolean,
        default: false
      },
      %{
        id: :show_actions,
        label: "Show Actions",
        type: :boolean,
        default: false
      },
      %{
        id: :disabled,
        label: "Disabled",
        type: :boolean,
        default: false
      },
      %{
        id: :loading,
        label: "Loading",
        type: :boolean,
        default: false
      }
    ]
  end
end
