defmodule DuskmoonStorybookWeb.Components.PageLive do
  @moduledoc """
  Hosts the existing component gallery templates inside the shared LiveView layout.

  The explicit component routes retain their URLs and content while the library's
  sticky left menu survives navigation between these pages and the React demos.
  """

  use DuskmoonStorybookWeb, :live_view

  alias DuskmoonStorybookWeb.ComponentNavigation

  @views %{
    "overview" => DuskmoonStorybookWeb.PageHTML,
    "action" => DuskmoonStorybookWeb.Components.ActionHTML,
    "data-display" => DuskmoonStorybookWeb.Components.DataDisplayHTML,
    "data-entry" => DuskmoonStorybookWeb.Components.DataEntryHTML,
    "feedback" => DuskmoonStorybookWeb.Components.FeedbackHTML,
    "navigation" => DuskmoonStorybookWeb.Components.NavigationHTML,
    "layout" => DuskmoonStorybookWeb.Components.LayoutHTML,
    "icon" => DuskmoonStorybookWeb.Components.IconHTML
  }

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       pagination_pages: %{"full" => 3, "thin" => 2, "jumper" => 1},
       show_removable_chip: true,
       chat_messages: [],
       demo_theme: ""
     )}
  end

  @impl true
  def handle_params(_params, uri, socket) do
    path = uri |> URI.parse() |> Map.fetch!(:path) |> URI.decode() |> String.trim_trailing("/")

    {group, item} =
      Enum.find_value(ComponentNavigation.groups(), fn group ->
        if item = Enum.find(group.items, &(&1.to == path)), do: {group, item}
      end)

    template =
      if path == "/components",
        do: "components",
        else: path |> Path.basename() |> String.replace("-", "_")

    socket =
      assign(socket,
        page_module: Map.fetch!(@views, group.id),
        page_template: template,
        active_menu: item.id
      )

    socket =
      if path == "/components",
        do: assign(socket, :catalog, DuskmoonStorybookWeb.PageController.catalog()),
        else: socket

    {:noreply, socket}
  end

  @impl true
  def handle_event("paginate_" <> variant, %{"current" => current}, socket)
      when variant in ["full", "thin", "jumper"] do
    case Integer.parse(current) do
      {page, ""} ->
        max_page = if variant == "thin", do: 5, else: 10
        page = page |> max(1) |> min(max_page)
        pages = Map.put(socket.assigns.pagination_pages, variant, page)
        {:noreply, assign(socket, :pagination_pages, pages)}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("remove-chip", _params, socket) do
    {:noreply, assign(socket, :show_removable_chip, false)}
  end

  def handle_event("send_message", %{"value" => value}, socket) do
    case String.trim(value) do
      "" -> {:noreply, socket}
      message -> {:noreply, update(socket, :chat_messages, &(&1 ++ [message]))}
    end
  end

  def handle_event("theme_changed", %{"theme" => theme}, socket) do
    if theme in ["default", "sunshine", "moonlight"],
      do: {:noreply, assign(socket, :demo_theme, theme)},
      else: {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    Phoenix.Template.render(assigns.page_module, assigns.page_template, "html", assigns)
  end
end
