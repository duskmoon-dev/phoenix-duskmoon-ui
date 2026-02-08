defmodule PhoenixDuskmoon.Component.DataEntry.Form do
  @moduledoc """
  Form components for PhoenixDuskmoon UI.

  This module provides form-related components including form containers,
  labels, error messages, and alerts. Input components are provided in
  separate modules for better organization:

  * `PhoenixDuskmoon.Component.Form.Input` - All input types (dm_input)
  * `PhoenixDuskmoon.Component.Form.CompactInput` - Compact inputs (dm_compact_input)

  ## Examples

      <.dm_form :let={f} for={@form} phx-change="validate" phx-submit="save">
        <.dm_input field={f[:email]} label="Email"/>
        <.dm_input field={f[:username]} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.dm_form>

  """
  use Phoenix.Component

  import PhoenixDuskmoon.Component.Icons

  @doc """
  Renders a form container.

  ## Examples

      <.dm_form :let={f} for={@form} phx-change="validate" phx-submit="save">
        <.dm_input field={f[:email]} label="Email"/>
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.dm_form>

  """
  @doc type: :component
  attr(:id, :any, default: nil)
  attr(:class, :any, default: nil)
  attr(:for, :any, doc: "the datastructure for the form")
  attr(:as, :any, default: nil, doc: "the server side parameter to collect all input under")

  attr(:rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"
  )

  slot(:inner_block, required: true)
  slot(:actions, doc: "the slot for form actions, such as a submit button")

  def dm_form(assigns) do
    assigns = assigns |> assign_new(:for, fn -> to_form(%{}) end)

    ~H"""
    <.form
      id={@id}
      class={["dm-form", @class]}
      :let={f}
      for={@for}
      as={@as}
      {@rest}
    >
      {render_slot(@inner_block, f)}
      <div :for={action <- @actions} class="mt-2 flex items-center justify-between gap-6">
        {render_slot(action, f)}
      </div>
    </.form>
    """
  end

  @doc """
  Renders a label.

  ## Examples

      <.dm_label for="email">Email</.dm_label>

  """
  @doc type: :component
  attr(:id, :any, default: nil)
  attr(:class, :any, default: nil)
  attr(:for, :string, default: nil)
  slot(:inner_block, required: true)

  def dm_label(assigns) do
    ~H"""
    <label for={@for} id={@id} class={["dm-label", @class]}>
      {render_slot(@inner_block)}
    </label>
    """
  end

  @doc """
  Generates an error message.

  ## Examples

      <.dm_error>Something went wrong</.dm_error>

  """
  @doc type: :component
  attr(:id, :any, default: nil)
  attr(:class, :any, default: nil)
  slot(:inner_block, required: true)

  def dm_error(assigns) do
    ~H"""
    <span id={@id} class={["dm-error-text flex items-center gap-1", @class]}>
      <.dm_bsi name="exclamation-circle" class="h-3 w-3 flex-none" />
      {render_slot(@inner_block)}
    </span>
    """
  end

  @doc """
  Generates an alert component.

  ## Examples

      <.dm_alert variant="info">
        This is an informational message.
      </.dm_alert>

      <.dm_alert variant="error" icon="exclamation-triangle">
        Something went wrong!
      </.dm_alert>

  """
  @doc type: :component
  attr(:id, :any, default: nil)
  attr(:class, :any, default: nil)

  attr(:variant, :string,
    default: "info",
    values: ~w(info success warning error),
    doc: "the alert variant"
  )

  attr(:icon, :string, default: nil, doc: "override default icon")
  attr(:title, :string, default: nil, doc: "alert title")
  slot(:inner_block, required: true)

  def dm_alert(assigns) do
    assigns =
      assign_new(assigns, :icon, fn ->
        case assigns.variant do
          "info" -> "information-circle"
          "success" -> "check-circle"
          "warning" -> "exclamation-triangle"
          "error" -> "exclamation-circle"
          _ -> "information-circle"
        end
      end)

    ~H"""
    <div id={@id} class={["dm-alert", "dm-alert--#{@variant}", @class]}>
      <.dm_mdi name={@icon} class="h-5 w-5 flex-none" />
      <div>
        <h3 :if={@title} class="font-bold">{@title}</h3>
        <div class="text-sm">{render_slot(@inner_block)}</div>
      </div>
    </div>
    """
  end

  @doc """
  Normalizes checkbox values for boolean fields.
  """
  def normalize_checkbox_value(value) when value in [true, "true", "1"], do: true
  def normalize_checkbox_value(_), do: false
end
