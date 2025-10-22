defmodule PhoenixDuskmoon.Component.Form.CompactInput do
  @moduledoc """
  Compact form input components for PhoenixDuskmoon UI.

  This module provides compact input components that combine the label
  and input in a more condensed layout, useful for forms with limited space
  or when a more streamlined appearance is desired.

  ## Examples

      <.dm_compact_input field={@form[:email]} type="email" label="Email" />
      <.dm_compact_input name="username" label="Username" value="john" />
      <.dm_compact_input type="select" name="country" label="Country" options={[{"USA", "us"}, {"Canada", "ca"}]} />
  """

  use PhoenixDuskmoon.Component, :html
  import PhoenixDuskmoon.Component.Form

  @doc """
  Renders a compact input with label and error messages.

  A `Phoenix.HTML.FormField` may be passed as argument,
  which is used to retrieve the input name, id, and values.
  Otherwise all attributes may be passed explicitly.

  ## Types

  Only input and select are supported.

  ## Examples

      <.dm_compact_input field={@form[:email]} type="email" />
      <.dm_compact_input name="my-input" errors={["oh no!"]} />
  """
  attr(:field_class, :any, default: nil)
  attr(:id, :any, default: nil)
  attr(:class, :any, default: nil)
  attr(:name, :any)
  attr(:label, :string, default: nil)
  attr(:value, :any)

  attr(:type, :string,
    default: "text",
    values: ~w(color date datetime-local email file month number password
               search select tel text time url week)
  )

  attr(:field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"
  )

  attr(:errors, :list, default: [])
  attr(:checked, :boolean, doc: "the checked flag for checkbox inputs")
  attr(:prompt, :string, default: nil, doc: "the prompt for select inputs")
  attr(:options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2")
  attr(:multiple, :boolean, default: false, doc: "the multiple flag for select inputs")

  attr(:rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)
  )

  slot(:inner_block)

  def dm_compact_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    # |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> dm_compact_input()
  end

  def dm_compact_input(%{type: "select"} = assigns) do
    ~H"""
    <div
      class={[
        "select select-bordered",
        @errors != [] && "select-error",
        @class
      ]}
    >
      <label for={@id} class={["label", @errors != [] && "text-error"]}>
        <%= @label %>
      </label>
      <select
        id={@id}
        name={@name}
        class={[
          "compact-select",
        ]}
        multiple={@multiple}
        {@rest}
      >
        <option :if={@prompt} value=""><%= @prompt %></option>
        <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
      </select>
    </div>
    <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
    """
  end

  def dm_compact_input(assigns) do
    ~H"""
    <div
      class={[
        "input input-bordered",
        @errors != [] && "input-error",
        @class
      ]}
      phx-feedback-for={@name}
    >
      <label for={@id} class={["label", @errors != [] && "text-error"]}>
        <%= @label %>
      </label>
      <input
        type={@type}
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class={[
          "compact-input",
        ]}
        {@rest}
      />
      <%= render_slot(@inner_block) %>
    </div>
    <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
    """
  end
end
