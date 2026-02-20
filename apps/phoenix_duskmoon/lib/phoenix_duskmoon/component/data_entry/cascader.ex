defmodule PhoenixDuskmoon.Component.DataEntry.Cascader do
  @moduledoc """
  Cascader component using CSS classes from `@duskmoon-dev/core`.

  Renders a cascading multi-panel select where each panel shows one
  level of hierarchy. Selecting a parent reveals a child panel to the
  right. Options are structured as a tree with `:children` lists.

  ## Examples

      <.dm_cascader
        options={[
          %{value: "asia", label: "Asia", children: [
            %{value: "cn", label: "China", children: [
              %{value: "bj", label: "Beijing"},
              %{value: "sh", label: "Shanghai"}
            ]},
            %{value: "jp", label: "Japan"}
          ]},
          %{value: "eu", label: "Europe", children: [
            %{value: "uk", label: "United Kingdom"}
          ]}
        ]}
        selected_path={["asia", "cn", "bj"]}
      />

  """
  use Phoenix.Component

  @doc """
  Renders a cascader with horizontal multi-panel navigation.

  ## Examples

      <.dm_cascader
        options={[%{value: "a", label: "Alpha", children: [%{value: "b", label: "Beta"}]}]}
        selected_path={["a", "b"]}
      />

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :string, default: nil, doc: "additional CSS classes")
  attr(:name, :string, default: nil, doc: "form field name (submits last value in path)")

  attr(:options, :list,
    default: [],
    doc: "tree of option maps with :value, :label, optional :children, :disabled"
  )

  attr(:selected_path, :list,
    default: [],
    doc: "list of values forming the selected path from root to leaf"
  )

  attr(:placeholder, :string, default: nil, doc: "placeholder text")
  attr(:open, :boolean, default: false, doc: "whether the dropdown is open")

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
  attr(:disabled, :boolean, default: false, doc: "disable the component")
  attr(:loading, :boolean, default: false, doc: "show loading state")
  attr(:searchable, :boolean, default: false, doc: "show search input")
  attr(:clearable, :boolean, default: false, doc: "show clear button")
  attr(:separator, :string, default: " / ", doc: "path separator in display")
  attr(:empty_text, :string, default: "No options available", doc: "text when no options")
  attr(:rest, :global)

  def dm_cascader(assigns) do
    selected_set = MapSet.new(assigns.selected_path)
    panels = build_panels(assigns.options, assigns.selected_path)
    path_labels = build_path_labels(assigns.options, assigns.selected_path)

    assigns =
      assigns
      |> assign(:selected_set, selected_set)
      |> assign(:panels, panels)
      |> assign(:path_labels, path_labels)

    ~H"""
    <div
      id={@id}
      class={[
        "cascader",
        @size && "cascader-#{@size}",
        @variant && "cascader-#{@variant}",
        @open && "cascader-open",
        @error && "cascader-error",
        @disabled && "cascader-disabled",
        @loading && "cascader-loading",
        @class
      ]}
      {@rest}
    >
      <button type="button" class="cascader-trigger" disabled={@disabled}>
        <span class="cascader-value">
          <%= if @path_labels != [] do %>
            <span class="cascader-path">
              <%= for {label, idx} <- Enum.with_index(@path_labels) do %>
                <span :if={idx > 0} class="cascader-path-separator">{@separator}</span>
                <span>{label}</span>
              <% end %>
            </span>
          <% else %>
            <span :if={@placeholder} class="cascader-placeholder">{@placeholder}</span>
          <% end %>
        </span>
        <button
          :if={@clearable && @selected_path != []}
          type="button"
          class="cascader-clear"
          aria-label="Clear selection"
        >
          &times;
        </button>
        <span class="cascader-arrow"></span>
      </button>

      <div class="cascader-dropdown">
        <div :if={@searchable} class="cascader-search">
          <input
            type="text"
            class="cascader-search-input"
            placeholder="Search..."
            autocomplete="off"
          />
        </div>

        <div class="cascader-panels">
          <%= if @options == [] do %>
            <div class="cascader-empty">{@empty_text}</div>
          <% else %>
            <div :for={panel <- @panels} class="cascader-panel">
              <div :if={panel[:header]} class="cascader-panel-header">{panel[:header]}</div>
              <div class="cascader-options">
                <div
                  :for={opt <- panel.options}
                  class={[
                    "cascader-option",
                    opt[:selected] && "cascader-option-selected",
                    opt[:active] && "cascader-option-active",
                    opt[:disabled] && "cascader-option-disabled"
                  ]}
                  role="option"
                  aria-selected={to_string(opt[:selected] || false)}
                  data-value={opt[:value]}
                >
                  <span class="cascader-option-label">{opt[:label]}</span>
                  <span :if={opt[:has_children]} class="cascader-option-arrow"></span>
                </div>
              </div>
            </div>
          <% end %>
        </div>
      </div>

      <input
        :if={@name && @selected_path != []}
        type="hidden"
        name={@name}
        value={List.last(@selected_path)}
      />
    </div>
    """
  end

  defp build_panels(options, selected_path) do
    build_panels_recursive(options, selected_path, [])
  end

  defp build_panels_recursive(options, selected_path, acc) do
    current_value = List.first(selected_path)
    remaining_path = if selected_path != [], do: tl(selected_path), else: []

    panel_options =
      Enum.map(options, fn opt ->
        has_children = is_list(opt[:children]) and opt[:children] != []
        selected = opt[:value] == current_value

        %{
          value: opt[:value],
          label: opt[:label],
          disabled: opt[:disabled],
          has_children: has_children,
          selected: selected,
          active: selected
        }
      end)

    panel = %{options: panel_options, header: nil}
    acc = acc ++ [panel]

    selected_opt = Enum.find(options, fn opt -> opt[:value] == current_value end)

    if selected_opt && is_list(selected_opt[:children]) && selected_opt[:children] != [] do
      build_panels_recursive(selected_opt[:children], remaining_path, acc)
    else
      acc
    end
  end

  defp build_path_labels(options, selected_path) do
    build_labels_recursive(options, selected_path, [])
  end

  defp build_labels_recursive(_options, [], acc), do: acc

  defp build_labels_recursive(options, [current | rest], acc) do
    case Enum.find(options, fn opt -> opt[:value] == current end) do
      nil ->
        acc

      opt ->
        new_acc = acc ++ [opt[:label]]

        if is_list(opt[:children]) do
          build_labels_recursive(opt[:children], rest, new_acc)
        else
          new_acc
        end
    end
  end
end
