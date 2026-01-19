defmodule PhoenixDuskmoon.Component.Form.Slider do
  @moduledoc """
  Slider component for range input.

  ## Examples

      <.dm_form for={@form} phx-submit="save">
        <.dm_slider field={@form[:volume]} label="Volume" min={0} max={100} />
        <.dm_slider field={@form[:brightness]} label="Brightness" min={0} max={100} color="success" />
      </.dm_form>

  """
  use Phoenix.Component

  @doc """
  Renders a range slider input.

  ## Examples

      <.dm_slider field={@form[:volume]} label="Volume" min={0} max={100} />
      <.dm_slider name="brightness" label="Brightness" value={50} />

  """
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
    <div class={["dm-form-group", @class]}>
      <div :if={@label} class="flex items-center justify-between mb-2">
        <label for={@id} class={["dm-label__text", @label_class]}>
          {@label}
        </label>
        <span :if={@show_value} class="text-sm font-medium opacity-70">
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
            "dm-range",
            "dm-range--#{@size}",
            "dm-range--#{@color}",
            @disabled && "opacity-50 cursor-not-allowed",
            @slider_class
          ]}
          {@rest}
        />
      </div>
      <div :if={@show_value} class="flex justify-between text-xs mt-1 opacity-60">
        <span>{@min}</span>
        <span>{@max}</span>
      </div>
    </div>
    """
  end
end
