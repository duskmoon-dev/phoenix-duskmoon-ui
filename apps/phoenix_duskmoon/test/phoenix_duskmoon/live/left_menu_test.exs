defmodule PhoenixDuskmoon.Live.LeftMenuTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  alias PhoenixDuskmoon.Live.LeftMenu

  test "mount accepts known enabled menu ids and clears unknown or disabled ids" do
    for active <- ["dashboard", "settings", ""] do
      assert mount_menu(active).assigns.active == active
    end

    for active <- ["missing", "disabled", nil, :dashboard, ["dashboard"], %{}] do
      assert mount_menu(active).assigns.active == ""
    end
  end

  test "active synchronization accepts known ids and an empty selection" do
    socket = mount_menu("dashboard")

    assert {:reply, %{status: "ok"}, socket} =
             LeftMenu.handle_event("set_active_nav", %{"active_nav" => "settings"}, socket)

    assert socket.assigns.active == "settings"

    assert {:reply, %{status: "ok"}, socket} =
             LeftMenu.handle_event("set_active_nav", %{"active_nav" => ""}, socket)

    assert socket.assigns.active == ""
  end

  test "malformed, disabled and unknown client ids leave the current selection unchanged" do
    socket = mount_menu("dashboard")

    for payload <- [
          %{},
          %{"active_nav" => "missing"},
          %{"active_nav" => "disabled"},
          %{"active_nav" => nil},
          %{"active_nav" => ["dashboard"]},
          %{"active_nav" => %{"id" => "dashboard"}},
          []
        ] do
      assert {:reply, %{status: "error"}, ^socket} =
               LeftMenu.handle_event("set_active_nav", payload, socket)
    end
  end

  test "render delegates configured groups, branding and active state to the canonical menu" do
    socket = mount_menu("settings")
    html = render_component(&LeftMenu.render/1, socket.assigns) |> LazyHTML.from_fragment()

    assert LazyHTML.attribute(LazyHTML.query(html, "#sidebar"), "phx-hook") == [
             "DuskmoonLeftMenu"
           ]

    assert LazyHTML.text(html) =~ "Workspace"
    assert LazyHTML.text(html) =~ "Example application"
    assert LazyHTML.text(html) =~ "Version 1"
    assert LazyHTML.text(html) =~ "Account information"

    assert LazyHTML.attribute(LazyHTML.query(html, "a[aria-current=page]"), "href") == [
             "/settings"
           ]

    assert Enum.count(LazyHTML.query(html, "details")) == 1
    assert Enum.empty?(LazyHTML.query(html, "[data-phx-sticky]"))
  end

  test "controlled sticky input is consumed by the parent marker, never stale child active patches" do
    socket = mount_menu("dashboard", %{collapse_controlled: true, storage_key: "ignored"})

    assert {:reply, %{status: "ok"}, socket} =
             LeftMenu.handle_event("set_active_nav", %{"active_nav" => "settings"}, socket)

    html = render_component(&LeftMenu.render/1, socket.assigns) |> LazyHTML.from_fragment()
    assert Enum.empty?(LazyHTML.query(html, "[data-server-collapsed], [data-storage-key]"))

    assert LazyHTML.attribute(LazyHTML.query(html, "a[aria-current=page]"), "href") == [
             "/settings"
           ]
  end

  defp mount_menu(active, overrides \\ %{}) do
    config =
      %{
        id: "sidebar",
        class: "sticky top-0 h-dvh",
        size: "md",
        groups: [
          %{
            id: "workspace",
            label: "Workspace",
            open: true,
            items: [
              item("dashboard", "Dashboard", "/dashboard"),
              item("settings", "Settings", "/settings"),
              %{item("disabled", "Disabled", "/disabled") | disabled: true}
            ]
          }
        ],
        brand: %{
          label: "Example application",
          icon: "moon-waning-crescent",
          to: "/dashboard",
          version: "Version 1"
        },
        footer_text: "Account information",
        collapsible: true,
        collapsed: false,
        storage_key: nil,
        nav_label: "Application navigation",
        expand_label: "Expand navigation",
        collapse_label: "Collapse navigation",
        rest: %{}
      }
      |> Map.merge(overrides)

    {:ok, socket} =
      LeftMenu.mount(
        :not_mounted_at_router,
        %{"config" => config, "active" => active},
        %Phoenix.LiveView.Socket{assigns: %{__changed__: %{}}}
      )

    socket
  end

  defp item(id, label, to) do
    %{id: id, label: label, to: to, icon: "home", disabled: false, class: nil, rest: %{}}
  end
end
