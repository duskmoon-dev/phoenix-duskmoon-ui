defmodule PhoenixDuskmoon.Component.DataEntry.FilterGroup do
  @moduledoc """
  Native checkbox or radio filters styled as Core chips.
  The browser owns selection and form reset. Use a list-style name such as `tags[]`
  for multiple selection, or `multiple={false}` for a single native radio group.

      <.dm_filter_group name="status" label="Status" multiple={false}>
        <:option value="open" checked>Open</:option>
        <:option value="closed">Closed</:option>
      </.dm_filter_group>
  """
  use Phoenix.Component

  @doc "Renders named native inputs with labels and an accessible group legend."
  @doc type: :component
  attr(:id, :any, default: nil)
  attr(:name, :string, required: true)
  attr(:label, :string, required: true)
  attr(:multiple, :boolean, default: true)
  attr(:disabled, :boolean, default: false)

  attr(:color, :string,
    default: "primary",
    values: ~w(primary secondary tertiary info success warning error)
  )

  attr(:class, :any, default: nil)
  attr(:rest, :global)

  slot :option, required: true do
    attr(:value, :string, required: true)
    attr(:checked, :boolean)
    attr(:disabled, :boolean)
  end

  def dm_filter_group(assigns) do
    ~H"""
    <fieldset id={@id} class={["filter-group", "filter-group-#{@color}", @class]} disabled={@disabled} {@rest}>
      <legend class="sr-only">{@label}</legend>
      <label :for={option <- @option} class="chip">
        <input type={if @multiple, do: "checkbox", else: "radio"} class="filter-group-input" name={@name} value={option.value} checked={option[:checked]} disabled={option[:disabled]} />
        {render_slot(option)}
      </label>
    </fieldset>
    """
  end
end
