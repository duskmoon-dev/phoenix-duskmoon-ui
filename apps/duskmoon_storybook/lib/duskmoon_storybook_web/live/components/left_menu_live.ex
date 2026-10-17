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
  def mount(params, _session, socket) do
    controlled = params["controlled"] == "true"

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
                to:
                  "/components/navigation/left-menu/live/#{item.id}" <>
                    if(controlled, do: "?controlled=true", else: ""),
                rest: %{"id" => "left-menu-demo-link-#{item.id}"}
              })
            end)
        }
      end)

    {:ok,
     assign(socket,
       menu_groups: groups,
       collapse_controlled: controlled,
       sidebar_collapsed: false,
       collapse_notifications: 0
     ), layout: {__MODULE__, :demo_layout}}
  end

  @impl true
  def handle_params(%{"page" => page} = params, _uri, socket) do
    page = if page in @pages, do: page, else: "dashboard"

    {:noreply, assign(socket, active_nav: page, details: params["tab"] == "details")}
  end

  @impl true
  def handle_event(
        "sidebar_collapse",
        %{"id" => "left-menu-demo-sidebar", "collapsed" => collapsed},
        socket
      )
      when is_boolean(collapsed) do
    {:noreply,
     socket
     |> assign(:sidebar_collapsed, collapsed)
     |> update(:collapse_notifications, &(&1 + 1))}
  end

  def handle_event("sidebar_collapse", _params, socket), do: {:noreply, socket}

  def handle_event("set_sidebar_collapse", %{"collapsed" => value}, socket)
      when value in ["true", "false"] do
    {:noreply, assign(socket, :sidebar_collapsed, value == "true")}
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
        storage_key={if !@collapse_controlled, do: "duskmoon:storybook:left-menu-collapsed"}
        collapse_controlled={@collapse_controlled}
        collapsed={@sidebar_collapsed}
        collapse_event={if @collapse_controlled, do: "storybook:left-menu:collapse"}
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
      phx-hook={if @collapse_controlled, do: "DuskmoonLeftMenuHostDemo"}
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
      <section :if={@collapse_controlled} class="space-y-3 rounded-lg bg-surface-container p-6">
        <h2 class="text-lg font-semibold">Host-owned collapse state</h2>
        <p>
          This page keeps the preference in its LiveView assigns. An application can use its
          session store in the same event handler. Full page LiveView remounts reset this demo.
        </p>
        <p
          id="left-menu-host-state"
          data-collapsed={to_string(@sidebar_collapsed)}
          data-notifications={@collapse_notifications}
        >
          Host collapsed: {to_string(@sidebar_collapsed)} · user notifications: {@collapse_notifications}
        </p>
        <button
          id="left-menu-host-collapse"
          class="btn btn-outline"
          phx-click="set_sidebar_collapse"
          phx-value-collapsed="true"
        >Collapse from host</button>
        <button
          id="left-menu-host-expand"
          class="btn btn-outline"
          phx-click="set_sidebar_collapse"
          phx-value-collapsed="false"
        >Expand from host</button>
        <.link
          id="left-menu-host-patch"
          patch={~p"/components/navigation/left-menu/live/settings?controlled=true"}
          class="btn btn-ghost"
        >Change page with patch</.link>
      </section>
      <div class="flex flex-wrap gap-3">
        <.link
          id="left-menu-demo-dashboard"
          navigate={
            ~p"/components/navigation/left-menu/live/dashboard?controlled=#{@collapse_controlled}"
          }
          class="btn btn-outline"
        >Dashboard</.link>
        <.link
          id="left-menu-demo-settings"
          navigate={
            ~p"/components/navigation/left-menu/live/settings?controlled=#{@collapse_controlled}"
          }
          class="btn btn-outline"
        >Settings</.link>
        <.link
          id="left-menu-demo-details"
          patch={
            ~p"/components/navigation/left-menu/live/#{@active_nav}?tab=details&controlled=#{@collapse_controlled}"
          }
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
