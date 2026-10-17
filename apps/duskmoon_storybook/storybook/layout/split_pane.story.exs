defmodule Storybook.Layout.SplitPane do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Layout.SplitPane.dm_split_pane/1
  def layout, do: :one_column

  def description,
    do:
      "Drag the separator or focus it and use ArrowLeft/Right, Home and End. Narrow containers stack both panes; resizing stays in the browser."

  def variations do
    for {id, attributes} <- [
          {:file_browser, %{}},
          {:bounded, %{initial_width: 200, min_width: 120, max_width: 300}},
          {:stacked, %{class: "h-72 max-w-sm"}}
        ] do
      %Variation{
        id: id,
        attributes:
          Map.merge(
            %{
              id: "split-pane-#{id}",
              class: "h-72 w-full",
              resize_label: "Resize folder navigation",
              primary_class: "p-4 bg-surface-container-low",
              secondary_class: "p-4"
            },
            attributes
          ),
        slots: [
          ~s|<:primary><nav aria-label="Folders"><h3 class="font-bold">Folders</h3><ul class="menu"><li><a href="#documents">Documents</a></li><li><a href="#projects">Projects with long prefixes</a></li></ul></nav></:primary>|,
          ~s|<section><h3 class="font-bold">Files</h3><p>Both pane contents stay visible when this preview becomes narrow.</p><input class="input" aria-label="Filter files" placeholder="Filter files" /></section>|
        ]
      }
    end
  end
end
