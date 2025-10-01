defmodule PhoenixDuskmoon.Component.Pagination do
  @moduledoc """
  Duskmoon UI Pagination Component
  """
  use PhoenixDuskmoon.Component, :html

  import PhoenixDuskmoon.Component.Icons

  @doc """
  Generates a pagination.

  ## Examples

      <.dm_pagination page_num={5} page_size={15} total={100} update_event="update-page"/>

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

  attr(:page_size, :integer,
    default: 10,
    doc: """
    items shows per page
    """
  )

  attr(:page_num, :integer,
    default: 1,
    doc: """
    page num
    """
  )

  attr(:total, :integer,
    default: 0,
    doc: """
    total items count
    """
  )

  attr(:show_total, :boolean,
    default: false,
    doc: """
    whether show total items count
    """
  )

  attr(:update_event, :string,
    default: "update_current_page",
    doc: """
    Phoenix live event name for page status update.
    """
  )

  attr(:page_url, :any,
    default: nil,
    doc: """
    Page url.
    """
  )

  attr(:page_url_marker, :string,
    default: "{page}",
    doc: """
    Marker in page url. Default is `{page}`.
    Replace this marker with page number.
    """
  )

  attr(:page_link_type, :string,
    default: "patch",
    values: ~w(patch navigate href),
    doc: """
    Phoenix link type.
    """
  )

  slot(:inner_block,
    required: false,
    doc: """
    Page slot
    """
  )

  def dm_pagination(assigns) do
    {max_page, pages} = generate_pages(assigns.total, assigns.page_size, assigns.page_num)

    assigns =
      assigns
      |> assign(:max_page, max_page)
      |> assign(:pages, pages)

    ~H"""
    <div
      id={@id}
      class={[
        "flex items-center gap-4",
        @class
      ]}
    >
      <div :if={@show_total} class="flex flex-row items-center gap-2">
        <.dm_mdi name="view-dashboard" class="w-5 h-5" />
        <code><%= @total %></code>
      </div>
      <nav class="join" aria-label="Pagination">
        <a
          phx-click={if(@page_num == 1, do: false, else: @update_event)}
          phx-value-current={if(@page_num == 1, do: nil, else: @page_num - 1)}
          disabled={if(@page_num == 1, do: true, else: false)}
          class={[
            "join-item btn btn-sm",
          ]}
          data-phx-link={@page_link_type}
          data-phx-link-state="push"
          href={if(!is_nil(@page_url), do: String.replace(@page_url, @page_url_marker, "#{if(@page_num == 1, do: 1, else: @page_num - 1)}"), else: nil)}
        >
          <span class="sr-only">Previous</span>
          <.dm_mdi name="page-previous" class="w-5 h-5" />
        </a>

        <%= for p <- @pages do %>
          <%= if is_binary(p) do %>
            <a
              disabled="disabled"
              class={[
                "join-item btn btn-sm",
              ]}
            ><%= p %></a>
          <% else %>
            <a
              phx-click={@update_event} phx-value-current={p}
              aria-current={if p == @page_num, do: "page", else: false }
              class={[
                "join-item btn btn-sm",
                if(p == @page_num, do: "btn-primary", else: ""),
              ]}
              data-phx-link={@page_link_type}
              data-phx-link-state="push"
              href={if(!is_nil(@page_url), do: String.replace(@page_url, @page_url_marker, "#{p}"), else: nil)}
            ><%= p %></a>
          <% end %>
        <% end %>

        <a
          phx-click={if @page_num == @max_page, do: false, else: @update_event}
          phx-value-current={if @page_num == @max_page, do: nil, else: @page_num + 1}
          disabled={if @page_num == @max_page, do: true, else: false}
          class={[
            "join-item btn btn-sm",
          ]}
          data-phx-link={@page_link_type}
          data-phx-link-state="push"
          href={if(!is_nil(@page_url), do: String.replace(@page_url, @page_url_marker, "#{if @page_num == @max_page, do: @page_num, else: @page_num + 1}"), else: nil)}
        >
          <i class="sr-only">Next</i>
          <.dm_mdi name="page-next" class="w-5 h-5" />
        </a>
      </nav>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Generates a Pagination.
  Use duskmoonui style.

  ## Examples

      <.dm_pagination_thin page_num={5} page_size={15} total={100} update_event="update-page" loading={false} />

  """
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

  attr(
    :loading,
    :boolean,
    default: false,
    doc: """
    when loading, disable the pagination
    """
  )

  attr(
    :show_page_jumper,
    :boolean,
    default: false,
    doc: """
    show quick jumper
    """
  )

  attr(:page_size, :integer,
    default: 10,
    doc: """
    items shows per page
    """
  )

  attr(:page_num, :integer,
    default: 1,
    doc: """
    page num
    """
  )

  attr(:total, :integer,
    default: 0,
    doc: """
    total items count
    """
  )

  attr(:show_total, :boolean,
    default: false,
    doc: """
    whether show total items count
    """
  )

  attr(:update_event, :string,
    default: "update_current_page",
    doc: """
    Phoenix live event name for page status update.
    """
  )

  def dm_pagination_thin(assigns) do
    {max_page, pages} = generate_pages(assigns.total, assigns.page_size, assigns.page_num)

    assigns =
      assigns
      |> assign(:max_page, max_page)
      |> assign(:pages, pages)

    ~H"""
    <div
      id={@id}
      class={[
        "flex items-center gap-4",
        @class
      ]}
    >
      <div :if={@show_total} class={["flex flex-row items-center gap-2"]}>
        <.dm_mdi name="view-dashboard" class="w-5 h-5" />
        <code class="font-medium"><%= @total %></code>
      </div>
      <nav class="join">
        <span
          phx-click={if(@page_num == 1 || @loading, do: false, else: @update_event)}
          phx-value-current={if @page_num == 1, do: nil, else: @page_num - 1}
          disabled={if @page_num == 1, do: true, else: false}
          class={[
            if(@page_num == 1, do: "", else: "cursor-pointer"),
            "join-item btn btn-sm",
            if(@loading, do: "cursor-wait")
          ]}
        >
          <span class="sr-only">Previous</span>
          <.dm_mdi name="chevron-left" class="w-5 h-5" />
        </span>

        <span
          phx-click={if(@loading, do: false, else: @update_event)}
          phx-value-current={@page_num}
          aria-current={"page"}
          class={[
            "join-item btn btn-sm",
            "bg-primary text-primary-content",
          ]}
        >
          <span :if={@loading} class="loading loading-spinner loading-xs"></span>
          <%= @page_num %>
        </span>

        <span
          phx-click={if(@page_num == @max_page || @loading, do: false, else: @update_event)}
          phx-value-current={if @page_num == @max_page, do: nil, else: @page_num + 1}
          disabled={if @page_num == @max_page, do: true, else: false}
          class={[
            if(@page_num == @max_page, do: "", else: "cursor-pointer"),
            "join-item btn btn-sm",
            if(@loading, do: "cursor-wait")
          ]}
        >
          <span class="sr-only">Next</span>
          <.dm_mdi name="chevron-right" class="w-5 h-5" />
        </span>
      </nav>
      <div
        :if={@show_page_jumper}
        class="text-medium flex-nowrap flex items-center gap-2"
      >
        <span><.dm_mdi name="arrow-right-top" class="w-4 h-4" /></span>
        <form class="font-medium" phx-change={if(@loading, do: false, else: @update_event)}>
          <input
            type="number"
            name="current"
            class={["input input-sm w-auto"]}
            min={1}
            max={@max_page}
            phx-debounce={300}
            oninput={"this.value = Math.round(this.value);if(this.value<1){this.value=1}if(this.value>#{@max_page}){this.value=#{@max_page}}"}
            value={@page_num}
          />
        </form>
      </div>
    </div>
    """
  end

  defp generate_pages(total, page_size, page_num) do
    max_page =
      if total > 0 do
        (total / page_size) |> ceil
      else
        1
      end

    pages =
      cond do
        max_page == 1 ->
          [1]

        max_page < 7 ->
          1..max_page |> Enum.map(& &1)

        page_num < 3 ->
          [1, 2, 3] ++ ["..."] ++ [max_page - 2, max_page - 1, max_page]

        page_num == 3 ->
          [1, 2, 3, 4] ++ ["..."] ++ [max_page - 2, max_page - 1, max_page]

        page_num > 3 && page_num < max_page - 2 ->
          [1] ++ ["...", page_num - 1, page_num, page_num + 1, "..."] ++ [max_page]

        page_num == max_page - 2 ->
          [1, 2, 3] ++ ["...", max_page - 3, max_page - 2, max_page - 1, max_page]

        page_num > max_page - 2 ->
          [1, 2, 3] ++ ["...", max_page - 2, max_page - 1, max_page]
      end

    {max_page, pages}
  end
end
