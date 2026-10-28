defmodule DuskmoonStorybookWeb.HologramLive do
  @moduledoc "Hosts Hologram demos in the same Phoenix page shell as Components."

  use DuskmoonStorybookWeb, :live_view

  alias DuskmoonStorybookWeb.DemoLayout

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :demo_section, :hologram)}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    active = Atom.to_string(socket.assigns.live_action)
    demo = Enum.find(DemoLayout.hologram_demos(), &(&1.id == active))
    {:noreply, assign(socket, demo: demo, active_menu: active, page_title: demo.label)}
  end

  @impl true
  def handle_event("theme_changed", _params, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <iframe
      id="hologram-demo"
      src={@demo.source}
      title={@demo.label}
      phx-hook="DuskmoonHologramFrame"
      class="block w-full border-0"
      height="960"
    ></iframe>
    """
  end
end
