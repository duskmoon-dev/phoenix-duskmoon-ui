defmodule PhoenixDuskmoon.Component.Fun.Eclipse do
  @moduledoc """
  Animated eclipse visual effect component.

  ## Examples

      <.dm_fun_eclipse
        id="eclipse-1"
        size="medium"
        bg_color="#09090b"
        class="mx-auto"
      />

      <.dm_fun_eclipse
        id="eclipse-2"
        size="large"
        bg_color="#000000"
        animation_speed="slow"
      />

  ## Attributes

  * `id` - Component ID (required)
  * `size` - Size preset: small (400px), medium (600px), large (800px) (default: medium)
  * `bg_color` - Background color of the eclipse (default: "#09090b")
  * `animation_speed` - Animation speed multiplier (default: 1.0)
  * `class` - Additional CSS classes

  ## Styling

  This component uses the `dm-fun-eclipse` CSS class from the eclipse.css file.
  It creates a beautiful animated eclipse effect with multiple rotating layers
  that create a celestial eclipse visualization.

  The animation consists of 6 layers with different rotation speeds and directions:
  - Layer 1: Fast forward rotation (30s base)
  - Layer 2: Medium reverse rotation (20s base)
  - Layer 3: Medium forward rotation (20s base)
  - Layer 4: Slow reverse rotation (40s base)
  - Layer 5: Slow forward rotation (40s base)
  - Layer 6: Static background layer with gradient effects
  """

  use Phoenix.Component

  @doc type: :component
  attr(:id, :string, required: true)
  attr(:size, :string, default: "medium", values: ["small", "medium", "large"])
  attr(:bg_color, :string, default: "#09090b")
  attr(:animation_speed, :float, default: 1.0)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def dm_fun_eclipse(assigns) do
    speed = max(assigns.animation_speed, 0.01)

    assigns
    |> assign(size_px: size_to_pixels(assigns.size))
    |> assign(
      layer_1_duration: round(30 / speed),
      layer_2_duration: round(20 / speed),
      layer_3_duration: round(20 / speed),
      layer_4_duration: round(40 / speed),
      layer_5_duration: round(40 / speed)
    )
    |> render_eclipse()
  end

  defp render_eclipse(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "dm-fun-eclipse",
        @class
      ]}
      style={"--size: #{@size_px}px; --bg-color: #{@bg_color};"}
      {@rest}
    >
      <!-- Layer 1: Fast rotating layer -->
      <div
        class="layer layer-1"
        style={"animation-duration: #{@layer_1_duration}s"}
      ></div>

      <!-- Layer 2: Medium reverse rotating layer -->
      <div
        class="layer layer-2"
        style={"animation-duration: #{@layer_2_duration}s"}
      ></div>

      <!-- Layer 3: Medium forward rotating layer -->
      <div
        class="layer layer-3"
        style={"animation-duration: #{@layer_3_duration}s"}
      ></div>

      <!-- Layer 4: Slow reverse rotating layer -->
      <div
        class="layer layer-4"
        style={"animation-duration: #{@layer_4_duration}s"}
      ></div>

      <!-- Layer 5: Slow forward rotating layer -->
      <div
        class="layer layer-5"
        style={"animation-duration: #{@layer_5_duration}s"}
      ></div>

      <!-- Layer 6: Static background layer with complex gradients -->
      <div class="layer layer-6"></div>
    </div>
    """
  end

  defp size_to_pixels("small"), do: 400
  defp size_to_pixels("medium"), do: 600
  defp size_to_pixels("large"), do: 800
end
