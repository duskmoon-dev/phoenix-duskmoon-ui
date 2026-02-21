defmodule PhoenixDuskmoon.Component.DataEntry.Radio do
  @moduledoc """
  Radio button component for single selection.

  ## Examples

      <.dm_form for={@form} phx-submit="save">
        <.dm_radio field={@form[:theme]} value="light" label="Light theme" />
        <.dm_radio field={@form[:theme]} value="dark" label="Dark theme" color="secondary" />
        <.dm_radio field={@form[:theme]} value="auto" label="Auto theme" size="lg" />
      </.dm_form>

  """
  use Phoenix.Component

  import PhoenixDuskmoon.Component.DataEntry.Form

  @doc """
  Renders a radio button input.

  ## Examples

      <.dm_radio field={@form[:theme]} value="light" label="Light" />
      <.dm_radio name="size" value="sm" label="Small" />

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:name, :any, doc: "HTML name attribute for form submission")
  attr(:value, :any, doc: "the radio button value")
  attr(:field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form")
  attr(:checked, :boolean, default: false, doc: "whether this radio option is selected")
  attr(:label, :string, default: nil, doc: "text label displayed next to the radio button")

  attr(:size, :string,
    default: "md",
    values: ["xs", "sm", "md", "lg", "xl"],
    doc: "radio button size"
  )

  attr(:color, :string,
    default: "primary",
    values: ["primary", "secondary", "tertiary", "accent", "info", "success", "warning", "error"],
    doc: "color variant"
  )

  attr(:helper, :string, default: nil, doc: "helper text displayed below the radio button")
  attr(:errors, :list, default: [], doc: "list of error messages to display")
  attr(:disabled, :boolean, default: false, doc: "disables the radio button")
  attr(:class, :string, default: nil, doc: "additional CSS classes for the wrapper")
  attr(:label_class, :string, default: nil, doc: "additional CSS classes for the label")
  attr(:radio_class, :string, default: nil, doc: "additional CSS classes for the radio input")
  attr(:horizontal, :boolean, default: false, doc: "horizontal layout (label beside input)")

  attr(:state, :string,
    default: nil,
    values: [nil, "success", "warning"],
    doc: "validation state (applies form-group-success/warning)"
  )

  attr(:rest, :global)

  def dm_radio(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:checked, fn -> field.value == assigns.value end)
    |> dm_radio()
  end

  def dm_radio(assigns) do
    assigns = assign(assigns, :color, css_color(assigns.color))

    ~H"""
    <div class={["form-group", @horizontal && "form-group-horizontal", @disabled && "form-group-disabled", @errors != [] && "form-group-error", @state && "form-group-#{@state}", @class]} phx-feedback-for={@name}>
      <label class={["flex items-center gap-2", !@disabled && "cursor-pointer"]}>
        <input
          type="radio"
          name={@name}
          id={@id}
          value={@value}
          checked={@checked}
          disabled={@disabled}
          aria-invalid={@errors != [] && "true"}
          aria-describedby={
            (@errors != [] && @id && "#{@id}-errors") ||
              (@helper && @errors == [] && @id && "#{@id}-helper")
          }
          class={[
            "radio",
            "radio-#{@size}",
            "radio-#{@color}",


            @radio_class
          ]}
          {@rest}
        />
        <span :if={@label} class={@label_class}>
          {@label}
        </span>
      </label>
      <span :if={@helper && @errors == []} id={@id && "#{@id}-helper"} class={["helper-text", @state && "helper-text-#{@state}"]}>{@helper}</span>
      <div :if={@errors != []} id={@id && "#{@id}-errors"}>
        <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
      </div>
    </div>
    """
  end

  defp css_color("accent"), do: "tertiary"
  defp css_color(color), do: color
end
