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

  @doc """
  Renders an OTP/PIN input group.

  ## Examples

      <.dm_otp_input length={6} color="primary" />

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :string, default: nil, doc: "additional CSS classes")
  attr(:name, :string, default: nil, doc: "form field name")
  attr(:field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form")
  attr(:length, :integer, default: 6, doc: "number of input fields")

  attr(:size, :string,
    default: nil,
    values: [nil, "sm", "lg"],
    doc: "size variant"
  )

  attr(:color, :string,
    default: nil,
    values: [nil, "primary", "secondary", "tertiary"],
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
  attr(:success, :boolean, default: false, doc: "show success state")
  attr(:label, :string, default: nil, doc: "label text above the input")
  attr(:helper, :string, default: nil, doc: "helper text below the input")
  attr(:error_message, :string, default: nil, doc: "error message below the input")
  attr(:rest, :global)

  def dm_otp_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:name, field.name)
    |> dm_otp_input()
  end

  def dm_otp_input(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "otp-group",
        @class
      ]}
      {@rest}
    >
      <label :if={@label} class="otp-label">{@label}</label>
      <div class={[
        "otp-input",
        @size && "otp-input-#{@size}",
        @color && "otp-input-#{@color}",
        @variant && "otp-input-#{@variant}",
        @gap && "otp-input-#{@gap}",
        @masked && "otp-input-masked",
        @error && "otp-input-error",
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
          aria-label={"Digit #{i} of #{@length}"}
        />
      </div>
      <span :if={@error_message} class="otp-error-message">{@error_message}</span>
      <span :if={@helper && !@error_message} class="otp-helper">{@helper}</span>
    </div>
    """
  end
end
