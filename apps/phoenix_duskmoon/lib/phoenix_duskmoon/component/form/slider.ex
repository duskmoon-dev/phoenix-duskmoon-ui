defmodule PhoenixDuskmoon.Component.Form.Slider do
  @moduledoc """
  Slider component for range input.

  ## Examples

      <.dm_form for={@form} phx-submit="save">
        <.dm_slider field={@form[:volume]} label="Volume" min="0" max="100" />
        <.dm_slider field={@form[:brightness]} label="Brightness" min="0" max="100" color="success" />
      </.dm_form>

  ## Attributes

  * `field` - Phoenix form field
  * `label` - Slider label text
  * `min` - Minimum value (default: 0)
  * `max` - Maximum value (default: 100)
  * `step` - Step increment (default: 1)
  * `color` - Slider color: primary, secondary, accent, info, success, warning, error (default: primary)
  * `size` - Slider size: xs, sm, md, lg (default: md)
  * `disabled` - Disable the slider
  * `show_value` - Show current value (default: true)
  * `class` - Additional CSS classes
  * `label_class` - Additional CSS classes for label
  * `slider_class` - Additional CSS classes for slider element
  """

  use Phoenix.Component

  @doc type: :component
  attr(:id, :any, default: nil)
  attr(:name, :any)
  attr(:value, :any)
  attr(:field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form")
  attr(:label, :string, default: nil)
  attr(:min, :integer, default: 0)
  attr(:max, :integer, default: 100)
  attr(:step, :integer, default: 1)

  attr(:color, :string,
    default: "primary",
    values: ["primary", "secondary", "accent", "info", "success", "warning", "error"]
  )

  attr(:size, :string, default: "md", values: ["xs", "sm", "md", "lg"])
  attr(:disabled, :boolean, default: false)
  attr(:show_value, :boolean, default: true)
  attr(:class, :string, default: nil)
  attr(:label_class, :string, default: nil)
  attr(:slider_class, :string, default: nil)
  attr(:rest, :global)

  def dm_slider(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value || assigns.min end)
    |> dm_slider()
  end

  def dm_slider(assigns) do
    ~H"""
    <div class={@class}>
      <div class="flex items-center justify-between mb-2" :if={@label}>
        <label for={@id} class={["label-text", @label_class]}>
          {@label}
        </label>
        <span :if={@show_value} class="text-sm font-medium text-base-content/70">
          {@value}
        </span>
      </div>
      <div class="flex items-center gap-2">
        <input
          type="range"
          name={@name}
          id={@id}
          value={@value}
          min={@min}
          max={@max}
          step={@step}
          disabled={@disabled}
          class={[
            "range",
            size_classes(@size),
            color_classes(@color),
            @disabled && "opacity-50 cursor-not-allowed",
            @slider_class
          ]}
          {@rest}
        />
      </div>
      <div class="flex justify-between text-xs mt-1" :if={@show_value}>
        <span>{@min}</span>
        <span>{@max}</span>
      </div>
    </div>
    """
  end

  defp size_classes("xs"), do: "range-xs"
  defp size_classes("sm"), do: "range-sm"
  defp size_classes("md"), do: "range-md"
  defp size_classes("lg"), do: "range-lg"

  defp color_classes("primary"), do: "range-primary"
  defp color_classes("secondary"), do: "range-secondary"
  defp color_classes("accent"), do: "range-accent"
  defp color_classes("info"), do: "range-info"
  defp color_classes("success"), do: "range-success"
  defp color_classes("warning"), do: "range-warning"
  defp color_classes("error"), do: "range-error"
end
