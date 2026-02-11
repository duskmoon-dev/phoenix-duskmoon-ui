defmodule PhoenixDuskmoon.Component.DataEntry.FormTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataEntry.Form

  defp inner_block(text \\ "content") do
    %{inner_block: fn _, _ -> text end}
  end

  describe "dm_form/1" do
    test "renders basic form with dm-form class" do
      result =
        render_component(&dm_form/1, %{
          for: %{},
          inner_block: inner_block("form content")
        })

      assert result =~ "<form"
      assert result =~ "dm-form"
      assert result =~ "form content"
    end

    test "renders form with custom id" do
      result =
        render_component(&dm_form/1, %{
          for: %{},
          id: "my-form",
          inner_block: inner_block()
        })

      assert result =~ ~s[id="my-form"]
    end

    test "renders form with custom class" do
      result =
        render_component(&dm_form/1, %{
          for: %{},
          class: "custom-form",
          inner_block: inner_block()
        })

      assert result =~ "custom-form"
    end

    test "renders form with actions slot" do
      result =
        render_component(&dm_form/1, %{
          for: %{},
          inner_block: inner_block(),
          actions: [%{inner_block: fn _, _ -> "Save" end}]
        })

      assert result =~ "Save"
      assert result =~ "flex items-center justify-between"
    end

    test "renders form without for defaults to empty form" do
      result =
        render_component(&dm_form/1, %{
          inner_block: inner_block()
        })

      assert result =~ "<form"
      assert result =~ "dm-form"
    end
  end

  describe "dm_label/1" do
    test "renders label with dm-label class" do
      result =
        render_component(&dm_label/1, %{
          inner_block: inner_block("Email")
        })

      assert result =~ "<label"
      assert result =~ "dm-label"
      assert result =~ "Email"
    end

    test "renders label with for attribute" do
      result =
        render_component(&dm_label/1, %{
          for: "email-input",
          inner_block: inner_block("Email")
        })

      assert result =~ ~s[for="email-input"]
    end

    test "renders label with custom id" do
      result =
        render_component(&dm_label/1, %{
          id: "my-label",
          inner_block: inner_block("Email")
        })

      assert result =~ ~s[id="my-label"]
    end

    test "renders label with custom class" do
      result =
        render_component(&dm_label/1, %{
          class: "required-label",
          inner_block: inner_block("Email")
        })

      assert result =~ "required-label"
    end
  end

  describe "dm_error/1" do
    test "renders error with dm-error-text class" do
      result =
        render_component(&dm_error/1, %{
          inner_block: inner_block("is required")
        })

      assert result =~ "dm-error-text"
      assert result =~ "is required"
    end

    test "renders error with icon" do
      result =
        render_component(&dm_error/1, %{
          inner_block: inner_block("error")
        })

      assert result =~ "flex items-center gap-1"
    end

    test "renders error with custom id" do
      result =
        render_component(&dm_error/1, %{
          id: "email-error",
          inner_block: inner_block("invalid")
        })

      assert result =~ ~s[id="email-error"]
    end

    test "renders error with custom class" do
      result =
        render_component(&dm_error/1, %{
          class: "my-error",
          inner_block: inner_block("oops")
        })

      assert result =~ "my-error"
    end
  end

  describe "dm_alert/1" do
    test "renders alert with default info variant" do
      result =
        render_component(&dm_alert/1, %{
          inner_block: inner_block("Info message")
        })

      assert result =~ "dm-alert"
      assert result =~ "dm-alert--info"
      assert result =~ "Info message"
    end

    test "renders alert with all variant options" do
      for variant <- ~w(info success warning error) do
        result =
          render_component(&dm_alert/1, %{
            variant: variant,
            inner_block: inner_block("msg")
          })

        assert result =~ "dm-alert--#{variant}"
      end
    end

    test "renders alert with title" do
      result =
        render_component(&dm_alert/1, %{
          variant: "info",
          title: "Note",
          inner_block: inner_block("Info text")
        })

      assert result =~ "Note"
      assert result =~ "font-bold"
    end

    test "renders alert without title by default" do
      result =
        render_component(&dm_alert/1, %{
          inner_block: inner_block("text")
        })

      refute result =~ "font-bold"
    end

    test "renders alert with custom id" do
      result =
        render_component(&dm_alert/1, %{
          id: "my-alert",
          inner_block: inner_block("text")
        })

      assert result =~ ~s[id="my-alert"]
    end

    test "renders alert with custom class" do
      result =
        render_component(&dm_alert/1, %{
          class: "my-alert",
          inner_block: inner_block("text")
        })

      assert result =~ "my-alert"
    end
  end

  describe "normalize_checkbox_value/1" do
    test "normalizes true values" do
      assert normalize_checkbox_value(true) == true
      assert normalize_checkbox_value("true") == true
      assert normalize_checkbox_value("1") == true
    end

    test "normalizes false values" do
      assert normalize_checkbox_value(false) == false
      assert normalize_checkbox_value("false") == false
      assert normalize_checkbox_value(nil) == false
      assert normalize_checkbox_value("0") == false
    end
  end
end
