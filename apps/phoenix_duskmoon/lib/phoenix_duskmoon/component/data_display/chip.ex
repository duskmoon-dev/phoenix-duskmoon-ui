defmodule PhoenixDuskmoon.Component.DataDisplay.Chip do
  @moduledoc """
  Chip component for displaying tags, filters, or selections.

  Wraps the `<el-dm-chip>` custom element for standard chips and provides
  native link and LiveView removal modes with accessible semantics.

  ## Examples

      <.dm_chip>Default</.dm_chip>

      <.dm_chip color="primary" variant="filled">Primary</.dm_chip>

      <.dm_chip color="error" deletable>Remove me</.dm_chip>

      <.dm_chip color="success" selected>Active</.dm_chip>

      <.dm_chip href="/categories/elixir" color="primary">Elixir</.dm_chip>

      <.dm_chip deletable delete_event="remove-category" delete_label="Remove category">
        Elixir
      </.dm_chip>

  ## Attributes

  * `variant` - Chip variant: filled, outlined, soft (default: filled)
  * `color` - Chip color: primary, secondary, tertiary, success, warning, error, info
  * `size` - Chip size: sm, md, lg (default: md)
  * `deletable` - Whether the chip shows a delete button (default: false)
  * `selected` - Whether the chip is in selected state (default: false)
  * `disabled` - Whether the chip is disabled (default: false)
  * `href`, `navigate`, `patch` - Render the chip as a semantic link
  * `delete_event` - Render a native removal button when used with `deletable`
  * `delete_label` - Accessible name for the removal button
  * `class` - Additional CSS classes

  Navigation and native removal are separate modes. When both are configured,
  `deletable` with `delete_event` takes precedence.

  ## Slots

  * `:inner_block` - Chip label content (required)
  * `:icon` - Leading icon slot
  """

  use Phoenix.Component

  @doc """
  Renders a chip element.

  ## Examples

      <.dm_chip color="info">Tag</.dm_chip>
      <.dm_chip color="warning" variant="outlined" deletable>Filter</.dm_chip>
      <.dm_chip navigate="/tags/elixir">Elixir</.dm_chip>
      <.dm_chip deletable delete_event="remove-tag" delete_label="Remove Elixir">Elixir</.dm_chip>
  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")

  attr(:variant, :string,
    default: "filled",
    values: ["filled", "outlined", "soft"],
    doc: "chip style variant"
  )

  attr(:color, :string,
    default: nil,
    values: [nil, "primary", "secondary", "tertiary", "success", "warning", "error", "info"],
    doc: "chip color"
  )

  attr(:size, :string, default: "md", values: ["sm", "md", "lg"], doc: "chip size")
  attr(:deletable, :boolean, default: false, doc: "show a delete button on the chip")
  attr(:selected, :boolean, default: false, doc: "mark the chip as selected")
  attr(:disabled, :boolean, default: false, doc: "disable the chip")

  attr(:navigate, :string,
    default: nil,
    doc: "navigate to another LiveView when the chip is activated"
  )

  attr(:patch, :string,
    default: nil,
    doc: "patch the current LiveView when the chip is activated"
  )

  attr(:href, :any,
    default: nil,
    doc: "use traditional browser navigation when the chip is activated"
  )

  attr(:replace, :boolean,
    default: false,
    doc: "replace browser history when using navigate or patch"
  )

  attr(:delete_event, :any,
    default: nil,
    doc: "LiveView event name or JS command dispatched by the native removal button"
  )

  attr(:delete_label, :string,
    default: "Remove chip",
    doc: "accessible label for the native removal button"
  )

  attr(:rest, :global,
    include: ~w(download hreflang referrerpolicy rel target type),
    doc: "additional HTML attributes"
  )

  slot(:inner_block, required: true, doc: "chip label text")
  slot(:icon, doc: "leading icon content")

  # WORKAROUND(upstream): duskmoon-dev/duskmoon-elements#74
  # Native modes avoid nested links and inaccessible delete controls until the
  # custom element provides equivalent semantic APIs.
  def dm_chip(assigns) do
    mode = chip_mode(assigns)
    {rest, delete_rest} = split_delete_rest(mode, assigns.rest)

    assigns =
      assigns
      |> assign(:mode, mode)
      |> assign(:chip_class, chip_class(assigns))
      |> assign(:rest, rest)
      |> assign(:delete_rest, delete_rest)

    ~H"""
    <.link
      :if={@mode == :link && !@disabled}
      id={@id}
      navigate={@navigate}
      patch={@patch}
      href={@href}
      replace={@replace}
      class={@chip_class}
      {@rest}
    >
      <span :if={@icon != []} class="chip-icon">{render_slot(@icon)}</span>
      <span class="chip-label">{render_slot(@inner_block)}</span>
    </.link>
    <span
      :if={@mode == :link && @disabled}
      id={@id}
      class={@chip_class}
      aria-disabled="true"
      {@rest}
    >
      <span :if={@icon != []} class="chip-icon">{render_slot(@icon)}</span>
      <span class="chip-label">{render_slot(@inner_block)}</span>
    </span>
    <span
      :if={@mode == :delete}
      id={@id}
      class={@chip_class}
      aria-disabled={@disabled && "true"}
      {@rest}
    >
      <span :if={@icon != []} class="chip-icon">{render_slot(@icon)}</span>
      <span class="chip-label">{render_slot(@inner_block)}</span>
      <button
        type="button"
        class="chip-close"
        phx-click={@delete_event}
        disabled={@disabled}
        aria-label={@delete_label}
        {@delete_rest}
      >
        <span aria-hidden="true">×</span>
      </button>
    </span>
    <el-dm-chip
      :if={@mode == :element}
      id={@id}
      variant={@variant}
      color={@color}
      size={@size}
      deletable={@deletable}
      selected={@selected}
      disabled={@disabled}
      aria-disabled={@disabled && "true"}
      class={@class}
      {@rest}
    >
      <span :if={@icon != []} slot="icon">{render_slot(@icon)}</span>
      {render_slot(@inner_block)}
    </el-dm-chip>
    """
  end

  defp chip_mode(%{deletable: true, delete_event: delete_event}) when not is_nil(delete_event),
    do: :delete

  defp chip_mode(%{href: href, navigate: navigate, patch: patch})
       when not is_nil(href) or not is_nil(navigate) or not is_nil(patch),
       do: :link

  defp chip_mode(_assigns), do: :element

  defp split_delete_rest(:delete, rest) do
    Enum.reduce(rest, {%{}, %{}}, fn {key, value}, {chip_rest, delete_rest} ->
      if delete_button_attr?(to_string(key)) do
        {chip_rest, Map.put(delete_rest, key, value)}
      else
        {Map.put(chip_rest, key, value), delete_rest}
      end
    end)
  end

  defp split_delete_rest(_mode, rest), do: {rest, %{}}

  defp delete_button_attr?("phx-target"), do: true
  defp delete_button_attr?("phx-disable-with"), do: true
  defp delete_button_attr?("phx-page-loading"), do: true
  defp delete_button_attr?("phx-value-" <> _name), do: true
  defp delete_button_attr?(_attribute), do: false

  defp chip_class(assigns) do
    [
      "chip",
      chip_mode(assigns) == :link && "chip-clickable",
      variant_class(assigns.variant),
      assigns.color && "chip-#{assigns.color}",
      assigns.size != "md" && "chip-#{assigns.size}",
      assigns.selected && "chip-selected",
      assigns.disabled && "chip-disabled",
      assigns.class
    ]
  end

  defp variant_class("outlined"), do: "chip-outlined"
  defp variant_class("soft"), do: "chip-tonal"
  defp variant_class(_variant), do: nil
end
