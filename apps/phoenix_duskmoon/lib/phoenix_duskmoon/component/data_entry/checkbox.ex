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

  @doc """
  Renders a checkbox input.

  ## Examples

      <.dm_checkbox field={@form[:agree]} label="I agree" />
      <.dm_checkbox name="remember" label="Remember me" checked />

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
  attr(:indeterminate, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:label_class, :string, default: nil)
  attr(:checkbox_class, :string, default: nil)
  attr(:multiple, :boolean, default: false)
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
    ~H"""
    <div class={["dm-form-group", @class]}>
      <label class="flex items-center gap-2 cursor-pointer">
        <input
          type="checkbox"
          name={@name}
          id={@id}
          value="true"
          checked={@checked}
          disabled={@disabled}
          class={[
            "dm-checkbox",
            "dm-checkbox--#{@size}",
            "dm-checkbox--#{@color}",
            @disabled && "opacity-50 cursor-not-allowed",
            @checkbox_class
          ]}
          phx-indeterminate={@indeterminate}
          {@rest}
        />
        <span :if={@label} class={["dm-label__text", @label_class]}>
          {@label}
        </span>
      </label>
    </div>
    """
  end
end
