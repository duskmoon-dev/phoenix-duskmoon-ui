defmodule PhoenixDuskmoon.Component.DataEntry.PinInput do
  @moduledoc """
  PIN input component using CSS classes from `@duskmoon-dev/core`.

  Renders a group of single-character input fields styled for PIN or
  security code entry. Features circle shape, dots display mode,
  visibility toggle, and compact spacing.

  ## Examples

      <.dm_pin_input length={4} />

      <.dm_pin_input
        length={6}
        color="primary"
        size="lg"
        shape="circle"
        label="Enter PIN"
      />

      <.dm_pin_input length={4} variant="filled" visible={false} />

  """
  use Phoenix.Component

  @doc """
  Renders a PIN input group.

  ## Examples

      <.dm_pin_input length={4} color="primary" />

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :string, default: nil, doc: "additional CSS classes")
  attr(:name, :string, default: nil, doc: "form field name")
  attr(:field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form")
  attr(:length, :integer, default: 4, doc: "number of input fields")

  attr(:size, :string,
    default: nil,
    values: [nil, "sm", "lg"],
    doc: "size variant"
  )

  attr(:color, :string,
    default: nil,
    values: [nil, "primary", "secondary", "tertiary", "accent"],
    doc: "focus ring color"
  )

  attr(:variant, :string,
    default: nil,
    values: [nil, "filled"],
    doc: "visual style: outlined (default) or filled"
  )

  attr(:shape, :string,
    default: nil,
    values: [nil, "circle"],
    doc: "field shape: square (default) or circle"
  )

  attr(:compact, :boolean, default: false, doc: "reduce spacing between fields")
  attr(:dots, :boolean, default: false, doc: "display input as dots style")
  attr(:visible, :boolean, default: true, doc: "show entered values (false masks as dots)")
  attr(:disabled, :boolean, default: false, doc: "disable all fields")
  attr(:error, :boolean, default: false, doc: "show error state with shake animation")
  attr(:success, :boolean, default: false, doc: "show success state")
  attr(:label, :string, default: nil, doc: "label text above the input")
  attr(:helper, :string, default: nil, doc: "helper text below the input")
  attr(:error_message, :string, default: nil, doc: "error message below the input")
  attr(:rest, :global)

  def dm_pin_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:name, field.name)
    |> dm_pin_input()
  end

  def dm_pin_input(assigns) do
    assigns = assign(assigns, :color, css_color(assigns.color))

    ~H"""
    <div
      id={@id}
      class={[
        "pin-group",
        @class
      ]}
      {@rest}
    >
      <label :if={@label} class="pin-label">{@label}</label>
      <div class={[
        "pin-input",
        @size && "pin-input-#{@size}",
        @color && "pin-input-#{@color}",
        @variant && "pin-input-#{@variant}",
        @shape && "pin-input-#{@shape}",
        @compact && "pin-input-compact",
        @dots && "pin-input-dots",
        @visible && "pin-input-visible",
        @error && "pin-input-error",
        @success && "pin-input-success"
      ]}>
        <input
          :for={i <- 1..@length}
          type="text"
          class="pin-input-field"
          maxlength="1"
          inputmode="numeric"
          pattern="[0-9]"
          autocomplete="off"
          disabled={@disabled}
          name={@name && "#{@name}[#{i}]"}
          aria-label={"PIN digit #{i} of #{@length}"}
        />
      </div>
      <span :if={@error_message} class="pin-error-message">{@error_message}</span>
      <span :if={@helper && !@error_message} class="pin-helper">{@helper}</span>
    </div>
    """
  end

  defp css_color("accent"), do: "tertiary"
  defp css_color(color), do: color
end
