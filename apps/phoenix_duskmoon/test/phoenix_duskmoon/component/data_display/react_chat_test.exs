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
end
