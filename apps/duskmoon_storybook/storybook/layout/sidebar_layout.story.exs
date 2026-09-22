defmodule Storybook.Layout.SidebarLayout do
  use PhoenixStorybook.Story, :component
  def function, do: &PhoenixDuskmoon.Component.Layout.SidebarLayout.dm_sidebar_layout/1

  def layout, do: :one_column

  def template do
    """
    <div class="w-full">
      <.psb-variation />
    </div>
    """
  end

  def description,
    do:
      "Sidebar appears at a container width of 48rem; the application supplies mobile navigation."

  def variations do
    for {id, attributes} <- [
          {:start, %{}},
          {:end, %{position: "end"}},
          {:compact, %{compact: true}},
          {:hidden, %{hidden: true}}
        ] do
      %Variation{
        id: id,
        attributes:
          Map.merge(%{class: "min-h-48", sidebar_class: "p-4", content_class: "p-6"}, attributes),
        slots: [
          ~s|<:sidebar><nav aria-label="Workspace"><ul class="menu menu-vertical"><li><a href="#inbox" aria-label="Inbox">📥</a></li><li><a href="#projects" aria-label="Projects">📁</a></li></ul></nav></:sidebar>|,
          ~s|<section><h2 class="text-xl font-bold">Workspace</h2><p>Resize the preview to see the persistent sidebar appear.</p><a class="link" href="#navigation">All workspace destinations</a></section>|
        ]
      }
    end
  end
end
