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

  @doc """
  Renders a toggle switch input.

  ## Examples

      <.dm_switch field={@form[:enabled]} label="Enable" />
      <.dm_switch name="active" label="Active" checked />

  """
  @doc type: :component
  attr(:id, :any, default: nil)
  attr(:name, :any)
  attr(:value, :any)
  attr(:field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form")
  attr(:checked, :boolean, default: false)
  attr(:label, :string, default: nil)
  attr(:size, :string, default: "md", values: ["xs", "sm", "md", "lg"])

  attr(:color, :string,
    default: "primary",
    values: ["primary", "secondary", "accent", "info", "success", "warning", "error"]
  )

  attr(:disabled, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:label_class, :string, default: nil)
  attr(:switch_class, :string, default: nil)
  attr(:multiple, :boolean, default: false)
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
    ~H"""
    <div class={["dm-form-group", @class]}>
      <label class={["dm-switch", "dm-switch--#{@size}", "dm-switch--#{@color}"]}>
        <input
          type="checkbox"
          role="switch"
          aria-checked={to_string(@checked)}
          name={@name}
          id={@id}
          value="true"
          checked={@checked}
          disabled={@disabled}
          class={["dm-switch__input", @switch_class]}
          {@rest}
        />
        <span class="dm-switch__track"></span>
        <span :if={@label} class={["dm-label__text ml-2", @label_class]}>
          {@label}
        </span>
      </label>
    </div>
    """
  end
end
