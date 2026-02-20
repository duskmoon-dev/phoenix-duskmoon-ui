defmodule PhoenixDuskmoon.Component.DataEntry.Autocomplete do
  @moduledoc """
  Autocomplete component using `el-dm-autocomplete` custom element.

  Renders a searchable select input with filtering, keyboard navigation,
  optional grouping, descriptions, and multi-select support.

  Options are provided as a list of maps with `:value` and `:label` keys,
  plus optional `:description`, `:disabled`, and `:group` keys.

  ## Examples

      <.dm_autocomplete
        placeholder="Search countries..."
        options={[
          %{value: "us", label: "United States", group: "Americas"},
          %{value: "ca", label: "Canada", group: "Americas"},
          %{value: "uk", label: "United Kingdom", group: "Europe"}
        ]}
      />

      <.dm_autocomplete
        multiple
        clearable
        placeholder="Select tags..."
        options={[
          %{value: "elixir", label: "Elixir"},
          %{value: "phoenix", label: "Phoenix"},
          %{value: "liveview", label: "LiveView"}
        ]}
      />

  """
  use Phoenix.Component

  @doc """
  Renders an autocomplete input with searchable dropdown.

  ## Examples

      <.dm_autocomplete
        placeholder="Search..."
        options={[%{value: "a", label: "Alpha"}, %{value: "b", label: "Beta"}]}
      />

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :string, default: nil, doc: "additional CSS classes")
  attr(:name, :string, default: nil, doc: "form field name")
  attr(:value, :string, default: nil, doc: "selected value (string or JSON array for multiple)")
  attr(:field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form")
  attr(:options, :list, default: [], doc: "list of option maps with :value, :label keys")
  attr(:multiple, :boolean, default: false, doc: "enable multi-select mode")
  attr(:disabled, :boolean, default: false, doc: "disable the autocomplete")
  attr(:clearable, :boolean, default: false, doc: "show clear button")
  attr(:placeholder, :string, default: nil, doc: "placeholder text")
  attr(:loading, :boolean, default: false, doc: "show loading state")

  attr(:no_results_text, :string,
    default: "No results found",
    doc: "text shown when no options match"
  )

  attr(:size, :string,
    default: "md",
    values: ["sm", "md", "lg"],
    doc: "component size"
  )

  attr(:rest, :global)

  def dm_autocomplete(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:name, field.name)
    |> assign(:value, field.value)
    |> dm_autocomplete()
  end

  def dm_autocomplete(assigns) do
    options_json = Jason.encode!(assigns.options)
    assigns = assign(assigns, :options_json, options_json)

    ~H"""
    <el-dm-autocomplete
      id={@id}
      name={@name}
      value={@value}
      options={@options_json}
      multiple={@multiple}
      disabled={@disabled}
      clearable={@clearable}
      placeholder={@placeholder}
      loading={@loading}
      noResultsText={@no_results_text}
      size={@size}
      class={@class}
      {@rest}
    >
    </el-dm-autocomplete>
    """
  end
end
