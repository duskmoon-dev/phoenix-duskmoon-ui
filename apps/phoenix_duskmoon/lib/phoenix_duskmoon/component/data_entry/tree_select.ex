defmodule PhoenixDuskmoon.Component.DataEntry.TreeSelect do
  @moduledoc """
  Tree select component using CSS classes from `@duskmoon-dev/core`.

  Renders a hierarchical select with expandable tree nodes, checkboxes
  for multi-select mode, and search. Options are structured as a tree
  with nested `:children` lists.

  ## Examples

      <.dm_tree_select
        options={[
          %{value: "fruits", label: "Fruits", children: [
            %{value: "apple", label: "Apple"},
            %{value: "banana", label: "Banana"}
          ]},
          %{value: "vegs", label: "Vegetables", children: [
            %{value: "carrot", label: "Carrot"}
          ]}
        ]}
        selected={["apple"]}
        placeholder="Select items..."
      />

  """
  use Phoenix.Component
  import PhoenixDuskmoon.Component.DataEntry.Form, only: [dm_error: 1]

  @doc """
  Renders a tree select dropdown with hierarchical options.

  ## Examples

      <.dm_tree_select
        options={[%{value: "a", label: "Alpha", children: [%{value: "b", label: "Beta"}]}]}
        selected={["b"]}
      />

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :string, default: nil, doc: "additional CSS classes")
  attr(:name, :string, default: nil, doc: "form field name")
  attr(:field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form")

  attr(:options, :list,
    default: [],
    doc: "tree of option maps with :value, :label, optional :children, :disabled, :icon"
  )

  attr(:selected, :list, default: [], doc: "list of selected values")
  attr(:expanded, :list, default: [], doc: "list of expanded node values")
  attr(:placeholder, :string, default: nil, doc: "placeholder text")
  attr(:open, :boolean, default: false, doc: "whether the dropdown is open")
  attr(:multiple, :boolean, default: false, doc: "enable multi-select with checkboxes")

  attr(:size, :string,
    default: nil,
    values: [nil, "sm", "lg"],
    doc: "size variant"
  )

  attr(:variant, :string,
    default: nil,
    values: [nil, "outlined", "filled"],
    doc: "visual style variant"
  )

  attr(:error, :boolean, default: false, doc: "show error state")
  attr(:errors, :list, default: [], doc: "list of error messages to display")
  attr(:disabled, :boolean, default: false, doc: "disable the component")
  attr(:loading, :boolean, default: false, doc: "show loading state")
  attr(:searchable, :boolean, default: false, doc: "show search input in dropdown")
  attr(:clearable, :boolean, default: false, doc: "show clear button")
  attr(:show_path, :boolean, default: false, doc: "show selected item path in trigger")
  attr(:empty_text, :string, default: "No options available", doc: "text when no options")
  attr(:helper, :string, default: nil, doc: "helper text displayed below the component")
  attr(:rest, :global)

  def dm_tree_select(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:name, field.name)
    |> assign(:selected, List.wrap(field.value || []))
    |> dm_tree_select()
  end

  def dm_tree_select(assigns) do
    selected_set = MapSet.new(assigns.selected)
    expanded_set = MapSet.new(assigns.expanded)
    selected_labels = find_selected_labels(assigns.options, selected_set)

    selected_paths =
      if assigns.show_path, do: find_selected_paths(assigns.options, selected_set), else: []

    assigns =
      assigns
      |> assign(:selected_set, selected_set)
      |> assign(:expanded_set, expanded_set)
      |> assign(:selected_labels, selected_labels)
      |> assign(:selected_paths, selected_paths)

    ~H"""
    <div
      id={@id}
      class={[
        "tree-select",
        @size && "tree-select-#{@size}",
        @variant && "tree-select-#{@variant}",
        @open && "tree-select-open",
        (@error || @errors != []) && "tree-select-error",
        @disabled && "tree-select-disabled",
        @loading && "tree-select-loading",
        @multiple && "tree-select-multiple",
        @class
      ]}
      phx-feedback-for={@name}
      {@rest}
    >
      <button
        id={@id && "#{@id}-trigger"}
        type="button"
        class="tree-select-trigger"
        disabled={@disabled}
        aria-expanded={to_string(@open)}
        aria-haspopup="tree"
        aria-invalid={@errors != [] && "true"}
        aria-describedby={
          (@errors != [] && @id && "#{@id}-errors") ||
            (@helper && @errors == [] && @id && "#{@id}-helper")
        }
      >
        <span class="tree-select-value">
          <%= cond do %>
            <% @show_path && @selected_paths != [] -> %>
              <span :for={path <- @selected_paths} class="tree-select-path">
                {Enum.join(path, " / ")}
              </span>
            <% @multiple && @selected_labels != [] -> %>
              <span class="tree-select-tags">
                <span :for={label <- @selected_labels} class="tree-select-tag">
                  {label}
                  <span role="button" tabindex="0" class="tree-select-tag-remove" aria-label={"Remove #{label}"}>
                    &times;
                  </span>
                </span>
              </span>
            <% @selected_labels != [] -> %>
              <span class="tree-select-value-selected">
                {Enum.join(@selected_labels, ", ")}
              </span>
            <% true -> %>
              <span :if={@placeholder} class="tree-select-placeholder">{@placeholder}</span>
          <% end %>
        </span>
        <span
          :if={@clearable && @selected != []}
          role="button"
          tabindex="0"
          class="tree-select-clear"
          aria-label="Clear selection"
        >
          &times;
        </span>
        <span class="tree-select-arrow"></span>
      </button>

      <div class="tree-select-dropdown">
        <div :if={@searchable} class="tree-select-search">
          <input
            type="text"
            class="tree-select-search-input"
            placeholder="Search..."
            autocomplete="off"
            aria-label="Search options"
          />
        </div>

        <div class="tree-select-options" role="tree" aria-labelledby={@id && "#{@id}-trigger"}>
          <div :if={@options == []} class="tree-select-empty">{@empty_text}</div>
          <.render_nodes
            :if={@options != []}
            nodes={@options}
            selected_set={@selected_set}
            expanded_set={@expanded_set}
            multiple={@multiple}
          />
        </div>
      </div>

      <input
        :for={val <- @selected}
        type="hidden"
        name={@name && (if @multiple, do: "#{@name}[]", else: @name)}
        value={val}
      />
      <span :if={@helper && @errors == []} id={@id && "#{@id}-helper"} class="helper-text">{@helper}</span>
      <div :if={@errors != []} id={@id && "#{@id}-errors"}>
        <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
      </div>
    </div>
    """
  end

  defp render_nodes(assigns) do
    ~H"""
    <div :for={node <- @nodes}>
      <.render_node
        node={node}
        selected_set={@selected_set}
        expanded_set={@expanded_set}
        multiple={@multiple}
      />
    </div>
    """
  end

  defp render_node(assigns) do
    has_children = is_list(assigns.node[:children]) and assigns.node[:children] != []
    selected = MapSet.member?(assigns.selected_set, assigns.node[:value])
    expanded = MapSet.member?(assigns.expanded_set, assigns.node[:value])

    assigns =
      assigns
      |> assign(:has_children, has_children)
      |> assign(:selected, selected)
      |> assign(:expanded, expanded)

    ~H"""
    <div
      class={[
        "tree-select-node",
        @selected && "tree-select-node-selected",
        !@has_children && "tree-select-node-leaf",
        @expanded && "tree-select-node-expanded"
      ]}
      role="treeitem"
      aria-selected={to_string(@selected)}
      aria-expanded={@has_children && to_string(@expanded)}
      data-value={@node[:value]}
    >
      <button :if={@has_children} type="button" class="tree-select-node-toggle" aria-label={"Toggle #{@node[:label]}"}>
        <span class="tree-select-node-icon"></span>
      </button>
      <span :if={@multiple} class="tree-select-checkbox">
        <input
          type="checkbox"
          class="tree-select-checkbox-input"
          checked={@selected}
          disabled={@node[:disabled]}
          tabindex="-1"
        />
        <span class="tree-select-checkbox-box"></span>
      </span>
      <span :if={@node[:icon]} class="tree-select-node-custom-icon">{@node[:icon]}</span>
      <span class="tree-select-node-label">{@node[:label]}</span>
    </div>
    <div :if={@has_children && @expanded} class="tree-select-children">
      <.render_nodes
        nodes={@node[:children]}
        selected_set={@selected_set}
        expanded_set={@expanded_set}
        multiple={@multiple}
      />
    </div>
    """
  end

  defp find_selected_labels(options, selected_set) do
    Enum.flat_map(options, fn opt ->
      labels =
        if MapSet.member?(selected_set, opt[:value]),
          do: [opt[:label]],
          else: []

      child_labels =
        if is_list(opt[:children]),
          do: find_selected_labels(opt[:children], selected_set),
          else: []

      labels ++ child_labels
    end)
  end

  defp find_selected_paths(options, selected_set) do
    find_paths(options, selected_set, [])
  end

  defp find_paths(options, selected_set, prefix) do
    Enum.flat_map(options, fn opt ->
      current_path = prefix ++ [opt[:label]]

      paths =
        if MapSet.member?(selected_set, opt[:value]),
          do: [current_path],
          else: []

      child_paths =
        if is_list(opt[:children]),
          do: find_paths(opt[:children], selected_set, current_path),
          else: []

      paths ++ child_paths
    end)
  end
end
