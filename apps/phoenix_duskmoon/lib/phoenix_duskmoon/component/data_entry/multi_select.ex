defmodule PhoenixDuskmoon.Component.DataEntry.MultiSelect do
  @moduledoc """
  Multi-select component using CSS classes from `@duskmoon-dev/core`.

  Renders a multi-select input with tags, dropdown, search, option
  checkboxes, grouping, and action buttons. State management (open/close,
  selection) is handled by the parent LiveView via attrs.

  Options are provided as a list of maps with `:value` and `:label` keys,
  plus optional `:description`, `:disabled`, and `:group` keys.

  ## Examples

      <.dm_multi_select
        options={[
          %{value: "elixir", label: "Elixir"},
          %{value: "phoenix", label: "Phoenix"},
          %{value: "liveview", label: "LiveView"}
        ]}
        selected={["elixir", "phoenix"]}
        placeholder="Select languages..."
      />

      <.dm_multi_select
        options={[
          %{value: "us", label: "United States", group: "Americas"},
          %{value: "ca", label: "Canada", group: "Americas"},
          %{value: "uk", label: "United Kingdom", group: "Europe"}
        ]}
        selected={["us"]}
        open
        searchable
        show_actions
      />

  """
  use Phoenix.Component
  import PhoenixDuskmoon.Component.DataEntry.Form, only: [dm_error: 1]

  @doc """
  Renders a multi-select input with tags and dropdown.

  ## Examples

      <.dm_multi_select
        options={[%{value: "a", label: "Alpha"}, %{value: "b", label: "Beta"}]}
        selected={["a"]}
      />

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :string, default: nil, doc: "additional CSS classes")
  attr(:name, :string, default: nil, doc: "form field name")
  attr(:field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form")
  attr(:options, :list, default: [], doc: "list of option maps with :value, :label keys")
  attr(:selected, :list, default: [], doc: "list of currently selected values")
  attr(:placeholder, :string, default: nil, doc: "placeholder text when nothing selected")
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
  attr(:errors, :list, default: [], doc: "list of error messages to display")
  attr(:disabled, :boolean, default: false, doc: "disable the component")
  attr(:loading, :boolean, default: false, doc: "show loading state")
  attr(:searchable, :boolean, default: false, doc: "show search input in dropdown")
  attr(:show_actions, :boolean, default: false, doc: "show select all/deselect all actions")
  attr(:show_counter, :boolean, default: false, doc: "show selected count badge")
  attr(:clearable, :boolean, default: false, doc: "show clear all button")

  attr(:tag_variant, :string,
    default: nil,
    values: [nil, "primary", "outlined"],
    doc: "tag style variant"
  )

  attr(:max_tags, :integer, default: nil, doc: "max tags to show before overflow indicator")
  attr(:empty_text, :string, default: "No options available", doc: "text when no options")
  attr(:helper, :string, default: nil, doc: "helper text displayed below the component")
  attr(:rest, :global)

  def dm_multi_select(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:name, field.name)
    |> assign(:selected, List.wrap(field.value || []))
    |> dm_multi_select()
  end

  def dm_multi_select(assigns) do
    selected_set = MapSet.new(assigns.selected)
    selected_options = Enum.filter(assigns.options, &MapSet.member?(selected_set, &1[:value]))
    grouped_options = group_options(assigns.options)

    visible_tags =
      if assigns.max_tags,
        do: Enum.take(selected_options, assigns.max_tags),
        else: selected_options

    overflow_count =
      if assigns.max_tags,
        do: max(0, length(selected_options) - assigns.max_tags),
        else: 0

    assigns =
      assigns
      |> assign(:selected_set, selected_set)
      |> assign(:selected_options, selected_options)
      |> assign(:grouped_options, grouped_options)
      |> assign(:visible_tags, visible_tags)
      |> assign(:overflow_count, overflow_count)

    ~H"""
    <div
      id={@id}
      class={[
        "multi-select",
        @size && "multi-select-#{@size}",
        @variant && "multi-select-#{@variant}",
        @open && "multi-select-open",
        (@error || @errors != []) && "multi-select-error",
        @disabled && "multi-select-disabled",
        @loading && "multi-select-loading",
        @class
      ]}
      phx-feedback-for={@name}
      {@rest}
    >
      <button
        id={@id && "#{@id}-trigger"}
        type="button"
        class="multi-select-trigger"
        disabled={@disabled}
        aria-expanded={to_string(@open)}
        aria-haspopup="listbox"
        aria-invalid={@errors != [] && "true"}
        aria-describedby={
          (@errors != [] && @id && "#{@id}-errors") ||
            (@helper && @errors == [] && @id && "#{@id}-helper")
        }
      >
        <span :if={@selected_options == [] && @placeholder} class="multi-select-placeholder">{@placeholder}</span>
        <div :if={@selected_options != []} class="multi-select-tags">
          <span
            :for={opt <- @visible_tags}
            class={[
              "multi-select-tag",
              @tag_variant && "multi-select-tag-#{@tag_variant}"
            ]}
          >
            <span class="multi-select-tag-text">{opt[:label]}</span>
            <span role="button" tabindex="0" class="multi-select-tag-remove" aria-label={"Remove #{opt[:label]}"}>
              &times;
            </span>
          </span>
          <span :if={@overflow_count > 0} class="multi-select-tag-overflow">
            +{@overflow_count} more
          </span>
        </div>
        <span :if={@show_counter && @selected_options != []} class="multi-select-counter">
          {length(@selected_options)}
        </span>
        <span :if={@clearable && @selected_options != []} role="button" tabindex="0" class="multi-select-clear-all" aria-label="Clear all">
          &times;
        </span>
        <span class="multi-select-arrow"></span>
      </button>

      <div class="multi-select-dropdown">
        <div :if={@searchable} class="multi-select-search">
          <input
            type="text"
            class="multi-select-search-input"
            placeholder="Search..."
            autocomplete="off"
            aria-label="Search options"
          />
        </div>

        <div :if={@show_actions} class="multi-select-actions">
          <button type="button" class="multi-select-action">Select All</button>
          <button type="button" class="multi-select-action">Deselect All</button>
        </div>

        <div class="multi-select-options" role="listbox" aria-multiselectable="true" aria-labelledby={@id && "#{@id}-trigger"}>
          <div :if={@options == []} class="multi-select-empty">{@empty_text}</div>
          <%= for {group, opts} <- @grouped_options do %>
            <div :if={group} class="multi-select-group">
              <div class="multi-select-group-header">{group}</div>
              <.render_option :for={opt <- opts} opt={opt} selected_set={@selected_set} />
            </div>
            <.render_option :for={opt <- opts} :if={!group} opt={opt} selected_set={@selected_set} />
          <% end %>
        </div>
      </div>

      <input
        :for={val <- @selected}
        type="hidden"
        name={@name && "#{@name}[]"}
        value={val}
      />
      <span :if={@helper && @errors == []} id={@id && "#{@id}-helper"} class="helper-text">{@helper}</span>
      <div :if={@errors != []} id={@id && "#{@id}-errors"}>
        <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
      </div>
    </div>
    """
  end

  defp render_option(assigns) do
    selected = MapSet.member?(assigns.selected_set, assigns.opt[:value])
    assigns = assign(assigns, :selected, selected)

    ~H"""
    <div
      class={[
        "multi-select-option",
        @selected && "multi-select-option-selected",
        @opt[:disabled] && "multi-select-option-disabled"
      ]}
      role="option"
      aria-selected={to_string(@selected)}
      data-value={@opt[:value]}
    >
      <span class="multi-select-option-checkbox">
        <input
          type="checkbox"
          class="multi-select-checkbox-input"
          checked={@selected}
          disabled={@opt[:disabled]}
          tabindex="-1"
        />
        <span class="multi-select-checkbox-box"></span>
      </span>
      <span class="multi-select-option-text">{@opt[:label]}</span>
      <span :if={@opt[:description]} class="multi-select-option-description">
        {@opt[:description]}
      </span>
    </div>
    """
  end

  defp group_options(options) do
    {ungrouped, grouped} = Enum.split_with(options, fn opt -> is_nil(opt[:group]) end)

    grouped_map =
      grouped
      |> Enum.group_by(& &1[:group])
      |> Enum.sort_by(fn {group, _} -> group end)

    if ungrouped == [] do
      grouped_map
    else
      [{nil, ungrouped} | grouped_map]
    end
  end
end
