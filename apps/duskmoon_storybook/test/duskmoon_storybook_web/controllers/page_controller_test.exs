defmodule DuskmoonStorybookWeb.PageControllerTest do
  use DuskmoonStorybookWeb.ConnCase

  test "GET /components renders the component catalog", %{conn: conn} do
    conn = get(conn, "/components")
    html = html_response(conn, 200)

    assert html =~ "Components"
    assert html =~ ~s[href="/components/data-display/datetime"]
    assert html =~ "Datetime"
    assert html =~ ~s[href="/components/data-display/markdown-body"]
    assert html =~ "Markdown Body"
  end
end
