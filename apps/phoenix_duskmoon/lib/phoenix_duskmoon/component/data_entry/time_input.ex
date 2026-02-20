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
  attr(:disabled, :boolean, default: false, doc: "Whether the input is disabled")

  attr(:size, :string,
    default: nil,
    values: [nil, "sm", "lg"],
    doc: "Size variant"
  )

  attr(:color, :string,
    default: nil,
    values: [nil, "primary", "secondary", "tertiary"],
    doc: "Color variant"
  )

  attr(:variant, :string,
    default: nil,
    values: [nil, "filled"],
    doc: "Style variant"
  )

  attr(:error, :boolean, default: false, doc: "Error state")
  attr(:show_seconds, :boolean, default: false, doc: "Show seconds segment")
  attr(:show_period, :boolean, default: false, doc: "Show AM/PM toggle")
  attr(:rest, :global)

  def dm_time_input(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "time-input",
        @size && "time-input-#{@size}",
        @color && "time-input-#{@color}",
        @variant && "time-input-#{@variant}",
        @error && "time-input-error",
        @class
      ]}
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
    """
  end
end
