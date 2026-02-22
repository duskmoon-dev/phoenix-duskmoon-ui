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
      }
    ]
  end
end
