defmodule Storybook.Layout.Indicator do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Layout.Indicator.dm_indicator/1

  def description,
    do: "Logical indicator positions work in left-to-right and right-to-left layouts."

  def variations do
    [
      %Variation{
        id: :badge,
        attributes: %{class: "m-4"},
        slots: [
          ~s(<button type="button" class="btn btn-primary">Inbox</button>),
          ~s(<:indicator><span class="badge badge-error" aria-label="3 unread messages">3</span></:indicator>)
        ]
      },
      %Variation{
        id: :bottom_start,
        attributes: %{class: "m-4", dir: "rtl"},
        slots: [
          ~s(<div class="card p-8">Project status</div>),
          ~s(<:indicator vertical="bottom" horizontal="start"><span class="badge badge-success">Ready</span></:indicator>)
        ]
      }
    ]
  end
end
