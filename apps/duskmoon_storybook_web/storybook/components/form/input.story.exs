defmodule Storybook.Components.Form.Input do
  # :live_component or :page are also available
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Form.dm_input/1
  def description, do: "A input element."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          type: "text",
          label: "Username",
          name: "name",
          value: nil
        }
      },
      %Variation{
        id: :password,
        attributes: %{
          type: "password",
          label: "Password",
          name: "password",
          value: nil
        }
      },
      %Variation{
        id: :email,
        attributes: %{
          type: "email",
          label: "Email",
          name: "email",
          value: nil,
          class: "input-sm"
        }
      },
      %Variation{
        id: :input_error,
        attributes: %{
          type: "search",
          label: "Search",
          name: "search",
          value: nil,
          errors: ["Search is required"]
        }
      },
      %Variation{
        id: :checkbox,
        attributes: %{
          type: "checkbox",
          label: "Checkbox",
          name: "checkbox"
        }
      },
      %Variation{
        id: :toggle,
        attributes: %{
          type: "toggle",
          label: "Auto",
          name: "auto",
          value: nil
        }
      },
      %Variation{
        id: :select,
        attributes: %{
          type: "select",
          label: "Location",
          name: "location",
          value: nil,
          options: [
            {"New York", "new_york"},
            {"California",
             [
               {"San Diego", "san_diego"},
               {"San Francisco", "san_francisco"},
               {"Los Angeles", "los_angeles"}
             ]}
          ]
        }
      },
      %Variation{
        id: :select_multiple,
        attributes: %{
          type: "select",
          label: "Favorite Cities",
          name: "favorite_cities",
          value: nil,
          multiple: true,
          options: [
            {"New York", "new_york"},
            {"California",
             [
               {"San Diego", "san_diego"},
               {"San Francisco", "san_francisco"},
               {"Los Angeles", "los_angeles"}
             ]}
          ]
        }
      },
      %Variation{
        id: :checkbox_group,
        attributes: %{
          type: "checkbox_group",
          label: "Favorite countries",
          name: "favorite_countries",
          value: nil,
          multiple: true,
          options: [
            {"United States", "us"},
            {"United Kigndom", "uk"},
            {"Franch", "fr"},
            {"German", "ge"}
          ]
        }
      },
      %Variation{
        id: :radio_group,
        attributes: %{
          type: "radio_group",
          label: "Most visited country",
          name: "most_visited_country",
          value: nil,
          options: [
            {"United States", "us"},
            {"United Kigndom", "uk"},
            {"Franch", "fr"},
            {"German", "ge"}
          ]
        }
      },
      %Variation{
        id: :textarea,
        attributes: %{
          type: "textarea",
          label: "Story",
          name: "story",
          value: nil
        }
      },
      %Variation{
        id: :file,
        attributes: %{
          type: "file",
          label: "Attachment",
          name: "attachment",
          value: nil
        }
      }
    ]
  end
end
