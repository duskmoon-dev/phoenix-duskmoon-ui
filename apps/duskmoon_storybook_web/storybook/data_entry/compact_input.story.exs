defmodule Storybook.DataEntry.CompactInput do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.CompactInput.dm_compact_input/1
  def description, do: "Compact input combining label and field in a single row. Ideal for dense forms and settings panels."

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
        },
        slots: [
          """
          <span class="badge badge-soft badge-info">@gsmlg.dev</span>
          """
        ]
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
      }
    ]
  end
end
