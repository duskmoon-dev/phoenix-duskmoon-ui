defmodule PhoenixDuskmoon.Component.DataEntry.Switch do
  @moduledoc """
  Switch component for toggle functionality.

  ## Examples

      <.dm_form for={@form} phx-submit="save">
        <.dm_switch field={@form[:notifications]} label="Enable notifications" />
        <.dm_switch field={@form[:dark_mode]} label="Dark mode" size="lg" />
      </.dm_form>

  """
  use Phoenix.Component

  alias PhoenixDuskmoon.Component.DataEntry.Form
  import PhoenixDuskmoon.Component.DataEntry.Form, only: [dm_error: 1]

  @doc """
  Renders a toggle switch input.

  ## Examples

      <.dm_switch field={@form[:enabled]} label="Enable" />
      <.dm_switch name="active" label="Active" checked />

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:name, :any, doc: "HTML name attribute for form submission")
  attr(:value, :any, doc: "the input value")
  attr(:field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form")
  attr(:checked, :boolean, default: false, doc: "whether the switch is toggled on")
  attr(:label, :string, default: nil, doc: "text label displayed next to the switch")
  attr(:size, :string, default: "md", values: ["xs", "sm", "md", "lg"], doc: "switch size")

  attr(:color, :string,
    default: "primary",
    values: ["primary", "secondary", "tertiary", "accent", "info", "success", "warning", "error"],
    doc: "color variant"
  )

  attr(:errors, :list, default: [], doc: "list of error messages to display")
  attr(:disabled, :boolean, default: false, doc: "disables the switch")
  attr(:class, :string, default: nil, doc: "additional CSS classes for the wrapper")
  attr(:label_class, :string, default: nil, doc: "additional CSS classes for the label")
  attr(:switch_class, :string, default: nil, doc: "additional CSS classes for the switch input")
  attr(:multiple, :boolean, default: false, doc: "appends [] to the field name for array values")
  attr(:rest, :global)

  def dm_switch(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> assign_new(:checked, fn -> Form.normalize_checkbox_value(field.value) end)
    |> dm_switch()
  end

  def dm_switch(assigns) do
    assigns = assign(assigns, :color, css_color(assigns.color))

    ~H"""
    <div class={["form-group", @class]}>
      <label class="switch-label">
        <input
          type="checkbox"
          role="switch"
          aria-checked={to_string(@checked)}
          aria-invalid={@errors != [] && "true"}
          aria-describedby={@errors != [] && @id && "#{@id}-errors"}
          name={@name}
          id={@id}
          value="true"
          checked={@checked}
          disabled={@disabled}
          class={["switch", "switch-#{@size}", "switch-#{@color}", @switch_class]}
          {@rest}
        />
        <span :if={@label} class={@label_class}>{@label}</span>
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
