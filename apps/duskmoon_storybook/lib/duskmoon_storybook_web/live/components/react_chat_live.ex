defmodule DuskmoonStorybookWeb.Components.ReactChatLive do
  @moduledoc "Interactive UI demo for the React-owned streaming chat."

  use DuskmoonStorybookWeb, :live_view

  @chat_id "react-chat-demo"
  @conversation_id "react-demo"
  @stream_interval 80

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       chat_id: @chat_id,
       conversation_id: @conversation_id,
       messages: initial_messages(),
       active_stream: nil,
       action_sequences: %{},
       runtime: %{active: false, phase: "idle"},
       admission: %{allowWhileStreaming: true},
       event_count: 0,
       stream_count: 0,
       status: "Ready for a prompt",
       last_event: "Initial snapshot"
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full max-w-7xl p-4 md:p-8">
      <.dm_breadcrumb class="mb-6">
        <:crumb to={~p"/components"}>Components</:crumb>
        <:crumb to={~p"/components/data-display/react-chat"}>Data Display</:crumb>
        <:crumb>React Chat</:crumb>
      </.dm_breadcrumb>

      <header class="mb-8 flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
        <div>
          <div class="mb-3 flex flex-wrap items-center gap-2">
            <.dm_badge variant="primary">React integration</.dm_badge>
            <span class="text-sm opacity-60">dm_react_chat</span>
          </div>
          <h1 class="text-4xl font-bold tracking-tight">React-owned streaming chat</h1>
          <p class="mt-3 max-w-3xl text-base opacity-70">
            A real LiveView surface for long transcripts, Markdown, tool calls, retries, and
            batched streaming updates. React owns the ignored transcript while LiveView owns
            authorization and the task lifecycle.
          </p>
        </div>
        <div class="flex items-center gap-2 text-sm opacity-70">
          <span class="inline-block h-2 w-2 rounded-full bg-success"></span>
          <span id="chat-status">{@status}</span>
        </div>
      </header>

      <div class="grid gap-6 xl:grid-cols-[minmax(0,1fr)_22rem]">
        <section class="card border border-base-300 bg-base-100 shadow-sm">
          <div class="card-body p-4 md:p-6">
            <div class="mb-4 flex items-center justify-between gap-4">
              <div>
                <h2 class="text-xl font-semibold">Conversation playground</h2>
                <p class="text-sm opacity-60">
                  Try a prompt, inspect the tool state, or jump between assistant replies.
                </p>
              </div>
              <span class="font-mono text-xs opacity-50">conversation_id: demo</span>
            </div>
            <.dm_react_chat
              id={@chat_id}
              conversation_id={@conversation_id}
              messages={@messages}
              hook="DuskmoonComposedChat"
              runtime={@runtime}
              admission={@admission}
              label="React streaming chat demonstration"
              class="h-[38rem] min-h-0 rounded-lg bg-base-200/50 p-3 md:p-5"
            />
          </div>
        </section>

        <aside class="flex flex-col gap-4">
          <section class="card border border-base-300 bg-base-100 shadow-sm">
            <div class="card-body gap-4 p-5">
              <h2 class="text-lg font-semibold">Performance signals</h2>
              <div class="grid grid-cols-2 gap-3">
                <div class="rounded-lg bg-base-200 p-3">
                  <p class="text-xs uppercase tracking-wide opacity-60">Events pushed</p>
                  <p id="chat-event-count" class="mt-1 text-2xl font-bold">{@event_count}</p>
                </div>
                <div class="rounded-lg bg-base-200 p-3">
                  <p class="text-xs uppercase tracking-wide opacity-60">Streams</p>
                  <p id="chat-stream-count" class="mt-1 text-2xl font-bold">{@stream_count}</p>
                </div>
              </div>
              <p class="text-sm opacity-60">
                The transcript is not re-rendered for each token. Events arrive in bounded
                batches and React schedules one DOM update per frame.
              </p>
              <p class="font-mono text-xs opacity-50">Last event: {@last_event}</p>
            </div>
          </section>

          <section class="card border border-base-300 bg-base-100 shadow-sm">
            <div class="card-body gap-3 p-5">
              <h2 class="text-lg font-semibold">Scenario controls</h2>
              <button
                id="chat-seed-long"
                type="button"
                class="btn btn-outline w-full"
                phx-click="seed-long"
              >
                Seed 12-message transcript
              </button>
              <button
                id="chat-reset"
                type="button"
                class="btn btn-ghost w-full"
                phx-click="reset-chat"
              >
                Reset conversation
              </button>
              <p class="text-xs opacity-60">
                Reset and seed use a snapshot event, so the ignored React subtree updates without
                rebuilding the LiveView page.
              </p>
            </div>
          </section>
        </aside>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("chat.send", %{"id" => @chat_id, "text" => text}, socket) do
    text = String.trim(text)

    if text == "" do
      {:reply, %{status: "error", message: "Enter a message first"}, socket}
    else
      if socket.assigns.active_stream do
        {:reply, %{status: "ok", admission: "steering"}, append_user(socket, text)}
      else
        {:reply, %{status: "ok", admission: "new_turn"},
         start_stream(append_user(socket, text), text)}
      end
    end
  end

  def handle_event("chat.stop", %{"id" => @chat_id}, socket),
    do: {:reply, %{status: "ok"}, stop_stream(socket)}

  def handle_event("chat.retry", %{"id" => @chat_id, "message_id" => message_id}, socket),
    do: {:reply, %{status: "ok"}, start_stream(socket, "Retrying #{message_id}")}

  def handle_event(
        "chat.action",
        %{"id" => @chat_id, "message_id" => message_id, "action" => action},
        socket
      ) do
    {:reply, %{status: "ok"}, append_tool_event(socket, message_id, action)}
  end

  def handle_event("chat.sync", %{"id" => @chat_id}, socket),
    do: {:reply, %{status: "ok"}, push_snapshot(socket)}

  def handle_event("seed-long", _params, socket),
    do:
      {:noreply,
       reset_conversation(socket, long_conversation(), "Seeded a 12-message conversation")}

  def handle_event("reset-chat", _params, socket),
    do: {:noreply, reset_conversation(socket, initial_messages(), "Conversation reset")}

  @impl true
  def handle_info({:chat_stream_tick, message_id}, socket) do
    case socket.assigns.active_stream do
      %{message_id: ^message_id, events: events, next_index: index} = stream ->
        event = Enum.at(events, index)
        sequence = stream.next_sequence + 1

        socket =
          socket
          |> apply_demo_event(Map.merge(event, base_event(message_id, sequence)))
          |> assign(
            event_count: socket.assigns.event_count + 1,
            last_event: event.type
          )

        if index + 1 < length(events) do
          Process.send_after(
            self(),
            {:chat_stream_tick, message_id},
            if(Map.get(event, :runtime, %{})[:phase] == "waiting_for_approval",
              do: 900,
              else: @stream_interval
            )
          )

          {:noreply,
           assign(socket,
             active_stream: %{stream | next_index: index + 1, next_sequence: sequence}
           )}
        else
          {:noreply,
           assign(socket,
             active_stream: nil,
             status: "Response complete",
             last_event: event.type
           )}
        end

      _ ->
        {:noreply, socket}
    end
  end

  defp start_stream(socket, text) do
    message_id = "demo-#{System.unique_integer([:positive])}"

    stream = %{
      message_id: message_id,
      events: stream_events(text, message_id),
      next_index: 0,
      next_sequence: 0
    }

    Process.send_after(self(), {:chat_stream_tick, message_id}, 10)

    assign(socket,
      active_stream: stream,
      stream_count: socket.assigns.stream_count + 1,
      status: "Streaming response",
      runtime: %{active: true, phase: "provider_streaming"},
      last_event: "Waiting for chat.message"
    )
  end

  defp stop_stream(%{assigns: %{active_stream: nil}} = socket), do: socket

  defp stop_stream(socket) do
    stream = socket.assigns.active_stream
    sequence = stream.next_sequence + 1

    socket =
      if stream.next_sequence == 0 do
        socket
        |> apply_demo_event(
          Map.merge(Enum.at(stream.events, 0), base_event(stream.message_id, 1))
        )
        |> apply_demo_event(
          base_event(stream.message_id, 2, %{
            type: "chat.complete",
            status: "cancelled",
            runtime: %{active: false, phase: "cancelled"}
          })
        )
      else
        apply_demo_event(
          socket,
          base_event(stream.message_id, sequence, %{
            type: "chat.complete",
            status: "cancelled",
            runtime: %{active: false, phase: "cancelled"}
          })
        )
      end

    assign(socket,
      active_stream: nil,
      event_count: socket.assigns.event_count + if(stream.next_sequence == 0, do: 2, else: 1),
      status: "Response stopped",
      last_event: "chat.complete (cancelled)"
    )
  end

  defp append_tool_event(socket, message_id, action) do
    sequence = Map.get(socket.assigns.action_sequences, message_id, 0) + 1

    apply_demo_event(
      socket,
      base_event(message_id, sequence, %{
        type: "chat.tool",
        tool: %{
          id: "action-#{action}",
          name: "#{String.capitalize(action)} action",
          status: "success",
          result: %{message: "Action handled by LiveView", action: action}
        }
      })
    )
    |> assign(
      action_sequences: Map.put(socket.assigns.action_sequences, message_id, sequence),
      event_count: socket.assigns.event_count + 1,
      status: "Action handled",
      last_event: "chat.tool"
    )
  end

  defp push_snapshot(socket) do
    push_event(socket, "chat:event", %{
      id: @chat_id,
      type: "chat.snapshot",
      conversation_id: @conversation_id,
      messages: socket.assigns.messages,
      sequences: socket.assigns.action_sequences,
      runtime: socket.assigns.runtime,
      admission: socket.assigns.admission
    })
    |> assign(event_count: socket.assigns.event_count + 1, last_event: "chat.snapshot")
  end

  defp reset_conversation(socket, messages, status) do
    socket
    |> assign(
      messages: messages,
      active_stream: nil,
      action_sequences: %{},
      runtime: %{active: false, phase: "idle"},
      status: status,
      last_event: "chat.reset"
    )
    |> push_event("chat:event", %{
      id: @chat_id,
      type: "chat.reset",
      conversation_id: @conversation_id,
      messages: messages,
      sequences: %{},
      runtime: %{active: false, phase: "idle"},
      admission: socket.assigns.admission
    })
    |> assign(event_count: socket.assigns.event_count + 1)
  end

  # The fixture keeps canonical messages/sequences so chat.sync restores custom state.
  defp apply_demo_event(socket, event) do
    messages = socket.assigns.messages
    index = Enum.find_index(messages, &(&1.id == event.message_id))
    current = if index, do: Enum.at(messages, index), else: %{}

    message =
      case event.type do
        "chat.message" ->
          event.message

        "chat.delta" ->
          Map.update(current, :content, event.text, &(&1 <> event.text))

        "chat.tool" ->
          Map.put(
            current,
            :tools,
            Enum.reject(Map.get(current, :tools, []), &(&1.id == event.tool.id)) ++ [event.tool]
          )

        "chat.complete" ->
          Map.put(current, :status, event.status)
      end

    messages =
      if index, do: List.replace_at(messages, index, message), else: messages ++ [message]

    runtime = Map.get(event, :runtime, socket.assigns.runtime)

    socket
    |> assign(
      messages: messages,
      runtime: runtime,
      action_sequences: Map.put(socket.assigns.action_sequences, event.message_id, event.sequence)
    )
    |> push_event("chat:event", Map.put(event, :runtime, runtime))
  end

  defp append_user(socket, text) do
    id = "user-#{System.unique_integer([:positive])}"

    apply_demo_event(
      socket,
      base_event(id, 1, %{
        type: "chat.message",
        message: %{id: id, role: "user", content: text, status: "complete"}
      })
    )
  end

  defp base_event(message_id, sequence, extra \\ %{}) do
    Map.merge(
      %{
        id: @chat_id,
        conversation_id: @conversation_id,
        message_id: message_id,
        sequence: sequence
      },
      extra
    )
  end

  defp stream_events(text, message_id) do
    [
      %{
        type: "chat.message",
        message: %{
          id: message_id,
          role: "assistant",
          author: "Duskmoon",
          status: "streaming",
          content: ""
        }
      },
      %{type: "chat.delta", text: "I received **#{text}** and started a batched response. "},
      %{
        type: "chat.tool",
        runtime: %{active: true, phase: "tool_execution"},
        tool: %{id: "search", name: "Knowledge search", status: "running", input: %{query: text}}
      },
      %{
        type: "chat.delta",
        text: "The tool result is rendered alongside the message without a full LiveView diff. "
      },
      %{
        type: "chat.tool",
        tool: %{
          id: "search",
          name: "Knowledge search",
          status: "success",
          result: %{matches: 3, latency_ms: 42}
        }
      },
      %{
        type: "chat.delta",
        text:
          "This final chunk demonstrates Markdown, tool state, and frame-scheduled React updates."
      },
      %{
        type: "chat.complete",
        status: "complete",
        runtime: %{active: true, phase: "waiting_for_approval"}
      },
      %{
        type: "chat.message",
        runtime: %{active: false, phase: "complete"},
        message: %{
          id: message_id,
          role: "assistant",
          author: "Duskmoon",
          status: "complete",
          content:
            "I received **#{text}** and started a batched response. The tool result is rendered alongside the message without a full LiveView diff. This final chunk demonstrates Markdown, tool state, and frame-scheduled React updates.",
          tools: [
            %{
              id: "search",
              name: "Knowledge search",
              status: "success",
              result: %{matches: 3, latency_ms: 42}
            }
          ],
          metadata: %{
            reasoning: "Checked the conversation and searched available context.",
            usage: %{tokens: 128, duration_ms: 640},
            summary: "Turn complete: one tool call and a streamed answer."
          },
          actions: [
            %{id: "resend", label: "Resend", eligible: true},
            %{id: "retry", label: "Checkpoint Retry", confirm: "Retry from this checkpoint?"},
            %{id: "continue", label: "Continue", eligible: true},
            %{id: "fork", label: "Fork", eligible: false}
          ]
        }
      }
    ]
  end

  defp initial_messages do
    [
      %{
        id: "welcome",
        role: "assistant",
        author: "Duskmoon",
        status: "complete",
        content:
          "Welcome. Ask for a **streamed explanation**, a tool lookup, or a performance summary.",
        metadata: %{
          reasoning: "This panel uses a consumer composer and message renderer.",
          usage: %{tokens: 42, duration_ms: 120},
          summary: "A single summary belongs to this completed turn."
        },
        actions: [%{id: "explain", label: "Explain architecture"}]
      },
      %{
        id: "question",
        role: "user",
        author: "You",
        status: "complete",
        content: "Show the tool-call state.",
        attachments: [
          %{
            url:
              "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='96' height='64'%3E%3Crect width='96' height='64' fill='%236755a8'/%3E%3C/svg%3E",
            name: "Sample attachment"
          }
        ]
      },
      %{
        id: "tool-demo",
        role: "assistant",
        author: "Duskmoon",
        status: "complete",
        content:
          "Tool calls stay attached to the assistant message and can be expanded on demand.",
        tools: [%{id: "latency", name: "Latency probe", status: "success", result: %{p95_ms: 48}}]
      }
    ]
  end

  defp long_conversation do
    Enum.map(1..12, fn index ->
      role = if rem(index, 2) == 0, do: "assistant", else: "user"
      author = if role == "assistant", do: "Duskmoon", else: "You"

      %{
        id: "seed-#{index}",
        role: role,
        author: author,
        status: "complete",
        content:
          "Seed message #{index}: a stable transcript lets you inspect scrolling and rendering performance."
      }
    end)
  end
end
