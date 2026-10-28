defmodule DuskmoonStorybookWeb.PageControllerTest do
  use DuskmoonStorybookWeb.ConnCase

  test "GET /components renders the component card catalog", %{conn: conn} do
    conn = get(conn, "/components")
    html = html_response(conn, 200)

    assert html =~ "Components"
    assert html =~ "UI demos"
    assert html =~ ~s[href="/components/data-display/react-chat"]
    assert html =~ "React Chat"
    assert html =~ ~s[href="/components/data-entry/react-form"]
    assert html =~ "React Form"
    refute html =~ "/storybook/data_display/react_chat"
    refute html =~ "/storybook/data_entry/react_form"
  end

  test "the shared menu links to Hologram before Storybook and the old demo redirects", %{
    conn: conn
  } do
    html = conn |> get("/components") |> html_response(200)

    links =
      html
      |> LazyHTML.from_document()
      |> LazyHTML.query("nav[aria-label='Main navigation'] a")
      |> LazyHTML.attribute("href")

    assert links == ["/components", "/art-component", "/hologram", "/storybook"]
    assert conn |> get("/examples/hologram") |> redirected_to() == "/hologram/playground"
  end
end
