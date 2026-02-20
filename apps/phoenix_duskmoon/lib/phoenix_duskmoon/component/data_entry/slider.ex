defmodule PhoenixDuskmoon.Component.DataEntry.Slider do
  @moduledoc """
  Slider component for range input.

  ## Examples

      <.dm_form for={@form} phx-submit="save">
        <.dm_slider field={@form[:volume]} label="Volume" min={0} max={100} />
        <.dm_slider field={@form[:brightness]} label="Brightness" min={0} max={100} color="success" />
      </.dm_form>

  """
  use Phoenix.Component

  import PhoenixDuskmoon.Component.DataEntry.Form

  @doc """
  Renders a range slider input.

  ## Examples

      <.dm_slider field={@form[:volume]} label="Volume" min={0} max={100} />
      <.dm_slider name="brightness" label="Brightness" value={50} />

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:name, :any, doc: "HTML name attribute for form submission")
  attr(:value, :any, doc: "current slider value")
  attr(:field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form")
  attr(:label, :string, default: nil, doc: "text label displayed above the slider")
  attr(:min, :integer, default: 0, doc: "minimum allowed value")
  attr(:max, :integer, default: 100, doc: "maximum allowed value")
  attr(:step, :integer, default: 1, doc: "step increment between values")

  attr(:color, :string,
    default: "primary",
    values: ["primary", "secondary", "accent", "info", "success", "warning", "error"],
    doc: "color variant"
  )

  attr(:errors, :list, default: [], doc: "list of error messages to display")
  attr(:size, :string, default: "md", values: ["xs", "sm", "md", "lg"], doc: "slider size")
  attr(:disabled, :boolean, default: false, doc: "disables the slider")
  attr(:show_value, :boolean, default: true, doc: "show the current value and min/max labels")
  attr(:class, :string, default: nil, doc: "additional CSS classes for the wrapper")
  attr(:label_class, :string, default: nil, doc: "additional CSS classes for the label")
  attr(:slider_class, :string, default: nil, doc: "additional CSS classes for the range input")
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
          aria-invalid={@errors != [] && "true"}
          aria-describedby={@errors != [] && @id && "#{@id}-errors"}
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
      <div :if={@errors != []} id={@id && "#{@id}-errors"}>
        <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
      </div>
    </div>
    """
  end
end
