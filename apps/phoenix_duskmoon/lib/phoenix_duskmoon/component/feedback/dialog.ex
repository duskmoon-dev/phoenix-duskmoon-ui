defmodule PhoenixDuskmoon.Component.Feedback.Dialog do
  @moduledoc """
  Modal dialog component using el-dm-dialog custom element.

  ## Examples

      <.dm_modal>
        <:trigger :let={dialog_id}>
          <.dm_btn onclick={"\#{dialog_id}.showModal()"}>Open</.dm_btn>
        </:trigger>
        <:title>PhoenixDuskmoon</:title>
        <:body>Modal content here</:body>
        <:footer>
          <.dm_btn>Close</.dm_btn>
        </:footer>
      </.dm_modal>

  """
  use Phoenix.Component

  import PhoenixDuskmoon.Component.Icon.Icons

  @doc """
  Renders a modal dialog.

  ## Examples

      <.dm_modal>
        <:trigger :let={dialog_id}>
          <button type="button" onclick={"\#{dialog_id}.showModal()"}>Open</button>
        </:trigger>
        <:title>Modal Title</:title>
        <:body>Modal body content</:body>
      </.dm_modal>

  """
  @doc type: :component
  attr(:id, :any, doc: "Modal id")
  attr(:class, :any, default: nil, doc: "Additional CSS classes")

  attr(:hide_close, :boolean,
    default: false,
    doc: "Hide the close button"
  )

  attr(:position, :string,
    default: nil,
    values: [nil, "top", "middle", "bottom"],
    doc: "Modal position"
  )

  attr(:backdrop, :boolean,
    default: false,
    doc: "Apply backdrop blur effect"
  )

  attr(:size, :string,
    default: nil,
    values: [nil, "xs", "sm", "md", "lg", "xl"],
    doc: "Modal size"
  )

  attr(:responsive, :boolean,
    default: false,
    doc: "Make modal responsive"
  )

  attr(:no_backdrop, :boolean,
    default: false,
    doc: "Hide the backdrop overlay"
  )

  attr(:close_label, :string, default: "Close", doc: "Accessible label for the close button")
  attr(:rest, :global)

  slot(:trigger, doc: "Element that opens the modal") do
    attr(:class, :any)
  end

  slot(:title, doc: "Modal title") do
    attr(:class, :any)
  end

  slot(:body, doc: "Modal content", required: true) do
    attr(:class, :any)
  end

  slot(:footer, doc: "Modal footer with actions") do
    attr(:class, :any)
  end

  def dm_modal(assigns) do
    assigns =
      assigns
      |> assign_new(:id, fn -> "modal-#{Enum.random(0..999_999)}" end)

    ~H"""
    {render_slot(@trigger, @id)}
    <el-dm-dialog
      id={@id}
      role="dialog"
      aria-modal="true"
      aria-labelledby={length(@title) > 0 && "#{@id}-title"}
      aria-label={length(@title) == 0 && "Dialog"}
      position={@position}
      size={@size}
      backdrop={@backdrop && "blur"}
      responsive={@responsive}
      no-backdrop={@no_backdrop}
      class={@class}
      {@rest}
    >
      <%= for {title, idx} <- Enum.with_index(@title) do %>
        <span
          id={idx == 0 && "#{@id}-title"}
          slot="header"
          class={Map.get(title, :class)}
        >
          {render_slot(title)}
        </span>
      <% end %>
      <form :if={!@hide_close} method="dialog" slot="close">
        <el-dm-button variant="ghost" size="sm" shape="circle" aria-label={@close_label}>
          <.dm_mdi name="close" class="w-4 h-4" />
        </el-dm-button>
      </form>
      <div
        :for={body <- @body}
        class={Map.get(body, :class)}
      >
        {render_slot(body)}
      </div>
      <span
        :for={footer <- @footer}
        slot="footer"
        class={Map.get(footer, :class)}
      >
        {render_slot(footer)}
      </span>
    </el-dm-dialog>
    """
  end
end
