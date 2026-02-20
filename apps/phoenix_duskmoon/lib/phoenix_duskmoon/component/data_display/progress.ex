defmodule PhoenixDuskmoon.Component.DataDisplay.Progress do
  @moduledoc """
  Progress bar component for showing completion status.

  ## Examples

      <.dm_progress value={75} max={100} />

      <.dm_progress value={30} max={100} color="success" />

      <.dm_progress value={60} max={100} size="lg" color="warning" show_label />

      <.dm_progress value={@upload_progress} max={100} color="primary" animated />

  ## Attributes

  * `value` - Current progress value (default: 0)
  * `max` - Maximum progress value (default: 100)
  * `color` - Progress color: primary, secondary, accent, info, success, warning, error (default: primary)
  * `size` - Progress size: xs, sm, md, lg (default: md)
  * `show_label` - Show percentage label (default: false)
  * `animated` - Add striped animation effect (default: false)
  * `indeterminate` - Show indeterminate progress animation (default: false)
  * `class` - Additional CSS classes
  * `label_class` - Additional CSS classes for label
  * `progress_class` - Additional CSS classes for progress element

  ## Styling

  This component uses `@duskmoon-dev/core` progress classes with additional
  styling for labels and animations. It supports both determinate and
  indeterminate progress states.
  """

  use Phoenix.Component

  @doc type: :component
  attr(:value, :integer, default: 0, doc: "Current progress value")
  attr(:max, :integer, default: 100, doc: "Maximum progress value")

  attr(:color, :string,
    default: "primary",
    values: ["primary", "secondary", "accent", "info", "success", "warning", "error"],
    doc: "Progress bar color variant"
  )

  attr(:size, :string, default: "md", values: ["xs", "sm", "md", "lg"], doc: "Progress bar size")
  attr(:show_label, :boolean, default: false, doc: "Show percentage label")
  attr(:animated, :boolean, default: false, doc: "Enable animation")
  attr(:indeterminate, :boolean, default: false, doc: "Show indeterminate progress")
  attr(:class, :string, default: nil, doc: "Additional CSS classes for the wrapper")
  attr(:label_class, :string, default: nil, doc: "CSS classes for the label")
  attr(:progress_class, :string, default: nil, doc: "CSS classes for the progress bar")
  attr(:label_text, :string, default: "Progress", doc: "Text for the progress label")
  attr(:complete_text, :string, default: "Complete", doc: "Text appended after percentage")
  attr(:rest, :global)

  def dm_progress(assigns) do
    assigns
    |> assign(percentage: calculate_percentage(assigns.value, assigns.max))
    |> render_progress()
  end

  defp render_progress(assigns) do
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
          size_classes(@size),
          @animated && "progress-striped progress-animated",
          @indeterminate && "progress-indeterminate",
          @progress_class
        ]}
        aria-valuenow={if(!@indeterminate, do: @value)}
        aria-valuemin={0}
        aria-valuemax={@max}
        aria-label={if(!@show_label, do: @label_text)}
        {@rest}
      >
        <div
          class="progress-bar"
          style={if(!@indeterminate, do: "width: #{@percentage}%")}
        ></div>
      </div>

      <div :if={@show_label} class="text-sm text-[var(--color-on-surface-variant)] mt-1">
        {@percentage}% {@complete_text}
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

  defp size_classes("xs"), do: "progress-xs"
  defp size_classes("sm"), do: "progress-sm"
  defp size_classes("md"), do: nil
  defp size_classes("lg"), do: "progress-lg"
end
