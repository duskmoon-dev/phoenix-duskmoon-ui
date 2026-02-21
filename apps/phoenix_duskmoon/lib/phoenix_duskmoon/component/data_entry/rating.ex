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
  import PhoenixDuskmoon.Component.DataEntry.Form, only: [dm_error: 1]
  import PhoenixDuskmoon.Component.Helpers, only: [css_color: 1, format_label: 2]

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
  attr(:field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form")
  attr(:max, :integer, default: 5, doc: "maximum number of stars")

  attr(:size, :string,
    default: nil,
    values: [nil, "xs", "sm", "lg", "xl"],
    doc: "rating size variant"
  )

  attr(:color, :string,
    default: nil,
    values: [
      nil,
      "primary",
      "secondary",
      "tertiary",
      "accent",
      "info",
      "success",
      "warning",
      "error"
    ],
    doc: "color variant for filled stars"
  )

  attr(:readonly, :boolean, default: false, doc: "make rating read-only (no interaction)")
  attr(:disabled, :boolean, default: false, doc: "disable rating entirely")
  attr(:animated, :boolean, default: false, doc: "enable pop animation on filled stars")
  attr(:compact, :boolean, default: false, doc: "reduce spacing between stars")
  attr(:icon, :string, default: "star", doc: "MDI icon name for rating items")
  attr(:error, :boolean, default: false, doc: "show error state")
  attr(:errors, :list, default: [], doc: "list of error messages to display")
  attr(:helper, :string, default: nil, doc: "helper text displayed below the component")
  attr(:class, :any, default: nil, doc: "additional CSS classes")

  attr(:group_label, :string,
    default: "Rating: {value} out of {max}",
    doc: "Accessible label for the rating group. Use {value} and {max} (i18n)"
  )

  attr(:item_label, :string,
    default: "Rate {index} out of {max}",
    doc: "Accessible label template for each star button. Use {index} and {max} (i18n)"
  )

  attr(:rest, :global)

  def dm_rating(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:name, field.name)
    |> assign(:value, field.value || 0)
    |> dm_rating()
  end

  def dm_rating(assigns) do
    value = assigns.value || 0

    assigns =
      assigns
      |> assign(:safe_value, value)
      |> assign(:color, css_color(assigns.color))

    ~H"""
    <div phx-feedback-for={@name}>
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
          (@error || @errors != []) && "rating-error",
          @class
        ]}
        role="group"
        aria-label={format_label(@group_label, %{"value" => @safe_value, "max" => @max})}
        aria-disabled={@disabled && "true"}
        aria-invalid={@errors != [] && "true"}
        aria-describedby={
          (@errors != [] && @id && "#{@id}-errors") ||
            (@helper && @errors == [] && @id && "#{@id}-helper")
        }
        {@rest}
      >
        <input :if={@name} type="hidden" name={@name} value={@safe_value} class="rating-input" />
        <button
          :for={i <- 1..@max}
          type="button"
          class={["rating-item", i <= @safe_value && "filled"]}
          aria-label={format_label(@item_label, %{"index" => i, "max" => @max})}
          aria-pressed={to_string(i <= @safe_value)}
          disabled={@disabled || @readonly}
          tabindex={if(@readonly || @disabled, do: "-1", else: "0")}
        >
          <.dm_mdi name={@icon} class="rating-icon" />
        </button>
      </div>
      <span :if={@helper && @errors == []} id={@id && "#{@id}-helper"} class="helper-text">{@helper}</span>
      <div :if={@errors != []} id={@id && "#{@id}-errors"}>
        <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
      </div>
    </div>
    """
  end
end
