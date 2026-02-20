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
  attr(:size, :string, default: "md", values: ["xs", "sm", "md", "lg"], doc: "radio button size")

  attr(:color, :string,
    default: "primary",
    values: ["primary", "secondary", "accent", "info", "success", "warning", "error"],
    doc: "color variant"
  )

  attr(:errors, :list, default: [], doc: "list of error messages to display")
  attr(:disabled, :boolean, default: false, doc: "disables the radio button")
  attr(:class, :string, default: nil, doc: "additional CSS classes for the wrapper")
  attr(:label_class, :string, default: nil, doc: "additional CSS classes for the label")
  attr(:radio_class, :string, default: nil, doc: "additional CSS classes for the radio input")
  attr(:rest, :global)

  def dm_radio(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:checked, fn -> field.value == assigns.value end)
    |> dm_radio()
  end

  def dm_radio(assigns) do
    ~H"""
    <div class={["form-group", @class]}>
      <label class={["flex items-center gap-2", !@disabled && "cursor-pointer", @disabled && "cursor-not-allowed"]}>
        <input
          type="radio"
          name={@name}
          id={@id}
          value={@value}
          checked={@checked}
          disabled={@disabled}
          aria-invalid={@errors != [] && "true"}
          aria-describedby={@errors != [] && @id && "#{@id}-errors"}
          class={[
            "dm-radio",
            "dm-radio--#{@size}",
            "dm-radio--#{@color}",
            @disabled && "opacity-50 cursor-not-allowed",
            @radio_class
          ]}
          {@rest}
        />
        <span :if={@label} class={["dm-label__text", @label_class]}>
          {@label}
        </span>
      </label>
      <div :if={@errors != []} id={@id && "#{@id}-errors"}>
        <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
      </div>
    </div>
    """
  end
end
