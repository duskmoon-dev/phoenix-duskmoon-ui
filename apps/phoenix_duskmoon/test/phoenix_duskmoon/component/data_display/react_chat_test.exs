defmodule PhoenixDuskmoon.Component.DataDisplay.ReactChatTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataDisplay.ReactChat

  test "renders an ignored React mount with conversation protocol data" do
    html =
      render_component(&dm_react_chat/1,
        id: "chat",
        conversation_id: "conv-1",
        messages: [%{id: "m1", role: "user", content: "Hi"}]
      )

    document = LazyHTML.from_fragment(html)

    assert LazyHTML.attribute(LazyHTML.query(document, "#chat"), "phx-hook") == [
             "DuskmoonReactChat"
           ]

    assert LazyHTML.attribute(LazyHTML.query(document, "#chat"), "phx-update") == ["ignore"]
    [json] = LazyHTML.attribute(LazyHTML.query(document, "#chat"), "data-chat")

    assert %{"conversationId" => "conv-1", "messages" => [%{"id" => "m1"}], "actions" => actions} =
             Jason.decode!(json)

    assert actions["send"] == "chat.send"
  end

  test "serializes custom hook and application runtime/admission maps" do
    html =
      render_component(&dm_react_chat/1,
        id: "composed",
        conversation_id: "conv-1",
        hook: "ApplicationChat",
        metadata: %{session: "s1"},
        runtime: %{active: true, phase: "tool_execution"},
        admission: %{allowWhileStreaming: true},
        target: "#component"
      )

    root = html |> LazyHTML.from_fragment() |> LazyHTML.query("#composed")
    assert LazyHTML.attribute(root, "phx-hook") == ["ApplicationChat"]
    assert LazyHTML.attribute(root, "data-target") == ["#component"]
    [json] = LazyHTML.attribute(root, "data-chat")
    snapshot = Jason.decode!(json)
    assert snapshot["metadata"] == %{"session" => "s1"}
    assert snapshot["runtime"] == %{"active" => true, "phase" => "tool_execution"}
    assert snapshot["admission"] == %{"allowWhileStreaming" => true}
  end

  test "structured composer is explicit and preserves opaque scope and action mappings" do
    projection = %{
      revision: 3,
      capabilities: %{protocolVersion: 1, documentVersions: [1], intents: ["send"]},
      providers: [%{providerId: "files", label: "Files"}],
      queue: %{
        protocolVersion: 1,
        scope: %{contextKey: "repo:你好", conversationId: "conv-1"},
        revision: 2,
        items: []
      }
    }

    html =
      render_component(&dm_react_chat/1,
        id: "structured",
        conversation_id: "conv-1",
        context_key: "repo:你好",
        protocol_version: 1,
        composer: projection,
        actions: %{
          send: "application.submit",
          reconcile: "application.lookup",
          queue_remove: "application.remove"
        }
      )

    root = html |> LazyHTML.from_fragment() |> LazyHTML.query("#structured")
    [json] = LazyHTML.attribute(root, "data-chat")
    snapshot = Jason.decode!(json)
    assert snapshot["protocolVersion"] == 1
    assert snapshot["scope"] == %{"conversationId" => "conv-1", "contextKey" => "repo:你好"}
    assert snapshot["composer"] == Jason.decode!(Jason.encode!(projection))
    assert snapshot["actions"]["send"] == "application.submit"
    assert snapshot["actions"]["reconcile"] == "application.lookup"
    assert snapshot["actions"]["stop"] == "chat.stop"
    assert snapshot["actions"]["queue_remove"] == "application.remove"
  end
end
