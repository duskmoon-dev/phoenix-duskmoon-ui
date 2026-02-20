defmodule Storybook.DataDisplay.Stat do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Stat.dm_stat/1

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default stat",
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
        id: :large_size,
        description: "Large size",
        attributes: %{title: "Total Sales", value: "$1.2M", size: "lg", color: "primary"}
      }
    ]
  end
end
