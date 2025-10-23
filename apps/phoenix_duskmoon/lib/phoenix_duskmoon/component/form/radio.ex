defmodule PhoenixDuskmoon.Component.Form.Radio do
  @moduledoc """
  Radio button component for single selection.

  ## Examples

      <.dm_form for={@form} phx-submit="save">
        <.dm_radio field={@form[:theme]} value="light" label="Light theme" />
        <.dm_radio field={@form[:theme]} value="dark" label="Dark theme" color="secondary" />
        <.dm_radio field={@form[:theme]} value="auto" label="Auto theme" size="lg" />
      </.dm_form>

  ## Attributes

  * `field` - Phoenix form field
  * `value` - Radio button value
  * `label` - Radio button label text
  * `size` - Radio size: xs, sm, md, lg (default: md)
  * `color` - Radio color: primary, secondary, accent, info, success, warning, error (default: primary)
  * `disabled` - Disable the radio button
  * `class` - Additional CSS classes
  * `label_class` - Additional CSS classes for label
  * `radio_class` - Additional CSS classes for radio element
  """

  use Phoenix.Component

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
  attr(:radio_class, :string, default: nil)
  attr(:rest, :global)

  def dm_radio(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:checked, fn -> field.value == assigns.value end)
    |> dm_radio()
  end

  def dm_radio(assigns) do
    ~H"""
    <div class={@class}>
      <label class="flex items-center gap-2 cursor-pointer">
        <input
          type="radio"
          name={@name}
          id={@id}
          value={@value}
          checked={@checked}
          disabled={@disabled}
          class={[
            "radio",
            size_classes(@size),
            color_classes(@color),
            @disabled && "opacity-50 cursor-not-allowed",
            @radio_class
          ]}
          {@rest}
        />
        <span :if={@label} class={["label-text", @label_class]}>
          {@label}
        </span>
      </label>
    </div>
    """
  end

  defp size_classes("xs"), do: "radio-xs"
  defp size_classes("sm"), do: "radio-sm"
  defp size_classes("md"), do: "radio-md"
  defp size_classes("lg"), do: "radio-lg"

  defp color_classes("primary"), do: "radio-primary"
  defp color_classes("secondary"), do: "radio-secondary"
  defp color_classes("accent"), do: "radio-accent"
  defp color_classes("info"), do: "radio-info"
  defp color_classes("success"), do: "radio-success"
  defp color_classes("warning"), do: "radio-warning"
  defp color_classes("error"), do: "radio-error"
end
