defmodule PhoenixDuskmoon.Component.DataEntry.FormTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataEntry.Form

  defp inner_block(text \\ "content") do
    %{inner_block: fn _, _ -> text end}
  end

  describe "dm_form/1" do
    test "renders basic form" do
      result =
        render_component(&dm_form/1, %{
          for: %{},
          inner_block: inner_block("form content")
        })

      assert result =~ "<form"
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
    end
  end

  describe "dm_label/1" do
    test "renders label with form-label class" do
      result =
        render_component(&dm_label/1, %{
          inner_block: inner_block("Email")
        })

      assert result =~ "<label"
      assert result =~ "form-label"
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
    test "renders error with helper-text text-error class" do
      result =
        render_component(&dm_error/1, %{
          inner_block: inner_block("is required")
        })

      assert result =~ "helper-text text-error"
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
    test "renders el-dm-alert custom element" do
      result =
        render_component(&dm_alert/1, %{
          inner_block: inner_block("Info message")
        })

      assert result =~ "<el-dm-alert"
      assert result =~ "</el-dm-alert>"
      assert result =~ "Info message"
    end

    test "renders alert with default info type" do
      result =
        render_component(&dm_alert/1, %{
          inner_block: inner_block("Info message")
        })

      assert result =~ ~s[type="info"]
    end

    test "renders alert with all variant options mapped to type" do
      for variant <- ~w(info success warning error) do
        result =
          render_component(&dm_alert/1, %{
            variant: variant,
            inner_block: inner_block("msg")
          })

        assert result =~ ~s[type="#{variant}"]
      end
    end

    test "renders alert with title attribute" do
      result =
        render_component(&dm_alert/1, %{
          variant: "info",
          title: "Note",
          inner_block: inner_block("Info text")
        })

      assert result =~ ~s[title="Note"]
    end

    test "renders alert without title by default" do
      result =
        render_component(&dm_alert/1, %{
          inner_block: inner_block("text")
        })

      [_, alert_tag] = String.split(result, "<el-dm-alert", parts: 2)
      [alert_attrs, _] = String.split(alert_tag, ">", parts: 2)
      refute alert_attrs =~ ~s[title="]
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

    test "renders alert with dismissible attribute" do
      result =
        render_component(&dm_alert/1, %{
          dismissible: true,
          inner_block: inner_block("text")
        })

      assert result =~ "dismissible"
    end

    test "renders alert with compact attribute" do
      result =
        render_component(&dm_alert/1, %{
          compact: true,
          inner_block: inner_block("text")
        })

      assert result =~ "compact"
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

  describe "dm_alert variants" do
    test "renders alert with success variant" do
      result =
        render_component(&dm_alert/1, %{
          variant: "success",
          inner_block: inner_block("Success message")
        })

      assert result =~ ~s[type="success"]
      assert result =~ "Success message"
    end

    test "renders alert with warning variant" do
      result =
        render_component(&dm_alert/1, %{
          variant: "warning",
          inner_block: inner_block("Warning message")
        })

      assert result =~ ~s[type="warning"]
    end

    test "renders alert with error variant" do
      result =
        render_component(&dm_alert/1, %{
          variant: "error",
          inner_block: inner_block("Error message")
        })

      assert result =~ ~s[type="error"]
    end

    test "renders alert with title attribute" do
      result =
        render_component(&dm_alert/1, %{
          title: "Important",
          inner_block: inner_block("Alert body")
        })

      assert result =~ ~s[title="Important"]
    end
  end

  describe "dm_form rest attrs" do
    test "renders form with phx-change rest attribute" do
      result =
        render_component(&dm_form/1, %{
          for: %{},
          "phx-change": "validate",
          inner_block: inner_block()
        })

      assert result =~ ~s[phx-change="validate"]
    end

    test "renders form with phx-submit rest attribute" do
      result =
        render_component(&dm_form/1, %{
          for: %{},
          "phx-submit": "save",
          inner_block: inner_block()
        })

      assert result =~ ~s[phx-submit="save"]
    end

    test "renders form with autocomplete rest attribute" do
      result =
        render_component(&dm_form/1, %{
          for: %{},
          autocomplete: "off",
          inner_block: inner_block()
        })

      assert result =~ ~s[autocomplete="off"]
    end

    test "renders form with multiple action slots" do
      result =
        render_component(&dm_form/1, %{
          for: %{},
          inner_block: inner_block(),
          actions: [
            %{inner_block: fn _, _ -> "Save" end},
            %{inner_block: fn _, _ -> "Cancel" end}
          ]
        })

      assert result =~ "Save"
      assert result =~ "Cancel"
      # Each action gets its own flex wrapper
      count = result |> String.split("flex items-center justify-between") |> length()
      assert count >= 3
    end
  end

  describe "dm_alert icon" do
    test "renders alert without icon slot when icon is nil" do
      result =
        render_component(&dm_alert/1, %{
          inner_block: inner_block("msg")
        })

      refute result =~ ~s[slot="icon"]
    end

    test "renders alert with custom icon in icon slot" do
      result =
        render_component(&dm_alert/1, %{
          variant: "info",
          icon: "star",
          inner_block: inner_block("Custom icon")
        })

      assert result =~ ~s[slot="icon"]
      assert result =~ "<svg"
      assert result =~ "Custom icon"
    end

    test "renders alert with title and custom class combined" do
      result =
        render_component(&dm_alert/1, %{
          variant: "warning",
          title: "Caution",
          class: "border-l-4",
          inner_block: inner_block("Be careful")
        })

      assert result =~ ~s[title="Caution"]
      assert result =~ "border-l-4"
      assert result =~ ~s[type="warning"]
      assert result =~ "Be careful"
    end
  end

  describe "dm_label extras" do
    test "renders label with id" do
      result =
        render_component(&dm_label/1, %{
          id: "lbl-1",
          inner_block: inner_block("Name")
        })

      assert result =~ ~s[id="lbl-1"]
    end

    test "renders label with for and class combined" do
      result =
        render_component(&dm_label/1, %{
          for: "input-1",
          class: "text-error",
          inner_block: inner_block("Email")
        })

      assert result =~ ~s[for="input-1"]
      assert result =~ "text-error"
      assert result =~ "form-label"
    end
  end

  describe "dm_alert rest attributes" do
    test "renders alert with rest attributes" do
      result =
        render_component(&dm_alert/1, %{
          "data-testid": "alert-1",
          inner_block: inner_block("Important message")
        })

      assert result =~ ~s[data-testid="alert-1"]
    end
  end
end
