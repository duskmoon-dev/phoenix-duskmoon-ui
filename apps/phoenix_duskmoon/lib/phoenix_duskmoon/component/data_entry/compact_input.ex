defmodule PhoenixDuskmoon.Component.DataEntry.CompactInput do
  @moduledoc """
  Compact form input components for PhoenixDuskmoon UI.

  This module provides compact input components that combine the label
  and input in a more condensed layout, useful for forms with limited space.

  ## Examples

      <.dm_compact_input field={@form[:email]} type="email" label="Email" />
      <.dm_compact_input name="username" label="Username" value="john" />
      <.dm_compact_input type="select" name="country" label="Country" options={[{"USA", "us"}]} />

  """
  use Phoenix.Component

  import PhoenixDuskmoon.Component.DataEntry.Form
  import PhoenixDuskmoon.Component.Helpers, only: [css_color: 1]

  @doc """
  Renders a compact input with inline label.

  ## Examples

      <.dm_compact_input field={@form[:email]} type="email" label="Email" />
      <.dm_compact_input name="my-input" errors={["oh no!"]} />

  """
  @doc type: :component
  attr(:field_class, :any, default: nil, doc: "additional CSS classes for the field element")
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes for the wrapper")
  attr(:name, :any, doc: "HTML name attribute for form submission")
  attr(:label, :string, default: nil, doc: "inline label text")
  attr(:value, :any, doc: "the input value")

  attr(:type, :string,
    default: "text",
    values: ~w(color date datetime-local email file month number password
               search select tel text time url week),
    doc: "the input type"
  )

  attr(:field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"
  )

  attr(:size, :string, default: "md", values: ["xs", "sm", "md", "lg"], doc: "input size")

  attr(:color, :string,
    default: "primary",
    values: ["primary", "secondary", "tertiary", "accent", "info", "success", "warning", "error"],
    doc: "color variant"
  )

  attr(:variant, :string,
    default: nil,
    values: ["ghost", "filled", "bordered", nil],
    doc: "the input style variant (ghost, filled, bordered)"
  )

  attr(:helper, :string, default: nil, doc: "helper text displayed below the input")
  attr(:errors, :list, default: [], doc: "list of error messages to display")
  attr(:checked, :boolean, doc: "the checked flag for checkbox inputs")
  attr(:prompt, :string, default: nil, doc: "the prompt for select inputs")
  attr(:options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2")
  attr(:multiple, :boolean, default: false, doc: "the multiple flag for select inputs")
  attr(:horizontal, :boolean, default: false, doc: "horizontal layout (label beside input)")

  attr(:state, :string,
    default: nil,
    values: [nil, "success", "warning"],
    doc: "validation state (applies form-group-success/warning)"
  )

  attr(:rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)
  )

  slot(:inner_block)

  def dm_compact_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> dm_compact_input()
  end

  def dm_compact_input(%{type: "select"} = assigns) do
    assigns = assign(assigns, :color, css_color(assigns.color))

    ~H"""
    <div class={[
      "form-group",
      @horizontal && "form-group-horizontal",
      @errors != [] && "form-group-error",
      @state && "form-group-#{@state}",
      @class
    ]} phx-feedback-for={@name}>
      <label for={@id} class="form-label">
        {@label}
      </label>
      <select
        id={@id}
        name={@name}
        class={[
          "select",
          @variant && "select-#{@variant}",
          "select-#{@size}",
          "select-#{@color}"
        ]}
        multiple={@multiple}
        aria-invalid={@errors != [] && "true"}
        aria-describedby={
          (@errors != [] && @id && "#{@id}-errors") ||
            (@helper && @errors == [] && @id && "#{@id}-helper")
        }
        {@rest}
      >
        <option :if={@prompt} value="">{@prompt}</option>
        {Phoenix.HTML.Form.options_for_select(@options, @value)}
      </select>
      <span :if={@helper && @errors == []} id={@id && "#{@id}-helper"} class={["helper-text", @state && "helper-text-#{@state}"]}>{@helper}</span>
      <div :if={@errors != []} id={@id && "#{@id}-errors"}>
        <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
      </div>
    </div>
    """
  end

  def dm_compact_input(assigns) do
    assigns = assign(assigns, :color, css_color(assigns.color))

    ~H"""
    <div
      class={[
        "form-group",
        @horizontal && "form-group-horizontal",
        @errors != [] && "form-group-error",
        @state && "form-group-#{@state}",
        @class
      ]}
      phx-feedback-for={@name}
    >
      <label for={@id} class="form-label">
        {@label}
      </label>
      <input
        type={@type}
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class={[
          "input",
          @variant && "input-#{@variant}",
          "input-#{@size}",
          "input-#{@color}"
        ]}
        aria-invalid={@errors != [] && "true"}
        aria-describedby={
          (@errors != [] && @id && "#{@id}-errors") ||
            (@helper && @errors == [] && @id && "#{@id}-helper")
        }
        {@rest}
      />
      {render_slot(@inner_block)}
      <span :if={@helper && @errors == []} id={@id && "#{@id}-helper"} class={["helper-text", @state && "helper-text-#{@state}"]}>{@helper}</span>
      <div :if={@errors != []} id={@id && "#{@id}-errors"}>
        <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
      </div>
    </div>
    """
  end
end
