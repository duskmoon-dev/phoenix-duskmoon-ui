defmodule PhoenixDuskmoon.Component.DataEntry.Checkbox do
  @moduledoc """
  Checkbox component for multiple selection.

  ## Examples

      <.dm_form for={@form} phx-submit="save">
        <.dm_checkbox field={@form[:agree]} label="I agree to terms" />
        <.dm_checkbox field={@form[:newsletter]} label="Subscribe to newsletter" color="success" />
        <.dm_checkbox field={@form[:features]} label="Enable advanced features" size="lg" />
      </.dm_form>

  """
  use Phoenix.Component

  alias PhoenixDuskmoon.Component.DataEntry.Form
  import PhoenixDuskmoon.Component.DataEntry.Form, only: [dm_error: 1]

  @doc """
  Renders a checkbox input.

  ## Examples

      <.dm_checkbox field={@form[:agree]} label="I agree" />
      <.dm_checkbox name="remember" label="Remember me" checked />

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:name, :any, doc: "HTML name attribute for form submission")
  attr(:value, :any, doc: "the input value")
  attr(:field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form")
  attr(:checked, :boolean, default: false, doc: "whether the checkbox is checked")
  attr(:label, :string, default: nil, doc: "text label displayed next to the checkbox")

  attr(:size, :string,
    default: "md",
    values: ["xs", "sm", "md", "lg", "xl"],
    doc: "checkbox size"
  )

  attr(:color, :string,
    default: "primary",
    values: ["primary", "secondary", "tertiary", "accent", "info", "success", "warning", "error"],
    doc: "color variant"
  )

  attr(:errors, :list, default: [], doc: "list of error messages to display")
  attr(:disabled, :boolean, default: false, doc: "disables the checkbox")
  attr(:indeterminate, :boolean, default: false, doc: "renders in indeterminate state")
  attr(:class, :string, default: nil, doc: "additional CSS classes for the wrapper")
  attr(:label_class, :string, default: nil, doc: "additional CSS classes for the label")

  attr(:checkbox_class, :string,
    default: nil,
    doc: "additional CSS classes for the checkbox input"
  )

  attr(:multiple, :boolean, default: false, doc: "appends [] to the field name for array values")
  attr(:rest, :global)

  def dm_checkbox(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> assign_new(:checked, fn -> Form.normalize_checkbox_value(field.value) end)
    |> dm_checkbox()
  end

  def dm_checkbox(assigns) do
    assigns = assign(assigns, :color, css_color(assigns.color))

    ~H"""
    <div class={["form-group", @class]}>
      <label class={["flex items-center gap-2", !@disabled && "cursor-pointer", @disabled && "cursor-not-allowed"]}>
        <input type="hidden" name={@name} value="false" disabled={@disabled} />
        <input
          type="checkbox"
          name={@name}
          id={@id}
          value="true"
          checked={@checked}
          disabled={@disabled}
          aria-invalid={@errors != [] && "true"}
          aria-describedby={@errors != [] && @id && "#{@id}-errors"}
          class={[
            "checkbox",
            "checkbox-#{@size}",
            "checkbox-#{@color}",
            @disabled && "opacity-50 cursor-not-allowed",
            @checkbox_class
          ]}
          phx-indeterminate={@indeterminate}
          {@rest}
        />
        <span :if={@label} class={@label_class}>
          {@label}
        </span>
      </label>
      <div :if={@errors != []} id={@id && "#{@id}-errors"}>
        <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
      </div>
    </div>
    """
  end

  defp css_color("accent"), do: "tertiary"
  defp css_color(color), do: color
end
