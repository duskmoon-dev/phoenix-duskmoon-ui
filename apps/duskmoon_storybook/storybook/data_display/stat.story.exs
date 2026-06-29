defmodule Storybook.DataDisplay.Stat do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Stat.dm_stat/1
  def description, do: "Statistic display with title, value, and optional description slots for dashboards and summaries."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default stat (no color)",
        attributes: %{title: "Total Users", value: "1,234"}
      },
      %Variation{
        id: :with_description,
        description: "Stat with description text",
        attributes: %{
          title: "Revenue",
          value: "$45.6K",
          description: "+12.3% from last month"
        }
      },
      %Variation{
        id: :with_icon,
        description: "Stat with icon slot",
        attributes: %{title: "Downloads", value: "8.4K", color: "success"},
        slots: [~s(<:icon>↓</:icon>)]
      },
      %VariationGroup{
        id: :colors,
        description: "Color variants",
        variations: [
          %Variation{id: :primary, attributes: %{title: "Sessions", value: "892", color: "primary"}},
          %Variation{id: :secondary, attributes: %{title: "Page Views", value: "15.2K", color: "secondary"}},
          %Variation{id: :tertiary, attributes: %{title: "Plans", value: "57", color: "tertiary"}},
          %Variation{id: :accent, attributes: %{title: "Bookmarks", value: "348", color: "accent"}},
          %Variation{id: :info, attributes: %{title: "Pending", value: "42", color: "info"}},
          %Variation{
            id: :success,
            attributes: %{title: "Growth", value: "+24%", color: "success", description: "Up from 18%"}
          },
          %Variation{
            id: :warning,
            attributes: %{title: "Response", value: "450ms", color: "warning", description: "Above target"}
          },
          %Variation{
            id: :error,
            attributes: %{title: "Errors", value: "3.2%", color: "error", description: "Above threshold"}
          }
        ]
      },
      %VariationGroup{
        id: :sizes,
        description: "Size variants",
        variations: [
          %Variation{id: :small, attributes: %{title: "Uptime", value: "99.9%", size: "sm"}},
          %Variation{id: :medium, attributes: %{title: "CPU", value: "67%", size: "md", color: "info"}},
          %Variation{id: :large, attributes: %{title: "Sales", value: "$1.2M", size: "lg", color: "primary"}}
        ]
      }
    ]
  end

  def modifiers do
    [
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
        id: :size,
        label: "Size",
        type: :select,
        options: [
          {"sm", "SM"},
          {"md", "MD"},
          {"lg", "LG"}
        ],
        default: "md"
      }
    ]
  end
end
