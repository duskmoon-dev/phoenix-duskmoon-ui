defmodule DuskmoonStorybookWeb.LeftMenuLiveTest do
  use DuskmoonStorybookWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  @demo_path "/components/navigation/left-menu/live/dashboard"

  defmodule ConfigurableMenuLive do
    use Phoenix.LiveView, layout: false
    import PhoenixDuskmoon.Component.Navigation.LeftMenu

    @impl true
    def mount(_params, _session, socket) do
      {:ok,
       assign(socket,
         groups: [
           %{
             id: "pages",
             label: "Pages",
             items: [
               %{id: "dashboard", label: "Dashboard", to: "/dashboard", icon: "home"},
               %{id: "settings", label: "Settings", to: "/settings", icon: "cog"}
             ]
           }
         ],
         active: "dashboard"
       )}
    end

    @impl true
    def render(assigns) do
      ~H"""
      <.dm_left_menu
        id="configurable-sidebar"
        sticky
        socket={@socket}
        groups={@groups}
        active={@active}
      />
      """
    end

    @impl true
    def handle_event("select", %{"active" => active}, socket) do
      {:noreply, Phoenix.Component.assign(socket, :active, active)}
    end

    def handle_event("restrict", _params, socket) do
      groups = Enum.map(socket.assigns.groups, &%{&1 | items: Enum.take(&1.items, 1)})
      {:noreply, Phoenix.Component.assign(socket, :groups, groups)}
    end
  end

  test "live route mounts a sticky child with a collapsible long menu", %{conn: conn} do
    {:ok, view, html} = live(conn, @demo_path)
    sidebar_id = sidebar_id(html)
    sidebar = find_live_child(view, sidebar_id)

    assert sidebar
    assert sidebar.module == PhoenixDuskmoon.Live.LeftMenu
    assert has_element?(view, "##{sidebar_id}[data-phx-sticky]")
    assert has_element?(sidebar, "#left-menu-demo-sidebar[phx-hook=DuskmoonLeftMenu]")
    assert has_element?(sidebar, "#left-menu-demo-sidebar-scroll[data-left-menu-scroll]")
    assert has_element?(sidebar, "[data-left-menu-toggle][aria-expanded=true]")
    assert has_element?(sidebar, "#left-menu-demo-link-dashboard[aria-current=page]")
    refute has_element?(sidebar, "#left-menu-demo-sidebar-group-administration[open]")

    assert has_element?(
             view,
             "#left-menu-demo-sidebar-navigation[phx-hook=DuskmoonLeftMenuNavigation][data-active-nav=dashboard]"
           )

    refute has_element?(view, "#left-menu-demo-page[phx-hook]")

    links = html |> LazyHTML.from_document() |> LazyHTML.query("#left-menu-demo-sidebar a")
    assert Enum.count(links) == 24
  end

  test "sticky child accepts known active pages and ignores malformed or unknown values", %{
    conn: conn
  } do
    {:ok, view, html} = live(conn, @demo_path)
    sidebar = find_live_child(view, sidebar_id(html))

    render_hook(sidebar, "set_active_nav", %{"active_nav" => "settings"})
    assert has_element?(sidebar, "#left-menu-demo-link-settings[aria-current=page]")
    refute has_element?(sidebar, "#left-menu-demo-link-dashboard[aria-current]")

    for payload <- [
          %{},
          %{"active_nav" => "unknown-page"},
          %{"active_nav" => nil},
          %{"active_nav" => ["dashboard"]},
          %{"active_nav" => %{"page" => "dashboard"}}
        ] do
      render_hook(sidebar, "set_active_nav", payload)
      assert has_element?(sidebar, "#left-menu-demo-link-settings[aria-current=page]")
      refute has_element?(sidebar, "#left-menu-demo-link-dashboard[aria-current]")
    end
  end

  test "page and tab patches retain the library sidebar and update its built-in synchronization marker",
       %{
         conn: conn
       } do
    {:ok, view, html} = live(conn, @demo_path)
    sidebar_id = sidebar_id(html)
    sidebar = find_live_child(view, sidebar_id)

    html = render_patch(view, "/components/navigation/left-menu/live/item-24?tab=details")
    assert html =~ "Details tab"
    assert has_element?(view, "#left-menu-demo-sidebar-navigation[data-active-nav=item-24]")
    assert find_live_child(view, sidebar_id).pid == sidebar.pid

    render_hook(sidebar, "set_active_nav", %{"active_nav" => "item-24"})
    assert has_element?(sidebar, "#left-menu-demo-link-item-24[aria-current=page]")

    html = render_patch(view, "/components/navigation/left-menu/live/settings")
    assert html =~ "Overview tab"
    assert has_element?(view, "#left-menu-demo-sidebar-navigation[data-active-nav=settings]")
    assert find_live_child(view, sidebar_id).pid == sidebar.pid
  end

  test "active changes preserve the child while changed menu data replaces stale configuration",
       %{
         conn: conn
       } do
    {:ok, view, html} = live_isolated(conn, ConfigurableMenuLive)
    original_id = sidebar_id(html)
    original = find_live_child(view, original_id)

    html = render_hook(view, "select", %{"active" => "settings"})
    assert sidebar_id(html) == original_id
    assert find_live_child(view, original_id).pid == original.pid
    assert has_element?(view, "#configurable-sidebar-navigation[data-active-nav=settings]")

    html = render_hook(view, "restrict", %{})
    replacement_id = sidebar_id(html)
    refute replacement_id == original_id
    replacement = find_live_child(view, replacement_id)
    refute replacement.pid == original.pid
    assert has_element?(replacement, "a[href='/dashboard']")
    refute has_element?(replacement, "a[href='/settings']")
    refute has_element?(replacement, "[aria-current]")
    render_hook(replacement, "set_active_nav", %{"active_nav" => "settings"})
    refute has_element?(replacement, "[aria-current]")
  end

  defp sidebar_id(html) do
    html
    |> LazyHTML.from_document()
    |> LazyHTML.query("[data-phx-sticky]")
    |> LazyHTML.attribute("id")
    |> then(fn [id] -> id end)
  end
end
