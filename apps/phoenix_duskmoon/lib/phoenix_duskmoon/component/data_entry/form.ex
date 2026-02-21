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

  attr(:actions_align, :string,
    default: "between",
    values: ["between", "right", "center"],
    doc: "alignment of form actions (between, right, center)"
  )

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
      <div :for={action <- @actions} class={["form-actions", "form-actions-#{@actions_align}"]}>
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
  Renders a fieldset with optional legend.

  ## Examples

      <.dm_fieldset legend="Personal Info">
        <.dm_input field={f[:name]} label="Name" />
        <.dm_input field={f[:email]} label="Email" />
      </.dm_fieldset>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:legend, :string, default: nil, doc: "fieldset legend text")

  attr(:variant, :string,
    default: nil,
    values: [nil, "filled", "borderless", "card"],
    doc: "fieldset style variant"
  )

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def dm_fieldset(assigns) do
    ~H"""
    <fieldset id={@id} class={[
      "fieldset",
      @variant && "fieldset-#{@variant}",
      @class
    ]} {@rest}>
      <legend :if={@legend} class="fieldset-legend">{@legend}</legend>
      {render_slot(@inner_block)}
    </fieldset>
    """
  end

  @doc """
  Renders a form row for side-by-side fields.

  ## Examples

      <.dm_form_row>
        <.dm_input field={f[:first_name]} label="First" />
        <.dm_input field={f[:last_name]} label="Last" />
      </.dm_form_row>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def dm_form_row(assigns) do
    ~H"""
    <div id={@id} class={["form-row", @class]} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a form grid layout.

  ## Examples

      <.dm_form_grid cols={2}>
        <.dm_input field={f[:city]} label="City" />
        <.dm_input field={f[:state]} label="State" />
      </.dm_form_grid>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:cols, :integer, default: 2, values: [2, 3, 4], doc: "number of grid columns")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def dm_form_grid(assigns) do
    ~H"""
    <div id={@id} class={["form-grid", "form-grid-#{@cols}", @class]} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a form section with title and optional description.

  ## Examples

      <.dm_form_section title="Contact Information" description="How we can reach you.">
        <.dm_input field={f[:email]} label="Email" />
        <.dm_input field={f[:phone]} label="Phone" />
      </.dm_form_section>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:title, :string, default: nil, doc: "section title")
  attr(:description, :string, default: nil, doc: "section description")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def dm_form_section(assigns) do
    ~H"""
    <div id={@id} class={["form-section", @class]} {@rest}>
      <div :if={@title} class="form-section-title">{@title}</div>
      <div :if={@description} class="form-section-description">{@description}</div>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a form divider, optionally with text.

  ## Examples

      <.dm_form_divider />
      <.dm_form_divider text="or" />

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:text, :string, default: nil, doc: "divider text")
  attr(:rest, :global)

  def dm_form_divider(assigns) do
    ~H"""
    <div :if={!@text} id={@id} class={["form-divider", @class]} {@rest}></div>
    <div :if={@text} id={@id} class={["form-divider-text", @class]} {@rest}>{@text}</div>
    """
  end

  @doc """
  Renders an inline form layout.

  ## Examples

      <.dm_form_inline>
        <.dm_input field={f[:first]} label="First" />
        <.dm_input field={f[:last]} label="Last" />
        <.dm_btn type="submit">Go</.dm_btn>
      </.dm_form_inline>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def dm_form_inline(assigns) do
    ~H"""
    <div id={@id} class={["form-inline", @class]} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a form hint displayed above an input.

  ## Examples

      <.dm_form_hint>Must be at least 8 characters</.dm_form_hint>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def dm_form_hint(assigns) do
    ~H"""
    <span id={@id} class={["form-hint", @class]} {@rest}>
      {render_slot(@inner_block)}
    </span>
    """
  end

  @doc """
  Renders a character counter for inputs.

  ## Examples

      <.dm_form_counter current={5} max={100} />
      <.dm_form_counter current={150} max={100} error />

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:current, :integer, required: true, doc: "current character count")
  attr(:max, :integer, required: true, doc: "maximum character count")
  attr(:error, :boolean, default: false, doc: "whether to show error styling")
  attr(:rest, :global)

  def dm_form_counter(assigns) do
    ~H"""
    <span id={@id} class={["form-counter", @error && "form-counter-error", @class]} {@rest}>
      {@current}/{@max}
    </span>
    """
  end

  @doc """
  Normalizes checkbox values for boolean fields.
  """
  def normalize_checkbox_value(value) when value in [true, "true", "1"], do: true
  def normalize_checkbox_value(_), do: false
end
