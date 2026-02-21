defmodule PhoenixDuskmoon.Component.DataEntry.Select do
  @moduledoc """
  Select dropdown component for single selection.

  ## Examples

      <.dm_form for={@form} phx-submit="save">
        <.dm_select field={@form[:country]} label="Country" options={country_options()} />
        <.dm_select field={@form[:priority]} label="Priority" options={priority_options()} color="warning" />
      </.dm_form>

      <!-- With option groups -->
      <.dm_select field={@form[:category]} label="Category">
        <option value="">Select a category</option>
        <optgroup label="Fruits">
          <option value="apple">Apple</option>
          <option value="orange">Orange</option>
        </optgroup>
      </.dm_select>

  """
  use Phoenix.Component

  import PhoenixDuskmoon.Component.DataEntry.Form
  import PhoenixDuskmoon.Component.Helpers, only: [css_color: 1]

  @doc """
  Renders a select dropdown.

  ## Examples

      <.dm_select field={@form[:country]} label="Country" options={[{"us", "USA"}, {"uk", "UK"}]} />

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:name, :any, doc: "HTML name attribute for form submission")
  attr(:value, :any, doc: "the currently selected value")
  attr(:field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form")
  attr(:label, :string, default: nil, doc: "text label displayed above the select")
  attr(:options, :list, default: nil, doc: "list of {value, label} tuples for options")

  attr(:prompt, :string,
    default: nil,
    doc: "placeholder option text shown when no value selected"
  )

  attr(:size, :string, default: "md", values: ["xs", "sm", "md", "lg"], doc: "select size")

  attr(:variant, :string,
    default: nil,
    values: ["ghost", "filled", "bordered", nil],
    doc: "the select style variant (ghost, filled, bordered)"
  )

  attr(:color, :string,
    default: "primary",
    values: ["primary", "secondary", "tertiary", "accent", "info", "success", "warning", "error"],
    doc: "color variant"
  )

  attr(:helper, :string, default: nil, doc: "helper text displayed below the select")
  attr(:errors, :list, default: [], doc: "list of error messages to display")
  attr(:disabled, :boolean, default: false, doc: "disables the select")
  attr(:horizontal, :boolean, default: false, doc: "horizontal layout (label beside input)")

  attr(:state, :string,
    default: nil,
    values: [nil, "success", "warning"],
    doc: "validation state (applies form-group-success/warning)"
  )

  attr(:multiple, :boolean, default: false, doc: "allow multiple selections")
  attr(:class, :any, default: nil, doc: "additional CSS classes for the wrapper")
  attr(:label_class, :any, default: nil, doc: "additional CSS classes for the label")
  attr(:select_class, :any, default: nil, doc: "additional CSS classes for the select element")
  attr(:rest, :global)

  slot(:inner_block, required: false)

  def dm_select(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> dm_select()
  end

  def dm_select(assigns) do
    assigns = assign(assigns, :color, css_color(assigns.color))

    ~H"""
    <div class={[
      "form-group",
      @horizontal && "form-group-horizontal",
      @disabled && "form-group-disabled",
      @errors != [] && "form-group-error",
      @state && "form-group-#{@state}",
      @class
    ]} phx-feedback-for={@name}>
      <label :if={@label} for={@id} class={["form-label", @label_class]}>
        <span>{@label}</span>
      </label>
      <select
        id={@id}
        name={@name}
        multiple={@multiple}
        disabled={@disabled}
        aria-disabled={@disabled && "true"}
        aria-invalid={@errors != [] && "true"}
        aria-describedby={
          (@errors != [] && @id && "#{@id}-errors") ||
            (@helper && @errors == [] && @id && "#{@id}-helper")
        }
        class={[
          "select",
          @variant && "select-#{@variant}",
          "select-#{@size}",
          "select-#{@color}",


          @select_class
        ]}
        {@rest}
      >
        {render_options(assigns)}
      </select>
      <span :if={@helper && @errors == []} id={@id && "#{@id}-helper"} class={["helper-text", @state && "helper-text-#{@state}"]}>{@helper}</span>
      <div :if={@errors != []} id={@id && "#{@id}-errors"}>
        <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
      </div>
    </div>
    """
  end

  defp render_options(%{options: options} = assigns) when is_list(options) do
    ~H"""
    <option :if={@prompt} value="">{@prompt}</option>
    <option :for={{value, label} <- @options} value={value} selected={@value == value}>
      {label}
    </option>
    """
  end

  defp render_options(assigns) do
    ~H"""
    <option :if={@prompt} value="">{@prompt}</option>
    {render_slot(@inner_block)}
    """
  end
end
