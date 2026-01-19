defmodule PhoenixDuskmoon.Component.Progress do
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

  This component uses DaisyUI progress classes with additional styling for
  labels and animations. It supports both determinate and indeterminate
  progress states.
  """

  use Phoenix.Component

  @doc type: :component
  attr(:value, :integer, default: 0)
  attr(:max, :integer, default: 100)

  attr(:color, :string,
    default: "primary",
    values: ["primary", "secondary", "accent", "info", "success", "warning", "error"]
  )

  attr(:size, :string, default: "md", values: ["xs", "sm", "md", "lg"])
  attr(:show_label, :boolean, default: false)
  attr(:animated, :boolean, default: false)
  attr(:indeterminate, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:label_class, :string, default: nil)
  attr(:progress_class, :string, default: nil)
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
          Progress
        </span>
        <span class="text-sm font-medium">{@percentage}%</span>
      </div>

      <progress
        class={[
          "dm-progress dm-progress--#{@color}",
          size_classes(@size),
          @animated && "dm-progress--animated",
          @indeterminate && "dm-progress--indeterminate",
          @progress_class
        ]}
        value={@indeterminate && nil || @value}
        max={@max}
        {@rest}
      ></progress>

      <div :if={@show_label} class="text-sm text-base-content/70 mt-1">
        {@percentage}% Complete
      </div>
    </div>

    <style>
      /* Animated striped progress */
      .dm-progress--animated::-webkit-progress-value {
        background-image: linear-gradient(
          45deg,
          rgba(255, 255, 255, 0.2) 25%,
          transparent 25%,
          transparent 50%,
          rgba(255, 255, 255, 0.2) 50%,
          rgba(255, 255, 255, 0.2) 75%,
          transparent 75%,
          transparent
        );
        background-size: 1rem 1rem;
        animation: progress-bar-stripes 1s linear infinite;
      }

      .dm-progress--animated::-moz-progress-bar {
        background-image: linear-gradient(
          45deg,
          rgba(255, 255, 255, 0.2) 25%,
          transparent 25%,
          transparent 50%,
          rgba(255, 255, 255, 0.2) 50%,
          rgba(255, 255, 255, 0.2) 75%,
          transparent 75%,
          transparent
        );
        background-size: 1rem 1rem;
        animation: progress-bar-stripes 1s linear infinite;
      }

      @keyframes progress-bar-stripes {
        0% {
          background-position: 1rem 0;
        }
        100% {
          background-position: 0 0;
        }
      }

      /* Indeterminate progress */
      .dm-progress--indeterminate::-webkit-progress-value {
        background-image: linear-gradient(
          90deg,
          transparent,
          currentColor,
          transparent
        );
        animation: progress-indeterminate 2s ease-in-out infinite;
      }

      .dm-progress--indeterminate::-moz-progress-bar {
        background-image: linear-gradient(
          90deg,
          transparent,
          currentColor,
          transparent
        );
        animation: progress-indeterminate 2s ease-in-out infinite;
      }

      @keyframes progress-indeterminate {
        0% {
          left: -35%;
          right: 100%;
        }
        60% {
          left: 100%;
          right: -90%;
        }
        100% {
          left: 100%;
          right: -90%;
        }
      }
    </style>
    """
  end

  defp calculate_percentage(value, max) when max > 0 do
    (value / max * 100)
    |> Float.round(1)
    |> to_string()
  end

  defp calculate_percentage(_, _), do: "0"

  defp size_classes("xs"), do: "dm-progress--xs"
  defp size_classes("sm"), do: "dm-progress--sm"
  defp size_classes("md"), do: "dm-progress--md"
  defp size_classes("lg"), do: "dm-progress--lg"
end
