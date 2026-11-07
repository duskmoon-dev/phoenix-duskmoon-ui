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
  attr(:hook, :string, default: "DuskmoonReactChat")
  attr(:metadata, :map, default: %{})
  attr(:runtime, :map, default: %{})
  attr(:admission, :map, default: %{})

  attr(:protocol_version, :integer,
    default: nil,
    doc: "Opt into the structured composer protocol (1)"
  )

  attr(:context_key, :string,
    default: nil,
    doc: "Opaque application scope, including repository context"
  )

  attr(:composer, :map,
    default: nil,
    doc: "Revisioned capabilities, providers, options and queue projection"
  )

  attr(:actions, :map,
    default: %{},
    doc: "Additional or overridden bridge action to LiveView event mappings"
  )

  attr(:class, :any, default: nil)
  attr(:target, :any, default: nil)
  attr(:rest, :global, include: ~w(phx-submit phx-stop phx-target))

  def dm_react_chat(assigns) do
    snapshot =
      Jason.encode!(%{
        conversationId: assigns.conversation_id,
        messages: assigns.messages,
        label: assigns.label,
        event: assigns.event,
        metadata: assigns.metadata,
        runtime: assigns.runtime,
        admission: assigns.admission,
        protocolVersion: assigns.protocol_version,
        scope:
          if(assigns.protocol_version == 1,
            do: %{contextKey: assigns.context_key, conversationId: assigns.conversation_id},
            else: nil
          ),
        composer: assigns.composer,
        actions:
          Map.merge(
            %{
              send: "chat.send",
              stop: "chat.stop",
              retry: "chat.retry",
              action: "chat.action",
              sync: "chat.sync"
            },
            assigns.actions
          )
      })

    assigns = assign(assigns, :snapshot, snapshot)

    ~H"""
    <div id={@id} class={@class} phx-hook={@hook} phx-update="ignore" data-chat={@snapshot} data-target={@target} {@rest}>
      <div data-react-chat-loading role="status">Loading conversation…</div>
    </div>
    """
  end
end
