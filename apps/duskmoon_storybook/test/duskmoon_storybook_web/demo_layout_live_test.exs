defmodule DuskmoonStorybookWeb.DemoLayoutLiveTest do
  use DuskmoonStorybookWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias DuskmoonStorybookWeb.DemoLayout

  test "all demo sections mount the canonical persistent menu in the shared layout" do
    for {path, sidebar_id} <- [
          {"/components", "components-sidebar"},
          {"/components/action/button", "components-sidebar"},
          {"/art-component", "art-components-sidebar"},
          {"/art-component/atom", "art-components-sidebar"},
          {"/hologram", "hologram-sidebar"},
          {"/hologram/tasks", "hologram-sidebar"}
        ] do
      {:ok, view, html} = live(build_conn(), path)
      [child_id] = sticky_sidebar_ids(html)

      assert find_live_child(view, child_id).module == PhoenixDuskmoon.Live.LeftMenu
      assert has_element?(view, "#demo-layout #demo-content")
      assert has_element?(view, "##{sidebar_id} [data-left-menu-toggle][aria-expanded=true]")
      assert has_element?(view, "##{sidebar_id}-scroll[data-left-menu-scroll]")
      assert has_element?(view, "##{sidebar_id}-navigation[phx-hook=DuskmoonLeftMenuNavigation]")
    end
  end

  test "every Art Components destination connects with its selected menu item" do
    for item <- DemoLayout.art_components() do
      {:ok, view, _html} = live(build_conn(), item.to)

      assert view.module == DuskmoonStorybookWeb.ArtComponentLive

      assert has_element?(
               view,
               "#art-components-link-#{String.replace_prefix(item.id, "art-", "")}[aria-current=page]"
             )

      assert has_element?(
               view,
               "#demo-content",
               if(item.id == "art-index", do: "Art Components", else: item.label)
             )
    end
  end

  test "Art patches and navigation retain the same sticky sidebar", %{conn: conn} do
    {:ok, view, html} = live(conn, "/art-component")
    [child_id] = sticky_sidebar_ids(html)
    sidebar = find_live_child(view, child_id)

    render_patch(view, "/art-component/atom")
    assert has_element?(view, "#demo-content el-dm-art-atom")
    assert has_element?(view, "#art-components-sidebar-navigation[data-active-nav=art-atom]")
    assert find_live_child(view, child_id).pid == sidebar.pid

    result = view |> element("#art-components-link-moon") |> render_click()
    {:ok, destination, html} = follow_redirect(result, conn, "/art-component/moon")

    assert [^child_id] = sticky_sidebar_ids(html)
    assert has_element?(destination, "#demo-content el-dm-art-moon")
    assert has_element?(destination, "#art-components-link-moon[aria-current=page]")
  end

  test "legacy Art URLs retain their removal notices in the shared layout" do
    for slug <- ["button-noise", "signature", "spotlight-search"] do
      {:ok, view, _html} = live(build_conn(), "/art-component/#{slug}")
      assert has_element?(view, "#demo-layout #art-components-sidebar")
      assert has_element?(view, "#demo-content", "has been removed")
    end
  end

  defp sticky_sidebar_ids(html) do
    html
    |> LazyHTML.from_document()
    |> LazyHTML.query("[data-phx-sticky]")
    |> LazyHTML.attribute("id")
  end
end
