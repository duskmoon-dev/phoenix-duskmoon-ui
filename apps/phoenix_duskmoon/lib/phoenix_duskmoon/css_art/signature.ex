defmodule PhoenixDuskmoon.CssArt.Signature do
  @moduledoc """
  Customizable signature/seal component for decorative purposes.

  ## Examples

      <.dm_art_signature
        id="signature-1"
        content="A"
        size="large"
        color="#ff0000"
        rotation="-30"
        right="2rem"
        top="2rem"
      />

      <.dm_art_signature
        id="signature-2"
        content="Approved"
        size="medium"
        color="#0066cc"
        opacity="0.8"
        position="absolute"
      />

      <.dm_art_signature
        id="signature-3"
        content="★"
        size="small"
        color="#daa520"
      />

  ## Attributes

  * `id` - Component ID (required)
  * `content` - Content to display in the signature (default: "A")
  * `size` - Size preset: small (3rem), medium (5rem), large (8rem) (default: medium)
  * `color` - Signature color (default: "#ff0000aa")
  * `rotation` - Rotation angle in degrees (default: -30)
  * `opacity` - Opacity value (0.0 to 1.0) (default: 0.618)
  * `right` - Distance from right edge (default: "2rem")
  * `top` - Distance from top edge (default: "2rem")
  * `position` - CSS position (default: "absolute")
  * `class` - Additional CSS classes

  ## Styling

  This component creates a decorative signature/seal element with:
  - Outer circular border
  - Inner circular border
  - Content in the center
  - Customizable colors, size, rotation, and opacity
  - Absolute positioning by default

  It's perfect for watermarks, approvals, signatures, or decorative elements.
  """

  use Phoenix.Component

  @doc """
  Renders a decorative signature/seal stamp element.

  ## Examples

      <.dm_art_signature id="seal" content="A" size="medium" />

  """
  @doc type: :component
  attr(:id, :string, required: true)
  attr(:content, :string, default: "A")
  attr(:size, :string, default: "medium", values: ["small", "medium", "large"])
  attr(:color, :string, default: "#ff0000aa")
  attr(:rotation, :integer, default: -30)
  attr(:opacity, :float, default: 0.618)
  attr(:right, :string, default: "2rem")
  attr(:top, :string, default: "2rem")
  attr(:position, :string, default: "absolute")
  attr(:class, :any, default: nil)
  attr(:rest, :global)

  def dm_art_signature(assigns) do
    assigns
    |> assign(size_px: size_to_pixels(assigns.size))
    |> render_signature()
  end

  defp render_signature(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "dm-art-signature",
        @class
      ]}
      style={
        "--size: #{@size_px}px; --sign-color: #{@color}; --rotate: #{@rotation}deg; --opacity: #{@opacity}; --right: #{@right}; --top: #{@top}; position: #{@position};"
      }
      aria-hidden="true"
      data-content={@content}
      {@rest}
    >
    </div>
    """
  end

  # 3rem
  defp size_to_pixels("small"), do: 48
  # 5rem
  defp size_to_pixels("medium"), do: 80
  # 8rem
  defp size_to_pixels("large"), do: 128
end
