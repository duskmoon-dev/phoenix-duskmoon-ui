defmodule PhoenixDuskmoon.Component.DataEntry.Form do
  @moduledoc """
  Form components for PhoenixDuskmoon UI.

  This module provides form-related components including form containers,
  labels, error messages, and alerts. Input components are provided in
  separate modules for better organization:

  * `PhoenixDuskmoon.Component.DataEntry.Input` - All input types (dm_input)
  * `PhoenixDuskmoon.Component.DataEntry.CompactInput` - Compact inputs (dm_compact_input)

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

  import PhoenixDuskmoon.Component.Icon.Icons

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
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes for the form")
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
      class={@class}
      :let={f}
      for={@for}
      as={@as}
      {@rest}
    >
      {render_slot(@inner_block, f)}
      <div :for={action <- @actions} class="form-actions form-actions-between">
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
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:for, :string, default: nil, doc: "the id of the input this label is for")
  attr(:required, :boolean, default: false, doc: "show required indicator (*)")
  attr(:optional, :boolean, default: false, doc: "show optional indicator")
  attr(:size, :string, default: nil, values: ["sm", "lg", nil], doc: "label size (sm, lg)")
  slot(:inner_block, required: true)

  def dm_label(assigns) do
    ~H"""
    <label for={@for} id={@id} class={[
      "form-label",
      @required && "form-label-required",
      @optional && "form-label-optional",
      @size && "form-label-#{@size}",
      @class
    ]}>
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
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  slot(:inner_block, required: true)

  def dm_error(assigns) do
    ~H"""
    <span id={@id} class={["helper-text helper-text-error helper-text-icon", @class]}>
      <.dm_bsi name="exclamation-circle" class="h-3 w-3 flex-none" />
      {render_slot(@inner_block)}
    </span>
    """
  end

  @doc """
  Generates an alert component.

  Wraps the `<el-dm-alert>` custom element.

  ## Examples

      <.dm_alert variant="info">
        This is an informational message.
      </.dm_alert>

      <.dm_alert variant="error" icon="exclamation-triangle">
        Something went wrong!
      </.dm_alert>

      <.dm_alert variant="success" dismissible>
        Settings saved successfully.
      </.dm_alert>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")

  attr(:variant, :string,
    default: "info",
    values: ~w(info success warning error),
    doc: "the alert variant (maps to element type)"
  )

  attr(:icon, :string, default: nil, doc: "override default icon (MDI name)")
  attr(:title, :string, default: nil, doc: "alert title")
  attr(:dismissible, :boolean, default: false, doc: "whether the alert can be dismissed")
  attr(:compact, :boolean, default: false, doc: "use compact styling")
  attr(:filled, :boolean, default: false, doc: "use filled style (solid background)")
  attr(:outlined, :boolean, default: false, doc: "use outlined style (border emphasis)")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def dm_alert(assigns) do
    element_variant =
      cond do
        assigns.filled -> "filled"
        assigns.outlined -> "outlined"
        true -> nil
      end

    assigns = assign(assigns, :element_variant, element_variant)

    ~H"""
    <el-dm-alert
      id={@id}
      type={@variant}
      variant={@element_variant}
      title={@title}
      dismissible={@dismissible}
      compact={@compact}
      class={@class}
      {@rest}
    >
      <span :if={@icon} slot="icon"><.dm_mdi name={@icon} class="h-5 w-5" /></span>
      {render_slot(@inner_block)}
    </el-dm-alert>
    """
  end

  @doc """
  Normalizes checkbox values for boolean fields.
  """
  def normalize_checkbox_value(value) when value in [true, "true", "1"], do: true
  def normalize_checkbox_value(_), do: false
end
