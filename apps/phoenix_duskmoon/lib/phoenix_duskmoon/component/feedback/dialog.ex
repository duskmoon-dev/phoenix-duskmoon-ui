defmodule PhoenixDuskmoon.Component.Feedback.Dialog do
  @moduledoc """
  Modal dialog component using the native HTML `<dialog>` element and
  `@duskmoon-dev/core` dialog CSS.

  Open and close with the Invoker Commands API (`command` / `commandfor`).

  ## Examples

      <.dm_modal id="my-modal">
        <:trigger :let={id}>
          <.dm_btn variant="primary" command="show-modal" commandfor={id}>Open</.dm_btn>
        </:trigger>
        <:title>PhoenixDuskmoon</:title>
        <:body>Modal content here</:body>
        <:footer>
          <.dm_btn command="close" commandfor="my-modal">Close</.dm_btn>
        </:footer>
      </.dm_modal>

  """
  use Phoenix.Component

  import PhoenixDuskmoon.Component.Icon.Icons

  @doc """
  Renders a modal dialog.

  ## Examples

      <.dm_modal id="my-modal">
        <:trigger :let={id}>
          <button type="button" command="show-modal" commandfor={id}>Open</button>
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
    doc: "Modal position (top / bottom; middle is default centered)"
  )

  attr(:size, :string,
    default: nil,
    values: [nil, "xs", "sm", "md", "lg", "xl"],
    doc: "Modal size (sm / lg / xl map to core classes; xs and md use default width)"
  )

  attr(:close_label, :string, default: "Close", doc: "Accessible label for the close button")

  attr(:dialog_label, :string,
    default: "Dialog",
    doc: "Accessible fallback label when no title slot is provided (i18n)"
  )

  attr(:rest, :global)

  slot(:trigger, doc: "Element that opens the modal") do
    attr(:class, :any, doc: "trigger wrapper CSS classes")
  end

  slot(:title, doc: "Modal title") do
    attr(:class, :any, doc: "title container CSS classes")
  end

  slot(:body, doc: "Modal content", required: true) do
    attr(:class, :any, doc: "body container CSS classes")
  end

  slot(:footer, doc: "Modal footer with actions") do
    attr(:class, :any, doc: "footer container CSS classes")
  end

  def dm_modal(assigns) do
    assigns =
      assigns
      |> assign_new(:id, fn -> "modal-#{System.unique_integer([:positive])}" end)

    ~H"""
    {render_slot(@trigger, @id)}
    <dialog
      id={@id}
      class={["dialog", dialog_size(@size), dialog_position(@position), @class]}
      aria-labelledby={@title != [] && "#{@id}-title"}
      aria-label={@title == [] && @dialog_label}
      {@rest}
    >
      <div class="dialog-box">
        <div :if={@title != [] || !@hide_close} class="dialog-header">
          <h2
            :for={{title, idx} <- Enum.with_index(@title)}
            id={idx == 0 && "#{@id}-title"}
            class={["dialog-title", title[:class]]}
          >
            {render_slot(title)}
          </h2>
          <button
            :if={!@hide_close}
            type="button"
            class="dialog-close"
            command="close"
            commandfor={@id}
            aria-label={@close_label}
          >
            <.dm_mdi name="close" class="w-4 h-4" />
          </button>
        </div>
        <div
          :for={body <- @body}
          class={["dialog-body", body[:class]]}
        >
          {render_slot(body)}
        </div>
        <div
          :for={footer <- @footer}
          class={["dialog-footer", footer[:class]]}
        >
          {render_slot(footer)}
        </div>
      </div>
    </dialog>
    """
  end

  defp dialog_size("sm"), do: "dialog-sm"
  defp dialog_size("lg"), do: "dialog-lg"
  defp dialog_size("xl"), do: "dialog-xl"
  defp dialog_size(_), do: nil

  defp dialog_position("top"), do: "dialog-top"
  defp dialog_position("bottom"), do: "dialog-bottom"
  defp dialog_position(_), do: nil
end
