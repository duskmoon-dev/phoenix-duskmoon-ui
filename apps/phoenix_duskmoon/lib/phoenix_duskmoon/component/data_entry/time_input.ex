defmodule PhoenixDuskmoon.Component.DataEntry.TimeInput do
  @moduledoc """
  Time input component using `@duskmoon-dev/core` CSS classes.

  Renders a segmented time input with separate fields for hours, minutes,
  and optionally seconds and AM/PM period toggle.

  ## Examples

      <.dm_time_input />

      <.dm_time_input
        show_seconds
        show_period
        color="primary"
        size="lg"
      />

  """

  use Phoenix.Component

  import PhoenixDuskmoon.Component.DataEntry.Form, only: [dm_error: 1]

  @doc """
  Renders a time input with segmented hour/minute/second fields.

  ## Examples

      <.dm_time_input name="start_time" />

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:name, :string, default: nil, doc: "Form name attribute")
  attr(:value, :string, default: nil, doc: "Time value (HH:MM or HH:MM:SS)")
  attr(:field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form")
  attr(:disabled, :boolean, default: false, doc: "Whether the input is disabled")

  attr(:size, :string,
    default: nil,
    values: [nil, "sm", "lg"],
    doc: "Size variant"
  )

  attr(:color, :string,
    default: nil,
    values: [
      nil,
      "primary",
      "secondary",
      "tertiary",
      "accent",
      "info",
      "success",
      "warning",
      "error"
    ],
    doc: "Color variant"
  )

  attr(:variant, :string,
    default: nil,
    values: [nil, "filled"],
    doc: "Style variant"
  )

  attr(:error, :boolean, default: false, doc: "Error state")
  attr(:errors, :list, default: [], doc: "list of error messages to display")
  attr(:helper, :string, default: nil, doc: "helper text displayed below the component")
  attr(:show_seconds, :boolean, default: false, doc: "Show seconds segment")
  attr(:show_period, :boolean, default: false, doc: "Show AM/PM toggle")
  attr(:rest, :global)

  def dm_time_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:name, field.name)
    |> assign(:value, field.value)
    |> dm_time_input()
  end

  def dm_time_input(assigns) do
    assigns = assign(assigns, :color, css_color(assigns.color))

    ~H"""
    <div phx-feedback-for={@name}>
      <div
        id={@id}
        class={[
          "time-input",
          @size && "time-input-#{@size}",
          @color && "time-input-#{@color}",
          @variant && "time-input-#{@variant}",
          (@error || @errors != []) && "time-input-error",
          @class
        ]}
        role="group"
        aria-label="Time input"
        aria-invalid={@errors != [] && "true"}
        aria-describedby={
          (@errors != [] && @id && "#{@id}-errors") ||
            (@helper && @errors == [] && @id && "#{@id}-helper")
        }
        {@rest}
      >
        <div class="time-input-segments">
          <input
            type="text"
            class="time-input-segment"
            placeholder="HH"
            maxlength="2"
            inputmode="numeric"
            aria-label="Hours"
            disabled={@disabled}
            name={@name && "#{@name}[hour]"}
          />
          <span class="time-input-separator">:</span>
          <input
            type="text"
            class="time-input-segment"
            placeholder="MM"
            maxlength="2"
            inputmode="numeric"
            aria-label="Minutes"
            disabled={@disabled}
            name={@name && "#{@name}[minute]"}
          />
          <span :if={@show_seconds} class="time-input-separator">:</span>
          <input
            :if={@show_seconds}
            type="text"
            class="time-input-segment"
            placeholder="SS"
            maxlength="2"
            inputmode="numeric"
            aria-label="Seconds"
            disabled={@disabled}
            name={@name && "#{@name}[second]"}
          />
        </div>
        <div :if={@show_period} class="time-input-period">
          <button type="button" class="time-input-period-btn" disabled={@disabled}>AM</button>
          <button type="button" class="time-input-period-btn" disabled={@disabled}>PM</button>
        </div>
      </div>
      <span :if={@helper && @errors == []} id={@id && "#{@id}-helper"} class="helper-text">{@helper}</span>
      <div :if={@errors != []} id={@id && "#{@id}-errors"}>
        <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
      </div>
    </div>
    """
  end

  defp css_color("accent"), do: "tertiary"
  defp css_color(color), do: color
end
