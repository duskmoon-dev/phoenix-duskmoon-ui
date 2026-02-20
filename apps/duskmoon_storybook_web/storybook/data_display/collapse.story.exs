defmodule Storybook.DataDisplay.Collapse do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Collapse.dm_collapse/1
  def description, do: "Collapsible content panel with trigger and content slots."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "col-default"
        },
        slots: [
          """
          <:trigger>Click to expand</:trigger>
          <:content>This is the collapsible content area.</:content>
          """
        ]
      },
      %Variation{
        id: :card_variant,
        attributes: %{
          id: "col-card",
          variant: "card"
        },
        slots: [
          """
          <:trigger>Card style collapse</:trigger>
          <:content>Content inside a card-styled collapse panel.</:content>
          """
        ]
      },
      %Variation{
        id: :open,
        attributes: %{
          id: "col-open",
          open: true,
          variant: "bordered",
          color: "primary"
        },
        slots: [
          """
          <:trigger>Open by default</:trigger>
          <:content>This panel starts open with primary color border.</:content>
          """
        ]
      },
      %Variation{
        id: :variants,
        attributes: %{},
        slots: [
          """
          <div class="space-y-4">
            <.dm_collapse id="c-ghost" variant="ghost">
              <:trigger>Ghost variant</:trigger>
              <:content>Ghost content</:content>
            </.dm_collapse>
            <.dm_collapse id="c-divider" variant="divider">
              <:trigger>Divider variant</:trigger>
              <:content>Divider content</:content>
            </.dm_collapse>
          </div>
          """
        ]
      }
    ]
  end
end
