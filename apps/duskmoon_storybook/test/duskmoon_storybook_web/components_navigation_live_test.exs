defmodule DuskmoonStorybookWeb.ComponentsNavigationLiveTest do
  use DuskmoonStorybookWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias DuskmoonStorybookWeb.ComponentNavigation

  test "every Components menu destination connects with the persistent navigation" do
    for group <- ComponentNavigation.groups(), item <- group.items do
      {:ok, _view, html} = live(build_conn(), item.to)
      document = LazyHTML.from_document(html)

      assert Enum.count(LazyHTML.query(document, "#components-sidebar")) == 1,
             "missing sidebar at #{item.to}"

      assert LazyHTML.attribute(
               LazyHTML.query(document, "#components-sidebar-navigation"),
               "data-active-nav"
             ) == [item.id],
             "incorrect active navigation at #{item.to}"

      assert LazyHTML.attribute(
               LazyHTML.query(document, "#components-link-#{item.id}"),
               "aria-current"
             ) == ["page"],
             "missing initial selection at #{item.to}"

      assert [_sidebar_id] = sticky_sidebar_ids(document)
    end
  end

  test "catalog remains available with links to ordinary and interactive demos", %{conn: conn} do
    {:ok, view, html} = live(conn, "/components")

    assert html =~ "UI demos"
    assert has_element?(view, ".card-actions a[href='/components/action/button']")
    assert has_element?(view, ".card-actions a[href='/components/data-display/react-chat']")
    assert has_element?(view, ".card-actions a[href='/components/data-entry/react-form']")

    assert has_element?(
             view,
             "#components-sidebar-navigation[data-active-nav=components-index]"
           )
  end

  test "ordinary component templates and the native form mount as connected LiveViews", %{
    conn: conn
  } do
    for {path, active, content} <- [
          {"/components/action/button", "action-button", "Button"},
          {"/components/data-display/markdown-body", "data-display-markdown-body",
           "Markdown Body"},
          {"/components/data-entry/form", "data-entry-form", "Complete Form Example"}
        ] do
      {:ok, view, html} = live(conn, path)
      [sidebar_id] = html |> LazyHTML.from_document() |> sticky_sidebar_ids()
      sidebar = find_live_child(view, sidebar_id)

      assert view.module == DuskmoonStorybookWeb.Components.PageLive
      assert sidebar.module == PhoenixDuskmoon.Live.LeftMenu
      assert html =~ content
      assert has_element?(sidebar, "#components-sidebar[phx-hook=DuskmoonLeftMenu]")
      assert has_element?(sidebar, "[data-left-menu-toggle][aria-expanded=true]")

      assert has_element?(
               view,
               "#components-sidebar-navigation[data-active-nav='#{active}']"
             )

      if active == "data-entry-form" do
        assert has_element?(view, "form[action='/'][method=get] input[name=demo-name]")
        assert has_element?(view, "form[action='/'][method=get] input[name=demo-email]")
      end
    end
  end

  test "menu links navigate between static pages and existing interactive LiveViews", %{
    conn: conn
  } do
    {:ok, view, html} = live(conn, "/components/action/button")
    [sidebar_id] = html |> LazyHTML.from_document() |> sticky_sidebar_ids()

    Enum.reduce(
      [
        {"data-display-react-chat", "/components/data-display/react-chat",
         DuskmoonStorybookWeb.Components.ReactChatLive, "#react-chat-demo"},
        {"data-entry-react-form", "/components/data-entry/react-form",
         DuskmoonStorybookWeb.Components.ReactFormLive, "#react-profile"},
        {"data-entry-form", "/components/data-entry/form",
         DuskmoonStorybookWeb.Components.PageLive, "input[name=demo-name]"}
      ],
      view,
      fn {active, path, module, selector}, current_view ->
        result = current_view |> element("#components-link-#{active}") |> render_click()
        {:ok, destination, html} = follow_redirect(result, conn, path)

        assert destination.module == module
        assert has_element?(destination, selector)
        assert [^sidebar_id] = html |> LazyHTML.from_document() |> sticky_sidebar_ids()
        assert find_live_child(destination, sidebar_id).module == PhoenixDuskmoon.Live.LeftMenu

        assert has_element?(
                 destination,
                 "#components-sidebar-navigation[data-active-nav='#{active}']"
               )

        destination
      end
    )
  end

  test "encoded paths, trailing slashes and queries retain the requested Components page", %{
    conn: conn
  } do
    for {path, active, content} <- [
          {"/components/", "components-index", "UI demos"},
          {"/components/action/button/?source=sidebar", "action-button",
           "Button component for triggering actions"},
          {"/components/action/%62utton", "action-button",
           "Button component for triggering actions"}
        ] do
      {:ok, view, html} = live(conn, path)

      assert html =~ content

      assert has_element?(
               view,
               "#components-sidebar-navigation[data-active-nav='#{active}']"
             )
    end
  end

  test "patching static pages replaces their content while retaining the sidebar process", %{
    conn: conn
  } do
    {:ok, view, html} = live(conn, "/components/action/button")
    [sidebar_id] = html |> LazyHTML.from_document() |> sticky_sidebar_ids()
    sidebar = find_live_child(view, sidebar_id)
    refute has_element?(view, "input[name=demo-name]")

    html = render_patch(view, "/components/data-entry/form?source=sidebar")
    assert html =~ "Complete Form Example"
    assert has_element?(view, "form[action='/'][method=get] input[name=demo-name]")
    assert has_element?(view, "#components-sidebar-navigation[data-active-nav=data-entry-form]")
    assert find_live_child(view, sidebar_id).pid == sidebar.pid

    html = render_patch(view, "/components/")
    assert html =~ "UI demos"
    assert has_element?(view, ".card-actions a[href='/components/action/button']")
    refute has_element?(view, "input[name=demo-name]")
    assert has_element?(view, "#components-sidebar-navigation[data-active-nav=components-index]")
    assert find_live_child(view, sidebar_id).pid == sidebar.pid
  end

  test "pagination demos change independently while keeping the sidebar process", %{conn: conn} do
    {:ok, view, html} = live(conn, "/components/data-display/pagination")
    [sidebar_id] = html |> LazyHTML.from_document() |> sticky_sidebar_ids()
    sidebar = find_live_child(view, sidebar_id)

    assert_pagination_pages(view, 3, 2, 1)

    view |> element("#pagination-full-demo button[aria-label='Next page']") |> render_click()
    assert_pagination_pages(view, 4, 2, 1)

    view |> element("#pagination-full-demo button[aria-label='Page 10']") |> render_click()
    assert_pagination_pages(view, 10, 2, 1)
    assert has_element?(view, "#pagination-full-demo button[aria-label='Next page'][disabled]")

    view |> element("#pagination-thin-demo button[aria-label='Next page']") |> render_click()
    assert_pagination_pages(view, 10, 3, 1)

    view |> element("#pagination-jumper-demo button[aria-label='Next page']") |> render_click()
    assert_pagination_pages(view, 10, 3, 2)
    assert find_live_child(view, sidebar_id).pid == sidebar.pid
  end

  test "pagination jumper form changes clamp to available pages without changing other demos", %{
    conn: conn
  } do
    {:ok, view, html} = live(conn, "/components/data-display/pagination")
    [sidebar_id] = html |> LazyHTML.from_document() |> sticky_sidebar_ids()
    sidebar = find_live_child(view, sidebar_id)

    view |> form("#pagination-jumper-demo-jumper", %{current: "7"}) |> render_change()
    assert_pagination_pages(view, 3, 2, 7)

    view |> form("#pagination-jumper-demo-jumper", %{current: "-4"}) |> render_change()
    assert_pagination_pages(view, 3, 2, 1)

    assert has_element?(
             view,
             "#pagination-jumper-demo button[aria-label='Previous page'][disabled]"
           )

    view |> form("#pagination-jumper-demo-jumper", %{current: "999"}) |> render_change()
    assert_pagination_pages(view, 3, 2, 10)
    assert has_element?(view, "#pagination-jumper-demo button[aria-label='Next page'][disabled]")
    assert find_live_child(view, sidebar_id).pid == sidebar.pid
  end

  test "invalid and empty pagination inputs leave each demo's current page intact", %{conn: conn} do
    {:ok, view, html} = live(conn, "/components/data-display/pagination")
    [sidebar_id] = html |> LazyHTML.from_document() |> sticky_sidebar_ids()
    sidebar = find_live_child(view, sidebar_id)

    view |> element("#pagination-full-demo button[aria-label='Next page']") |> render_click()
    view |> element("#pagination-thin-demo button[aria-label='Next page']") |> render_click()
    view |> form("#pagination-jumper-demo-jumper", %{current: "6"}) |> render_change()
    assert_pagination_pages(view, 4, 3, 6)

    for invalid <- ["", "not-a-page", "3.5", "4x"] do
      render_click(view, "paginate_full", %{"current" => invalid})
      render_click(view, "paginate_thin", %{"current" => invalid})
      view |> form("#pagination-jumper-demo-jumper", %{current: invalid}) |> render_change()

      assert_pagination_pages(view, 4, 3, 6)
      assert find_live_child(view, sidebar_id).pid == sidebar.pid
    end
  end

  test "the removable chip demo handles its native delete control", %{conn: conn} do
    {:ok, view, html} = live(conn, "/components/data-display/chip")
    [sidebar_id] = html |> LazyHTML.from_document() |> sticky_sidebar_ids()
    sidebar = find_live_child(view, sidebar_id)

    assert has_element?(view, "#removable-chip-demo", "Removable")

    view
    |> element("#removable-chip-demo button[phx-click=remove-chip][aria-label='Remove category']")
    |> render_click()

    refute has_element?(view, "#removable-chip-demo")
    assert find_live_child(view, sidebar_id).pid == sidebar.pid
  end

  test "the chat composer hook appends trimmed messages and ignores empty sends", %{conn: conn} do
    {:ok, view, html} = live(conn, "/components/data-display/chat")
    [sidebar_id] = html |> LazyHTML.from_document() |> sticky_sidebar_ids()
    sidebar = find_live_child(view, sidebar_id)

    assert has_element?(
             view,
             "el-dm-chat-input#chat-composer[phx-hook=WebComponentHook][duskmoon-send-send=send_message]"
           )

    view |> element("#chat-composer") |> render_hook("send_message", %{value: " \n ", files: []})
    refute has_element?(view, "#chat-conversation #chat-sent-1")

    view
    |> element("#chat-composer")
    |> render_hook("send_message", %{value: "  Hello from the gallery  ", files: []})

    assert has_element?(
             view,
             "#chat-conversation el-dm-chat#chat-sent-1[align=end][content='Hello from the gallery']"
           )

    view
    |> element("#chat-composer")
    |> render_hook("send_message", %{value: "A second message"})

    assert has_element?(
             view,
             "#chat-conversation el-dm-chat#chat-sent-2[content='A second message']"
           )

    view |> element("#chat-composer") |> render_hook("send_message", %{value: "", files: []})
    refute has_element?(view, "#chat-conversation #chat-sent-3")
    assert has_element?(view, "#chat-sent-1[content='Hello from the gallery']")
    assert has_element?(view, "#chat-sent-2[content='A second message']")
    assert find_live_child(view, sidebar_id).pid == sidebar.pid
  end

  test "the theme demo accepts supported hook values and ignores unsupported themes", %{
    conn: conn
  } do
    {:ok, view, html} = live(conn, "/components/layout/theme-switcher")
    [sidebar_id] = html |> LazyHTML.from_document() |> sticky_sidebar_ids()
    sidebar = find_live_child(view, sidebar_id)

    assert has_element?(view, "details#theme-switcher-demo[phx-hook=ThemeSwitcher]")

    for theme <- ["moonlight", "sunshine", "default"] do
      view |> element("#theme-switcher-demo") |> render_hook("theme_changed", %{theme: theme})

      assert has_element?(view, "#theme-switcher-demo[data-theme='#{theme}']")
      assert has_element?(view, "#theme-switcher-demo input[value='#{theme}'][checked]")
      refute has_element?(view, "#theme-switcher-demo input[checked]:not([value='#{theme}'])")
      assert find_live_child(view, sidebar_id).pid == sidebar.pid
    end

    view
    |> element("#theme-switcher-demo")
    |> render_hook("theme_changed", %{theme: "unsupported-theme"})

    assert has_element?(view, "#theme-switcher-demo[data-theme=default]")
    assert has_element?(view, "#theme-switcher-demo input[value=default][checked]")
    refute has_element?(view, "#theme-switcher-demo input[checked]:not([value=default])")
    assert find_live_child(view, sidebar_id).pid == sidebar.pid
  end

  test "unknown component paths still return 404", %{conn: conn} do
    conn = get(conn, "/components/action/no-such-component")
    assert html_response(conn, 404)
  end

  defp assert_pagination_pages(view, full, thin, jumper) do
    for {id, page} <- [
          {"pagination-full-demo", full},
          {"pagination-thin-demo", thin},
          {"pagination-jumper-demo", jumper}
        ] do
      assert has_element?(view, "##{id} button[aria-current=page][aria-label='Page #{page}']")
    end

    assert has_element?(
             view,
             "#pagination-jumper-demo-jumper input[name=current][value='#{jumper}']"
           )
  end

  defp sticky_sidebar_ids(document) do
    document
    |> LazyHTML.query("[data-phx-sticky]")
    |> LazyHTML.attribute("id")
  end
end
