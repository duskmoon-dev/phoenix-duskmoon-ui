defmodule PhoenixDuskmoon.Component.DataDisplay.List do
  @moduledoc """
  List component using CSS classes from `@duskmoon-dev/core`.

  Renders structured lists with items that can include icons, titles,
  subtitles, and action slots. Supports bordered, compact, dense,
  hoverable, and multi-line layouts.

  ## Examples

      <.dm_list>
        <:item title="Profile" icon="account">View your profile</:item>
        <:item title="Settings" icon="cog">App settings</:item>
      </.dm_list>

      <.dm_list bordered hoverable>
        <:item title="Inbox" subtitle="3 new messages" active />
        <:item title="Sent" subtitle="No new messages" />
      </.dm_list>

  """
  use Phoenix.Component

  import PhoenixDuskmoon.Component.Icon.Icons

  @doc """
  Renders a list container with items.

  ## Examples

      <.dm_list compact>
        <:item title="Item 1" />
        <:item title="Item 2" />
      </.dm_list>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:bordered, :boolean, default: false, doc: "add border and item separators")
  attr(:compact, :boolean, default: false, doc: "compact spacing")
  attr(:dense, :boolean, default: false, doc: "dense spacing (smaller than compact)")
  attr(:hoverable, :boolean, default: false, doc: "show hover effects on items")
  attr(:two_line, :boolean, default: false, doc: "two-line layout for title + subtitle")
  attr(:three_line, :boolean, default: false, doc: "three-line layout for longer content")
  attr(:rest, :global)

  slot :item, required: true, doc: "List items" do
    attr(:title, :string)
    attr(:subtitle, :string)
    attr(:icon, :string)
    attr(:active, :boolean)
    attr(:disabled, :boolean)
    attr(:interactive, :boolean)
    attr(:class, :any)
  end

  slot(:subheader, doc: "Optional section header")

  def dm_list(assigns) do
    ~H"""
    <ul
      id={@id}
      class={[
        "list",
        @bordered && "list-bordered",
        @compact && "list-compact",
        @dense && "list-dense",
        @hoverable && "list-hoverable",
        @two_line && "list-two-line",
        @three_line && "list-three-line",
        @class
      ]}
      {@rest}
    >
      <li :for={sh <- @subheader} class="list-subheader">
        {render_slot(sh)}
      </li>
      <li
        :for={item <- @item}
        class={[
          "list-item",
          item[:active] && "list-item-active",
          item[:disabled] && "list-item-disabled",
          item[:interactive] && "list-item-interactive",
          item[:class]
        ]}
        aria-disabled={item[:disabled] && "true"}
      >
        <span :if={item[:icon]} class="list-item-icon">
          <.dm_mdi name={item[:icon]} class="w-6 h-6" />
        </span>
        <div class="list-item-content">
          <div :if={item[:title]} class="list-item-title">{item[:title]}</div>
          <div :if={item[:subtitle]} class="list-item-subtitle">{item[:subtitle]}</div>
          {render_slot(item)}
        </div>
      </li>
    </ul>
    """
  end
end
