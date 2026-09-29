defmodule DuskmoonStorybookWeb.ReactDemoLiveTest do
  use DuskmoonStorybookWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "chat demo exposes the high-volume stream controls", %{conn: conn} do
    {:ok, view, html} = live(conn, "/components/data-display/react-chat")

    assert html =~ "React-owned streaming chat"
    assert has_element?(view, "#react-chat-demo")
    assert has_element?(view, "#chat-seed-long")
    assert has_element?(view, "#chat-reset")

    html = view |> element("#chat-seed-long") |> render_click()
    assert html =~ "Seeded a 12-message conversation"

    html = view |> element("#chat-reset") |> render_click()
    assert html =~ "Conversation reset"
  end

  test "form demo exposes presets and reset controls", %{conn: conn} do
    {:ok, view, html} = live(conn, "/components/data-entry/react-form")

    assert html =~ "React JSON form"
    assert has_element?(view, "#react-profile")
    assert has_element?(view, "#form-preset-minimal")
    assert has_element?(view, "#form-reset")

    html = view |> element("#form-preset-minimal") |> render_click()
    assert html =~ "Loaded minimal preset"

    html = view |> element("#form-reset") |> render_click()
    assert html =~ "Draft reset"
  end
end
