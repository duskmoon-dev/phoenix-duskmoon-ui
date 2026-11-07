defmodule DuskmoonStorybookWeb.Components.ReactChatLive do
  @moduledoc "Interactive UI demo for the React-owned streaming chat."

  use DuskmoonStorybookWeb, :live_view

  @chat_id "react-chat-demo"
  @conversation_id "react-demo"
  @stream_interval 80
  @fixture_fields [
    :fixture_composer,
    :fixture_runtime,
    :fixture_messages,
    :fixture_receipts,
    :fixture_next_id
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       active_menu: "data-display-react-chat",
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
       last_event: "Initial snapshot",
       fixture_composer: fixture_composer(),
       fixture_runtime: %{active: true, phase: "fixture_running", activeTurnId: "fixture-turn"},
       fixture_messages: [],
       fixture_receipts: %{},
       fixture_next_id: 0
     )
     |> restore_fixture()}
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

      <section class="card mt-8 border border-base-300 bg-base-100 shadow-sm">
        <div class="card-body gap-4 p-4 md:p-6">
          <h2 class="text-2xl font-semibold">Structured composer and recovery fixtures</h2>
          <p class="text-sm opacity-70">
            A second independent mount keeps its single React root and places its composer
            in the ignored portal below. Load the optional rich editor for atomic references,
            quotes, and @file or /command suggestions. The fixture turn is simulated; no model
            is executed. Switch admission scenarios to inspect explicit receipts and edit while pending.
            Reconnect retains this fixture in server memory for up to 30 idle minutes and
            128 sessions. Reload, expiry, eviction, or server restart can reset it; the durable
            receipt scenario is simulated.
          </p>
          <.dm_react_chat
            id="react-structured-chat-demo"
            conversation_id="react-structured-demo"
            context_key="storybook:composer:v1"
            metadata={%{composerPortalId: "react-chat-composer-portal"}}
            protocol_version={1}
            composer={@fixture_composer}
            runtime={@fixture_runtime}
            admission={%{allowWhileStreaming: true}}
            actions={
              %{
                reconcile: "composer.reconcile",
                configure: "composer.configure",
                queue_edit: "composer.queue.edit",
                queue_remove: "composer.queue.remove",
                queue_promote: "composer.queue.promote"
              }
            }
            messages={@fixture_messages}
            hook="DuskmoonComposedChat"
            label="Structured fixture transcript"
            class="h-64 min-h-0 overflow-auto rounded-lg bg-base-200/50 p-3"
          />
          <div id="react-chat-composer-portal" phx-update="ignore" class="flex flex-col gap-4"></div>
        </div>
      </section>
    </div>
    """
  end

  @impl true
  def handle_event("chat.send", %{"id" => "react-structured-chat-demo"} = params, socket) do
    {receipt, socket} = fixture_submit(socket, params)
    {:reply, fixture_response(params, receipt), retain_fixture(socket)}
  end

  def handle_event("composer.reconcile", %{"id" => "react-structured-chat-demo"} = params, socket) do
    receipt =
      if fixture_valid_scope?(params) do
        case socket.assigns.fixture_receipts[params["clientSubmissionId"]] do
          %{receipt: receipt} ->
            receipt

          nil ->
            fixture_receipt(params, "unknown", %{
              error: %{
                code: "not_found",
                message: "No definitive evidence; absence does not authorize replay"
              }
            })
        end
      else
        fixture_error(params, "scope_mismatch", "The fixture scope is incompatible")
      end

    {:reply, fixture_response(params, receipt), socket}
  end

  def handle_event("chat.sync", %{"id" => "react-structured-chat-demo"} = params, socket) do
    if fixture_valid_scope?(params) do
      {:reply, %{status: "ok"}, fixture_snapshot(socket, params)}
    else
      {:reply, %{status: "error", message: "The fixture scope is incompatible"}, socket}
    end
  end

  def handle_event("chat.stop", %{"id" => "react-structured-chat-demo"} = params, socket) do
    if fixture_valid_scope?(params) do
      socket =
        assign(socket,
          fixture_runtime: %{
            socket.assigns.fixture_runtime
            | active: false,
              phase: "fixture_cancelled"
          }
        )

      {:reply, %{status: "ok"},
       socket
       |> fixture_projection(params, socket.assigns.fixture_composer)
       |> retain_fixture()}
    else
      {:reply, %{status: "error", message: "The fixture scope is incompatible"}, socket}
    end
  end

  def handle_event("composer.configure", %{"id" => "react-structured-chat-demo"} = params, socket) do
    composer = socket.assigns.fixture_composer

    valid =
      fixture_valid_scope?(params) and params["expectedRevision"] == composer.revision and
        params["settingId"] == "model" and params["value"] in ["fixture-small", "fixture-large"]

    {result, socket} =
      if valid do
        socket =
          fixture_projection(socket, params, %{composer | options: %{model: params["value"]}})

        {%{
           outcome: "accepted",
           value: params["value"],
           revision: socket.assigns.fixture_composer.revision
         }, socket}
      else
        {%{
           outcome: "rejected",
           message: "Fixture setting or expected revision is invalid",
           revision: composer.revision
         }, socket}
      end

    result =
      Map.merge(result, %{
        requestId: params["requestId"],
        scopeKey: params["scopeKey"],
        settingId: params["settingId"]
      })

    {:reply, %{status: "ok", result: result}, retain_fixture(socket)}
  end

  def handle_event(
        "composer.queue." <> operation,
        %{"id" => "react-structured-chat-demo"} = params,
        socket
      )
      when operation in ["edit", "remove", "promote"] do
    {result, socket} = fixture_queue(socket, params, operation)

    {:reply,
     %{
       request_id: params["request_id"],
       instanceGeneration: params["instanceGeneration"],
       result: result
     }, retain_fixture(socket)}
  end

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

  # This is an in-memory protocol fixture, not a persistence or execution service.
  defp restore_fixture(socket) do
    case DuskmoonStorybook.ComposerFixtureStore.get(socket.id) do
      nil -> socket
      fixture -> assign(socket, fixture)
    end
  end

  defp retain_fixture(socket) do
    DuskmoonStorybook.ComposerFixtureStore.put(
      socket.id,
      Map.take(socket.assigns, @fixture_fields)
    )

    socket
  end

  defp fixture_scope do
    %{contextKey: "storybook:composer:v1", conversationId: "react-structured-demo"}
  end

  defp fixture_composer do
    %{
      revision: 0,
      capabilities: %{
        protocolVersion: 1,
        documentVersions: [1],
        intents: ["send", "follow_up", "steer"],
        commands: true,
        attachments: true,
        queue: %{edit: "text", remove: true, promote: true},
        durableRecovery: false
      },
      providers: [%{providerId: "files"}, %{providerId: "commands"}],
      options: %{model: "fixture-small"},
      queue: %{
        protocolVersion: 1,
        scope: fixture_scope(),
        revision: 0,
        items: [
          %{
            id: "fixture-waiting-1",
            document: %{
              schemaVersion: 1,
              content: [%{type: "text", text: "A confirmed fixture follow-up"}]
            },
            attachments: [],
            capabilities: %{edit: "text", remove: true, promote: true}
          }
        ]
      }
    }
  end

  defp fixture_valid_scope?(params) do
    params["protocolVersion"] == 1 and
      params["scope"] == %{
        "contextKey" => "storybook:composer:v1",
        "conversationId" => "react-structured-demo"
      } and is_integer(params["instanceGeneration"]) and params["instanceGeneration"] > 0
  end

  defp fixture_receipt(params, outcome, extra) do
    Map.merge(
      %{
        protocolVersion: 1,
        clientSubmissionId: params["clientSubmissionId"],
        scope: fixture_scope(),
        operation: params["operation"],
        outcome: outcome
      },
      extra
    )
  end

  defp fixture_error(params, code, message) do
    fixture_receipt(params, "rejected", %{error: %{code: code, message: message}})
  end

  defp fixture_response(params, receipt) do
    %{
      request_id: params["request_id"],
      instanceGeneration: params["instanceGeneration"],
      receipt: receipt
    }
  end

  defp fixture_payload(params) do
    Map.drop(params, ["request_id", "instanceGeneration", "id", "conversation_id"])
  end

  defp fixture_submit(socket, params) do
    id = params["clientSubmissionId"]
    existing = socket.assigns.fixture_receipts[id]

    {receipt, socket} =
      cond do
        not fixture_valid_scope?(params) ->
          {fixture_error(
             params,
             "scope_mismatch",
             "The fixture scope or protocol is incompatible"
           ), socket}

        not is_binary(id) or id == "" ->
          {fixture_error(params, "invalid_identity", "A logical submission identity is required"),
           socket}

        existing && existing.payload != fixture_payload(params) ->
          {fixture_error(
             params,
             "identity_conflict",
             "The logical ID already belongs to another snapshot"
           ), socket}

        existing ->
          {existing.receipt, socket}

        not fixture_document?(params["document"]) ->
          {fixture_error(params, "unsupported_document", "Only ComposerDocument v1 is supported"),
           socket}

        params["attachments"] != [] ->
          {fixture_error(params, "upload_unavailable", "This fixture has no upload transport"),
           socket}

        not is_map(params["options"]) ->
          {fixture_error(params, "invalid_options", "Fixture options must be a JSON object"),
           socket}

        params["options"]["model"] not in ["fixture-small", "fixture-large"] ->
          {fixture_error(params, "unsupported_model", "Select a fixture model"), socket}

        params["options"]["scenario"] == "rejected" ->
          {fixture_error(
             params,
             "fixture_rejected",
             "Explicit fixture rejection; draft is retained"
           ), socket}

        params["operation"] == "command" ->
          fixture_command(socket, params)

        params["operation"] == "prompt" ->
          fixture_prompt(socket, params)

        true ->
          {fixture_error(params, "unsupported_operation", "Choose prompt or command"), socket}
      end

    if is_binary(id) and id != "" and fixture_valid_scope?(params) and
         not Map.has_key?(socket.assigns.fixture_receipts, id) do
      record = %{payload: fixture_payload(params), receipt: receipt}

      {receipt,
       assign(socket, fixture_receipts: Map.put(socket.assigns.fixture_receipts, id, record))}
    else
      {receipt, socket}
    end
  end

  defp fixture_command(socket, params) do
    if params["document"]["command"] == %{
         "providerId" => "commands",
         "commandId" => "reload-tools"
       } do
      receipt =
        fixture_receipt(params, "accepted", %{result: %{action: "reload-tools", reloaded: 2}})

      fixture_retain(socket, params, receipt)
    else
      {fixture_error(
         params,
         "unknown_command",
         "The fixture catalog does not contain that command"
       ), socket}
    end
  end

  defp fixture_prompt(socket, params) do
    intent = params["intent"]
    runtime = socket.assigns.fixture_runtime

    cond do
      params["document"]["command"] != nil ->
        {fixture_error(
           params,
           "command_operation",
           "The fixture catalog requires a command operation"
         ), socket}

      intent not in ["send", "follow_up", "steer"] ->
        {fixture_error(params, "unsupported_intent", "The fixture does not support this intent"),
         socket}

      intent == "steer" and (not runtime.active or params["targetTurnId"] != runtime.activeTurnId) ->
        {fixture_error(params, "stale_turn", "Steering must target the current fixture turn"),
         socket}

      true ->
        next_id = socket.assigns.fixture_next_id + 1
        message_id = "fixture-message-#{next_id}"

        persistence =
          if params["options"]["scenario"] == "durable", do: "durable", else: "volatile"

        delivery = if intent == "send", do: "immediate", else: intent
        fields = %{delivery: delivery, persistence: persistence}
        socket = assign(socket, fixture_next_id: next_id)

        {fields, socket} =
          if intent == "follow_up" do
            item = %{
              id: "fixture-queue-#{next_id}",
              document: params["document"],
              attachments: [],
              capabilities: %{edit: "text", remove: true, promote: true}
            }

            queue = socket.assigns.fixture_composer.queue
            queue = %{queue | revision: queue.revision + 1, items: queue.items ++ [item]}

            {%{fields | delivery: "follow_up"}
             |> Map.merge(%{queueItemId: item.id, queueRevision: queue.revision}),
             fixture_projection(socket, params, %{socket.assigns.fixture_composer | queue: queue})}
          else
            message = %{
              id: message_id,
              role: "user",
              content: fixture_text(params["document"]),
              status: "complete"
            }

            socket =
              assign(socket, fixture_messages: socket.assigns.fixture_messages ++ [message])

            {%{fields | delivery: delivery} |> Map.put(:messageId, message_id),
             fixture_snapshot(socket, params)}
          end

        fixture_retain(socket, params, fixture_receipt(params, "accepted", fields))
    end
  end

  defp fixture_retain(socket, params, receipt) do
    record = %{payload: fixture_payload(params), receipt: receipt}

    socket =
      assign(socket,
        fixture_receipts:
          Map.put(socket.assigns.fixture_receipts, params["clientSubmissionId"], record)
      )

    if params["options"]["scenario"] == "unknown" do
      unknown =
        fixture_receipt(params, "unknown", %{
          error: %{
            code: "fixture_reply_lost",
            message: "Admission evidence was withheld; reconcile before retrying"
          }
        })

      {unknown, socket}
    else
      {receipt, socket}
    end
  end

  defp fixture_text(document) do
    Enum.map_join(document["content"] || [], fn
      %{"type" => "text", "text" => text} -> text
      %{"type" => "reference", "plainText" => text} -> text
      %{"type" => "quote", "text" => text} -> "\n> " <> text
    end)
  end

  defp fixture_envelope(params) do
    %{
      id: "react-structured-chat-demo",
      conversation_id: "react-structured-demo",
      protocolVersion: 1,
      scope: fixture_scope(),
      instanceGeneration: params["instanceGeneration"]
    }
  end

  defp fixture_snapshot(socket, params) do
    receipts =
      Enum.flat_map(params["unresolvedSubmissionIds"] || [], fn id ->
        case socket.assigns.fixture_receipts[id] do
          nil -> []
          record -> [record.receipt]
        end
      end)

    event =
      Map.merge(fixture_envelope(params), %{
        type: "chat.snapshot",
        messages: socket.assigns.fixture_messages,
        sequences: %{},
        composer: socket.assigns.fixture_composer,
        metadata: %{composerPortalId: "react-chat-composer-portal"},
        runtime: socket.assigns.fixture_runtime,
        admission: %{allowWhileStreaming: true},
        receipts: receipts
      })

    push_event(socket, "chat:event", event)
  end

  defp fixture_projection(socket, params, composer) do
    composer = %{composer | revision: socket.assigns.fixture_composer.revision + 1}
    socket = assign(socket, fixture_composer: composer)

    event =
      Map.merge(fixture_envelope(params), %{
        type: "chat.composer-state",
        composer: composer,
        runtime: socket.assigns.fixture_runtime,
        admission: %{allowWhileStreaming: true}
      })

    push_event(socket, "chat:event", event)
  end

  defp fixture_queue(socket, params, operation) do
    composer = socket.assigns.fixture_composer
    queue = composer.queue
    item = Enum.find(queue.items, &(&1.id == params["itemId"]))

    error =
      cond do
        not fixture_valid_scope?(params) ->
          %{code: "scope_mismatch", message: "The fixture scope is incompatible"}

        params["operation"] != operation ->
          %{
            code: "operation_mismatch",
            message: "The queue action mapping does not match the requested operation"
          }

        params["expectedRevision"] != queue.revision ->
          %{code: "stale_revision", message: "Queue changed; use its authoritative projection"}

        is_nil(item) ->
          %{
            code: "missing_item",
            message: "The fixture queue item was already consumed or removed"
          }

        operation == "promote" and
            (not socket.assigns.fixture_runtime.active or
               params["targetTurnId"] != socket.assigns.fixture_runtime.activeTurnId) ->
          %{code: "stale_turn", message: "Promotion must target the current fixture turn"}

        operation == "edit" and not fixture_text_document?(params["document"]) ->
          %{code: "text_only", message: "Fixture queue editing supports text only"}

        true ->
          nil
      end

    if error do
      {%{requestId: params["requestId"], outcome: "rejected", error: error, projection: queue},
       socket}
    else
      items =
        if operation == "edit" do
          Enum.map(queue.items, fn candidate ->
            if candidate.id == item.id,
              do: %{candidate | document: params["document"]},
              else: candidate
          end)
        else
          Enum.reject(queue.items, &(&1.id == item.id))
        end

      queue = %{queue | revision: queue.revision + 1, items: items}
      socket = fixture_projection(socket, params, %{composer | queue: queue})
      {%{requestId: params["requestId"], outcome: "accepted", projection: queue}, socket}
    end
  end

  defp fixture_document?(%{"schemaVersion" => 1, "content" => content}) when is_list(content) do
    Enum.all?(content, fn
      %{"type" => "text", "text" => text} ->
        is_binary(text)

      %{"type" => "quote", "nodeId" => id, "text" => text} ->
        is_binary(id) and is_binary(text)

      %{"type" => "reference"} = node ->
        Enum.all?(["nodeId", "providerId", "refId", "label", "plainText"], &is_binary(node[&1]))

      _node ->
        false
    end)
  end

  defp fixture_document?(_document), do: false

  defp fixture_text_document?(%{"schemaVersion" => 1, "content" => content})
       when is_list(content),
       do:
         Enum.all?(content, &match?(%{"type" => "text", "text" => text} when is_binary(text), &1))

  defp fixture_text_document?(_document), do: false
end
