defmodule PhoenixDuskmoon.Component.DataEntry.CompactInputTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataEntry.CompactInput

  test "renders basic compact input" do
    result =
      render_component(&dm_compact_input/1, %{name: "user", label: "Username", value: nil})

    assert result =~ "dm-compact-input"
    assert result =~ "Username"
  end

  test "renders compact input with label" do
    result =
      render_component(&dm_compact_input/1, %{name: "email", label: "Email", value: nil})

    assert result =~ "dm-compact-input__label"
    assert result =~ "Email"
  end

  test "renders compact input with default type text" do
    result =
      render_component(&dm_compact_input/1, %{name: "user", label: "User", value: nil})

    assert result =~ ~s[type="text"]
  end

  test "renders compact input with email type" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "email",
        label: "Email",
        type: "email",
        value: nil
      })

    assert result =~ ~s[type="email"]
  end

  test "renders compact input with password type" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "pass",
        label: "Password",
        type: "password",
        value: nil
      })

    assert result =~ ~s[type="password"]
  end

  test "renders compact input with value" do
    result =
      render_component(&dm_compact_input/1, %{name: "user", label: "User", value: "john"})

    assert result =~ ~s[value="john"]
  end

  test "renders compact input with custom id" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "user",
        label: "User",
        value: nil,
        id: "my-input"
      })

    assert result =~ ~s[id="my-input"]
  end

  test "renders compact input with dm-compact-input__field class" do
    result =
      render_component(&dm_compact_input/1, %{name: "user", label: "User", value: nil})

    assert result =~ "dm-compact-input__field"
  end

  test "renders compact input with phx-feedback-for" do
    result =
      render_component(&dm_compact_input/1, %{name: "user", label: "User", value: nil})

    assert result =~ ~s[phx-feedback-for="user"]
  end

  test "renders compact select input" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "country",
        label: "Country",
        type: "select",
        value: nil,
        options: [{"us", "USA"}, {"ca", "Canada"}]
      })

    assert result =~ "<select"
    assert result =~ "dm-compact-input__select"
    assert result =~ "USA"
    assert result =~ "Canada"
  end

  test "renders compact select with prompt" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "country",
        label: "Country",
        type: "select",
        value: nil,
        prompt: "Choose...",
        options: [{"us", "USA"}]
      })

    assert result =~ "Choose..."
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
    assert result =~ "dm-compact-input--error"
    assert result =~ "dm-compact-input__label--error"
  end

  test "renders compact input with custom class" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "user",
        label: "User",
        value: nil,
        class: "my-compact"
      })

    assert result =~ "my-compact"
  end
end
