defmodule PhoenixDuskmoon.Component.DataEntry.ReactForm do
  @moduledoc """
  A nested HEEX form whose interactive fields are managed by React and submitted
  to LiveView as typed JSON.

  The form accepts ordinary HTML and `dm_react_field` children. React owns only
  the marked fields; the surrounding HEEX layout and native controls remain
  ordinary HTML. Passing `schema` mounts the published `JsonSchemaForm` renderer
  instead; React owns its controls and form. `phx-change` and `phx-submit` retain
  their Phoenix event names in both modes.
  """
  use Phoenix.Component

  @field_types ~w(text email password textarea number checkbox select multiselect)

  @doc """
  Renders a React JSON form without Phoenix form serialization.

  Pass a JSON Schema map to use the upstream schema renderer, or provide HEEX
  children for the classic form. Omitted `values` use schema defaults in schema
  mode and an empty value map in classic mode. Schema mode supplies its own
  Submit and Reset controls; optional slot content appears outside that form.
  """
  @doc type: :component
  attr(:id, :string, required: true)
  attr(:values, :map, default: nil, doc: "Initial typed JSON values; nil uses schema defaults")

  attr(:schema, :map,
    default: nil,
    doc: "JSON Schema draft 2020-12 subset for the upstream renderer"
  )

  attr(:class, :any, default: nil)

  attr(:rest, :global,
    include: ~w(autocomplete name novalidate phx-change phx-submit phx-target phx-debounce)
  )

  slot(:inner_block, doc: "Classic form fields, or content outside the schema-owned form")

  def dm_react_form(assigns) do
    values =
      if assigns.schema && is_nil(assigns.values),
        do: nil,
        else: Jason.encode!(assigns.values || %{})

    assigns =
      assigns
      |> assign(:initial_values, values)
      |> assign(:schema_json, assigns.schema && Jason.encode!(assigns.schema))

    ~H"""
    <div id={@id} class={@class} phx-hook="DuskmoonReactForm" phx-update="ignore" data-initial-values={@initial_values} data-schema={@schema_json} {@rest}>
      <%= if @schema do %>
        <div data-dm-react-schema>
          <span role="status">Loading…</span>
        </div>
        {render_slot(@inner_block)}
      <% else %>
        <form data-dm-react-form novalidate>
          {render_slot(@inner_block)}
        </form>
      <% end %>
    </div>
    """
  end

  @doc "Marks one nested field for an upstream DuskMoon React control."
  @doc type: :component
  attr(:name, :any, required: true, doc: "String or nested path list")
  attr(:type, :string, default: "text", values: @field_types)
  attr(:label, :string, default: nil)
  attr(:options, :list, default: [])
  attr(:class, :any, default: nil)
  attr(:rest, :global)

  def dm_react_field(assigns) do
    assigns =
      assign(
        assigns,
        :field_config,
        Jason.encode!(%{
          name: assigns.name,
          type: assigns.type,
          label: assigns.label,
          options: assigns.options
        })
      )

    ~H"""
    <span class={[@class, "dm-react-field"]} data-dm-react-field={@field_config} {@rest}>
      <span data-react-field-loading role="status">Loading…</span>
    </span>
    """
  end

  @doc "Converts an Ecto changeset into the JSON error reply used by React forms."
  def validation_reply(%{__struct__: module} = changeset, opts \\ []) do
    translator = Keyword.get(opts, :translate, &default_error/1)

    %{
      status: "error",
      errors: apply(module, :traverse_errors, [changeset, fn error -> translator.(error) end])
    }
  end

  def success_reply(message \\ nil) do
    %{status: "ok"} |> maybe_message(message)
  end

  defp maybe_message(reply, nil), do: reply
  defp maybe_message(reply, message), do: Map.put(reply, :message, message)

  defp default_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, text ->
      String.replace(text, "%{#{key}}", to_string(value))
    end)
  end
end
