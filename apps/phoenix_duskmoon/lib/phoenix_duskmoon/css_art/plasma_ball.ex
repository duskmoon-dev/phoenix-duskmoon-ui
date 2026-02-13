defmodule PhoenixDuskmoon.CssArt.PlasmaBall do
  @moduledoc """
  Interactive plasma ball component with animated electricity effects.

  ## Examples

      # Basic usage
      <.dm_art_plasma_ball
        id="plasma-ball-1"
        size="medium"
        base_color="#222222"
      />

      # With phx-click and phx-target for use within a LiveComponent
      <.dm_art_plasma_ball
        id="plasma-ball-2"
        size="large"
        base_color="#1a1a2e"
        phx-click="plasma_toggle"
        phx-target={@myself}
        show_electrode={false}
      />

  ## Attributes

  * `id` - Component ID (required)
  * `size` - Size preset: small (250px), medium (350px), large (450px) (default: medium)
  * `base_color` - Base color of the plasma ball (default: "#222222")
  * `show_electrode` - Show bottom electrode (default: true)
  * `class` - Additional CSS classes
  * `phx_target` - LiveView target for events

  ## Styling

  This component uses the `dm-art-plasma-ball` CSS class from the plasma-ball.css file.
  It creates an interactive plasma ball with animated electricity effects that respond
  to hover and click interactions.
  """

  use Phoenix.Component

  @doc type: :component
  attr(:id, :string, required: true)
  attr(:size, :string, default: "medium", values: ["small", "medium", "large"])
  attr(:base_color, :string, default: "#222222")
  attr(:show_electrode, :boolean, default: true)
  attr(:class, :string, default: nil)
  attr(:phx_target, :any, default: nil)

  attr(:toggle_label, :string,
    default: "Toggle plasma effect",
    doc: "Accessible label for the toggle switch"
  )

  attr(:rest, :global)

  def dm_art_plasma_ball(assigns) do
    assigns
    |> assign(size_px: size_to_pixels(assigns.size))
    |> render_plasma_ball()
  end

  defp render_plasma_ball(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "dm-art-plasma-ball",
        @class
      ]}
      style={"--size: #{@size_px}px; --base-color: #{@base_color};"}
      phx-click="plasma_toggle"
      phx-target={@phx_target}
      {@rest}
    >
      <!-- Base structure -->
      <div class="base">
        <div></div>
        <div></div>
        <span></span>
      </div>

      <!-- Toggle switch -->
      <input type="checkbox" class="switcher" aria-label={@toggle_label} phx-target={@phx_target} />

      <!-- Glass ball with effects -->
      <div class="glassball">
        <!-- Electrode -->
        <div class={["electrode", !@show_electrode && "hide-electrode"]}></div>

        <!-- Electricity rays -->
        <div class="rays">
          <div class="ray"><span></span><span></span><span></span><span></span></div>
          <div class="ray bigwave"><span></span><span></span><span></span><span></span></div>
          <div class="ray"><span></span><span></span><span></span><span></span></div>
          <div class="ray"><span></span><span></span><span></span><span></span></div>
          <div class="ray"><span></span><span></span><span></span><span></span></div>
        </div>
        <div class="rays">
          <div class="ray"><span></span><span></span><span></span><span></span></div>
          <div class="ray bigwave"><span></span><span></span><span></span><span></span></div>
          <div class="ray"><span></span><span></span><span></span><span></span></div>
          <div class="ray"><span></span><span></span><span></span><span></span></div>
          <div class="ray"><span></span><span></span><span></span><span></span></div>
        </div>
        <div class="rays">
          <div class="ray"><span></span><span></span><span></span><span></span></div>
          <div class="ray bigwave"><span></span><span></span><span></span><span></span></div>
          <div class="ray"><span></span><span></span><span></span><span></span></div>
          <div class="ray"><span></span><span></span><span></span><span></span></div>
          <div class="ray"><span></span><span></span><span></span><span></span></div>
        </div>
        <div class="rays">
          <div class="ray"><span></span><span></span><span></span><span></span></div>
          <div class="ray bigwave"><span></span><span></span><span></span><span></span></div>
          <div class="ray"><span></span><span></span><span></span><span></span></div>
          <div class="ray"><span></span><span></span><span></span><span></span></div>
          <div class="ray"><span></span><span></span><span></span><span></span></div>
        </div>
      </div>

      <!-- Switch button -->
      <div class="switch"></div>
    </div>
    """
  end

  defp size_to_pixels("small"), do: 250
  defp size_to_pixels("medium"), do: 350
  defp size_to_pixels("large"), do: 450
end
