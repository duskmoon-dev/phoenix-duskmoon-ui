defmodule PhoenixDuskmoon.Component.DataEntry.FormTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataEntry.Form

  test "renders basic form" do
    result =
      render_component(&dm_form/1, %{
        for: %{},
        inner_block: %{inner_block: fn _, _ -> "form content" end}
      })

    assert result =~ "<form"
    assert result =~ "dm-form"
    assert result =~ "form content"
  end

  test "renders form with id" do
    result =
      render_component(&dm_form/1, %{
        for: %{},
        id: "my-form",
        inner_block: %{inner_block: fn _, _ -> "content" end}
      })

    assert result =~ ~s[id="my-form"]
  end

  test "renders form with class" do
    result =
      render_component(&dm_form/1, %{
        for: %{},
        class: "custom-form",
        inner_block: %{inner_block: fn _, _ -> "content" end}
      })

    assert result =~ "custom-form"
  end

  test "renders label" do
    result =
      render_component(&dm_label/1, %{
        inner_block: %{inner_block: fn _, _ -> "Email" end}
      })

    assert result =~ "<label"
    assert result =~ "dm-label"
    assert result =~ "Email"
  end

  test "renders label with for attribute" do
    result =
      render_component(&dm_label/1, %{
        for: "email-input",
        inner_block: %{inner_block: fn _, _ -> "Email" end}
      })

    assert result =~ ~s[for="email-input"]
  end

  test "renders error message" do
    result =
      render_component(&dm_error/1, %{
        inner_block: %{inner_block: fn _, _ -> "is required" end}
      })

    assert result =~ "dm-error-text"
    assert result =~ "is required"
  end

  test "renders alert with variant" do
    result =
      render_component(&dm_alert/1, %{
        variant: "error",
        inner_block: %{inner_block: fn _, _ -> "Something failed" end}
      })

    assert result =~ "dm-alert"
    assert result =~ "dm-alert--error"
    assert result =~ "Something failed"
  end

  test "renders alert with title" do
    result =
      render_component(&dm_alert/1, %{
        variant: "info",
        title: "Note",
        inner_block: %{inner_block: fn _, _ -> "Info text" end}
      })

    assert result =~ "Note"
    assert result =~ "Info text"
  end
end
