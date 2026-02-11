defmodule PhoenixDuskmoon.Component.Fun.Snow do
  @moduledoc """
  Snowflake animation component for creating winter/fall effects.

  ## Examples

      <.dm_fun_snow
        id="snow-1"
        count="50"
        container_class="h-screen relative overflow-hidden"
      />

      <.dm_fun_snow
        id="snow-2"
        count="20"
        size_range={{5, 15}}
        color="#FFFFFF"
        use_unicode={true}
        animation_duration={{10, 30}}
      />

  ## Attributes

  * `id` - Component ID (required)
  * `count` - Number of snowflakes (default: 30)
  * `size_range` - Tuple of {min_size, max_size} in pixels (default: {5, 20})
  * `color` - Snowflake color (default: "#FFFFFF")
  * `use_unicode` - Use Unicode snowflake character instead of circles (default: false)
  * `animation_duration` - Tuple of {min_duration, max_duration} in seconds (default: {5, 15})
  * `container_class` - CSS class for the container (default: "relative w-full h-full")
  * `snowflake_class` - Additional CSS classes for individual snowflakes

  ## Usage Notes

  This component creates animated snowflakes that fall from top to bottom.
  Each snowflake has randomized properties for natural-looking animation.
  The component is container-relative, so it works within any positioned container.

  ## LiveView Integration

  You can dynamically control the snow effect:
  ```elixir
  def handle_event("toggle_snow", _, socket) do
    {:noreply, assign(socket, snow_enabled: !socket.assigns.snow_enabled)}
  end
  ```
  """

  use Phoenix.Component

  @doc type: :component
  attr(:id, :string, required: true)
  attr(:count, :integer, default: 30)
  attr(:size_range, :any, default: {5, 20})
  attr(:color, :string, default: "#FFFFFF")
  attr(:use_unicode, :boolean, default: false)
  attr(:animation_duration, :any, default: {5, 15})
  attr(:container_class, :string, default: "relative w-full h-full")
  attr(:snowflake_class, :string, default: nil)
  attr(:rest, :global)

  def dm_fun_snow(assigns) do
    assigns
    |> assign(
      snowflakes:
        generate_snowflakes(assigns.count, assigns.size_range, assigns.animation_duration)
    )
    |> render_snow()
  end

  defp render_snow(assigns) do
    ~H"""
    <div
      id={@id}
      class={[@container_class, "overflow-hidden"]}
      {@rest}
    >
      <div
        :for={{snowflake, index} <- Enum.with_index(@snowflakes)}
        key={index}
        class={[
          "dm-fun-snowflake",
          @use_unicode && "snowflake-unicode",
          @snowflake_class
        ]}
        style={
          "--snowflake-size: #{snowflake.size}px; --snowflake-color: #{@color}; left: #{snowflake.left}%; animation-duration: #{snowflake.duration}s; animation-delay: #{snowflake.delay}s;"
        }
      >
      </div>
    </div>

    <style>
      /* Add keyframes for falling animation */
      @keyframes snowfall {
        0% {
          transform: translateY(-100px) translateX(0);
          opacity: 0;
        }
        10% {
          opacity: 1;
        }
        90% {
          opacity: 1;
        }
        100% {
          transform: translateY(calc(100vh + 100px)) translateX(#{:rand.uniform(40) - 20}px);
          opacity: 0;
        }
      }

      .dm-fun-snowflake {
        position: absolute;
        top: -100px;
        animation: snowfall linear infinite;
      }

      /* Gentle swaying effect */
      .dm-fun-snowflake:nth-child(odd) {
        animation-name: snowfall, swayLeft;
      }

      .dm-fun-snowflake:nth-child(even) {
        animation-name: snowfall, swayRight;
      }

      @keyframes swayLeft {
        0%, 100% { transform: translateX(0); }
        50% { transform: translateX(-20px); }
      }

      @keyframes swayRight {
        0%, 100% { transform: translateX(0); }
        50% { transform: translateX(20px); }
      }
    </style>
    """
  end

  defp generate_snowflakes(count, _size_range, _duration_range) when count < 1, do: []

  defp generate_snowflakes(count, {min_size, max_size}, {min_duration, max_duration}) do
    1..count
    |> Enum.map(fn _ ->
      %{
        size: :rand.uniform(max_size - min_size + 1) + min_size - 1,
        left: :rand.uniform(100),
        duration: :rand.uniform(max_duration - min_duration + 1) + min_duration - 1,
        delay: :rand.uniform(5)
      }
    end)
  end
end
