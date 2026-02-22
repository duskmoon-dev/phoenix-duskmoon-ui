defmodule Storybook.DataDisplay.Stat do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Stat.dm_stat/1

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default stat (no color)",
        attributes: %{title: "Total Users", value: "1,234"}
      },
      %Variation{
        id: :with_description,
        description: "Stat with description",
        attributes: %{
          title: "Revenue",
          value: "$45.6K",
          description: "+12.3% from last month"
        }
      },
      %Variation{
        id: :primary_color,
        description: "Primary color",
        attributes: %{title: "Active Sessions", value: "892", color: "primary"}
      },
      %Variation{
        id: :secondary_color,
        description: "Secondary color",
        attributes: %{title: "Page Views", value: "15.2K", color: "secondary"}
      },
      %Variation{
        id: :accent_color,
        description: "Accent color",
        attributes: %{title: "Bookmarks", value: "348", color: "accent"}
      },
      %Variation{
        id: :info_color,
        description: "Info color",
        attributes: %{title: "Pending", value: "42", color: "info"}
      },
      %Variation{
        id: :success_color,
        description: "Success color with description",
        attributes: %{
          title: "Growth Rate",
          value: "+24%",
          color: "success",
          description: "Up from 18% last quarter"
        }
      },
      %Variation{
        id: :warning_color,
        description: "Warning color",
        attributes: %{
          title: "Response Time",
          value: "450ms",
          color: "warning",
          description: "Above 300ms target"
        }
      },
      %Variation{
        id: :error_color,
        description: "Error color",
        attributes: %{
          title: "Error Rate",
          value: "3.2%",
          color: "error",
          description: "Above threshold"
        }
      },
      %Variation{
        id: :small_size,
        description: "Small size",
        attributes: %{title: "Uptime", value: "99.9%", size: "sm"}
      },
      %Variation{
        id: :medium_size,
        description: "Medium size (default)",
        attributes: %{title: "CPU Usage", value: "67%", size: "md", color: "info"}
      },
      %Variation{
        id: :large_size,
        description: "Large size",
        attributes: %{title: "Total Sales", value: "$1.2M", size: "lg", color: "primary"}
      },
      %Variation{
        id: :tertiary_color,
        description: "Tertiary color",
        attributes: %{title: "Active Plans", value: "57", color: "tertiary"}
      },
      %Variation{
        id: :with_icon,
        description: "Stat with icon slot",
        attributes: %{title: "Downloads", value: "8.4K", color: "success"},
        slots: [
          ~s(<:icon>↓</:icon>)
        ]
      }
    ]
  end
end
