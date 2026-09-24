defmodule PhoenixDuskmoon.Component.DataDisplay.ReactChat do
  @moduledoc """
  React-owned streaming chat integration.

  The server keeps task ownership and persistence while React owns the transcript,
  draft, markdown rendering, scroll state, and streaming message. Push chat events
  with `push_event/3`; do not update the transcript assign for every token.
  """
  use Phoenix.Component

  @doc "Renders a React chat mount point with an initial JSON snapshot."
  @doc type: :component
  attr(:id, :string, required: true)
  attr(:messages, :list, default: [])
  attr(:label, :string, default: "Conversation")
  attr(:conversation_id, :string, required: true)
  attr(:event, :string, default: "chat:event")
  attr(:class, :any, default: nil)
  attr(:target, :any, default: nil)
  attr(:rest, :global, include: ~w(phx-submit phx-stop phx-target))
  slot(:inner_block)

  def dm_react_chat(assigns) do
    snapshot =
      Jason.encode!(%{
        conversationId: assigns.conversation_id,
        messages: assigns.messages,
        label: assigns.label,
        event: assigns.event,
        actions: %{
          send: "chat.send",
          stop: "chat.stop",
          retry: "chat.retry",
          action: "chat.action",
          sync: "chat.sync"
        }
      })

    assigns = assign(assigns, :snapshot, snapshot)

    ~H"""
    <div id={@id} class={@class} phx-hook="DuskmoonReactChat" phx-update="ignore" data-chat={@snapshot} data-target={@target} {@rest}>
      <div data-react-chat-loading role="status">Loading conversation…</div>
    </div>
    """
  end
end
