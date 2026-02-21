defmodule PhoenixDuskmoon.Component.Feedback.Snackbar do
  @moduledoc """
  Snackbar component using `@duskmoon-dev/core` CSS classes.

  Renders brief notification messages, similar to toasts but with
  action buttons and different positioning. Snackbars provide brief
  feedback about an operation through a message at the edge of the screen.

  ## Examples

      <.dm_snackbar_container position="bottom">
        <.dm_snackbar type="info">
          <:message>File saved successfully</:message>
          <:action>Undo</:action>
        </.dm_snackbar>
      </.dm_snackbar_container>

      <.dm_snackbar type="error">
        <:message>Failed to upload file</:message>
        <:action>Retry</:action>
        <:close />
      </.dm_snackbar>

  """

  use Phoenix.Component

  @doc """
  Renders a snackbar notification.

  ## Examples

      <.dm_snackbar type="success">
        <:message>Operation completed</:message>
      </.dm_snackbar>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")

  attr(:type, :string,
    default: nil,
    values: [
      nil,
      "info",
      "success",
      "warning",
      "error",
      "primary",
      "secondary",
      "tertiary",
      "dark"
    ],
    doc: "Color/type variant"
  )

  attr(:open, :boolean, default: false, doc: "Whether the snackbar is visible")
  attr(:multiline, :boolean, default: false, doc: "Multiline layout for longer messages")

  attr(:position, :string,
    default: nil,
    values: [nil, "bottom", "bottom-left", "bottom-right", "top", "top-left", "top-right"],
    doc: "Standalone position (when not inside a container)"
  )

  attr(:rest, :global)

  slot(:message, required: true, doc: "Message content")
  slot(:action, doc: "Action button")
  slot(:close, doc: "Close button")

  def dm_snackbar(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "snackbar",
        @type && "snackbar-#{@type}",
        @open && "snackbar-show",
        @multiline && "snackbar-multiline",
        @position && "snackbar-#{@position}",
        @class
      ]}
      role="alert"
      aria-live="assertive"
      {@rest}
    >
      <span class="snackbar-message">{render_slot(@message)}</span>
      <button :for={action <- @action} type="button" class="snackbar-action">
        {render_slot(action)}
      </button>
      <button :for={_close <- @close} type="button" class="snackbar-close" aria-label="Close">
        &times;
      </button>
    </div>
    """
  end

  @doc """
  Renders a snackbar container for positioning multiple snackbars.

  ## Examples

      <.dm_snackbar_container position="bottom-right">
        <.dm_snackbar type="info" open>
          <:message>New notification</:message>
        </.dm_snackbar>
      </.dm_snackbar_container>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")

  attr(:position, :string,
    default: "bottom",
    values: ["bottom", "bottom-left", "bottom-right", "top", "top-left", "top-right"],
    doc: "Position of the container"
  )

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def dm_snackbar_container(assigns) do
    ~H"""
    <div
      id={@id}
      class={["snackbar-container", "snackbar-container-#{@position}", @class]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
