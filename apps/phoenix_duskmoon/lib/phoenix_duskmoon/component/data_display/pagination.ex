defmodule PhoenixDuskmoon.Component.DataDisplay.Pagination do
  @moduledoc """
  Pagination component using el-dm-pagination custom element.

  ## Examples

      <.dm_pagination page_num={5} page_size={15} total={100} update_event="update-page"/>

      <.dm_pagination_thin page_num={1} page_size={10} total={50} loading={false} />

  """
  use Phoenix.Component

  import PhoenixDuskmoon.Component.Icon.Icons

  @doc """
  Generates a pagination control.

  ## Examples

      <.dm_pagination page_num={5} page_size={15} total={100} update_event="update-page"/>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "Additional CSS classes")

  attr(:page_size, :integer, default: 10, doc: "Items per page")
  attr(:page_num, :integer, default: 1, doc: "Current page number")
  attr(:total, :integer, default: 0, doc: "Total number of items")
  attr(:show_total, :boolean, default: false, doc: "Show total count")

  attr(:update_event, :string,
    default: "update_current_page",
    doc: "LiveView event name for page changes"
  )

  attr(:page_url, :any, default: nil, doc: "URL pattern for page links")
  attr(:page_url_marker, :string, default: "{page}", doc: "Marker to replace with page number")

  attr(:page_link_type, :string,
    default: "patch",
    values: ~w(patch navigate href),
    doc: "Phoenix link type"
  )

  attr(:prev_label, :string,
    default: "Previous",
    doc: "Screen reader label for the previous button"
  )

  attr(:next_label, :string, default: "Next", doc: "Screen reader label for the next button")

  attr(:pagination_label, :string,
    default: "Pagination",
    doc: "Accessible label for the pagination nav element"
  )

  attr(:prev_page_label, :string,
    default: "Previous page",
    doc: "Accessible label for the previous page button"
  )

  attr(:next_page_label, :string,
    default: "Next page",
    doc: "Accessible label for the next page button"
  )

  attr(:rest, :global)

  slot(:inner_block, required: false)

  def dm_pagination(assigns) do
    {max_page, pages} = generate_pages(assigns.total, assigns.page_size, assigns.page_num)

    assigns =
      assigns
      |> assign(:max_page, max_page)
      |> assign(:pages, pages)

    ~H"""
    <nav
      id={@id}
      class={["dm-pagination", @class]}
      aria-label={@pagination_label}
      {@rest}
    >
      <div :if={@show_total} class="dm-pagination__total">
        <.dm_mdi name="view-dashboard" class="w-5 h-5" />
        <code>{@total}</code>
      </div>
      <el-dm-pagination
        current-page={@page_num}
        total-pages={@max_page}
      >
        <button
          type="button"
          slot="prev"
          aria-label={@prev_page_label}
          phx-click={if(@page_num == 1, do: nil, else: @update_event)}
          phx-value-current={if(@page_num == 1, do: nil, else: @page_num - 1)}
          disabled={@page_num == 1}
          data-phx-link={@page_link_type}
          data-phx-link-state="push"
          href={page_url(@page_url, @page_url_marker, max(@page_num - 1, 1))}
        >
          <span class="sr-only">{@prev_label}</span>
          <.dm_mdi name="page-previous" class="w-5 h-5" />
        </button>

        <%= for p <- @pages do %>
          <%= if is_binary(p) do %>
            <span slot="page" class="dm-pagination__ellipsis">{p}</span>
          <% else %>
            <button
              type="button"
              slot="page"
              phx-click={@update_event}
              phx-value-current={p}
              aria-current={if p == @page_num, do: "page", else: nil}
              data-active={p == @page_num}
              data-phx-link={@page_link_type}
              data-phx-link-state="push"
              href={page_url(@page_url, @page_url_marker, p)}
            >
              {p}
            </button>
          <% end %>
        <% end %>

        <button
          type="button"
          slot="next"
          aria-label={@next_page_label}
          phx-click={if(@page_num == @max_page, do: nil, else: @update_event)}
          phx-value-current={if(@page_num == @max_page, do: nil, else: @page_num + 1)}
          disabled={@page_num == @max_page}
          data-phx-link={@page_link_type}
          data-phx-link-state="push"
          href={page_url(@page_url, @page_url_marker, min(@page_num + 1, @max_page))}
        >
          <span class="sr-only">{@next_label}</span>
          <.dm_mdi name="page-next" class="w-5 h-5" />
        </button>
      </el-dm-pagination>
      {render_slot(@inner_block)}
    </nav>
    """
  end

  @doc """
  Generates a compact/thin pagination control.

  Shows only current page with prev/next buttons, suitable for mobile or limited space.

  ## Examples

      <.dm_pagination_thin page_num={5} page_size={15} total={100} update_event="update-page" loading={false} />

  """
  @doc type: :component
  attr(:id, :any, default: nil)
  attr(:class, :any, default: nil)
  attr(:loading, :boolean, default: false, doc: "Show loading state")
  attr(:show_page_jumper, :boolean, default: false, doc: "Show page number input")
  attr(:page_size, :integer, default: 10)
  attr(:page_num, :integer, default: 1)
  attr(:total, :integer, default: 0)
  attr(:show_total, :boolean, default: false)
  attr(:update_event, :string, default: "update_current_page")

  attr(:prev_label, :string,
    default: "Previous",
    doc: "Screen reader label for the previous button"
  )

  attr(:next_label, :string, default: "Next", doc: "Screen reader label for the next button")

  attr(:pagination_label, :string,
    default: "Pagination",
    doc: "Accessible label for the pagination nav element"
  )

  attr(:prev_page_label, :string,
    default: "Previous page",
    doc: "Accessible label for the previous page button"
  )

  attr(:next_page_label, :string,
    default: "Next page",
    doc: "Accessible label for the next page button"
  )

  attr(:jump_to_page_label, :string,
    default: "Jump to page",
    doc: "Accessible label for the page jumper input"
  )

  attr(:rest, :global)

  def dm_pagination_thin(assigns) do
    {max_page, _pages} = generate_pages(assigns.total, assigns.page_size, assigns.page_num)

    assigns = assigns |> assign(:max_page, max_page)

    ~H"""
    <nav
      id={@id}
      class={["dm-pagination dm-pagination--thin", @class]}
      aria-label={@pagination_label}
      {@rest}
    >
      <div :if={@show_total} class="dm-pagination__total">
        <.dm_mdi name="view-dashboard" class="w-5 h-5" />
        <code>{@total}</code>
      </div>
      <div class="dm-pagination__controls">
        <button
          type="button"
          aria-label={@prev_page_label}
          phx-click={if(@page_num == 1 || @loading, do: nil, else: @update_event)}
          phx-value-current={if(@page_num == 1, do: nil, else: @page_num - 1)}
          disabled={@page_num == 1}
          class={["dm-pagination__btn", @loading && "dm-pagination__btn--loading"]}
        >
          <span class="sr-only">{@prev_label}</span>
          <.dm_mdi name="chevron-left" class="w-5 h-5" />
        </button>

        <button
          type="button"
          phx-click={if(@loading, do: nil, else: @update_event)}
          phx-value-current={@page_num}
          aria-current="page"
          class="dm-pagination__current"
        >
          <span :if={@loading} class="dm-pagination__spinner" aria-hidden="true"></span>
          {@page_num}
        </button>

        <button
          type="button"
          aria-label={@next_page_label}
          phx-click={if(@page_num == @max_page || @loading, do: nil, else: @update_event)}
          phx-value-current={if(@page_num == @max_page, do: nil, else: @page_num + 1)}
          disabled={@page_num == @max_page}
          class={["dm-pagination__btn", @loading && "dm-pagination__btn--loading"]}
        >
          <span class="sr-only">{@next_label}</span>
          <.dm_mdi name="chevron-right" class="w-5 h-5" />
        </button>
      </div>

      <div :if={@show_page_jumper} class="dm-pagination__jumper">
        <.dm_mdi name="arrow-right-top" class="w-4 h-4" />
        <form phx-change={if(@loading, do: nil, else: @update_event)}>
          <input
            type="number"
            name="current"
            aria-label={@jump_to_page_label}
            class="dm-pagination__input"
            min={1}
            max={@max_page}
            phx-debounce={300}
            oninput={"this.value = Math.round(this.value);if(this.value<1){this.value=1}if(this.value>#{@max_page}){this.value=#{@max_page}}"}
            value={@page_num}
          />
        </form>
      </div>
    </nav>
    """
  end

  defp page_url(nil, _marker, _page), do: nil
  defp page_url(url, marker, page), do: String.replace(url, marker, "#{page}")

  defp generate_pages(total, page_size, page_num) do
    safe_page_size = max(page_size, 1)

    max_page =
      if total > 0 do
        (total / safe_page_size) |> ceil()
      else
        1
      end

    pages =
      cond do
        max_page == 1 ->
          [1]

        max_page < 7 ->
          1..max_page |> Enum.to_list()

        page_num < 3 ->
          [1, 2, 3, "...", max_page - 2, max_page - 1, max_page]

        page_num == 3 ->
          [1, 2, 3, 4, "...", max_page - 2, max_page - 1, max_page]

        page_num > 3 && page_num < max_page - 2 ->
          [1, "...", page_num - 1, page_num, page_num + 1, "...", max_page]

        page_num == max_page - 2 ->
          [1, 2, 3, "...", max_page - 3, max_page - 2, max_page - 1, max_page]

        page_num > max_page - 2 ->
          [1, 2, 3, "...", max_page - 2, max_page - 1, max_page]

        true ->
          [1]
      end

    {max_page, pages}
  end
end
