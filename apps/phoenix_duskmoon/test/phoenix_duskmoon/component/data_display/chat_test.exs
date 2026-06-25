defmodule PhoenixDuskmoon.Component.DataDisplay.ChatTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import Phoenix.Component
  import PhoenixDuskmoon.Component.DataDisplay.Chat

  test "renders chat message element" do
    result =
      render_component(&dm_chat/1, %{
        author: "Assistant",
        avatar: "AI",
        content: "Hello",
        color: "primary"
      })

    assert result =~ "<el-dm-chat"
    assert result =~ ~s[author="Assistant"]
    assert result =~ ~s[avatar="AI"]
    assert result =~ ~s[content="Hello"]
    assert result =~ ~s[color="primary"]
    assert result =~ "</el-dm-chat>"
  end

  test "renders chat message slots" do
    assigns = %{}

    result =
      rendered_to_string(~H"""
      <.dm_chat>
        <:avatar_slot><img src="/avatar.png" /></:avatar_slot>
        <:header>Assistant</:header>
        <:footer>Delivered</:footer>
        <:actions_slot><button>Copy</button></:actions_slot>
        Message body
      </.dm_chat>
      """)

    assert result =~ ~s[slot="avatar"]
    assert result =~ ~s[src="/avatar.png"]
    assert result =~ ~s[slot="header"]
    assert result =~ "Assistant"
    assert result =~ ~s[slot="footer"]
    assert result =~ "Delivered"
    assert result =~ ~s[slot="actions"]
    assert result =~ "Message body"
  end

  test "renders chat quick action event bridge" do
    result =
      render_component(&dm_chat/1, %{
        actions: "Copy, Regenerate",
        "duskmoon-send-quick-action": "chat_action"
      })

    assert result =~ ~s[actions="Copy, Regenerate"]
    assert result =~ ~s[duskmoon-send-quick-action="chat_action"]
    assert result =~ ~s[phx-hook="WebComponentHook"]
  end

  test "renders chat bubble" do
    result =
      render_component(&dm_chat_bubble/1, %{
        align: "end",
        variant: "filled",
        size: "sm",
        content: "Thanks"
      })

    assert result =~ "<el-dm-chat-bubble"
    assert result =~ ~s[align="end"]
    assert result =~ ~s[variant="filled"]
    assert result =~ ~s[size="sm"]
    assert result =~ ~s[content="Thanks"]
    assert result =~ "</el-dm-chat-bubble>"
  end

  test "renders chat input" do
    result =
      render_component(&dm_chat_input/1, %{
        name: "message",
        value: "Draft",
        placeholder: "Ask anything",
        send_label: "Send message",
        clear_on_send: true
      })

    assert result =~ "<el-dm-chat-input"
    assert result =~ ~s[name="message"]
    assert result =~ ~s[value="Draft"]
    assert result =~ ~s[placeholder="Ask anything"]
    assert result =~ ~s[send-label="Send message"]
    assert result =~ "clear-on-send"
  end

  test "renders chat input event bridge" do
    result =
      render_component(&dm_chat_input/1, %{
        "duskmoon-send-send": "send_message"
      })

    assert result =~ ~s[duskmoon-send-send="send_message"]
    assert result =~ ~s[phx-hook="WebComponentHook"]
  end

  test "renders chat input quick action event bridge" do
    result =
      render_component(&dm_chat_input/1, %{
        "duskmoon-send-quick-action": "steer_message"
      })

    assert result =~ ~s[duskmoon-send-quick-action="steer_message"]
    assert result =~ ~s[phx-hook="WebComponentHook"]
  end

  test "renders chat input from form field" do
    field = Phoenix.Component.to_form(%{"message" => "Hello"}, as: "chat")[:message]
    result = render_component(&dm_chat_input/1, %{field: field})

    assert result =~ ~s[id="chat_message"]
    assert result =~ ~s|name="chat[message]"|
    assert result =~ ~s[value="Hello"]
  end

  test "renders reasoning section" do
    assigns = %{}

    result =
      rendered_to_string(~H"""
      <.dm_chat_reasoning summary="Thoughts" open>
        <:tool><.dm_chat_tool name="search" status="running" /></:tool>
        Reasoning text
      </.dm_chat_reasoning>
      """)

    assert result =~ "<el-dm-chat-reasoning"
    assert result =~ ~s[summary="Thoughts"]
    assert result =~ "open"
    assert result =~ ~s[slot="tool"]
    assert result =~ "Reasoning text"
  end

  test "renders chat tool with slots" do
    assigns = %{}

    result =
      rendered_to_string(~H"""
      <.dm_chat_tool name="search" status="success" open>
        <:call>query: duskmoon</:call>
        <:result>Found docs</:result>
      </.dm_chat_tool>
      """)

    assert result =~ "<el-dm-chat-tool"
    assert result =~ ~s[name="search"]
    assert result =~ ~s[status="success"]
    assert result =~ "open"
    assert result =~ ~s[slot="call"]
    assert result =~ ~s[slot="result"]
    assert result =~ "Found docs"
  end

  test "renders typing indicator" do
    result = render_component(&dm_chat_typing/1, %{class: "text-primary"})

    assert result =~ "<el-dm-chat-typing"
    assert result =~ ~s[class="text-primary"]
    assert result =~ "</el-dm-chat-typing>"
  end
end
