defmodule PhoenixDuskmoon.Component.DataDisplay.Progress do
  @moduledoc """
  Progress component for showing completion status.

  Supports both linear (bar) and circular (ring) variants.

  ## Examples

      <.dm_progress value={75} max={100} />

      <.dm_progress value={30} max={100} color="success" />

      <.dm_progress value={60} max={100} size="lg" color="warning" show_label />

      <.dm_progress type="circular" value={75} max={100} color="primary" show_label />

      <.dm_progress type="circular" indeterminate color="secondary" />

  ## Styling

  This component uses `@duskmoon-dev/core` progress classes with additional
  styling for labels and animations. It supports both determinate and
  indeterminate progress states, in linear and circular form.
  """

  use Phoenix.Component
  import PhoenixDuskmoon.Component.Helpers, only: [css_color: 1]

  @circle_radius 16
  @circle_circumference 2 * :math.pi() * @circle_radius

  @doc type: :component
  attr(:type, :string,
    default: "linear",
    values: ["linear", "circular"],
    doc: "Progress type: linear bar or circular ring"
  )

  attr(:value, :integer, default: 0, doc: "Current progress value")
  attr(:max, :integer, default: 100, doc: "Maximum progress value")

  attr(:color, :string,
    default: "primary",
    values: ["primary", "secondary", "tertiary", "accent", "info", "success", "warning", "error"],
    doc: "Progress color variant"
  )

  attr(:size, :string,
    default: "md",
    values: ["xs", "sm", "md", "lg", "xl"],
    doc: "Progress size"
  )

  attr(:show_label, :boolean, default: false, doc: "Show percentage label above/below the bar")

  attr(:inline_label, :boolean,
    default: false,
    doc: "Show percentage label inside the bar (linear only)"
  )

  attr(:striped, :boolean, default: false, doc: "Show striped pattern (linear only)")

  attr(:animated, :boolean,
    default: false,
    doc: "Animate the stripes (implies striped, linear only)"
  )

  attr(:indeterminate, :boolean, default: false, doc: "Show indeterminate progress")
  attr(:class, :any, default: nil, doc: "Additional CSS classes for the wrapper")
  attr(:label_class, :string, default: nil, doc: "CSS classes for the label")
  attr(:progress_class, :string, default: nil, doc: "CSS classes for the progress element")
  attr(:label_text, :string, default: "Progress", doc: "Text for the progress label")
  attr(:complete_text, :string, default: "Complete", doc: "Text appended after percentage")
  attr(:rest, :global)

  def dm_progress(assigns) do
    assigns
    |> assign(:color, css_color(assigns.color))
    |> assign(percentage: calculate_percentage(assigns.value, assigns.max))
    |> then(fn a ->
      case a.type do
        "circular" -> render_circular(a)
        _ -> render_linear(a)
      end
    end)
  end

  defp render_linear(assigns) do
    ~H"""
    <div class={@class}>
      <div :if={@show_label} class="flex justify-between items-center mb-2">
        <span class={@label_class}>
          {@label_text}
        </span>
        <span class="text-sm font-medium">{@percentage}%</span>
      </div>

      <div
        role="progressbar"
        class={[
          "progress",
          "progress-#{@color}",
          linear_size_classes(@size),
          @inline_label && "progress-labeled",
          (@striped || @animated) && "progress-striped",
          @animated && "progress-animated",
          @indeterminate && "progress-indeterminate",
          @progress_class
        ]}
        aria-valuenow={if(!@indeterminate, do: @value)}
        aria-valuemin={0}
        aria-valuemax={@max}
        aria-label={if(!@show_label && !@inline_label, do: @label_text)}
        {@rest}
      >
        <div
          class="progress-bar"
          style={if(!@indeterminate, do: "width: #{@percentage}%")}
        ></div>
        <span :if={@inline_label} class="progress-label">{@percentage}%</span>
      </div>

      <div :if={@show_label} class="text-sm text-on-surface-variant mt-1">
        {@percentage}% {@complete_text}
      </div>
    </div>
    """
  end

  defp render_circular(assigns) do
    circumference = @circle_circumference
    fraction = calculate_fraction(assigns.value, assigns.max)
    dash_offset = circumference * (1 - fraction)

    assigns =
      assigns
      |> assign(:circumference, Float.round(circumference, 2))
      |> assign(:dash_offset, Float.round(dash_offset, 2))

    ~H"""
    <div class={@class}>
      <div
        class={[
          "progress-circular",
          circular_size_classes(@size),
          @indeterminate && "progress-circular-indeterminate",
          @progress_class
        ]}
        role="progressbar"
        aria-valuenow={if(!@indeterminate, do: @value)}
        aria-valuemin={0}
        aria-valuemax={@max}
        aria-label={if(!@show_label, do: @label_text)}
        {@rest}
      >
        <svg viewBox="0 0 36 36">
          <circle class="progress-circular-track" cx="18" cy="18" r="16" />
          <circle
            class="progress-circular-bar"
            cx="18"
            cy="18"
            r="16"
            stroke-dasharray={if(!@indeterminate, do: @circumference)}
            stroke-dashoffset={if(!@indeterminate, do: @dash_offset)}
            style={"stroke: var(--color-#{@color})"}
          />
        </svg>
        <span :if={@show_label} class="progress-circular-label">
          {@percentage}%
        </span>
      </div>
    </div>
    """
  end

  defp calculate_percentage(value, max) when max > 0 do
    (value / max * 100)
    |> Float.round(1)
    |> to_string()
  end

  defp calculate_percentage(_, _), do: "0"

  defp calculate_fraction(value, max) when max > 0 do
    min(value / max, 1.0)
  end

  defp calculate_fraction(_, _), do: 0.0

  defp linear_size_classes("xs"), do: "progress-xs"
  defp linear_size_classes("sm"), do: "progress-sm"
  defp linear_size_classes("md"), do: nil
  defp linear_size_classes("lg"), do: "progress-lg"
  defp linear_size_classes("xl"), do: "progress-xl"

  defp circular_size_classes("xs"), do: "progress-circular-sm"
  defp circular_size_classes("sm"), do: "progress-circular-sm"
  defp circular_size_classes("md"), do: nil
  defp circular_size_classes("lg"), do: "progress-circular-lg"
  defp circular_size_classes("xl"), do: "progress-circular-xl"
end
