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
  attr(:title, :string, default: nil)
  attr(:kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup")
  attr(:autoshow, :boolean, default: true, doc: "whether to auto show the flash on mount")
  attr(:close, :boolean, default: true, doc: "whether the flash can be closed")
  attr(:rest, :global, doc: "the arbitrary HTML attributes to add to the flash container")

  slot(:inner_block, doc: "the optional inner block that renders the flash message")

  def dm_flash(assigns) do
    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-mounted={@autoshow && JS.show(to: "##{@id}")}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> JS.hide(to: "##{@id}")}
      role="alert"
      class={"hidden w-80 sm:w-96 dm-toast dm-toast--top dm-toast--end z-[1000]"}
      {@rest}
    >
      <div class={["flex flex-col gap-2 relative dm-alert", if(@kind == :info, do: "dm-alert--info"), if(@kind == :error, do: "dm-alert--error")]}>
        <div :if={@title} class="flex items-center gap-1.5 w-full text-xs font-semibold leading-6">
          <.dm_bsi :if={@kind == :info} name="info-circle" class="w-4 h-4" />
          <.dm_bsi :if={@kind == :error} name="exclamation-circle" class="w-4 h-4" />
          <%= @title %>
        </div>
        <div class="w-full text-xs leading-5"><%= msg %></div>
        <button
          :if={@close}
          type="button"
          class="absolute top-2 right-2 dm-btn dm-btn--ghost dm-btn--xs"
          aria-label={"close"}
        >
          <.dm_bsi name="x" class="w-5 h-5 " />
        </button>
      </div>
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

  def dm_flash_group(assigns) do
    ~H"""
    <.dm_flash id="flash-info" kind={:info} title={@info_title} flash={@flash} />
    <.dm_flash id="flash-error" kind={:error} title={@error_title} flash={@flash} />
    <.dm_flash
      id="disconnected"
      kind={:error}
      title="We can't find the internet"
      close={false}
      autoshow={false}
      phx-disconnected={JS.show(to: "#disconnected")}
      phx-connected={JS.hide(to: "#disconnected")}
    >
      Attempting to reconnect <.dm_bsi name="arrow-repeat" class="inline ml-1 w-3 h-3 animate-spin" />
    </.dm_flash>
    """
  end
end
