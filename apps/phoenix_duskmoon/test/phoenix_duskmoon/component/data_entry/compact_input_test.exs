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

  test "renders compact input with number type" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "age",
        label: "Age",
        type: "number",
        value: nil
      })

    assert result =~ ~s[type="number"]
  end

  test "renders compact input with date type" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "birthday",
        label: "Birthday",
        type: "date",
        value: nil
      })

    assert result =~ ~s[type="date"]
  end

  test "renders compact input with url type" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "website",
        label: "Website",
        type: "url",
        value: nil
      })

    assert result =~ ~s[type="url"]
  end

  test "renders compact input with tel type" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "phone",
        label: "Phone",
        type: "tel",
        value: nil
      })

    assert result =~ ~s[type="tel"]
  end

  test "renders compact input with multiple errors" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "user",
        label: "User",
        value: nil,
        errors: ["is required", "must be at least 3 characters"]
      })

    assert result =~ "is required"
    assert result =~ "must be at least 3 characters"
    assert result =~ "dm-compact-input--error"
  end

  test "renders compact input with disabled attribute" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "user",
        label: "User",
        value: nil,
        disabled: true
      })

    assert result =~ "disabled"
  end

  test "renders compact input with readonly attribute" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "user",
        label: "User",
        value: nil,
        readonly: true
      })

    assert result =~ "readonly"
  end

  test "renders compact input with placeholder attribute" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "user",
        label: "User",
        value: nil,
        placeholder: "Enter username"
      })

    assert result =~ ~s[placeholder="Enter username"]
  end

  test "renders compact input with required attribute" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "user",
        label: "User",
        value: nil,
        required: true
      })

    assert result =~ "required"
  end

  test "renders compact select with multiple flag" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "colors",
        label: "Colors",
        type: "select",
        value: nil,
        multiple: true,
        options: [{"red", "Red"}, {"blue", "Blue"}]
      })

    assert result =~ "multiple"
  end

  test "renders compact input without label" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "user",
        value: nil
      })

    assert result =~ "dm-compact-input__label"
    assert result =~ "dm-compact-input__field"
  end

  test "renders compact select with error state" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "country",
        label: "Country",
        type: "select",
        value: nil,
        options: [{"us", "USA"}],
        errors: ["is required"]
      })

    assert result =~ "dm-compact-input--error"
    assert result =~ "dm-compact-input__label--error"
    assert result =~ "is required"
  end

  test "renders compact input with field_class" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "user",
        label: "User",
        value: nil,
        field_class: "w-full"
      })

    assert result =~ "dm-compact-input"
  end

  test "renders aria-invalid when errors present" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "email",
        label: "Email",
        value: nil,
        errors: ["is required"]
      })

    assert result =~ ~s[aria-invalid="true"]
  end

  test "does not render aria-invalid when no errors" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "email",
        label: "Email",
        value: nil,
        errors: []
      })

    refute result =~ "aria-invalid"
  end

  test "renders aria-invalid on select type with errors" do
    result =
      render_component(&dm_compact_input/1, %{
        type: "select",
        name: "country",
        label: "Country",
        value: nil,
        options: [{"USA", "us"}],
        errors: ["must be selected"]
      })

    assert result =~ ~s[aria-invalid="true"]
  end
end
