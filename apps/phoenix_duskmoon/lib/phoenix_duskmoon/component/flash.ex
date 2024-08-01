defmodule PhoenixDuskmoon.Component.Flash do
  use PhoenixDuskmoon.Component, :html

  import PhoenixDuskmoon.Component.Icons

  @doc """
  Renders flash notices.

  ## Examples

      <.dm_flash kind={:info} flash={@flash} />
      <.dm_flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.dm_flash>
  """
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
      class={"w-80 sm:w-96 toast toast-top toast-end"}
      {@rest}
    >
      <div class={["flex flex-col gap-2 relative alert", if(@kind == :info, do: "alert-info"), if(@kind == :error, do: "alert-error")]}>
        <div :if={@title} class="flex items-center gap-1.5 w-full text-xs font-semibold leading-6">
          <.dm_bsi :if={@kind == :info} name="info-circle" class="w-4 h-4" />
          <.dm_bsi :if={@kind == :error} name="exclamation-circle" class="w-4 h-4" />
          <%= @title %>
        </div>
        <div class="w-full text-xs leading-5"><%= msg %></div>
        <button
          :if={@close}
          type="button"
          class="absolute top-2 right-2 btn btn-ghost btn-xs"
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
  attr(:flash, :map, required: true, doc: "the map of flash messages")

  def dm_flash_group(assigns) do
    ~H"""
    <.dm_flash id="flash-info" kind={:info} title={"Success!"} flash={@flash} />
    <.dm_flash id="flash-error" kind={:error} title={"Error!"} flash={@flash} />
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
