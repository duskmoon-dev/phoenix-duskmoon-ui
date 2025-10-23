defmodule PhoenixDuskmoon.Component.Form.Select do
  @moduledoc """
  Select dropdown component for single selection.

  ## Examples

      <.dm_form for={@form} phx-submit="save">
        <.dm_select field={@form[:country]} label="Country" options={country_options()} />
        <.dm_select field={@form[:priority]} label="Priority" options={priority_options()} color="warning" />
      </.dm_form>

      <!-- With option groups -->
      <.dm_select field={@form[:category]} label="Category">
        <option value="">Select a category</option>
        <optgroup label="Fruits">
          <option value="apple">Apple</option>
          <option value="orange">Orange</option>
        </optgroup>
        <optgroup label="Vegetables">
          <option value="carrot">Carrot</option>
          <option value="broccoli">Broccoli</option>
        </optgroup>
      </.dm_select>

  ## Attributes

  * `field` - Phoenix form field
  * `label` - Select label text
  * `options` - List of {value, label} tuples or keyword list
  * `prompt` - Placeholder text for empty selection
  * `size` - Select size: xs, sm, md, lg (default: md)
  * `color` - Select color: primary, secondary, accent, info, success, warning, error (default: primary)
  * `disabled` - Disable the select
  * `multiple` - Enable multiple selection
  * `class` - Additional CSS classes
  * `label_class` - Additional CSS classes for label
  * `select_class` - Additional CSS classes for select element
  """

  use Phoenix.Component

  @doc type: :component
  attr(:id, :any, default: nil)
  attr(:name, :any)
  attr(:value, :any)
  attr(:field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form")
  attr(:label, :string, default: nil)
  attr(:options, :list, default: nil)
  attr(:prompt, :string, default: nil)
  attr(:size, :string, default: "md", values: ["xs", "sm", "md", "lg"])

  attr(:color, :string,
    default: "primary",
    values: ["primary", "secondary", "accent", "info", "success", "warning", "error"]
  )

  attr(:disabled, :boolean, default: false)
  attr(:multiple, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:label_class, :string, default: nil)
  attr(:select_class, :string, default: nil)
  attr(:rest, :global)

  slot(:inner_block, required: false)

  def dm_select(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> dm_select()
  end

  def dm_select(assigns) do
    ~H"""
    <div class={@class}>
      <label :if={@label} for={@id} class={["label", @label_class]}>
        <span class="label-text">{@label}</span>
      </label>
      <select
        id={@id}
        name={@name}
        multiple={@multiple}
        disabled={@disabled}
        class={[
          "select select-bordered w-full",
          size_classes(@size),
          color_classes(@color),
          @disabled && "opacity-50 cursor-not-allowed",
          @select_class
        ]}
        {@rest}
      >
        {render_options(assigns)}
      </select>
    </div>
    """
  end

  defp render_options(%{options: options} = assigns) when is_list(options) do
    ~H"""
    <option :if={@prompt} value="">{@prompt}</option>
    <%= for {value, label} <- @options do %>
      <option value={value} selected={@value == value}>
        {label}
      </option>
    <% end %>
    """
  end

  defp render_options(assigns) do
    ~H"""
    <option :if={@prompt} value="">{@prompt}</option>
    <slot />
    """
  end

  defp size_classes("xs"), do: "select-xs"
  defp size_classes("sm"), do: "select-sm"
  defp size_classes("md"), do: "select-md"
  defp size_classes("lg"), do: "select-lg"

  defp color_classes("primary"), do: "select-primary"
  defp color_classes("secondary"), do: "select-secondary"
  defp color_classes("accent"), do: "select-accent"
  defp color_classes("info"), do: "select-info"
  defp color_classes("success"), do: "select-success"
  defp color_classes("warning"), do: "select-warning"
  defp color_classes("error"), do: "select-error"
end
