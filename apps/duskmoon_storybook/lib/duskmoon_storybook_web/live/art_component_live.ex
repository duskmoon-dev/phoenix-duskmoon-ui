defmodule DuskmoonStorybookWeb.ArtComponentLive do
  @moduledoc "Hosts Art Components in the shared demo layout and persistent navigation."

  use DuskmoonStorybookWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :demo_section, :art_components)}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    template = Atom.to_string(socket.assigns.live_action)
    active = "art-" <> String.replace(template, "_", "-")
    {:noreply, assign(socket, page_template: template, active_menu: active)}
  end

  @impl true
  def handle_event("theme_changed", _params, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    Phoenix.Template.render(
      DuskmoonStorybookWeb.ArtComponentHTML,
      assigns.page_template,
      "html",
      assigns
    )
  end
end
