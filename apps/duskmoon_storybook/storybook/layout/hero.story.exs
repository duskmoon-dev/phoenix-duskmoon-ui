defmodule Storybook.Layout.Hero do
  use PhoenixStorybook.Story, :component
  def function, do: &PhoenixDuskmoon.Component.Layout.Hero.dm_hero/1
  def description, do: "Layered hero composition with application-owned content and decoration."

  def variations do
    for align <- ["start", "center", "end"] do
      %Variation{
        id: String.to_atom(align),
        attributes: %{align: align, class: "min-h-64 p-8", content_class: "flex-col gap-4"},
        slots: [
          ~s|<:overlay><div class="h-full rounded-xl bg-primary/10"></div></:overlay>|,
          ~s|<h2 class="text-3xl font-bold">A workspace for your ideas</h2><p>Plan a project, invite your team, and make progress together.</p><a href="#start" class="btn btn-primary">Start a project</a>|
        ]
      }
    end
  end
end
