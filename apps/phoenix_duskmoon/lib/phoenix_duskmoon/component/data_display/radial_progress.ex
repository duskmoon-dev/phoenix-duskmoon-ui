defmodule PhoenixDuskmoon.Component.DataDisplay.RadialProgress do
  @moduledoc """
  Determinate percentage progress using Core's conic-gradient ring.
  Values are bounded to 0–100 for both visual presentation and accessibility.

      <.dm_radial_progress value={72} label="Upload progress" />
  """
  use Phoenix.Component

  @doc "Renders a named progressbar with matching visual and accessible values."
  @doc type: :component
  attr(:id, :any, default: nil)
  attr(:value, :integer, required: true)
  attr(:label, :string, required: true)
  attr(:size, :string, default: "md", values: ~w(sm md lg xl))

  attr(:color, :string,
    default: "primary",
    values: ~w(primary secondary tertiary info success warning error)
  )

  attr(:show_label, :boolean, default: true)
  attr(:class, :any, default: nil)
  attr(:style, :string, default: nil, doc: "Additional CSS declarations before the managed value")
  attr(:rest, :global)

  def dm_radial_progress(assigns) do
    assigns = assign(assigns, :value, min(100, max(0, assigns.value)))

    ~H"""
    <div id={@id} class={["radial-progress", "radial-progress-#{@color}", @size != "md" && "radial-progress-#{@size}", @class]} style={Enum.join(Enum.reject([@style, "--radial-progress-value: #{@value}"], &is_nil/1), "; ")} role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow={@value} aria-label={@label} {@rest}>
      <span :if={@show_label} class="relative z-10" aria-hidden="true">{@value}%</span>
    </div>
    """
  end
end
