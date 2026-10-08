defmodule PhoenixDuskmoon.Component.DataEntry.ReactFormTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataEntry.ReactForm

  defmodule FakeChangeset do
    defstruct errors: []

    def traverse_errors(%__MODULE__{errors: errors}, fun),
      do: Enum.into(errors, %{}, fn {field, error} -> {field, [fun.(error)]} end)
  end

  test "renders nested HEEX and typed initial JSON without Phoenix form attributes" do
    assigns = %{values: %{enabled: false, profile: %{city: "Shanghai"}}}

    html =
      rendered_to_string(~H"""
      <.dm_react_form id="profile" values={@values} phx-change="validate" phx-submit="save">
        <h3>Profile</h3>
        <.dm_react_field name={[:profile, :city]} type="text" label="City" />
        <input name="enabled" type="checkbox" />
      </.dm_react_form>
      """)

    document = LazyHTML.from_fragment(html)

    assert LazyHTML.attribute(LazyHTML.query(document, "#profile"), "phx-hook") == [
             "DuskmoonReactForm"
           ]

    assert LazyHTML.attribute(LazyHTML.query(document, "#profile"), "phx-update") == ["ignore"]
    assert LazyHTML.attribute(LazyHTML.query(document, "#profile"), "phx-change") == ["validate"]
    assert LazyHTML.text(LazyHTML.query(document, "h3")) == "Profile"

    assert [json] =
             LazyHTML.attribute(LazyHTML.query(document, "#profile"), "data-initial-values")

    assert Jason.decode!(json) == %{"enabled" => false, "profile" => %{"city" => "Shanghai"}}

    assert Enum.empty?(
             LazyHTML.query(document, "#profile > form[phx-submit], #profile > form[phx-change]")
           )
  end

  test "serializes schema JSON without a parent form or overriding upstream defaults" do
    schema = %{
      type: "object",
      required: ["count"],
      properties: %{
        count: %{type: "integer", default: 0, minimum: 0},
        enabled: %{type: "boolean", default: false},
        name: %{type: "string", title: "Name <&>\"", enum: ["Moon", "Sun"]}
      }
    }

    html =
      render_component(&dm_react_form/1, %{
        id: "schema-profile",
        schema: schema,
        "phx-change": "validate",
        "phx-submit": "save",
        "phx-target": "#editor"
      })

    document = LazyHTML.from_fragment(html)
    root = LazyHTML.query(document, "#schema-profile")

    assert [json] = LazyHTML.attribute(root, "data-schema")
    assert Jason.decode!(json) == Jason.decode!(Jason.encode!(schema))
    assert [] = LazyHTML.attribute(root, "data-initial-values")
    assert ["DuskmoonReactForm"] = LazyHTML.attribute(root, "phx-hook")
    assert ["ignore"] = LazyHTML.attribute(root, "phx-update")
    assert ["validate"] = LazyHTML.attribute(root, "phx-change")
    assert ["save"] = LazyHTML.attribute(root, "phx-submit")
    assert ["#editor"] = LazyHTML.attribute(root, "phx-target")
    assert Enum.empty?(LazyHTML.query(document, "form"))

    assert [_] =
             Enum.to_list(LazyHTML.query(document, "#schema-profile > [data-dm-react-schema]"))

    assert "Loading…" ==
             LazyHTML.text(LazyHTML.query(document, "[data-dm-react-schema] [role=status]"))
  end

  test "schema mode preserves explicit typed nested values and keeps optional HEEX outside the renderer" do
    assigns = %{
      schema: %{
        type: "object",
        properties: %{
          profile: %{
            type: "object",
            properties: %{count: %{type: "integer"}, enabled: %{type: "boolean"}}
          }
        }
      },
      values: %{profile: %{count: 0, enabled: false}}
    }

    html =
      rendered_to_string(~H"""
      <.dm_react_form id="schema-explicit" schema={@schema} values={@values}>
        <p id="schema-note">Server-owned help</p>
      </.dm_react_form>
      """)

    document = LazyHTML.from_fragment(html)

    assert [json] =
             LazyHTML.attribute(
               LazyHTML.query(document, "#schema-explicit"),
               "data-initial-values"
             )

    assert %{"profile" => %{"count" => 0, "enabled" => false}} = Jason.decode!(json)
    assert [_] = Enum.to_list(LazyHTML.query(document, "#schema-explicit > #schema-note"))
    assert Enum.empty?(LazyHTML.query(document, "[data-dm-react-schema] #schema-note, form"))
  end

  test "classic mode keeps its native form and empty JSON defaults when values are omitted" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.dm_react_form id="classic-default">
        <input name="notes" value="Draft" />
        <button type="submit">Save</button>
      </.dm_react_form>
      """)

    document = LazyHTML.from_fragment(html)

    assert [json] =
             LazyHTML.attribute(
               LazyHTML.query(document, "#classic-default"),
               "data-initial-values"
             )

    assert %{} == Jason.decode!(json)
    assert [] = LazyHTML.attribute(LazyHTML.query(document, "#classic-default"), "data-schema")

    assert [_] =
             Enum.to_list(LazyHTML.query(document, "#classic-default > form[data-dm-react-form]"))

    assert ["Draft"] =
             LazyHTML.attribute(LazyHTML.query(document, "form input[name=notes]"), "value")

    assert "Save" == LazyHTML.text(LazyHTML.query(document, "form button[type=submit]"))
    assert Enum.empty?(LazyHTML.query(document, "[data-dm-react-schema], form form"))
  end

  test "formats changeset errors as JSON and supports success replies" do
    changeset = %FakeChangeset{errors: [profile: {"is invalid", []}]}

    assert PhoenixDuskmoon.Component.DataEntry.ReactForm.validation_reply(changeset) == %{
             status: "error",
             errors: %{profile: ["is invalid"]}
           }

    assert PhoenixDuskmoon.Component.DataEntry.ReactForm.success_reply("Saved") == %{
             status: "ok",
             message: "Saved"
           }
  end
end
