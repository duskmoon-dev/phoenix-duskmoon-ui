defmodule PhoenixDuskmoon.Component.Tab do
  @moduledoc """
  Duskmoon UI Tab Component
  """
  use PhoenixDuskmoon.Component, :html

  @doc """
  Generates tabs
  ## Example
      <.dm_tab active_tab_index={0}>
        <:tab>Menu1</:tab>
        <:tab>Menu2</:tab>
        <:tab_content>Menu1 Content</:tab_content>
        <:tab_content>Menu2 Content</:tab_content>
      </.dm_tab>
  """
  @doc type: :component
  attr(:id, :any,
    default: false,
    doc: """
    html attribute id
    """
  )

  attr(:class, :any,
    default: "",
    doc: """
    html attribute class
    """
  )

  attr(:header_class, :any,
    default: "",
    doc: """
    header html attribute class
    """
  )

  attr(:orientation, :string,
    default: "horizontal",
    values: ["horizontal", "vertical"],
    doc: """
    header html attribute class
    """
  )

  attr(:active_tab_index, :integer,
    default: 0,
    doc: """
    the index of active tab, if active_tab_name is not set, this will be used
    """
  )

  attr(:active_tab_name, :string,
    default: "",
    doc: """
    the name of active tab, use for match tab and tab_content
    """
  )

  attr(:variant, :string,
    default: nil,
    doc: "tab style variant (lifted, bordered, boxed)"
  )

  attr(:size, :string,
    default: nil,
    doc: "tab size (xs, sm, lg)"
  )

  attr(:content_class, :any,
    default: "",
    doc: """
    tab_content html attribute class
    """
  )

  slot(:tab,
    required: false,
    doc: """
    Render tab
    """
  ) do
    attr(:id, :any)
    attr(:class, :any)
    attr(:name, :string)
  end

  slot(:tab_content,
    required: false,
    doc: """
    Render tab content
    """
  ) do
    attr(:id, :any)
    attr(:class, :any)
    attr(:name, :string)
  end

  def dm_tab(assigns) do
    ~H"""
    <section
      id={@id}
      class={[
        "tabs",
        @variant && "tabs-#{@variant}",
        @size && "tabs-#{@size}",
        if(@orientation == "horizontal", do: "tabs-lifted", else: "tabs-vertical"),
        @class
      ]}
    >
      <div
        class={[
          "flex justify-start items-center gap-2 sticky top-0",
          if(@orientation == "horizontal", do: "flex-row", else: "flex-col"),
          @header_class
        ]}
      >
        <%= for {tab, i} <- Enum.with_index(@tab) do %>
          <a
            id={Map.get(tab, :id, false)}
            class={[
              "tab",
              Map.get(tab, :class, ""),
              if(@active_tab_name != "",
                do: if(@active_tab_name == Map.get(tab, :name, ""),
                  do: "tab-active",
                  else: ""),
                else: if(@active_tab_index == i,
                  do: "tab-active",
                  else: ""))
            ]}
            phx-click={Map.get(tab, :phx_click, nil)}
          >
            <%= render_slot(tab) %>
          </a>
        <% end %>
      </div>
      <%= for {tab_content, i} <- Enum.with_index(@tab_content) do %>
        <%= if @active_tab_name != "" do %>
          <%= if @active_tab_name == Map.get(tab_content, :name, "") do %>
            <div id={Map.get(tab_content, :id, false)} class={["tab-content", Map.get(tab_content, :class, "")]}>
            <%= render_slot(tab_content) %>
            </div>
          <% end %>
        <% else %>
          <%= if @active_tab_index == i do %>
            <div id={Map.get(tab_content, :id, false)} class={["tab-content", Map.get(tab_content, :class, "")]}>
            <%= render_slot(tab_content) %>
            </div>
          <% end %>
        <% end %>
      <% end %>
    </section>
    """
  end
end
