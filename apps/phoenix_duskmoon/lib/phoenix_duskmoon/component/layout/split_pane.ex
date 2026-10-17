defmodule PhoenixDuskmoon.Component.Layout.SplitPane do
  @moduledoc """
  Two native HEEx panes with an accessible, client-owned resize separator.

  Register `DuskmoonSplitPane` from `phoenix_duskmoon/hooks` with your LiveSocket.
  The hook preserves the chosen width across LiveView patches without sending
  resize events to the server. See the split-pane guide for the lifecycle contract.
  """
  use Phoenix.Component

  @doc """
  Renders a resizable primary pane beside flexible secondary content.

  Widths and `stack_at` are integer CSS pixels. The panes stack when the container
  is narrower than `stack_at`, or cannot accommodate both minimum widths and the
  16px separator. Both panes remain visible. Without the hook they stay stacked.

  ArrowLeft/ArrowRight resize by 10px; Home/End select the available bounds.
  `initial_width` is an initial value, not a server-controlled width.

      <.dm_split_pane id="files" resize_label="Resize folder navigation">
        <:primary><nav aria-label="Folders">Folders</nav></:primary>
        <section>Files</section>
      </.dm_split_pane>
  """
  @doc type: :component
  attr(:id, :string, required: true)
  attr(:initial_width, :integer, default: 280)
  attr(:min_width, :integer, default: 160)
  attr(:max_width, :integer, default: 480)
  attr(:min_secondary_width, :integer, default: 240)
  attr(:stack_at, :integer, default: 640)
  attr(:resize_label, :string, default: "Resize panels")
  attr(:class, :any, default: nil)
  attr(:primary_class, :any, default: nil)
  attr(:secondary_class, :any, default: nil)
  attr(:rest, :global)
  slot(:primary, required: true)
  slot(:inner_block, required: true)

  def dm_split_pane(assigns) do
    for name <- [:initial_width, :min_width, :max_width, :min_secondary_width, :stack_at] do
      unless is_integer(assigns[name]) and assigns[name] >= 0 do
        raise ArgumentError, "#{name} must be a nonnegative integer number of pixels"
      end
    end

    if assigns.max_width < assigns.min_width do
      raise ArgumentError, "max_width must be at least min_width"
    end

    assigns =
      assign(
        assigns,
        :bounded_width,
        assigns.initial_width |> max(assigns.min_width) |> min(assigns.max_width)
      )

    assigns =
      assign(
        assigns,
        :rest,
        Map.drop(assigns.rest, ["phx-hook", "phx-update", :"phx-hook", :"phx-update"])
      )

    ~H"""
    <div
      id={@id}
      class={["dm-split-pane", @class]}
      phx-hook="DuskmoonSplitPane"
      data-initial-width={@bounded_width}
      data-min-width={@min_width}
      data-max-width={@max_width}
      data-min-secondary-width={@min_secondary_width}
      data-stack-at={@stack_at}
      {@rest}
    >
      <div id={"#{@id}-primary"} class={["dm-split-pane-primary", @primary_class]}>
        {render_slot(@primary)}
      </div>
      <div
        id={"#{@id}-separator"}
        class="divider divider-vertical dm-split-pane-handle"
        data-split-pane-handle
        role="separator"
        aria-label={@resize_label}
        aria-orientation="vertical"
        aria-controls={"#{@id}-primary"}
        aria-valuemin={@min_width}
        aria-valuemax={@max_width}
        aria-valuenow={@bounded_width}
        aria-valuetext={"#{@bounded_width} pixels"}
        tabindex="-1"
        hidden
      >
      </div>
      <div id={"#{@id}-secondary"} class={["dm-split-pane-secondary", @secondary_class]}>
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end
end
