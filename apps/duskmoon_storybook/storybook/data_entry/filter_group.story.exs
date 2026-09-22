defmodule Storybook.DataEntry.FilterGroup do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.FilterGroup.dm_filter_group/1

  def description,
    do:
      "Native checkbox and radio filters support keyboard selection and standard form submission."

  def variations do
    [
      %Variation{
        id: :multiple,
        attributes: %{name: "tags[]", label: "Project tags"},
        slots: [
          ~s(<:option value="design" checked>Design</:option>),
          ~s(<:option value="engineering">Engineering</:option>),
          ~s(<:option value="archived" disabled>Archived</:option>)
        ]
      },
      %Variation{
        id: :single,
        attributes: %{name: "status", label: "Project status", multiple: false, color: "tertiary"},
        slots: [
          ~s(<:option value="active" checked>Active</:option>),
          ~s(<:option value="complete">Complete</:option>)
        ]
      }
    ]
  end
end
