defmodule PhoenixDuskmoon.Component.DataDisplay.Table do
  @moduledoc """
  Duskmoon UI Table Component
  """
  use Phoenix.Component

  @doc """
  Generates a table.

  ## Examples

  ```heex
  <.dm_table data={[
    %{
      name: "Shmi Skywalker",
      portrayal: "Pernilla August (Episodes I-II)"
    },
    %{
      name: "Luke Skywalker",
      portrayal: "Mark Hamill (Episodes IV-IX, The Mandalorian, The Book of Boba Fett)"}
    ]}
  >
    <:caption>Skywalker House</:caption>
    <:col :let={r} label="Name" label_class="text-info" class="text-info">
      {r.name}
    </:col>
    <:col :let={r} label="Portrayal">
      {r.portrayal}
    </:col>
  </.dm_table>
  ```

  """
  @doc type: :component
  attr(:id, :any,
    default: nil,
    doc: "HTML id attribute"
  )

  attr(:class, :any,
    default: nil,
    doc: "additional CSS classes"
  )

  attr(:border, :boolean,
    default: false,
    doc: "show table borders using table-bordered CSS class"
  )

  attr(:zebra, :boolean,
    default: false,
    doc: "show zebra striping"
  )

  attr(:hover, :boolean,
    default: false,
    doc: "highlight rows on hover"
  )

  attr(:compact, :boolean,
    default: false,
    doc: "make table more compact"
  )

  attr(:data, :list,
    default: [],
    doc: """
    table data list
    """
  )

  attr(:rest, :global, doc: "additional HTML attributes for the table element")

  attr(:stream, :boolean,
    default: false,
    doc: "stream data"
  )

  slot(:caption,
    required: false,
    doc: """
    render a caption of table.

    Example
    ```heex
    <:caption>
      Table information
    </:caption>
    ```
    """
  ) do
    attr(:id, :any, doc: "table caption id")
    attr(:class, :any, doc: "table caption class")
  end

  slot(:col,
    required: false,
    doc: """
    render a column of table.

    Example
    ```heex
    <:col :let={r} label="Name">
      {r.name}
    </:col>
    ```
    """
  ) do
    attr(:label, :string, doc: "table column title")
    attr(:label_class, :any, doc: "table column title CSS classes")
    attr(:class, :any, doc: "table row column class")
  end

  slot(:expand,
    required: false,
    doc: """
    render a one column row after each row of table.

    Example
    ```heex
    <:expand :let={r} label="Name">
      <pre>
        {r.description}
      </pre>
    </:expand>
    ```
    """
  ) do
    attr(:id, :any, doc: "table row expand id")
    attr(:class, :any, doc: "table row expand class")
  end

  def dm_table(assigns) do
    ~H"""
    <table
      role="table"
      id={@id}
      class={[
        "table",
        @border && "table-bordered",
        @zebra && "table-zebra",
        @hover && "table-hover",
        @compact && "table-compact",
        @class,
      ]}
      {@rest}
    >
      <caption
        :for={caption <- @caption}
        id={caption[:id]}
        class={caption[:class]}
      >{render_slot(caption)}</caption>
      <thead role="row-group" class="hidden md:table-header-group sticky top-0">
        <tr role="row">
          <th
            :for={col <- @col}
            role="columnheader"
            scope="col"
            class={col[:label_class]}
          >{col.label}</th>
        </tr>
      </thead>
      <tbody :if={@stream} role="row-group" id={"#{@id}-stream-body"} phx-update="stream">
        <tr
          :for={{row_id, row} <- @data}
          role="row"
          id={row_id}
        >
          <td
            :for={col <- @col}
            data-label={col.label}
            role="cell"
            class={col[:class]}
          >{render_slot(col, row)}</td>
        </tr>
      </tbody>
      <tbody :if={!@stream} role="row-group">
        <%= for row <- @data do %>
          <tr
            role="row"
          >
            <td
              :for={col <- @col}
              data-label={col.label}
              role="cell"
              class={col[:class]}
            >{render_slot(col, row)}</td>
          </tr>
          <tr
            role="row"
            class={[
              "table-row-expand",
              expand[:class]
            ]}
            :if={@expand != []}
            :for={expand <- @expand}
            id={expand[:id]}
          >
            <td
              colspan={max(length(@col), 1)}
              role="cell"
              class="p-0"
            >{render_slot(expand, row)}</td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end
end
