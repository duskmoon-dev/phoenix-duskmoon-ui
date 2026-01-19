defmodule PhoenixDuskmoon.Component.Form.Textarea do
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

  @doc """
  Renders a textarea input.

  ## Examples

      <.dm_textarea field={@form[:description]} label="Description" />
      <.dm_textarea name="notes" label="Notes" rows={5} />

  """
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
    </div>
    """
  end

  defp resize_class("none"), do: "dm-textarea--resize-none"
  defp resize_class("vertical"), do: "dm-textarea--resize-y"
  defp resize_class("horizontal"), do: "dm-textarea--resize-x"
  defp resize_class("both"), do: "dm-textarea--resize-both"
end
