defmodule Storybook.DataDisplay.Accordion do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Accordion.dm_accordion/1
  def description, do: "Accordion component for collapsible content sections."

  def variations do
    [
      %Variation{
        id: :default,
        slots: [
          ~s(<:item value="s1" header="What is Phoenix Duskmoon UI?">A comprehensive component library for Phoenix LiveView applications.</:item>),
          ~s(<:item value="s2" header="How do I install it?">Add phoenix_duskmoon to your mix.exs dependencies.</:item>),
          ~s(<:item value="s3" header="Is it open source?">Yes, it is available on GitHub and Hex.pm.</:item>)
        ]
      },
      %Variation{
        id: :multiple_open,
        attributes: %{
          multiple: true,
          value: "s1,s3"
        },
        slots: [
          ~s(<:item value="s1" header="Section One">First section content</:item>),
          ~s(<:item value="s2" header="Section Two">Second section content</:item>),
          ~s(<:item value="s3" header="Section Three">Third section content</:item>)
        ]
      },
      %Variation{
        id: :with_disabled,
        slots: [
          ~s(<:item value="active" header="Active Item">This item can be toggled.</:item>),
          ~s(<:item value="disabled" header="Disabled Item" disabled>This item cannot be toggled.</:item>)
        ]
      },
      %Variation{
        id: :initially_open,
        attributes: %{
          value: "faq1"
        },
        slots: [
          ~s(<:item value="faq1" header="Initially Open">This section starts open.</:item>),
          ~s(<:item value="faq2" header="Closed by Default">Click to expand.</:item>)
        ]
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :multiple,
        label: "Multiple",
        type: :boolean,
        default: false
      }
    ]
  end
end
