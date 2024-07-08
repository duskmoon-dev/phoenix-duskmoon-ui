defmodule PhoenixDuskmoon.Table do
  @moduledoc """
  Render table.
  """
  use PhoenixDuskmoon, :html

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
    <:caption>Skywalker House</:catption>
    <:col :let={r} label="Name" label_class="text-teal-600" class="text-teal-400">
      <%= r.name %>
    </:col>
    <:col :let={r} label="Portrayal">
      <%= r.portrayal %>
    </:col>
  </.dm_table>
  ```

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

  attr(:border, :boolean,
    default: false,
    doc: """
    show table border
    """
  )

  attr(:data, :list,
    default: [],
    doc: """
    table data list
    """
  )

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
      <%= r.name %>
    </:col>
    ```
    """
  ) do
    attr(:label, :string, doc: "table column title")
    attr(:label_class, :any, doc: "table column title title")
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
        <%= r.description %>
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
        "table border-collapse border-spacing-0",
        if(@border, do: "border"),
        @class,
      ]}
    >
      <caption
        :for={caption <- @caption}
        role="caption"
        id={Map.get(caption, :id, false)}
        class={Map.get(caption, :class, "")}
      ><%= render_slot(caption) %></caption>
      <thead role="row-group" class="hidden md:table-header-group sticky top-0">
        <tr role="row" class="bg-slate-100 h-8">
          <th
            :for={col <- @col}
            role="columnheader"
            class={[
              "font-bold",
              if(@border, do: "border"),
              Map.get(col, :label_class, "")
            ]}
          ><%= col.label %></th>
        </tr>
      </thead>
      <%= if @stream do %>
        <tbody role="row-group" id={"@id-stream-body"} phx-update="stream">
          <tr
            :for={{row_id, row} <- @data}
            role="row"
            id={row_id}
            class={"table-row"}
          >
            <td
              :for={col <- @col}
              data-label={col.label}
              role="cell"
              class={[
                "px-4 py-2",
                if(@border, do: "border"),
                "grid before:content-[attr(data-label)] before:font-bold grid-cols-[6em_auto] gap-x-2 gap-y-4",
                "md:table-cell md:before:hidden",
                Map.get(col, :class, "")
              ]}
            ><%= render_slot(col, row) %></td>
          </tr>
        </tbody>
      <% else %>
        <tbody role="row-group">
          <%= for row <- @data do %>
            <tr
              role="row"
              class={"table-row"}
            >
              <td
                :for={col <- @col}
                data-label={col.label}
                role="cell"
                class={[
                  "px-4 py-2",
                  if(@border, do: "border"),
                  "grid before:content-[attr(data-label)] before:font-bold grid-cols-[6em_auto] gap-x-2 gap-y-4",
                  "md:table-cell md:before:hidden",
                  Map.get(col, :class, "")
                ]}
              ><%= render_slot(col, row) %></td>
            </tr>
            <tr
              role="row"
              class={[
                "table-row-expand",
                Map.get(expand, :class, "")
              ]}
              :if={length(@expand) > 0}
              :for={expand <- @expand}
              id={Map.get(expand, :id, false)}
            >
              <td
                colspan={length(@col)}
                role="cell"
                class={[
                  "px-4 py-2",
                  if(@border, do: "border"),
                ]}
              ><%= render_slot(expand, row) %></td>
            </tr>
          <% end %>
        </tbody>
      <%  end %>
    </table>
    """
  end
end
