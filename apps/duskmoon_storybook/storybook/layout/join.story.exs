defmodule Storybook.Layout.Join do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Layout.Join.dm_join/1
  def description, do: "Adjacent native controls retain their own behavior and form semantics."

  def variations do
    [
      %Variation{
        id: :horizontal,
        attributes: %{label: "Document actions"},
        slots: [
          ~s(<button type="button" class="btn join-item">Save</button><button type="button" class="btn join-item">Preview</button><button type="button" class="btn join-item">Share</button>)
        ]
      }
    ]
  end
end
