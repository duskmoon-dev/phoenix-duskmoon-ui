defmodule PhoenixDuskmoon.Component.DataEntry.CompactInputTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataEntry.CompactInput

  test "renders basic compact input" do
    result = render_component(&dm_compact_input/1, %{name: "user", label: "Username", value: nil})

    assert result =~ "Username"
  end

  test "renders compact input with type" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "email",
        label: "Email",
        type: "email",
        value: nil
      })

    assert result =~ ~s[type="email"]
  end

  test "renders compact input with value" do
    result =
      render_component(&dm_compact_input/1, %{name: "user", label: "User", value: "john"})

    assert result =~ ~s[value="john"]
  end

  test "renders compact select input" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "country",
        label: "Country",
        type: "select",
        value: nil,
        options: [{"USA", "us"}, {"Canada", "ca"}]
      })

    assert result =~ "<select"
  end

  test "renders compact input with errors" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "user",
        label: "User",
        value: nil,
        errors: ["is required"]
      })

    assert result =~ "is required"
  end
end
