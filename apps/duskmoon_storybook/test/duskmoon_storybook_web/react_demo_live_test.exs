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

  test "schema demo exposes nested controls and typed defaults without initial values", %{
    conn: conn
  } do
    {:ok, view, html} = live(conn, "/components/data-entry/react-form")
    root = html |> LazyHTML.from_document() |> LazyHTML.query("#react-schema-profile")

    assert ["DuskmoonReactForm"] = LazyHTML.attribute(root, "phx-hook")
    assert ["ignore"] = LazyHTML.attribute(root, "phx-update")
    assert [] = LazyHTML.attribute(root, "data-initial-values")
    assert [schema_json] = LazyHTML.attribute(root, "data-schema")
    schema = Jason.decode!(schema_json)

    assert schema["required"] == ["profile", "members"]
    assert get_in(schema, ["properties", "profile", "required"]) == ["name", "plan", "seats"]
    profile = get_in(schema, ["properties", "profile", "properties"])
    assert profile["name"]["default"] == "Moonlight team"
    assert profile["plan"]["enum"] == [1, 2, 3]
    assert profile["plan"]["default"] == 2
    assert profile["plan"]["x-widget"] == "select"
    assert profile["seats"]["minimum"] == 1
    assert profile["notifications"]["default"] == true
    assert get_in(schema, ["properties", "members", "minItems"]) == 1

    assert get_in(schema, ["properties", "members", "items", "properties", "email", "format"]) ==
             "email"

    assert has_element?(view, "#react-schema-profile > [data-dm-react-schema]")
    refute has_element?(view, "#react-schema-profile [data-dm-react-field]")
  end

  test "schema change and submit preserve changed paths, revisions, and typed JSON", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/components/data-entry/react-form")
    values = schema_values()

    render_hook(view, "validate-schema-profile", %{
      "id" => "react-schema-profile",
      "values" => values,
      "revision" => 4,
      "changed" => ["profile", "name"]
    })

    assert has_element?(view, "#schema-form-status", "Valid schema draft")
    assert has_element?(view, "#schema-form-revision", "4")
    assert has_element?(view, "#schema-form-changed", "profile.name")

    html =
      render_hook(view, "save-schema-profile", %{
        "id" => "react-schema-profile",
        "values" => values,
        "revision" => 5
      })

    saved =
      html
      |> LazyHTML.from_document()
      |> LazyHTML.query("#schema-form-payload-preview")
      |> LazyHTML.text()
      |> Jason.decode!()

    assert saved == values
    assert saved["profile"]["plan"] === 3
    assert saved["profile"]["seats"] === 12
    assert saved["profile"]["notifications"] === false
    assert has_element?(view, "#schema-form-revision", "5")
    assert has_element?(view, "#schema-form-status", "Schema profile saved successfully")
  end

  test "schema backend rejects reserved names with JSON Pointer error keys", %{conn: conn} do
    values = put_in(schema_values(), ["profile", "name"], "taken")

    params = %{
      "id" => "react-schema-profile",
      "values" => values,
      "revision" => 2,
      "changed" => ["profile", "name"]
    }

    {:ok, socket} =
      DuskmoonStorybookWeb.Components.ReactFormLive.mount(%{}, %{}, %Phoenix.LiveView.Socket{})

    reply = %{status: "error", errors: %{"/profile/name" => "Workspace name is already reserved"}}

    assert {:reply, ^reply, _socket} =
             DuskmoonStorybookWeb.Components.ReactFormLive.handle_event(
               "validate-schema-profile",
               params,
               socket
             )

    assert {:reply, ^reply, rejected_socket} =
             DuskmoonStorybookWeb.Components.ReactFormLive.handle_event(
               "save-schema-profile",
               params,
               socket
             )

    assert rejected_socket.assigns.schema_submitted == nil

    {:ok, view, _html} = live(conn, "/components/data-entry/react-form")
    render_hook(view, "validate-schema-profile", params)
    assert has_element?(view, "#schema-form-status", "Name availability error returned")
    render_hook(view, "save-schema-profile", params)
    assert has_element?(view, "#schema-form-status", "Choose another workspace name")
    assert has_element?(view, "#schema-form-payload-preview", "No schema submit yet")
  end

  test "schema preset targets only the schema form with typed replacement values", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/components/data-entry/react-form")
    html = view |> element("#schema-form-preset") |> render_click()
    values = schema_values()

    assert_push_event(view, "dm:form:reset", %{
      id: "react-schema-profile",
      values: ^values
    })

    assert html =~ "Loaded schema preset"
    assert has_element?(view, "#schema-form-revision", "1")
    assert has_element?(view, "#schema-form-changed", "preset")
    assert has_element?(view, "#form-status", "Waiting for a change")
  end

  defp schema_values do
    %{
      "profile" => %{
        "name" => "Platform team",
        "plan" => 3,
        "seats" => 12,
        "notifications" => false
      },
      "members" => [%{"email" => "team@example.test"}, %{"email" => "ops@example.test"}]
    }
  end
end
