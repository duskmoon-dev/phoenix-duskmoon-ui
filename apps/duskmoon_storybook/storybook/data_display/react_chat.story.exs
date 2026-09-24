defmodule Storybook.DataDisplay.ReactChat do
  use PhoenixStorybook.Story, :example
  import PhoenixDuskmoon.Component.DataDisplay.ReactChat

  def doc,
    do: "React-owned transcript with batched streaming events and LiveView command handling."

  @impl true
  def mount(_, _, socket),
    do:
      {:ok,
       assign(socket,
         messages: [
           %{
             id: "welcome",
             role: "assistant",
             content: "Ask me to stream a response.",
             status: "complete"
           }
         ]
       )}

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-[32rem] p-6 bg-surface text-on-surface">
      <.dm_react_chat id="react-chat" conversation_id="storybook" messages={@messages} class="h-full" />
    </div>
    """
  end

  @impl true
  def handle_event("chat.send", %{"id" => "react-chat", "text" => text}, socket) do
    send(self(), {:stream_demo, text})
    {:reply, %{status: "ok"}, socket}
  end

  @impl true
  def handle_info({:stream_demo, text}, socket) do
    message_id = "reply-#{System.unique_integer([:positive])}"

    push_event(socket, "chat:event", %{
      id: "react-chat",
      type: "chat.message",
      conversation_id: "storybook",
      message_id: message_id,
      sequence: 1,
      message: %{id: message_id, role: "assistant", status: "streaming", content: ""}
    })
    |> push_event("chat:event", %{
      id: "react-chat",
      type: "chat.delta",
      conversation_id: "storybook",
      message_id: message_id,
      sequence: 2,
      text: "You said: #{text}. "
    })
    |> push_event("chat:event", %{
      id: "react-chat",
      type: "chat.delta",
      conversation_id: "storybook",
      message_id: message_id,
      sequence: 3,
      text: "This text can arrive in batches without LiveView rerendering the transcript."
    })
    |> push_event("chat:event", %{
      id: "react-chat",
      type: "chat.complete",
      conversation_id: "storybook",
      message_id: message_id,
      sequence: 4,
      status: "complete"
    })
    |> then(&{:noreply, &1})
  end
end
