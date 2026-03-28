defmodule PhoenixDuskmoon.Component.DataEntry.Cascader do
  @moduledoc """
  Cascader component using `el-dm-cascader` custom element.

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
  import PhoenixDuskmoon.Component.DataEntry.Form, only: [dm_error: 1]

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
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:name, :string, default: nil, doc: "form field name (submits last value in path)")
  attr(:field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form")

  attr(:options, :list,
    default: [],
    doc: "tree of option maps with :value, :label, optional :children, :disabled"
  )

  attr(:selected_path, :list,
    default: [],
    doc: "list of values forming the selected path from root to leaf"
  )

  attr(:placeholder, :string, default: nil, doc: "placeholder text")

  attr(:size, :string,
    default: "md",
    values: ["sm", "md", "lg"],
    doc: "size variant"
  )

  attr(:error, :boolean, default: false, doc: "show error state")
  attr(:errors, :list, default: [], doc: "list of error messages to display")
  attr(:disabled, :boolean, default: false, doc: "disable the component")
  attr(:loading, :boolean, default: false, doc: "show loading state")
  attr(:searchable, :boolean, default: false, doc: "show search input")
  attr(:clearable, :boolean, default: false, doc: "show clear button")
  attr(:separator, :string, default: " / ", doc: "path separator in display")
  attr(:multiple, :boolean, default: false, doc: "enable multi-path selection")
  attr(:change_on_select, :boolean, default: false, doc: "emit change on each level")

  attr(:expand_trigger, :string,
    default: "click",
    values: ["click", "hover"],
    doc: "how to expand panels"
  )

  attr(:helper, :string, default: nil, doc: "helper text displayed below the component")
  attr(:rest, :global)

  def dm_cascader(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:name, field.name)
    |> assign(:selected_path, List.wrap(field.value || []))
    |> dm_cascader()
  end

  def dm_cascader(assigns) do
    options_json = Jason.encode!(assigns.options)
    value_json = Jason.encode!(assigns.selected_path)

    assigns =
      assigns
      |> assign(:options_json, options_json)
      |> assign(:value_json, value_json)

    ~H"""
    <div phx-feedback-for={@name}>
      <el-dm-cascader
        id={@id}
        options={@options_json}
        value={@value_json}
        placeholder={@placeholder}
        separator={@separator}
        size={@size}
        disabled={@disabled || nil}
        searchable={@searchable || nil}
        clearable={@clearable || nil}
        loading={@loading || nil}
        multiple={@multiple || nil}
        change-on-select={@change_on_select || nil}
        expand-trigger={@expand_trigger}
        validation-state={(@error || @errors != []) && "invalid" || nil}
        class={@class}
        aria-busy={@loading && "true"}
        aria-invalid={@errors != [] && "true"}
        aria-describedby={
          (@errors != [] && @id && "#{@id}-errors") ||
            (@helper && @errors == [] && @id && "#{@id}-helper")
        }
        {@rest}
      >
      </el-dm-cascader>
      <input
        :if={@name && @selected_path != []}
        type="hidden"
        name={@name}
        value={List.last(@selected_path)}
      />
      <span :if={@helper && @errors == []} id={@id && "#{@id}-helper"} class="helper-text">
        {@helper}
      </span>
      <div :if={@errors != []} id={@id && "#{@id}-errors"}>
        <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
      </div>
    </div>
    """
  end
end
