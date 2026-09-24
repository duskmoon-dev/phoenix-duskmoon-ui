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
