defmodule PhoenixDuskmoon.Component.DataEntry.Rating do
  @moduledoc """
  Standalone rating component using CSS classes from `@duskmoon-dev/core`.

  Renders interactive star-based ratings with proper `.rating` CSS classes
  instead of generic button styles.

  ## Examples

      <.dm_rating value={3} max={5} />

      <.dm_rating value={4} max={5} color="primary" size="lg" animated />

      <.dm_rating value={5} max={5} readonly />

  """
  use Phoenix.Component

  import PhoenixDuskmoon.Component.Icon.Icons

  @doc """
  Renders an interactive star rating.

  ## Examples

      <.dm_rating value={3} max={5} />

      <.dm_rating value={4} max={5} color="success" size="lg" animated />

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:name, :string, default: nil, doc: "form field name for hidden input")
  attr(:value, :integer, default: 0, doc: "current rating value (0 to max)")
  attr(:max, :integer, default: 5, doc: "maximum number of stars")

  attr(:size, :string,
    default: nil,
    values: [nil, "xs", "sm", "lg", "xl"],
    doc: "rating size variant"
  )

  attr(:color, :string,
    default: nil,
    values: [nil, "primary", "secondary", "success", "error"],
    doc: "color variant for filled stars"
  )

  attr(:readonly, :boolean, default: false, doc: "make rating read-only (no interaction)")
  attr(:disabled, :boolean, default: false, doc: "disable rating entirely")
  attr(:animated, :boolean, default: false, doc: "enable pop animation on filled stars")
  attr(:compact, :boolean, default: false, doc: "reduce spacing between stars")
  attr(:icon, :string, default: "star", doc: "MDI icon name for rating items")
  attr(:class, :string, default: nil, doc: "additional CSS classes")
  attr(:rest, :global)

  def dm_rating(assigns) do
    value = assigns.value || 0

    assigns = assign(assigns, :safe_value, value)

    ~H"""
    <div
      id={@id}
      class={[
        "rating",
        @size && "rating-#{@size}",
        @color && "rating-#{@color}",
        @readonly && "rating-readonly",
        @disabled && "rating-disabled",
        @animated && "rating-animated",
        @compact && "rating-compact",
        @class
      ]}
      role="group"
      aria-label={"Rating: #{@safe_value} out of #{@max}"}
      {@rest}
    >
      <input :if={@name} type="hidden" name={@name} value={@safe_value} class="rating-input" />
      <button
        :for={i <- 1..@max}
        type="button"
        class={["rating-item", i <= @safe_value && "filled"]}
        aria-label={"Rate #{i} out of #{@max}"}
        aria-pressed={to_string(i <= @safe_value)}
        disabled={@disabled || @readonly}
        tabindex={if(@readonly || @disabled, do: "-1", else: "0")}
      >
        <.dm_mdi name={@icon} class="rating-icon" />
      </button>
    </div>
    """
  end
end
