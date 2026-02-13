defmodule PhoenixDuskmoon.CssArt.ButtonNoise do
  @moduledoc """
  Interactive button with noise/electronic effect animation.

  ## Examples

      <.dm_art_button_noise
        id="noise-btn-1"
        content="Click Me"
        phx-click="handle_click"
      />

      <.dm_art_button_noise
        id="noise-btn-2"
        content="Submit"
        color_scheme="electric"
        phx-click="submit_form"
      />

      <.dm_art_button_noise
        id="noise-btn-3"
        content="Download"
        font_size="20px"
        font_family="Arial, sans-serif"
      />

  ## Attributes

  * `id` - Component ID (required)
  * `content` - Button text content (required)
  * `font_size` - Font size for the button text (default: "24px")
  * `font_family` - Font family for the button text (default: '"Josefin Sans", sans-serif')
  * `color_scheme` - Color scheme: default, electric, neon (default: default)
  * `class` - Additional CSS classes
  * `phx_target` - LiveView target for events

  ## Styling

  This component creates an interactive button with:
  - 72 animated light bars that appear on hover
  - Each bar has unique properties (size, duration, hue, animation)
  - Creates a noise/static electronic effect
  - Content fades out on hover while effects activate
  - Customizable colors and typography

  The effect simulates electronic interference or noise that responds to hover state.
  """

  use Phoenix.Component

  @doc type: :component
  attr(:id, :string, required: true)
  attr(:content, :string, required: true)
  attr(:font_size, :string, default: "24px")
  attr(:font_family, :string, default: ~s("Josefin Sans", sans-serif))
  attr(:color_scheme, :string, default: "default", values: ["default", "electric", "neon"])
  attr(:class, :string, default: nil)
  attr(:phx_target, :any, default: nil)
  attr(:rest, :global)

  def dm_art_button_noise(assigns) do
    assigns
    |> assign(color_variables: color_scheme_variables(assigns.color_scheme))
    |> render_button_noise()
  end

  defp render_button_noise(assigns) do
    ~H"""
    <button
      id={@id}
      type="button"
      class={[
        "btn-noise",
        @class
      ]}
      style={"font-family: #{@font_family}; font-size: #{@font_size}; #{@color_variables}"}
      data-content={@content}
      aria-label={@content}
      phx-target={@phx_target}
      {@rest}
    >
      <!-- 72 animated light bars -->
      <span aria-hidden="true"><i :for={index <- 1..72}></i></span>
    </button>
    """
  end

  defp color_scheme_variables("default"), do: ""
  defp color_scheme_variables("electric"), do: "--primary-hue: 180; --secondary-hue: 280;"
  defp color_scheme_variables("neon"), do: "--primary-hue: 300; --secondary-hue: 60;"
end
