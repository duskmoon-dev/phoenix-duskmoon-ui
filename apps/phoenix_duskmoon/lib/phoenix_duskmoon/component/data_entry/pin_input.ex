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

  import PhoenixDuskmoon.Component.DataEntry.Form, only: [dm_error: 1]
  import PhoenixDuskmoon.Component.Helpers, only: [css_color: 1]

  @doc """
  Renders a PIN input group.

  ## Examples

      <.dm_pin_input length={4} color="primary" />

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:name, :string, default: nil, doc: "form field name")
  attr(:value, :any, doc: "pre-fill value (string split across fields)")
  attr(:field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form")
  attr(:length, :integer, default: 4, doc: "number of input fields")

  attr(:size, :string,
    default: nil,
    values: [nil, "sm", "lg"],
    doc: "size variant"
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
  attr(:errors, :list, default: [], doc: "list of error messages to display")
  attr(:success, :boolean, default: false, doc: "show success state")
  attr(:label, :string, default: nil, doc: "label text above the input")
  attr(:label_class, :any, default: nil, doc: "additional CSS classes for the label")
  attr(:helper, :string, default: nil, doc: "helper text below the input")
  attr(:error_message, :string, default: nil, doc: "error message below the input")
  attr(:rest, :global)

  def dm_pin_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:name, field.name)
    |> assign_new(:value, fn -> field.value end)
    |> dm_pin_input()
  end

  def dm_pin_input(assigns) do
    assigns = assign_new(assigns, :value, fn -> nil end)
    value_chars = split_value(assigns.value, assigns.length)

    assigns =
      assigns
      |> assign(:color, css_color(assigns.color))
      |> assign(:value_chars, value_chars)

    ~H"""
    <div
      id={@id}
      class={[
        "pin-group",
        @class
      ]}
      phx-feedback-for={@name}
      role="group"
      aria-labelledby={@label && @id && "#{@id}-label"}
      aria-label={!@label && "PIN input, #{@length} digits"}
      aria-invalid={@errors != [] && "true"}
      aria-describedby={
        (@errors != [] && @id && "#{@id}-errors") ||
          (@error_message && @errors == [] && @id && "#{@id}-error-message") ||
          (@helper && !@error_message && @errors == [] && @id && "#{@id}-helper")
      }
      {@rest}
    >
      <label :if={@label} id={@id && "#{@id}-label"} class={["pin-label", @label_class]}>{@label}</label>
      <div class={[
        "pin-input",
        @size && "pin-input-#{@size}",
        @color && "pin-input-#{@color}",
        @variant && "pin-input-#{@variant}",
        @shape && "pin-input-#{@shape}",
        @compact && "pin-input-compact",
        @dots && "pin-input-dots",
        @visible && "pin-input-visible",
        @disabled && "form-group-disabled",
        (@error || @errors != []) && "pin-input-error",
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
          value={Enum.at(@value_chars, i - 1)}
          aria-label={"PIN digit #{i} of #{@length}"}
        />
      </div>
      <span :if={@error_message && @errors == []} id={@id && "#{@id}-error-message"} class="helper-text helper-text-error">{@error_message}</span>
      <div :if={@errors != []} id={@id && "#{@id}-errors"}>
        <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
      </div>
      <span :if={@helper && !@error_message && @errors == []} id={@id && "#{@id}-helper"} class="helper-text">{@helper}</span>
    </div>
    """
  end

  defp split_value(nil, _length), do: []

  defp split_value(value, length) when is_binary(value) do
    value |> String.graphemes() |> Enum.take(length)
  end

  defp split_value(_, _length), do: []
end
