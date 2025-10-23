defmodule PhoenixDuskmoon.Component.Form.Textarea do
  @moduledoc """
  Textarea component for multi-line text input.

  ## Examples

      <.dm_form for={@form} phx-submit="save">
        <.dm_textarea field={@form[:description]} label="Description" />
        <.dm_textarea field={@form[:notes]} label="Notes" rows="5" color="success" />
        <.dm_textarea field={@form[:comment]} label="Comment" size="lg" resize="none" />
      </.dm_form>

  ## Attributes

  * `field` - Phoenix form field
  * `label` - Textarea label text
  * `placeholder` - Placeholder text
  * `rows` - Number of visible text lines (default: 3)
  * `cols` - Visible width of the text control
  * `size` - Textarea size: xs, sm, md, lg (default: md)
  * `color` - Textarea color: primary, secondary, accent, info, success, warning, error (default: primary)
  * `resize` - Resize behavior: none, vertical, horizontal, both (default: vertical)
  * `disabled` - Disable the textarea
  * `readonly` - Make textarea readonly
  * `required` - Make textarea required
  * `maxlength` - Maximum number of characters
  * `class` - Additional CSS classes
  * `label_class` - Additional CSS classes for label
  * `textarea_class` - Additional CSS classes for textarea element
  """

  use Phoenix.Component

  @doc type: :component
  attr(:id, :any, default: nil)
  attr(:name, :any)
  attr(:value, :any)
  attr(:field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form")
  attr(:label, :string, default: nil)
  attr(:placeholder, :string, default: nil)
  attr(:rows, :integer, default: 3)
  attr(:cols, :integer, default: nil)
  attr(:size, :string, default: "md", values: ["xs", "sm", "md", "lg"])

  attr(:color, :string,
    default: "primary",
    values: ["primary", "secondary", "accent", "info", "success", "warning", "error"]
  )

  attr(:resize, :string, default: "vertical", values: ["none", "vertical", "horizontal", "both"])
  attr(:disabled, :boolean, default: false)
  attr(:readonly, :boolean, default: false)
  attr(:required, :boolean, default: false)
  attr(:maxlength, :integer, default: nil)
  attr(:class, :string, default: nil)
  attr(:label_class, :string, default: nil)
  attr(:textarea_class, :string, default: nil)
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
    <div class={@class}>
      <label :if={@label} for={@id} class={["label", @label_class]}>
        <span class="label-text">{@label}</span>
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
        class={[
          "textarea textarea-bordered w-full",
          size_classes(@size),
          color_classes(@color),
          resize_classes(@resize),
          @disabled && "textarea-disabled opacity-50 cursor-not-allowed",
          @textarea_class
        ]}
        {@rest}
      >{@value}</textarea>
    </div>
    """
  end

  defp size_classes("xs"), do: "textarea-xs"
  defp size_classes("sm"), do: "textarea-sm"
  defp size_classes("md"), do: "textarea-md"
  defp size_classes("lg"), do: "textarea-lg"

  defp color_classes("primary"), do: "textarea-primary"
  defp color_classes("secondary"), do: "textarea-secondary"
  defp color_classes("accent"), do: "textarea-accent"
  defp color_classes("info"), do: "textarea-info"
  defp color_classes("success"), do: "textarea-success"
  defp color_classes("warning"), do: "textarea-warning"
  defp color_classes("error"), do: "textarea-error"

  defp resize_classes("none"), do: "resize-none"
  defp resize_classes("vertical"), do: "resize-y"
  defp resize_classes("horizontal"), do: "resize-x"
  defp resize_classes("both"), do: "resize"
end
