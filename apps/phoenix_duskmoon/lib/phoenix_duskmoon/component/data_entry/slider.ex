defmodule PhoenixDuskmoon.Component.DataEntry.Slider do
  @moduledoc """
  Slider component for range input.

  ## Examples

      <.dm_form for={@form} phx-submit="save">
        <.dm_slider field={@form[:volume]} label="Volume" min={0} max={100} />
        <.dm_slider field={@form[:brightness]} label="Brightness" min={0} max={100} color="success" />
        <.dm_slider field={@form[:volume]} label="Volume" vertical />
      </.dm_form>

  """
  use Phoenix.Component

  import PhoenixDuskmoon.Component.DataEntry.Form, only: [dm_error: 1]
  import PhoenixDuskmoon.Component.Helpers, only: [css_color: 1]

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
    values: ["primary", "secondary", "tertiary", "accent", "info", "success", "warning", "error"],
    doc: "color variant"
  )

  attr(:helper, :string, default: nil, doc: "helper text displayed below the slider")
  attr(:errors, :list, default: [], doc: "list of error messages to display")
  attr(:size, :string, default: "md", values: ["xs", "sm", "md", "lg"], doc: "slider size")
  attr(:disabled, :boolean, default: false, doc: "disables the slider")
  attr(:horizontal, :boolean, default: false, doc: "horizontal layout (label beside input)")

  attr(:state, :string,
    default: nil,
    values: [nil, "success", "warning"],
    doc: "validation state (applies form-group-success/warning)"
  )

  attr(:vertical, :boolean, default: false, doc: "render as a vertical slider")
  attr(:show_value, :boolean, default: true, doc: "show the current value and min/max labels")
  attr(:class, :any, default: nil, doc: "additional CSS classes for the wrapper")
  attr(:label_class, :any, default: nil, doc: "additional CSS classes for the label")
  attr(:slider_class, :any, default: nil, doc: "additional CSS classes for the range input")
  attr(:rest, :global)

  def dm_slider(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value || assigns.min end)
    |> dm_slider()
  end

  def dm_slider(assigns) do
    assigns = assign(assigns, :color, css_color(assigns.color))

    ~H"""
    <div class={[
      "form-group",
      @horizontal && "form-group-horizontal",
      @disabled && "form-group-disabled",
      @errors != [] && "form-group-error",
      @state && "form-group-#{@state}",
      @class
    ]} phx-feedback-for={@name}>
      <div :if={@label} class="flex items-center justify-between mb-2">
        <label for={@id} class={["form-label", @label_class]}>
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
          aria-disabled={@disabled && "true"}
          aria-invalid={@errors != [] && "true"}
          aria-describedby={
            (@errors != [] && @id && "#{@id}-errors") ||
              (@helper && @errors == [] && @id && "#{@id}-helper")
          }
          class={[
            "slider",
            "slider-#{@size}",
            "slider-#{@color}",
            @vertical && "slider-vertical",
            @slider_class
          ]}
          {@rest}
        />
      </div>
      <div :if={@show_value} class="slider-labels">
        <span>{@min}</span>
        <span>{@max}</span>
      </div>
      <span :if={@helper && @errors == []} id={@id && "#{@id}-helper"} class={["helper-text", @state && "helper-text-#{@state}"]}>{@helper}</span>
      <div :if={@errors != []} id={@id && "#{@id}-errors"}>
        <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
      </div>
    </div>
    """
  end
end
