defmodule PhoenixDuskmoon.Component.Feedback.Toast do
  @moduledoc """
  Toast notification component using CSS classes from `@duskmoon-dev/core`.

  Renders individual toast notifications and positioned containers.
  No custom element — uses standard HTML with upstream CSS classes.

  ## Examples

      <.dm_toast_container position="top-right">
        <.dm_toast type="success" title="Saved" open>
          Your changes have been saved.
        </.dm_toast>
      </.dm_toast_container>

      <.dm_toast type="error" title="Error" icon="alert-circle" open>
        Something went wrong.
      </.dm_toast>

  """
  use Phoenix.Component

  import PhoenixDuskmoon.Component.Icon.Icons

  @doc """
  Renders a positioned container for toast notifications.

  ## Examples

      <.dm_toast_container position="top-right">
        <.dm_toast type="info" open>Hello</.dm_toast>
      </.dm_toast_container>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")

  attr(:position, :string,
    default: "top-right",
    values: [
      "top-right",
      "top-left",
      "top-center",
      "bottom-right",
      "bottom-left",
      "bottom-center"
    ],
    doc: "position of the toast container on screen"
  )

  attr(:rest, :global)
  slot(:inner_block, required: true, doc: "Toast notifications")

  def dm_toast_container(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "toast-container",
        "toast-container-#{@position}",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders an individual toast notification.

  ## Examples

      <.dm_toast type="success" title="Done" open>Task completed.</.dm_toast>

      <.dm_toast type="error" icon="alert-circle" filled open>Error occurred.</.dm_toast>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")

  attr(:type, :string,
    default: nil,
    values: [nil, "info", "success", "warning", "error"],
    doc: "toast type variant"
  )

  attr(:title, :string, default: nil, doc: "toast title text")
  attr(:icon, :string, default: nil, doc: "MDI icon name")
  attr(:filled, :boolean, default: false, doc: "use filled background style")
  attr(:open, :boolean, default: false, doc: "whether the toast is visible")
  attr(:show_close, :boolean, default: false, doc: "show a close button")
  attr(:close_label, :string, default: "Close", doc: "accessible label for the close button")
  attr(:rest, :global)
  slot(:inner_block, doc: "Toast message content")

  def dm_toast(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "toast",
        @type && "toast-#{@type}",
        @filled && "toast-filled",
        @open && "toast-open",
        @class
      ]}
      role="alert"
      aria-live="assertive"
      aria-atomic="true"
      {@rest}
    >
      <div :if={@icon} class="toast-icon" aria-hidden="true">
        <.dm_mdi name={@icon} class="w-5 h-5" />
      </div>
      <div class="toast-content">
        <div :if={@title} class="toast-title">{@title}</div>
        <div class="toast-message">{render_slot(@inner_block)}</div>
      </div>
      <button :if={@show_close} type="button" class="toast-close" aria-label={@close_label}>
        <.dm_mdi name="close" class="w-4 h-4" />
      </button>
    </div>
    """
  end
end
