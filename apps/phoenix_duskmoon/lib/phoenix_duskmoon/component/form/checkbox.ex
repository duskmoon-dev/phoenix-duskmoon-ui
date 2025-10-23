defmodule PhoenixDuskmoon.Component.Form.Checkbox do
  @moduledoc """
  Checkbox component for multiple selection.

  ## Examples

      <.dm_form for={@form} phx-submit="save">
        <.dm_checkbox field={@form[:agree]} label="I agree to terms" />
        <.dm_checkbox field={@form[:newsletter]} label="Subscribe to newsletter" color="success" />
        <.dm_checkbox field={@form[:features]} label="Enable advanced features" size="lg" />
      </.dm_form>

  ## Attributes

  * `field` - Phoenix form field
  * `label` - Checkbox label text
  * `size` - Checkbox size: xs, sm, md, lg (default: md)
  * `color` - Checkbox color: primary, secondary, accent, info, success, warning, error (default: primary)
  * `disabled` - Disable the checkbox
  * `indeterminate` - Set indeterminate state
  * `class` - Additional CSS classes
  * `label_class` - Additional CSS classes for label
  * `checkbox_class` - Additional CSS classes for checkbox element
  """

  use Phoenix.Component

  alias PhoenixDuskmoon.Component.Form

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
    <div class={@class}>
      <label class="flex items-center gap-2 cursor-pointer">
        <input
          type="checkbox"
          name={@name}
          id={@id}
          value="true"
          checked={@checked}
          disabled={@disabled}
          class={[
            "checkbox",
            size_classes(@size),
            color_classes(@color),
            @disabled && "opacity-50 cursor-not-allowed",
            @checkbox_class
          ]}
          phx-indeterminate={@indeterminate}
          {@rest}
        />
        <span :if={@label} class={["label-text", @label_class]}>
          {@label}
        </span>
      </label>
    </div>
    """
  end

  defp size_classes("xs"), do: "checkbox-xs"
  defp size_classes("sm"), do: "checkbox-sm"
  defp size_classes("md"), do: "checkbox-md"
  defp size_classes("lg"), do: "checkbox-lg"

  defp color_classes("primary"), do: "checkbox-primary"
  defp color_classes("secondary"), do: "checkbox-secondary"
  defp color_classes("accent"), do: "checkbox-accent"
  defp color_classes("info"), do: "checkbox-info"
  defp color_classes("success"), do: "checkbox-success"
  defp color_classes("warning"), do: "checkbox-warning"
  defp color_classes("error"), do: "checkbox-error"
end
