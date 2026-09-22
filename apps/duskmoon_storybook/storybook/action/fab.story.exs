defmodule Storybook.Action.Fab do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Action.Fab.dm_fab/1

  def description,
    do: "Native popover speed dial. Open the actions, press Escape, or click outside to dismiss."

  def variations do
    [
      %Variation{
        id: :create,
        attributes: %{
          id: "storybook-create-fab",
          label: "Create a resource",
          class: "!relative !inset-auto"
        },
        slots: [
          ~s(<:trigger>+</:trigger>),
          ~s(<button type="button" class="btn btn-primary" command="hide-popover" commandfor="storybook-create-fab">New document</button><button type="button" class="btn btn-secondary" command="hide-popover" commandfor="storybook-create-fab">New folder</button>)
        ]
      }
    ]
  end
end
