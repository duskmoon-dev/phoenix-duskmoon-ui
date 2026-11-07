defmodule DuskmoonStorybookWeb.ReactComposerLiveTest do
  use DuskmoonStorybookWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  alias DuskmoonStorybookWeb.Components.ReactChatLive

  test "structured fixture keeps an independent ignored mount and portal", %{conn: conn} do
    {:ok, view, html} = live(conn, "/components/data-display/react-chat")

    assert has_element?(view, "#react-chat-demo[phx-update=ignore]")
    assert has_element?(view, "#react-structured-chat-demo[phx-update=ignore]")
    assert has_element?(view, "#react-chat-composer-portal[phx-update=ignore]")
    assert html =~ "no model"

    root = html |> LazyHTML.from_document() |> LazyHTML.query("#react-structured-chat-demo")
    [json] = LazyHTML.attribute(root, "data-chat")

    assert %{
             "protocolVersion" => 1,
             "composer" => %{"capabilities" => %{"durableRecovery" => false}}
           } = Jason.decode!(json)
  end

  test "prompt receipts preserve actual delivery, reference identity and fixture persistence" do
    params = submission("volatile")

    assert {:reply, %{request_id: "request-1", instanceGeneration: 1, receipt: receipt}, socket} =
             ReactChatLive.handle_event("chat.send", params, fixture_socket())

    assert %{
             outcome: "accepted",
             operation: "prompt",
             delivery: "immediate",
             persistence: "volatile",
             messageId: message_id
           } = receipt

    refute Map.has_key?(receipt, :turnId)
    assert [%{id: ^message_id}] = socket.assigns.fixture_messages
    assert socket.assigns.fixture_receipts["logical-1"].payload["document"] == params["document"]

    durable = submission("durable")

    assert {:reply, %{receipt: %{persistence: "durable"}}, _socket} =
             ReactChatLive.handle_event("chat.send", durable, fixture_socket())
  end

  test "same logical snapshot returns the original admission and changed content conflicts" do
    params = submission("volatile")

    assert {:reply, %{receipt: original}, socket} =
             ReactChatLive.handle_event("chat.send", params, fixture_socket())

    retry = Map.put(params, "request_id", "request-2")

    assert {:reply, %{request_id: "request-2", receipt: ^original}, socket} =
             ReactChatLive.handle_event("chat.send", retry, socket)

    assert [_message] = socket.assigns.fixture_messages

    edited = put_in(retry, ["document", "content"], [%{"type" => "text", "text" => "Edited"}])

    assert {:reply, %{receipt: %{outcome: "rejected", error: %{code: "identity_conflict"}}},
            socket} = ReactChatLive.handle_event("chat.send", edited, socket)

    assert [_message] = socket.assigns.fixture_messages
  end

  test "command result creates no prompt identities and explicit rejection admits nothing" do
    command = submission("volatile") |> Map.put("operation", "command") |> Map.delete("intent")

    command =
      Map.put(command, "document", %{
        "schemaVersion" => 1,
        "content" => [%{"type" => "text", "text" => "/reload-tools"}],
        "command" => %{"providerId" => "commands", "commandId" => "reload-tools"}
      })

    assert {:reply, %{receipt: receipt}, socket} =
             ReactChatLive.handle_event("chat.send", command, fixture_socket())

    assert %{
             outcome: "accepted",
             operation: "command",
             result: %{action: "reload-tools", reloaded: 2}
           } = receipt

    refute Enum.any?(
             [:messageId, :turnId, :queueItemId, :delivery, :persistence],
             &Map.has_key?(receipt, &1)
           )

    assert socket.assigns.fixture_messages == []

    assert {:reply, %{receipt: %{outcome: "rejected", error: %{code: "fixture_rejected"}}},
            socket} =
             ReactChatLive.handle_event("chat.send", submission("rejected"), fixture_socket())

    assert socket.assigns.fixture_messages == []
  end

  test "unknown admission reconciles without replay; missing evidence remains unknown" do
    params = submission("unknown")

    assert {:reply, %{receipt: %{outcome: "unknown"}}, socket} =
             ReactChatLive.handle_event("chat.send", params, fixture_socket())

    assert [message] = socket.assigns.fixture_messages
    query = %{params | "request_id" => "lookup-1"}

    assert {:reply, %{receipt: %{outcome: "accepted", messageId: message_id}}, socket} =
             ReactChatLive.handle_event("composer.reconcile", query, socket)

    assert message_id == message.id
    assert [^message] = socket.assigns.fixture_messages

    missing = %{query | "clientSubmissionId" => "missing"}

    assert {:reply, %{receipt: %{outcome: "unknown", error: %{code: "not_found"}}}, _socket} =
             ReactChatLive.handle_event("composer.reconcile", missing, socket)

    sync = Map.put(params, "unresolvedSubmissionIds", ["logical-1", "missing"])

    assert {:reply, %{status: "ok"}, socket} =
             ReactChatLive.handle_event("chat.sync", sync, socket)

    [["chat:event", snapshot] | _] = socket.private.live_temp.push_events
    assert snapshot.type == "chat.snapshot"

    assert snapshot.scope == %{
             contextKey: "storybook:composer:v1",
             conversationId: "react-structured-demo"
           }

    assert snapshot.instanceGeneration == 1
    assert snapshot.metadata == %{composerPortalId: "react-chat-composer-portal"}
    assert [%{outcome: "accepted", clientSubmissionId: "logical-1"}] = snapshot.receipts
  end

  test "queue revisions reject stale mutations and Stop leaves waiting items confirmed" do
    socket = fixture_socket()

    params =
      submission("volatile")
      |> Map.merge(%{
        "requestId" => "queue-1",
        "itemId" => "fixture-waiting-1",
        "expectedRevision" => 0,
        "operation" => "remove"
      })

    assert {:reply, %{result: %{outcome: "accepted", projection: %{revision: 1, items: []}}},
            socket} = ReactChatLive.handle_event("composer.queue.remove", params, socket)

    assert socket.assigns.fixture_messages == []

    assert {:reply,
            %{
              result: %{
                outcome: "rejected",
                error: %{code: "stale_revision"},
                projection: %{revision: 1}
              }
            }, _socket} = ReactChatLive.handle_event("composer.queue.remove", params, socket)

    assert {:reply, %{status: "ok"}, stopped} =
             ReactChatLive.handle_event("chat.stop", submission("volatile"), fixture_socket())

    assert stopped.assigns.fixture_runtime.active == false
    assert [%{id: "fixture-waiting-1"}] = stopped.assigns.fixture_composer.queue.items
  end

  test "reconnect restores projection and original unknown admission without replay" do
    socket_id = "composer-reconnect-#{System.unique_integer([:positive])}"
    params = Map.put(submission("unknown"), "intent", "follow_up")

    assert {:reply, %{receipt: %{outcome: "unknown"}}, socket} =
             ReactChatLive.handle_event("chat.send", params, fixture_socket(socket_id))

    original = socket.assigns.fixture_receipts["logical-1"].receipt
    composer = socket.assigns.fixture_composer
    assert composer.revision == 1
    assert composer.queue.revision == 1
    assert %{queueItemId: "fixture-queue-1", persistence: "volatile"} = original

    reconnected = fixture_socket(socket_id)
    assert reconnected.assigns.fixture_composer == composer

    sync = Map.put(params, "unresolvedSubmissionIds", ["logical-1"])

    assert {:reply, %{status: "ok"}, reconnected} =
             ReactChatLive.handle_event("chat.sync", sync, reconnected)

    [["chat:event", snapshot] | _] = reconnected.private.live_temp.push_events
    assert snapshot.composer == composer
    assert snapshot.receipts == [original]
    assert snapshot.messages == []

    assert {:reply, %{receipt: ^original}, reconnected} =
             ReactChatLive.handle_event("composer.reconcile", params, reconnected)

    assert reconnected.assigns.fixture_next_id == 1
    assert reconnected.assigns.fixture_composer == composer

    independent = fixture_socket(socket_id <> "-new-root")
    assert independent.assigns.fixture_receipts == %{}
    assert independent.assigns.fixture_composer.revision == 0
    assert independent.assigns.fixture_composer.queue.revision == 0
  end

  test "model options remain controlled by the server projection and expected revision" do
    params =
      submission("volatile")
      |> Map.merge(%{
        "requestId" => "setting-1",
        "scopeKey" => "fixture",
        "settingId" => "model",
        "expectedRevision" => 0,
        "value" => "fixture-large"
      })

    assert {:reply,
            %{status: "ok", result: %{outcome: "accepted", revision: 1, value: "fixture-large"}},
            socket} = ReactChatLive.handle_event("composer.configure", params, fixture_socket())

    assert socket.assigns.fixture_composer.options.model == "fixture-large"

    assert {:reply, %{result: %{outcome: "rejected", revision: 1}}, _socket} =
             ReactChatLive.handle_event("composer.configure", params, socket)
  end

  defp fixture_socket(id \\ nil) do
    {:ok, socket} =
      ReactChatLive.mount(%{}, %{}, %Phoenix.LiveView.Socket{id: id, private: %{live_temp: %{}}})

    socket
  end

  defp submission(scenario) do
    %{
      "id" => "react-structured-chat-demo",
      "conversation_id" => "react-structured-demo",
      "protocolVersion" => 1,
      "scope" => %{
        "contextKey" => "storybook:composer:v1",
        "conversationId" => "react-structured-demo"
      },
      "instanceGeneration" => 1,
      "request_id" => "request-1",
      "clientSubmissionId" => "logical-1",
      "draftKey" => "fixture-draft",
      "draftRevision" => 7,
      "operation" => "prompt",
      "intent" => "send",
      "document" => %{
        "schemaVersion" => 1,
        "content" => [
          %{"type" => "text", "text" => "Check "},
          %{
            "type" => "reference",
            "nodeId" => "reference-occurrence",
            "providerId" => "files",
            "refId" => "README.md",
            "label" => "README.md",
            "plainText" => "@README.md"
          }
        ]
      },
      "attachments" => [],
      "options" => %{"model" => "fixture-small", "scenario" => scenario}
    }
  end
end
