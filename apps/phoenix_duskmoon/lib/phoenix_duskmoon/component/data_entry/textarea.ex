defmodule PhoenixDuskmoon.Component.DataEntry.Textarea do
  @moduledoc """
  Textarea component for multi-line text input.

  ## Examples

      <.dm_form for={@form} phx-submit="save">
        <.dm_textarea field={@form[:description]} label="Description" />
        <.dm_textarea field={@form[:notes]} label="Notes" rows={5} color="success" />
        <.dm_textarea field={@form[:comment]} label="Comment" size="lg" resize="none" />
      </.dm_form>

  """
  use Phoenix.Component

  import PhoenixDuskmoon.Component.DataEntry.Form

  @doc """
  Renders a textarea input.

  ## Examples

      <.dm_textarea field={@form[:description]} label="Description" />
      <.dm_textarea name="notes" label="Notes" rows={5} />

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:name, :any, doc: "HTML name attribute for form submission")
  attr(:value, :any, doc: "the textarea content")
  attr(:field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form")
  attr(:label, :string, default: nil, doc: "text label displayed above the textarea")
  attr(:placeholder, :string, default: nil, doc: "placeholder text shown when empty")
  attr(:rows, :integer, default: 3, doc: "number of visible text rows")
  attr(:cols, :integer, default: nil, doc: "number of visible text columns")
  attr(:size, :string, default: "md", values: ["xs", "sm", "md", "lg"], doc: "textarea size")

  attr(:color, :string,
    default: "primary",
    values: ["primary", "secondary", "accent", "info", "success", "warning", "error"],
    doc: "color variant"
  )

  attr(:resize, :string,
    default: "vertical",
    values: ["none", "vertical", "horizontal", "both"],
    doc: "resize behavior"
  )

  attr(:errors, :list, default: [], doc: "list of error messages to display")
  attr(:disabled, :boolean, default: false, doc: "disables the textarea")
  attr(:readonly, :boolean, default: false, doc: "makes the textarea read-only")
  attr(:required, :boolean, default: false, doc: "marks the textarea as required")
  attr(:maxlength, :integer, default: nil, doc: "maximum character count")
  attr(:class, :string, default: nil, doc: "additional CSS classes for the wrapper")
  attr(:label_class, :string, default: nil, doc: "additional CSS classes for the label")

  attr(:textarea_class, :string,
    default: nil,
    doc: "additional CSS classes for the textarea element"
  )

  attr(:rest, :global)

  def dm_textarea(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> dm_textarea()
  end

  def dm_textarea(assigns) do
    ~H"""
    <div class={["dm-form-group", @class]}>
      <label :if={@label} for={@id} class={["dm-label", @label_class]}>
        <span class="dm-label__text">{@label}</span>
      </label>
      <textarea
        id={@id}
        name={@name}
        placeholder={@placeholder}
        rows={@rows}
        cols={@cols}
        disabled={@disabled}
        readonly={@readonly}
        required={@required}
        maxlength={@maxlength}
        aria-invalid={@errors != [] && "true"}
        aria-describedby={@errors != [] && @id && "#{@id}-errors"}
        class={[
          "dm-textarea",
          "dm-textarea--#{@size}",
          "dm-textarea--#{@color}",
          resize_class(@resize),
          @disabled && "opacity-50 cursor-not-allowed",
          @textarea_class
        ]}
        {@rest}
      >{@value}</textarea>
      <div :if={@errors != []} id={@id && "#{@id}-errors"}>
        <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
      </div>
    </div>
    """
  end

  defp resize_class("none"), do: "dm-textarea--resize-none"
  defp resize_class("vertical"), do: "dm-textarea--resize-y"
  defp resize_class("horizontal"), do: "dm-textarea--resize-x"
  defp resize_class("both"), do: "dm-textarea--resize-both"
end
