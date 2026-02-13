defmodule PhoenixDuskmoon.Component.Action.Button do
  @moduledoc """
  Button component using el-dm-button custom element.

  Provides three button modes:
  - Standard button with variants and sizes
  - Button with confirmation dialog
  - Noise effect button (decorative)

  ## Examples

      <.dm_btn>Click me</.dm_btn>

      <.dm_btn variant="primary" size="lg">Primary</.dm_btn>

      <.dm_btn variant="error" confirm="Are you sure?">Delete</.dm_btn>

      <.dm_btn noise content="SUBMIT">Submit</.dm_btn>

  """
  use Phoenix.Component

  # The el-dm-button custom element only supports: primary, secondary, tertiary,
  # ghost, outline. For other variants (info, success, warning, error, accent, link)
  # we map to a supported variant and override colors via inline CSS custom properties.
  @variant_map %{
    "accent" => "tertiary",
    "link" => "ghost"
  }
  @color_override_variants ~w(info success warning error)

  defp map_variant(nil), do: nil
  defp map_variant(v) when is_map_key(@variant_map, v), do: @variant_map[v]
  defp map_variant(v) when v in @color_override_variants, do: "primary"
  defp map_variant(v), do: v

  defp variant_style(v) when v in @color_override_variants do
    "--color-primary: var(--color-#{v}); --color-primary-content: var(--color-#{v}-content);"
  end

  defp variant_style(_), do: nil

  @doc """
  Generates a button.

  ## Examples

      <.dm_btn id="show-btn">Show</.dm_btn>

      <.dm_btn variant="primary" size="lg">Primary Button</.dm_btn>

      <.dm_btn confirm="Are you sure?" confirm_title="Confirm Action">Delete</.dm_btn>

  """
  @doc type: :component
  attr(:id, :any, required: false)
  attr(:class, :any, default: nil, doc: "Additional CSS classes")

  attr(:variant, :string,
    default: nil,
    values: [
      nil,
      "primary",
      "secondary",
      "accent",
      "info",
      "success",
      "warning",
      "error",
      "ghost",
      "link",
      "outline"
    ],
    doc: "Button color variant"
  )

  attr(:size, :string,
    default: nil,
    values: [nil, "xs", "sm", "md", "lg"],
    doc: "Button size"
  )

  attr(:shape, :string,
    default: nil,
    values: [nil, "square", "circle"],
    doc: "Button shape"
  )

  attr(:loading, :boolean, default: false, doc: "Show loading state")
  attr(:disabled, :boolean, default: false, doc: "Disable the button")

  # Noise button attributes
  attr(:noise, :boolean, default: false, doc: "Use noise effect button style")
  attr(:content, :string, default: "", doc: "Content text for noise button")

  # Confirm dialog attributes
  attr(:confirm, :string, default: "", doc: "Confirmation message (enables confirm dialog)")
  attr(:confirm_title, :string, default: "", doc: "Title for confirmation dialog")
  attr(:confirm_text, :string, default: "Yes", doc: "Text for the confirm button in dialog")
  attr(:cancel_text, :string, default: "Cancel", doc: "Text for the cancel button in dialog")
  attr(:confirm_class, :any, default: nil, doc: "CSS class for confirm button")
  attr(:cancel_class, :any, default: nil, doc: "CSS class for cancel button")
  attr(:show_cancel_action, :boolean, default: true, doc: "Show cancel button in dialog")

  attr(:rest, :global,
    include: ~w(phx-click phx-target phx-value-id phx-disable-with name value type form),
    doc: "Additional HTML attributes"
  )

  slot(:inner_block,
    required: true,
    doc: "Button content"
  )

  slot(:confirm_action,
    required: false,
    doc: "Custom confirm action button content"
  )

  @spec dm_btn(map()) :: Phoenix.LiveView.Rendered.t()
  def dm_btn(%{confirm: confirm} = assigns) when confirm != "" do
    assigns =
      assigns
      |> assign_new(:id, fn -> "btn-#{Enum.random(0..999_999)}" end)
      |> assign(:el_variant, map_variant(assigns.variant))
      |> assign(:el_style, variant_style(assigns.variant))

    ~H"""
    <el-dm-button
      id={@id}
      variant={@el_variant}
      size={@size}
      shape={@shape}
      loading={@loading}
      disabled={@disabled}
      class={@class}
      style={@el_style}
      onclick={"document.getElementById('confirm-dialog-#{@id}').showModal()"}
    >
      {render_slot(@inner_block)}
    </el-dm-button>
    <el-dm-dialog id={"confirm-dialog-#{@id}"} role="dialog" aria-modal="true">
      <span slot="header" :if={String.length(@confirm_title) > 0}>
        {@confirm_title}
      </span>
      <p>{@confirm}</p>
      <div slot="footer">
        <%= if length(@confirm_action) > 0 do %>
          {render_slot(@confirm_action)}
        <% else %>
          <form method="dialog">
            <el-dm-button variant="primary" class={@confirm_class} {@rest}>
              {@confirm_text}
            </el-dm-button>
          </form>
        <% end %>
        <form :if={@show_cancel_action} method="dialog">
          <el-dm-button variant="ghost" class={@cancel_class}>
            {@cancel_text}
          </el-dm-button>
        </form>
      </div>
    </el-dm-dialog>
    """
  end

  def dm_btn(%{noise: true} = assigns) do
    assigns =
      assigns
      |> assign_new(:id, fn -> nil end)

    ~H"""
    <button
      type="button"
      id={@id}
      class={["btn-noise", @class]}
      data-content={@content}
      aria-label={@content}
      style="--aps: running"
      {@rest}
    >
      <span aria-hidden="true"><i :for={_ <- 0..72} /></span>
    </button>
    """
  end

  def dm_btn(%{} = assigns) do
    assigns =
      assigns
      |> assign_new(:id, fn -> nil end)
      |> assign(:el_variant, map_variant(assigns.variant))
      |> assign(:el_style, variant_style(assigns.variant))

    ~H"""
    <el-dm-button
      id={@id}
      variant={@el_variant}
      size={@size}
      shape={@shape}
      loading={@loading}
      disabled={@disabled}
      class={@class}
      style={@el_style}
      phx-hook={if @rest["phx-click"], do: "WebComponentHook"}
      {@rest}
    >
      {render_slot(@inner_block)}
    </el-dm-button>
    """
  end
end
