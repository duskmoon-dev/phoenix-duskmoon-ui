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

  describe "dm_alert variants" do
    test "renders alert with success variant" do
      result =
        render_component(&dm_alert/1, %{
          variant: "success",
          inner_block: inner_block("Success message")
        })

      assert result =~ "dm-alert--success"
      assert result =~ "Success message"
    end

    test "renders alert with warning variant" do
      result =
        render_component(&dm_alert/1, %{
          variant: "warning",
          inner_block: inner_block("Warning message")
        })

      assert result =~ "dm-alert--warning"
    end

    test "renders alert with error variant" do
      result =
        render_component(&dm_alert/1, %{
          variant: "error",
          inner_block: inner_block("Error message")
        })

      assert result =~ "dm-alert--error"
    end

    test "renders alert with title" do
      result =
        render_component(&dm_alert/1, %{
          title: "Important",
          inner_block: inner_block("Alert body")
        })

      assert result =~ "Important"
      assert result =~ "font-bold"
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

  describe "dm_alert icon default selection" do
    test "renders alert with different default icon per variant" do
      # Each variant should produce a different SVG path (not the error fallback)
      results =
        for variant <- ~w(info success warning error) do
          {variant,
           render_component(&dm_alert/1, %{
             variant: variant,
             inner_block: inner_block("msg")
           })}
        end

      # All should have SVGs
      for {variant, result} <- results do
        assert result =~ "<svg", "variant #{variant} should render an SVG icon"
        assert result =~ "dm-alert--#{variant}"
      end

      # Icons should differ between info and success (proving variant selection works)
      {_, info_result} = Enum.find(results, fn {v, _} -> v == "info" end)
      {_, success_result} = Enum.find(results, fn {v, _} -> v == "success" end)
      refute info_result == success_result
    end

    test "renders alert with nil icon uses variant default not error fallback" do
      # When icon is nil (default), the variant-specific icon should be used
      info_result =
        render_component(&dm_alert/1, %{
          variant: "info",
          inner_block: inner_block("msg")
        })

      success_result =
        render_component(&dm_alert/1, %{
          variant: "success",
          inner_block: inner_block("msg")
        })

      # The SVG content should differ because info uses information-circle
      # and success uses check-circle
      assert info_result =~ "<svg"
      assert success_result =~ "<svg"
      refute info_result == success_result
    end
  end

  describe "dm_alert icon" do
    test "renders alert with custom icon override renders SVG" do
      result =
        render_component(&dm_alert/1, %{
          variant: "info",
          icon: "star",
          inner_block: inner_block("Custom icon")
        })

      # Custom icon "star" renders as SVG path (different from default info icon)
      assert result =~ "<svg"
      assert result =~ "Custom icon"
      assert result =~ "dm-alert--info"
    end

    test "renders alert with different icon per variant renders different SVGs" do
      # Each variant gets a unique default icon, producing different SVG paths
      results =
        for variant <- ~w(info success warning error) do
          render_component(&dm_alert/1, %{
            variant: variant,
            inner_block: inner_block("msg")
          })
        end

      # Each result should have an SVG
      for result <- results do
        assert result =~ "<svg"
      end

      # The SVG paths should differ between variants (different icons)
      [info, success, _warning, _error] = results
      refute info == success
    end

    test "renders alert with title and custom class combined" do
      result =
        render_component(&dm_alert/1, %{
          variant: "warning",
          title: "Caution",
          class: "border-l-4",
          inner_block: inner_block("Be careful")
        })

      assert result =~ "Caution"
      assert result =~ "font-bold"
      assert result =~ "border-l-4"
      assert result =~ "dm-alert--warning"
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
      assert result =~ "dm-label"
    end
  end

  describe "dm_alert accessibility" do
    test "renders alert with role=alert for screen readers" do
      result =
        render_component(&dm_alert/1, %{
          inner_block: inner_block("Important message")
        })

      assert result =~ ~s[role="alert"]
    end

    test "renders alert with role=alert across all variants" do
      for variant <- ~w(info success warning error) do
        result =
          render_component(&dm_alert/1, %{
            variant: variant,
            inner_block: inner_block("msg")
          })

        assert result =~ ~s[role="alert"]
      end
    end
  end
end
