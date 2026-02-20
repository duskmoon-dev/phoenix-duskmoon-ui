defmodule PhoenixDuskmoon.Component.Navigation.Steps do
  @moduledoc """
  Steps/stepper component using el-dm-stepper custom element.

  Displays a sequence of steps showing progress through a multi-step process.

  ## Examples

      <.dm_steps current={1} steps={[
        %{label: "Account"},
        %{label: "Profile"},
        %{label: "Review"}
      ]} />

      <.dm_steps current={0} orientation="vertical" color="success" clickable steps={[
        %{label: "Step 1", description: "Create account"},
        %{label: "Step 2", description: "Fill profile"},
        %{label: "Step 3", description: "Submit"}
      ]} />

  """

  use Phoenix.Component

  @doc """
  Renders a stepper component.

  ## Examples

      <.dm_steps current={2} steps={[
        %{label: "Sign Up"},
        %{label: "Verify"},
        %{label: "Complete"}
      ]} />

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:current, :integer, default: 0, doc: "0-based index of the current step")

  attr(:orientation, :string,
    default: "horizontal",
    values: ["horizontal", "vertical"],
    doc: "Layout direction"
  )

  attr(:color, :string,
    default: "primary",
    values: ["primary", "secondary", "tertiary", "accent", "success", "warning", "error", "info"],
    doc: "Color theme"
  )

  attr(:clickable, :boolean, default: false, doc: "Whether steps are clickable for navigation")

  attr(:steps, :list,
    required: true,
    doc: "List of step maps with :label, optional :description and :icon"
  )

  attr(:rest, :global)

  def dm_steps(assigns) do
    assigns =
      assigns
      |> assign(:color, css_color(assigns.color))
      |> assign(:steps_json, Jason.encode!(assigns.steps))

    ~H"""
    <el-dm-stepper
      id={@id}
      steps={@steps_json}
      current={@current}
      orientation={@orientation}
      color={@color}
      clickable={@clickable}
      class={@class}
      {@rest}
    >
    </el-dm-stepper>
    """
  end

  defp css_color("accent"), do: "tertiary"
  defp css_color(color), do: color
end
