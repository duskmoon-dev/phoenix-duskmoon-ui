defmodule Storybook.DataEntry.SearchWithSuggestions do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.Input.dm_input/1
  def description, do: "A search input with autocomplete suggestions."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          type: "search_with_suggestions",
          label: "Search Users",
          name: "search_users",
          value: nil,
          suggestions: ["John Doe", "Jane Smith", "Bob Johnson"]
        }
      },
      %Variation{
        id: :with_value,
        attributes: %{
          type: "search_with_suggestions",
          label: "Find Product",
          name: "find_product",
          value: "Laptop",
          suggestions: ["Laptop", "Mouse", "Keyboard", "Monitor"]
        }
      },
      %Variation{
        id: :with_color,
        attributes: %{
          type: "search_with_suggestions",
          label: "Search Cities",
          name: "search_cities",
          value: nil,
          suggestions: ["New York", "Los Angeles", "Chicago", "Houston"],
          color: "info"
        }
      },
      %Variation{
        id: :small_size,
        attributes: %{
          type: "search_with_suggestions",
          label: "Quick Find",
          name: "quick_find",
          value: nil,
          suggestions: ["Home", "Profile", "Settings", "Help"],
          size: "sm"
        }
      },
      %Variation{
        id: :with_errors,
        attributes: %{
          type: "search_with_suggestions",
          label: "Search",
          name: "search",
          value: nil,
          suggestions: [],
          errors: ["No results found"]
        }
      }
    ]
  end
end
