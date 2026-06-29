defmodule Storybook.DataEntry.Autocomplete do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.Autocomplete.dm_autocomplete/1
  def description, do: "Searchable autocomplete input with dropdown suggestions."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Basic autocomplete with flat options",
        attributes: %{
          id: "auto-default",
          placeholder: "Search countries...",
          options: [
            %{value: "us", label: "United States"},
            %{value: "uk", label: "United Kingdom"},
            %{value: "ca", label: "Canada"},
            %{value: "de", label: "Germany"},
            %{value: "fr", label: "France"}
          ]
        }
      },
      %Variation{
        id: :with_groups,
        description: "Autocomplete with grouped options",
        attributes: %{
          id: "auto-groups",
          placeholder: "Select language...",
          options: [
            %{value: "js", label: "JavaScript", group: "Frontend"},
            %{value: "ts", label: "TypeScript", group: "Frontend"},
            %{value: "py", label: "Python", group: "Backend"},
            %{value: "ex", label: "Elixir", group: "Backend"},
            %{value: "go", label: "Go", group: "Backend"}
          ]
        }
      },
      %Variation{
        id: :multiple,
        description: "Multi-select autocomplete with clear button",
        attributes: %{
          id: "auto-multiple",
          placeholder: "Select tags...",
          multiple: true,
          clearable: true,
          options: [
            %{value: "elixir", label: "Elixir"},
            %{value: "phoenix", label: "Phoenix"},
            %{value: "liveview", label: "LiveView"}
          ]
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
          {"sm", "SM"},
          {"md", "MD"},
          {"lg", "LG"}
        ],
        default: "md"
      },
      %{
        id: :multiple,
        label: "Multiple",
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
