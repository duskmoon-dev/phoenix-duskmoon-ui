defmodule PhoenixDuskmoon.Component.Form.Switch do
  @moduledoc """
  Switch component for toggle functionality.

  ## Examples

      <.dm_form for={@form} phx-submit="save">
        <.dm_switch field={@form[:notifications]} label="Enable notifications" />
        <.dm_switch field={@form[:dark_mode]} label="Dark mode" size="lg" />
      </.dm_form>

  ## Attributes

  * `field` - Phoenix form field
  * `label` - Switch label text
  * `size` - Switch size: xs, sm, md, lg (default: md)
  * `color` - Switch color: primary, secondary, accent, info, success, warning, error (default: primary)
  * `disabled` - Disable the switch
  * `class` - Additional CSS classes
  * `label_class` - Additional CSS classes for label
  * `switch_class` - Additional CSS classes for switch element
  """

  use Phoenix.Component


  alias PhoenixDuskmoon.Component.Form

  @doc type: :component
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any
  attr :field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form"
  attr :checked, :boolean, default: false
  attr :label, :string, default: nil
  attr :size, :string, default: "md", values: ["xs", "sm", "md", "lg"]
  attr :color, :string, default: "primary", values: ["primary", "secondary", "accent", "info", "success", "warning", "error"]
  attr :disabled, :boolean, default: false
  attr :class, :string, default: nil
  attr :label_class, :string, default: nil
  attr :switch_class, :string, default: nil
  attr :rest, :global

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
    <div class={@class}>
      <label class="flex items-center gap-2 cursor-pointer">
        <input
          type="checkbox"
          name={@name}
          id={@id}
          value="true"
          checked={@checked}
          disabled={@disabled}
          class="sr-only peer"
          {@rest}
        />
        <div class={[
          "relative w-11 h-6 bg-gray-200 peer-focus:outline-none rounded-full peer",
          "peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:rounded-full after:h-5 after:w-5 after:transition-all",
          size_classes(@size),
          color_classes(@color),
          @disabled && "opacity-50 cursor-not-allowed",
          @switch_class
        ]}>
        </div>
        <span :if={@label} class={["label-text", @label_class]}>
          {@label}
        </span>
      </label>
    </div>
    """
  end

  defp size_classes("xs"), do: "w-8 h-4 after:top-[1px] after:left-[1px] after:h-3 after:w-3 peer-checked:after:translate-x-4"
  defp size_classes("sm"), do: "w-9 h-5 after:top-[1px] after:left-[1px] after:h-4 after:w-4 peer-checked:after:translate-x-4"
  defp size_classes("md"), do: "w-11 h-6 after:top-[2px] after:left-[2px] after:h-5 after:w-5 peer-checked:after:translate-x-5"
  defp size_classes("lg"), do: "w-14 h-7 after:top-[2px] after:left-[2px] after:h-6 after:w-6 peer-checked:after:translate-x-7"

  defp color_classes("primary"), do: "peer-checked:bg-primary"
  defp color_classes("secondary"), do: "peer-checked:bg-secondary"
  defp color_classes("accent"), do: "peer-checked:bg-accent"
  defp color_classes("info"), do: "peer-checked:bg-info"
  defp color_classes("success"), do: "peer-checked:bg-success"
  defp color_classes("warning"), do: "peer-checked:bg-warning"
  defp color_classes("error"), do: "peer-checked:bg-error"
end