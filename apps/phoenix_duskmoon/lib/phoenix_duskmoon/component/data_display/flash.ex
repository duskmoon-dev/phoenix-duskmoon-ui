defmodule PhoenixDuskmoon.Component.DataDisplay.Flash do
  @moduledoc """
  Duskmoon UI Flash Component

  Use this component to display flash messages.
  Replace default flash in `Phoenix` project.

      <.dm_flash_group flash={@flash} />
  """
  use PhoenixDuskmoon.Component, :html

  import PhoenixDuskmoon.Component.Icon.Icons

  @doc """
  Renders flash notices.

  ## Examples

      <.dm_flash kind={:info} flash={@flash} />
      <.dm_flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.dm_flash>
  """
  @doc type: :component
  attr(:id, :string, default: "flash", doc: "the optional id of flash container")
  attr(:flash, :map, default: %{}, doc: "the map of flash messages to display")
  attr(:title, :string, default: nil, doc: "flash message title")
  attr(:kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup")
  attr(:autoshow, :boolean, default: true, doc: "whether to auto show the flash on mount")
  attr(:close, :boolean, default: true, doc: "whether the flash can be closed")
  attr(:close_label, :string, default: "Close", doc: "accessible label for the close button")
  attr(:rest, :global, doc: "the arbitrary HTML attributes to add to the flash container")

  slot(:inner_block, doc: "the optional inner block that renders the flash message")

  def dm_flash(assigns) do
    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-mounted={@autoshow && JS.add_class("toast-open", to: "##{@id}")}
      phx-click={
        JS.push("lv:clear-flash", value: %{key: @kind})
        |> JS.remove_class("toast-open", to: "##{@id}")
      }
      role="alert"
      aria-live={if(@kind == :error, do: "assertive", else: "polite")}
      aria-atomic="true"
      class={["toast", "toast-#{@kind}"]}
      {@rest}
    >
      <div :if={@title} class="toast-icon" aria-hidden="true">
        <.dm_bsi :if={@kind == :info} name="info-circle" class="w-5 h-5" />
        <.dm_bsi :if={@kind == :error} name="exclamation-circle" class="w-5 h-5" />
      </div>
      <div class="toast-content">
        <div :if={@title} class="toast-title">{@title}</div>
        <div class="toast-message">{msg}</div>
      </div>
      <button
        :if={@close}
        type="button"
        class="toast-close"
        aria-label={@close_label}
      >
        <.dm_mdi name="close" class="w-4 h-4" aria-hidden="true" />
      </button>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.dm_flash_group flash={@flash} />
  """
  @doc type: :component
  attr(:flash, :map, required: true, doc: "the map of flash messages")
  attr(:info_title, :string, default: "Success!", doc: "title for info flash messages")
  attr(:error_title, :string, default: "Error!", doc: "title for error flash messages")

  attr(:disconnected_title, :string,
    default: "We can't find the internet",
    doc: "title for the disconnected flash message"
  )

  attr(:reconnecting_text, :string,
    default: "Attempting to reconnect",
    doc: "text shown while attempting to reconnect"
  )

  def dm_flash_group(assigns) do
    ~H"""
    <div class="toast-container toast-container-top-right">
      <.dm_flash id="flash-info" kind={:info} title={@info_title} flash={@flash} />
      <.dm_flash id="flash-error" kind={:error} title={@error_title} flash={@flash} />
      <.dm_flash
        id="disconnected"
        kind={:error}
        title={@disconnected_title}
        close={false}
        autoshow={false}
        phx-disconnected={JS.add_class("toast-open", to: "#disconnected")}
        phx-connected={JS.remove_class("toast-open", to: "#disconnected")}
      >
        {@reconnecting_text} <.dm_bsi name="arrow-repeat" class="inline ml-1 w-3 h-3 animate-spin" aria-hidden="true" />
      </.dm_flash>
    </div>
    """
  end
end
