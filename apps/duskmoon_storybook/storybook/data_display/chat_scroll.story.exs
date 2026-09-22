defmodule Storybook.DataDisplay.ChatScroll do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Chat.dm_chat_scroll/1

  def layout, do: :one_column

  def template do
    """
    <div class="w-full">
      <.psb-variation />
    </div>
    """
  end

  def imports, do: [{PhoenixDuskmoon.Component.DataDisplay.Chat, dm_chat: 1}]

  def description,
    do: "Scrollable conversations with accessible navigation to numbered assistant replies."

  def variations do
    [
      %Variation{
        id: :conversation,
        attributes: %{
          class: "h-96 w-full",
          label: "Travel planning",
          indicator_label: "Assistant responses"
        },
        slots: [
          ~S"""
          <.dm_chat author="You" align="end">Help me plan a relaxed weekend.</.dm_chat>
          <.dm_chat author="Assistant" avatar="AI" timeline={1} color="primary">
            Start with a morning walk, leave the afternoon open, and choose one neighborhood for dinner.
          </.dm_chat>
          <.dm_chat author="You" align="end">What if it rains?</.dm_chat>
          <.dm_chat author="Assistant" avatar="AI" timeline={2} color="tertiary">
            Keep a museum or bookstore as your backup, with a nearby café for a quiet break.
          </.dm_chat>
          <.dm_chat author="You" align="end">Make Sunday even quieter.</.dm_chat>
          <.dm_chat author="Assistant" avatar="AI" timeline={3} color="primary">
            Have a slow breakfast, visit a local market, and finish early enough to rest before Monday.
          </.dm_chat>
          """
        ]
      }
    ]
  end
end
