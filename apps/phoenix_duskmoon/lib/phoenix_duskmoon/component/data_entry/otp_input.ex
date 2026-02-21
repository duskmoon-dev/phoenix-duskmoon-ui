defmodule PhoenixDuskmoon.Component.DataEntry.OtpInput do
  @moduledoc """
  OTP/PIN input component using CSS classes from `@duskmoon-dev/core`.

  Renders a group of single-character input fields for entering
  verification codes or PINs. Supports size, color, style variants,
  error/success states, and optional labels and helper text.

  ## Examples

      <.dm_otp_input length={6} />

      <.dm_otp_input
        length={4}
        color="primary"
        size="lg"
        label="Enter verification code"
        helper="We sent a code to your email"
      />

      <.dm_otp_input length={4} variant="filled" masked />

  """
  use Phoenix.Component

  import PhoenixDuskmoon.Component.DataEntry.Form, only: [dm_error: 1]
  import PhoenixDuskmoon.Component.Helpers, only: [css_color: 1, format_label: 2, split_value: 2]

  @doc """
  Renders an OTP/PIN input group.

  ## Examples

      <.dm_otp_input length={6} color="primary" />

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:name, :string, default: nil, doc: "form field name")
  attr(:value, :any, doc: "pre-fill value (string split across fields)")
  attr(:field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form")
  attr(:length, :integer, default: 6, doc: "number of input fields")

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
    values: [nil, "filled", "underline"],
    doc: "visual style: outlined (default), filled, or underline"
  )

  attr(:gap, :string,
    default: nil,
    values: [nil, "compact", "wide"],
    doc: "gap between fields"
  )

  attr(:masked, :boolean, default: false, doc: "mask input as password dots")
  attr(:disabled, :boolean, default: false, doc: "disable all fields")
  attr(:error, :boolean, default: false, doc: "show error state")
  attr(:errors, :list, default: [], doc: "list of error messages to display")
  attr(:success, :boolean, default: false, doc: "show success state")
  attr(:label, :string, default: nil, doc: "label text above the input")
  attr(:label_class, :any, default: nil, doc: "additional CSS classes for the label")
  attr(:helper, :string, default: nil, doc: "helper text below the input")
  attr(:error_message, :string, default: nil, doc: "error message below the input")

  attr(:group_label, :string,
    default: "Verification code, {length} digits",
    doc:
      "Accessible fallback label when no label attr is set. Use {length} for the digit count (i18n)"
  )

  attr(:digit_label, :string,
    default: "Digit {index} of {length}",
    doc: "Accessible label template for each input field. Use {index} and {length} (i18n)"
  )

  attr(:rest, :global)

  def dm_otp_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:name, field.name)
    |> assign_new(:value, fn -> field.value end)
    |> dm_otp_input()
  end

  def dm_otp_input(assigns) do
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
        "otp-group",
        @class
      ]}
      phx-feedback-for={@name}
      role="group"
      aria-labelledby={@label && @id && "#{@id}-label"}
      aria-label={!@label && format_label(@group_label, %{"length" => @length})}
      aria-disabled={@disabled && "true"}
      aria-invalid={@errors != [] && "true"}
      aria-describedby={
        (@errors != [] && @id && "#{@id}-errors") ||
          (@error_message && @errors == [] && @id && "#{@id}-error-message") ||
          (@helper && !@error_message && @errors == [] && @id && "#{@id}-helper")
      }
      {@rest}
    >
      <label :if={@label} id={@id && "#{@id}-label"} class={["otp-label", @label_class]}>{@label}</label>
      <div class={[
        "otp-input",
        @size && "otp-input-#{@size}",
        @color && "otp-input-#{@color}",
        @variant && "otp-input-#{@variant}",
        @gap && "otp-input-#{@gap}",
        @masked && "otp-input-masked",
        @disabled && "otp-input-disabled",
        (@error || @errors != []) && "otp-input-error",
        @success && "otp-input-success"
      ]}>
        <input
          :for={i <- 1..@length}
          type={if(@masked, do: "password", else: "text")}
          class="otp-input-field"
          maxlength="1"
          inputmode="numeric"
          pattern="[0-9]"
          autocomplete="one-time-code"
          disabled={@disabled}
          name={@name && "#{@name}[#{i}]"}
          value={Enum.at(@value_chars, i - 1)}
          aria-label={format_label(@digit_label, %{"index" => i, "length" => @length})}
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

end
