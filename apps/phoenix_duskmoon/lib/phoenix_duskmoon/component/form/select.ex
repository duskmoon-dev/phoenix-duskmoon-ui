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
      </.dm_select>

  """
  use Phoenix.Component

  @doc """
  Renders a select dropdown.

  ## Examples

      <.dm_select field={@form[:country]} label="Country" options={[{"us", "USA"}, {"uk", "UK"}]} />

  """
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
    <div class={["dm-form-group", @class]}>
      <label :if={@label} for={@id} class={["dm-label", @label_class]}>
        <span class="dm-label__text">{@label}</span>
      </label>
      <select
        id={@id}
        name={@name}
        multiple={@multiple}
        disabled={@disabled}
        class={[
          "dm-select",
          "dm-select--#{@size}",
          "dm-select--#{@color}",
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
    {render_slot(@inner_block)}
    """
  end
end
