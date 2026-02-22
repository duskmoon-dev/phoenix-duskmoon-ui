defmodule Storybook.DataDisplay.Timeline do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Timeline.dm_timeline/1
  def description, do: "Vertical or horizontal timeline for events and progress."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "tl-default"
        },
        slots: [
          """
          <:item title="Order placed" time="2024-01-01" completed={true}>Order confirmed</:item>
          <:item title="Processing" time="2024-01-02" active={true}>In progress</:item>
          <:item title="Shipped" time="2024-01-03">Pending</:item>
          <:item title="Delivered">Pending</:item>
          """
        ]
      },
      %Variation{
        id: :alternate,
        attributes: %{
          id: "tl-alt",
          layout: "alternate"
        },
        slots: [
          """
          <:item title="Step 1" completed={true}>Done</:item>
          <:item title="Step 2" active={true}>Current</:item>
          <:item title="Step 3">Pending</:item>
          """
        ]
      },
      %Variation{
        id: :colored,
        description: "Colored timeline items",
        attributes: %{
          id: "tl-color"
        },
        slots: [
          """
          <:item title="Success" color="success" completed={true}>Completed</:item>
          <:item title="Warning" color="warning" active={true}>In progress</:item>
          <:item title="Error" color="error">Failed</:item>
          """
        ]
      },
      %Variation{
        id: :right_layout,
        description: "Right-aligned layout",
        attributes: %{
          id: "tl-right",
          layout: "right"
        },
        slots: [
          """
          <:item title="Step 1" completed={true}>Done</:item>
          <:item title="Step 2" active={true}>Current</:item>
          <:item title="Step 3">Pending</:item>
          """
        ]
      },
      %Variation{
        id: :horizontal_layout,
        description: "Horizontal timeline",
        attributes: %{
          id: "tl-horiz",
          layout: "horizontal"
        },
        slots: [
          """
          <:item title="Start" completed={true}>Done</:item>
          <:item title="Middle" active={true}>Now</:item>
          <:item title="End">Pending</:item>
          """
        ]
      },
      %Variation{
        id: :size_sm,
        description: "Small timeline",
        attributes: %{
          id: "tl-sm",
          size: "sm"
        },
        slots: [
          """
          <:item title="Created" completed={true}>Project created</:item>
          <:item title="Updated" active={true}>In review</:item>
          <:item title="Deployed">Pending</:item>
          """
        ]
      },
      %Variation{
        id: :size_lg,
        description: "Large timeline",
        attributes: %{
          id: "tl-lg",
          size: "lg"
        },
        slots: [
          """
          <:item title="Design" completed={true}>Designs approved</:item>
          <:item title="Development" active={true}>In progress</:item>
          <:item title="Testing">Pending</:item>
          """
        ]
      },
      %Variation{
        id: :with_loading,
        description: "Timeline item with loading state",
        attributes: %{
          id: "tl-loading"
        },
        slots: [
          """
          <:item title="Uploaded" completed={true}>File received</:item>
          <:item title="Processing" loading={true}>Analyzing data…</:item>
          <:item title="Done">Pending</:item>
          """
        ]
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :layout,
        label: "Layout",
        type: :select,
        options: [
          {nil, "Default"},
          {"alternate", "Alternate"},
          {"right", "Right"},
          {"horizontal", "Horizontal"}
        ],
        default: nil
      },
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
      }
    ]
  end
end
