defmodule PhoenixDuskmoon.Live.LeftMenu do
  @moduledoc """
  Persistent child LiveView owned by `dm_left_menu/1` in sticky mode.

  Use `dm_left_menu sticky socket={@socket} groups={@groups} active={@active}`
  in a shared LiveView layout instead of mounting this module directly.
  The component passes the normalized menu configuration and the package's
  navigation hook synchronizes the current page without replacing this child.

  Applications filter menu data according to their authorization rules before
  passing it to the component. This child only accepts active identifiers from
  enabled items in that menu, or an empty string to clear the selection.
  """

  use Phoenix.LiveView, layout: false

  import PhoenixDuskmoon.Component.Navigation.LeftMenu, only: [dm_left_menu: 1]

  @impl true
  def mount(_params, %{"config" => config} = session, socket) do
    allowed_ids =
      config.groups
      |> Enum.flat_map(& &1.items)
      |> Enum.reject(& &1.disabled)
      |> MapSet.new(& &1.id)

    active = Map.get(session, "active", "")
    active = if valid_active?(active, allowed_ids), do: active, else: ""

    {:ok, assign(socket, config: config, allowed_ids: allowed_ids, active: active)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <%!-- The parent marker owns mutable controlled input. Child active patches must
          never replay the initial collapse value over a newer client toggle. --%>
    <.dm_left_menu
      {@config}
      active={@active}
      collapse_controlled={false}
      storage_key={if @config[:collapse_controlled], do: nil, else: @config.storage_key}
    />
    """
  end

  @impl true
  def handle_event("set_active_nav", %{"active_nav" => active}, socket) do
    if valid_active?(active, socket.assigns.allowed_ids) do
      {:reply, %{status: "ok"}, assign(socket, :active, active)}
    else
      {:reply, %{status: "error"}, socket}
    end
  end

  def handle_event("set_active_nav", _payload, socket) do
    {:reply, %{status: "error"}, socket}
  end

  defp valid_active?(active, allowed_ids) do
    is_binary(active) && (active == "" || MapSet.member?(allowed_ids, active))
  end
end
