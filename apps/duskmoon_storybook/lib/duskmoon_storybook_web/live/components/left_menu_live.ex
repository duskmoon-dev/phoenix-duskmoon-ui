defmodule DuskmoonStorybookWeb.Components.LeftMenuLive do
  @moduledoc "Live navigation example using the library-owned persistent menu."

  use DuskmoonStorybookWeb, :live_view

  @items Enum.map(1..24, fn number ->
           case number do
             1 ->
               %{id: "dashboard", label: "Dashboard", icon: "view-dashboard-outline"}

             2 ->
               %{id: "settings", label: "Settings", icon: "cog-outline"}

             _ ->
               %{
                 id: "item-#{number}",
                 label: "Workspace item #{number}",
                 icon: "file-document-outline"
               }
           end
         end)
  @pages Enum.map(@items, & &1.id)

  @impl true
  def mount(_params, _session, socket) do
    groups =
      @items
      |> Enum.chunk_every(8)
      |> Enum.zip([
        {"workspace", "Workspace"},
        {"library", "Library"},
        {"administration", "Administration"}
      ])
      |> Enum.map(fn {items, {id, label}} ->
        %{
          id: id,
          label: label,
          open: id != "administration",
          items:
            Enum.map(items, fn item ->
              Map.merge(item, %{
                to: "/components/navigation/left-menu/live/#{item.id}",
                rest: %{"id" => "left-menu-demo-link-#{item.id}"}
              })
            end)
        }
      end)

    {:ok, assign(socket, menu_groups: groups), layout: {__MODULE__, :demo_layout}}
  end

  @impl true
  def handle_params(%{"page" => page} = params, _uri, socket) do
    page = if page in @pages, do: page, else: "dashboard"

    {:noreply, assign(socket, active_nav: page, details: params["tab"] == "details")}
  end

  @doc "Renders the shared live layout that keeps the sidebar mounted during navigation."
  def demo_layout(assigns) do
    ~H"""
    <div class="flex w-full items-start bg-surface text-on-surface">
      <.dm_left_menu
        id="left-menu-demo-sidebar"
        sticky
        socket={@socket}
        groups={@menu_groups}
        active={@active_nav}
        brand={%{label: "Duskmoon Workspace", icon: "moon-waning-crescent"}}
        footer_text="24 pages · persistent sidebar"
        storage_key="duskmoon:storybook:left-menu-collapsed"
        nav_label="Persistent workspace navigation"
        class="sticky top-0 h-dvh bg-base-200 text-base-content"
      />
      <main class="min-w-0 flex-1 p-6 md:p-10">{@inner_content}</main>
    </div>
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
    <section
      id="left-menu-demo-page"
      class="max-w-3xl space-y-6"
    >
      <.link navigate={~p"/components/navigation/left-menu"} class="link text-sm">← Left menu documentation</.link>
      <header>
        <p class="mb-2 text-sm text-on-surface-variant">Persistent navigation example</p>
        <h1 class="text-3xl font-bold">
          {String.replace(@active_nav, "-", " ") |> String.capitalize()}
        </h1>
        <p class="mt-3 text-on-surface-variant">
          Scroll the menu, close a group, and navigate between pages. The sticky sidebar
          keeps its scroll position and the toggle switches between labels and an icon rail.
        </p>
      </header>
      <div class="flex flex-wrap gap-3">
        <.link
          id="left-menu-demo-dashboard"
          navigate={~p"/components/navigation/left-menu/live/dashboard"}
          class="btn btn-outline"
        >Dashboard</.link>
        <.link
          id="left-menu-demo-settings"
          navigate={~p"/components/navigation/left-menu/live/settings"}
          class="btn btn-outline"
        >Settings</.link>
        <.link
          id="left-menu-demo-details"
          patch={~p"/components/navigation/left-menu/live/#{@active_nav}?tab=details"}
          class="btn btn-ghost"
        >Show details with patch</.link>
      </div>
      <section class="rounded-lg bg-surface-container p-6">
        <h2 class="text-lg font-semibold">{if @details, do: "Details tab", else: "Overview tab"}</h2>
        <p class="mt-3 text-on-surface-variant">
          Try browser Back and Forward after switching pages. On a shorter viewport,
          only the menu body scrolls; its brand and collapse button stay visible.
        </p>
      </section>
    </section>
    """
  end
end
