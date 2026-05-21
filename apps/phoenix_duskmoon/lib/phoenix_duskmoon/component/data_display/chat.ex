defmodule PhoenixDuskmoon.Component.DataDisplay.Chat do
  @moduledoc """
  Chat primitives for LLM-oriented conversations.

  Wraps the custom elements provided by `@duskmoon-dev/el-chat`.

  Requires `@duskmoon-dev/el-chat` registered in your project:

  ```js
  import "@duskmoon-dev/el-chat/register";
  ```
  """

  use Phoenix.Component

  @bubble_colors [nil, "primary", "secondary", "tertiary", "info", "success", "warning", "error"]
  @bubble_sizes [nil, "xs", "sm", "md", "lg"]
  @bubble_variants [nil, "tonal", "filled"]

  @doc """
  Renders a full chat message with optional avatar, metadata, actions, and markdown content.

  ## Examples

      <.dm_chat author="Assistant" avatar="AI" color="primary" content="Hello." />

      <.dm_chat align="end" author="You" avatar="JG" variant="filled">
        Hello from a slot.
      </.dm_chat>
  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:align, :string, default: "start", values: ["start", "end"], doc: "message alignment")
  attr(:color, :string, default: nil, values: @bubble_colors, doc: "bubble color")
  attr(:size, :string, default: nil, values: @bubble_sizes, doc: "bubble size")
  attr(:variant, :string, default: nil, values: @bubble_variants, doc: "bubble variant")
  attr(:streaming, :boolean, default: false, doc: "render the bubble in streaming state")
  attr(:avatar, :string, default: nil, doc: "avatar text")
  attr(:author, :string, default: nil, doc: "message author")
  attr(:time, :string, default: nil, doc: "message timestamp")
  attr(:status, :string, default: nil, doc: "delivery/status text")
  attr(:actions, :string, default: nil, doc: "comma-separated quick action labels")
  attr(:content, :string, default: nil, doc: "markdown message content")

  attr(:rest, :global,
    include: ~w[duskmoon-send-quick-action duskmoon-receive],
    doc: "additional HTML attributes"
  )

  slot(:inner_block, doc: "message content when `content` is not set")
  slot(:avatar_slot, doc: "custom avatar content")
  slot(:header, doc: "custom header content")
  slot(:footer, doc: "custom footer content")
  slot(:actions_slot, doc: "custom actions content")

  def dm_chat(assigns) do
    assigns = assign(assigns, :hook, web_component_hook(assigns.rest))

    ~H"""
    <el-dm-chat
      id={@id}
      align={@align}
      color={@color}
      size={@size}
      variant={@variant}
      streaming={@streaming}
      avatar={@avatar}
      author={@author}
      time={@time}
      status={@status}
      actions={@actions}
      content={@content}
      class={@class}
      phx-hook={@hook}
      {@rest}
    >
      <span :for={avatar <- @avatar_slot} slot="avatar">{render_slot(avatar)}</span>
      <span :for={header <- @header} slot="header">{render_slot(header)}</span>
      <span :for={footer <- @footer} slot="footer">{render_slot(footer)}</span>
      <span :for={actions <- @actions_slot} slot="actions">{render_slot(actions)}</span>
      {render_slot(@inner_block)}
    </el-dm-chat>
    """
  end

  @doc """
  Renders a chat bubble without avatar or metadata.
  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:align, :string, default: "start", values: ["start", "end"], doc: "bubble alignment")
  attr(:color, :string, default: nil, values: @bubble_colors, doc: "bubble color")
  attr(:size, :string, default: nil, values: @bubble_sizes, doc: "bubble size")
  attr(:variant, :string, default: nil, values: @bubble_variants, doc: "bubble variant")
  attr(:streaming, :boolean, default: false, doc: "render the bubble in streaming state")
  attr(:content, :string, default: nil, doc: "markdown bubble content")
  attr(:rest, :global, doc: "additional HTML attributes")

  slot(:inner_block, doc: "bubble content when `content` is not set")

  def dm_chat_bubble(assigns) do
    ~H"""
    <el-dm-chat-bubble
      id={@id}
      align={@align}
      color={@color}
      size={@size}
      variant={@variant}
      streaming={@streaming}
      content={@content}
      class={@class}
      {@rest}
    >{render_slot(@inner_block)}</el-dm-chat-bubble>
    """
  end

  @doc """
  Renders a markdown chat input that emits `send` events from the custom element.
  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:name, :any, default: nil, doc: "HTML name attribute for form submission")
  attr(:value, :any, default: nil, doc: "initial editor content")
  attr(:field, Phoenix.HTML.FormField, doc: "form field used to set id/name/value")
  attr(:placeholder, :string, default: nil, doc: "input placeholder")
  attr(:disabled, :boolean, default: false, doc: "disable the input")
  attr(:readonly, :boolean, default: false, doc: "make the input read-only")
  attr(:send_label, :string, default: "Send", doc: "send button label")
  attr(:clear_on_send, :boolean, default: false, doc: "clear the editor after send")
  attr(:class, :any, default: nil, doc: "additional CSS classes")

  attr(:rest, :global,
    include: ~w[duskmoon-send-send duskmoon-receive duskmoon-receive-reset],
    doc: "additional HTML attributes"
  )

  def dm_chat_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:name, field.name)
    |> assign(:value, field.value)
    |> dm_chat_input()
  end

  def dm_chat_input(assigns) do
    assigns = assign(assigns, :hook, web_component_hook(assigns.rest))

    ~H"""
    <el-dm-chat-input
      id={@id}
      name={@name}
      value={@value}
      placeholder={@placeholder}
      disabled={@disabled}
      readonly={@readonly}
      send-label={@send_label}
      clear-on-send={@clear_on_send}
      class={@class}
      phx-hook={@hook}
      {@rest}
    />
    """
  end

  @doc """
  Renders a collapsible reasoning section for assistant messages.
  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:summary, :string, default: "Reasoning", doc: "summary label")
  attr(:open, :boolean, default: false, doc: "render the section open")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:rest, :global, doc: "additional HTML attributes")

  slot(:inner_block, doc: "reasoning content")
  slot(:summary_slot, doc: "custom summary content")
  slot(:tool, doc: "tool content")
  slot(:tools, doc: "tools content")

  def dm_chat_reasoning(assigns) do
    ~H"""
    <el-dm-chat-reasoning
      id={@id}
      summary={@summary}
      open={@open}
      class={@class}
      {@rest}
    >
      <span :for={summary <- @summary_slot} slot="summary">{render_slot(summary)}</span>
      <span :for={tool <- @tool} slot="tool">{render_slot(tool)}</span>
      <span :for={tools <- @tools} slot="tools">{render_slot(tools)}</span>
      {render_slot(@inner_block)}
    </el-dm-chat-reasoning>
    """
  end

  @doc """
  Renders a chat tool call/result block.
  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:name, :string, default: nil, doc: "tool name")

  attr(:status, :string,
    default: "pending",
    values: ~w[pending running success error],
    doc: "tool status"
  )

  attr(:open, :boolean, default: false, doc: "render the tool details open")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:rest, :global, doc: "additional HTML attributes")

  slot(:inner_block, doc: "tool body content")
  slot(:name_slot, doc: "custom tool name content")
  slot(:call, doc: "tool call content")
  slot(:result, doc: "tool result content")

  def dm_chat_tool(assigns) do
    ~H"""
    <el-dm-chat-tool
      id={@id}
      name={@name}
      status={@status}
      open={@open}
      class={@class}
      {@rest}
    >
      <span :for={name <- @name_slot} slot="name">{render_slot(name)}</span>
      <div :for={call <- @call} slot="call">{render_slot(call)}</div>
      <div :for={result <- @result} slot="result">{render_slot(result)}</div>
      {render_slot(@inner_block)}
    </el-dm-chat-tool>
    """
  end

  @doc """
  Renders a typing indicator.
  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:rest, :global, doc: "additional HTML attributes")

  def dm_chat_typing(assigns) do
    ~H"""
    <el-dm-chat-typing id={@id} class={@class} {@rest}></el-dm-chat-typing>
    """
  end

  defp web_component_hook(rest) do
    if rest_value(rest, "duskmoon-send-send") || rest_value(rest, "duskmoon-send-quick-action") ||
         rest_value(rest, "duskmoon-receive") || rest_value(rest, "duskmoon-receive-reset"),
       do: "WebComponentHook"
  end

  defp rest_value(rest, key), do: rest[key] || rest[String.to_atom(key)]
end
