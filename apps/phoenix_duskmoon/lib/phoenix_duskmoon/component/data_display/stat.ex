defmodule PhoenixDuskmoon.Component.DataDisplay.Stat do
  @moduledoc """
  Stat component for displaying key metrics and statistics.

  A simple data display component that shows a label, value, and optional
  description. Built with Tailwind utility classes and theme color variables.

  ## Examples

      <.dm_stat title="Revenue" value="$1.2M" />

      <.dm_stat title="Users" value="2,345" description="↑ 12% from last month" color="success" />

      <.dm_stat title="Errors" value="3" color="error">
        <:icon><.dm_mdi name="alert-circle" class="w-6 h-6" /></:icon>
      </.dm_stat>
  """

  use Phoenix.Component

  @doc """
  Renders a stat display with title, value, and optional description.

  ## Examples

      <.dm_stat title="Total Users" value="1,234" />
      <.dm_stat title="Revenue" value="$45.6K" description="+12.3%" color="success" />
  """
  @doc type: :component
  attr(:id, :any, default: nil)
  attr(:class, :string, default: nil)
  attr(:title, :string, required: true, doc: "Label/title for the stat")
  attr(:value, :string, required: true, doc: "The main value to display")
  attr(:description, :string, default: nil, doc: "Optional description or change indicator")

  attr(:color, :string,
    default: nil,
    values: [nil, "primary", "secondary", "accent", "info", "success", "warning", "error"]
  )

  attr(:size, :string, default: "md", values: ["sm", "md", "lg"])
  attr(:rest, :global)

  slot(:icon, doc: "Optional icon displayed alongside the value")

  def dm_stat(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "flex gap-3 p-4",
        @class
      ]}
      {@rest}
    >
      <div :if={@icon != []} class={["shrink-0", value_color(@color)]}>
        {render_slot(@icon)}
      </div>
      <dl>
        <dt class={["text-on-surface-variant", title_size(@size)]}>{@title}</dt>
        <dd class={["font-semibold tracking-tight", value_color(@color), value_size(@size)]}>
          {@value}
        </dd>
        <p :if={@description} class={["text-sm text-on-surface-variant", desc_color(@color)]}>
          {@description}
        </p>
      </dl>
    </div>
    """
  end

  defp title_size("sm"), do: "text-xs"
  defp title_size("md"), do: "text-sm"
  defp title_size("lg"), do: "text-base"

  defp value_size("sm"), do: "text-lg"
  defp value_size("md"), do: "text-2xl"
  defp value_size("lg"), do: "text-4xl"

  defp value_color(nil), do: nil
  defp value_color("primary"), do: "text-primary"
  defp value_color("secondary"), do: "text-secondary"
  defp value_color("accent"), do: "text-accent"
  defp value_color("info"), do: "text-info"
  defp value_color("success"), do: "text-success"
  defp value_color("warning"), do: "text-warning"
  defp value_color("error"), do: "text-error"

  defp desc_color(nil), do: nil
  defp desc_color("success"), do: "text-success"
  defp desc_color("error"), do: "text-error"
  defp desc_color("warning"), do: "text-warning"
  defp desc_color(_), do: nil
end
