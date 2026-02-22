defmodule Storybook.DataEntry.Rating do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.Rating.dm_rating/1
  def description, do: "Star rating input component."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "rating-default",
          name: "rating",
          value: 3
        }
      },
      %Variation{
        id: :sizes,
        attributes: %{},
        slots: [
          """
          <div class="space-y-4">
            <.dm_rating id="xs" name="xs" value={3} size="xs" />
            <.dm_rating id="sm" name="sm" value={3} size="sm" />
            <.dm_rating id="def" name="def" value={3} />
            <.dm_rating id="lg" name="lg" value={3} size="lg" />
            <.dm_rating id="xl" name="xl" value={3} size="xl" />
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
            <.dm_rating id="primary" name="primary" value={4} color="primary" />
            <.dm_rating id="secondary" name="secondary" value={4} color="secondary" />
            <.dm_rating id="success" name="success" value={4} color="success" />
            <.dm_rating id="error" name="error" value={4} color="error" />
          </div>
          """
        ]
      },
      %Variation{
        id: :readonly,
        attributes: %{
          id: "rating-readonly",
          name: "readonly",
          value: 4,
          readonly: true
        }
      },
      %Variation{
        id: :disabled,
        attributes: %{
          id: "rating-disabled",
          name: "disabled",
          value: 2,
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
          {"lg", "LG"},
          {"xl", "XL"}
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
          {"tertiary", "Tertiary"},
          {"accent", "Accent"},
          {"info", "Info"},
          {"success", "Success"},
          {"warning", "Warning"},
          {"error", "Error"}
        ],
        default: nil
      },
      %{
        id: :readonly,
        label: "Readonly",
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
        id: :compact,
        label: "Compact",
        type: :boolean,
        default: false
      }
    ]
  end
end
