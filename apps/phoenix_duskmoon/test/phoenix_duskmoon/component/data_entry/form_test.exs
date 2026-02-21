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
      assert result =~ "form-actions form-actions-between"
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

    test "renders label with form-label-required class when required" do
      result =
        render_component(&dm_label/1, %{
          required: true,
          inner_block: inner_block("Email")
        })

      assert result =~ "form-label-required"
    end

    test "renders label with form-label-optional class when optional" do
      result =
        render_component(&dm_label/1, %{
          optional: true,
          inner_block: inner_block("Email")
        })

      assert result =~ "form-label-optional"
    end

    test "renders label without required/optional classes by default" do
      result =
        render_component(&dm_label/1, %{
          inner_block: inner_block("Email")
        })

      refute result =~ "form-label-required"
      refute result =~ "form-label-optional"
    end

    test "renders label with small size" do
      result =
        render_component(&dm_label/1, %{
          size: "sm",
          inner_block: inner_block("Email")
        })

      assert result =~ "form-label-sm"
    end

    test "renders label with large size" do
      result =
        render_component(&dm_label/1, %{
          size: "lg",
          inner_block: inner_block("Email")
        })

      assert result =~ "form-label-lg"
    end

    test "renders label without size class by default" do
      result =
        render_component(&dm_label/1, %{
          inner_block: inner_block("Email")
        })

      refute result =~ "form-label-sm"
      refute result =~ "form-label-lg"
    end
  end

  describe "dm_error/1" do
    test "renders error with upstream helper-text classes" do
      result =
        render_component(&dm_error/1, %{
          inner_block: inner_block("is required")
        })

      assert result =~ "helper-text-error"
      assert result =~ "helper-text-icon"
      assert result =~ "is required"
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

  describe "dm_form actions_align" do
    test "renders form actions with default between alignment" do
      result =
        render_component(&dm_form/1, %{
          for: %{},
          inner_block: inner_block(),
          actions: [%{inner_block: fn _, _ -> "Save" end}]
        })

      assert result =~ "form-actions-between"
    end

    test "renders form actions with right alignment" do
      result =
        render_component(&dm_form/1, %{
          for: %{},
          actions_align: "right",
          inner_block: inner_block(),
          actions: [%{inner_block: fn _, _ -> "Save" end}]
        })

      assert result =~ "form-actions-right"
      refute result =~ "form-actions-between"
    end

    test "renders form actions with center alignment" do
      result =
        render_component(&dm_form/1, %{
          for: %{},
          actions_align: "center",
          inner_block: inner_block(),
          actions: [%{inner_block: fn _, _ -> "Save" end}]
        })

      assert result =~ "form-actions-center"
      refute result =~ "form-actions-between"
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
      # Each action gets its own form-actions wrapper
      count = result |> String.split("form-actions form-actions-between") |> length()
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

  describe "dm_label rest attributes" do
    test "renders label with rest attributes" do
      result =
        render_component(&dm_label/1, %{
          "data-testid": "label-1",
          inner_block: inner_block("Name")
        })

      assert result =~ ~s[data-testid="label-1"]
    end
  end

  describe "dm_error rest attributes" do
    test "renders error with rest attributes" do
      result =
        render_component(&dm_error/1, %{
          "data-testid": "error-1",
          inner_block: inner_block("is required")
        })

      assert result =~ ~s[data-testid="error-1"]
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

  describe "dm_fieldset/1" do
    test "renders basic fieldset" do
      result =
        render_component(&dm_fieldset/1, %{
          inner_block: inner_block("field content")
        })

      assert result =~ "<fieldset"
      assert result =~ "fieldset"
      assert result =~ "field content"
    end

    test "renders fieldset with legend" do
      result =
        render_component(&dm_fieldset/1, %{
          legend: "Personal Info",
          inner_block: inner_block("fields")
        })

      assert result =~ "<legend"
      assert result =~ "fieldset-legend"
      assert result =~ "Personal Info"
    end

    test "renders fieldset without legend by default" do
      result =
        render_component(&dm_fieldset/1, %{
          inner_block: inner_block("fields")
        })

      refute result =~ "<legend"
    end

    test "renders fieldset with filled variant" do
      result =
        render_component(&dm_fieldset/1, %{
          variant: "filled",
          inner_block: inner_block("fields")
        })

      assert result =~ "fieldset-filled"
    end

    test "renders fieldset with borderless variant" do
      result =
        render_component(&dm_fieldset/1, %{
          variant: "borderless",
          inner_block: inner_block("fields")
        })

      assert result =~ "fieldset-borderless"
    end

    test "renders fieldset with card variant" do
      result =
        render_component(&dm_fieldset/1, %{
          variant: "card",
          inner_block: inner_block("fields")
        })

      assert result =~ "fieldset-card"
    end

    test "renders fieldset with custom id and class" do
      result =
        render_component(&dm_fieldset/1, %{
          id: "my-fieldset",
          class: "extra",
          inner_block: inner_block("fields")
        })

      assert result =~ ~s[id="my-fieldset"]
      assert result =~ "extra"
    end

    test "renders fieldset with rest attrs" do
      result =
        render_component(&dm_fieldset/1, %{
          "data-testid": "fs-1",
          inner_block: inner_block("fields")
        })

      assert result =~ ~s[data-testid="fs-1"]
    end
  end

  describe "dm_form_row/1" do
    test "renders form row with form-row class" do
      result =
        render_component(&dm_form_row/1, %{
          inner_block: inner_block("row content")
        })

      assert result =~ "<div"
      assert result =~ "form-row"
      assert result =~ "row content"
    end

    test "renders form row with custom id and class" do
      result =
        render_component(&dm_form_row/1, %{
          id: "row-1",
          class: "gap-4",
          inner_block: inner_block("content")
        })

      assert result =~ ~s[id="row-1"]
      assert result =~ "gap-4"
    end

    test "renders form row with rest attrs" do
      result =
        render_component(&dm_form_row/1, %{
          "data-testid": "row-1",
          inner_block: inner_block("content")
        })

      assert result =~ ~s[data-testid="row-1"]
    end
  end

  describe "dm_form_grid/1" do
    test "renders form grid with default 2 columns" do
      result =
        render_component(&dm_form_grid/1, %{
          inner_block: inner_block("grid content")
        })

      assert result =~ "form-grid"
      assert result =~ "form-grid-2"
      assert result =~ "grid content"
    end

    test "renders form grid with 3 columns" do
      result =
        render_component(&dm_form_grid/1, %{
          cols: 3,
          inner_block: inner_block("content")
        })

      assert result =~ "form-grid-3"
    end

    test "renders form grid with 4 columns" do
      result =
        render_component(&dm_form_grid/1, %{
          cols: 4,
          inner_block: inner_block("content")
        })

      assert result =~ "form-grid-4"
    end

    test "renders form grid with custom id and class" do
      result =
        render_component(&dm_form_grid/1, %{
          id: "grid-1",
          class: "my-grid",
          inner_block: inner_block("content")
        })

      assert result =~ ~s[id="grid-1"]
      assert result =~ "my-grid"
    end
  end

  describe "dm_form_section/1" do
    test "renders form section with form-section class" do
      result =
        render_component(&dm_form_section/1, %{
          inner_block: inner_block("section content")
        })

      assert result =~ "form-section"
      assert result =~ "section content"
    end

    test "renders form section with title" do
      result =
        render_component(&dm_form_section/1, %{
          title: "Contact",
          inner_block: inner_block("fields")
        })

      assert result =~ "form-section-title"
      assert result =~ "Contact"
    end

    test "renders form section with description" do
      result =
        render_component(&dm_form_section/1, %{
          description: "How we reach you",
          inner_block: inner_block("fields")
        })

      assert result =~ "form-section-description"
      assert result =~ "How we reach you"
    end

    test "renders form section with title and description" do
      result =
        render_component(&dm_form_section/1, %{
          title: "Account",
          description: "Your login info",
          inner_block: inner_block("fields")
        })

      assert result =~ "form-section-title"
      assert result =~ "Account"
      assert result =~ "form-section-description"
      assert result =~ "Your login info"
    end

    test "renders form section without title/description by default" do
      result =
        render_component(&dm_form_section/1, %{
          inner_block: inner_block("fields")
        })

      refute result =~ "form-section-title"
      refute result =~ "form-section-description"
    end

    test "renders form section with custom id and class" do
      result =
        render_component(&dm_form_section/1, %{
          id: "sec-1",
          class: "mb-8",
          inner_block: inner_block("fields")
        })

      assert result =~ ~s[id="sec-1"]
      assert result =~ "mb-8"
    end
  end

  describe "dm_form_divider/1" do
    test "renders plain divider" do
      result = render_component(&dm_form_divider/1, %{})

      assert result =~ "form-divider"
      refute result =~ "form-divider-text"
    end

    test "renders divider with text" do
      result =
        render_component(&dm_form_divider/1, %{
          text: "or"
        })

      assert result =~ "form-divider-text"
      assert result =~ "or"
    end

    test "renders divider with custom id and class" do
      result =
        render_component(&dm_form_divider/1, %{
          id: "div-1",
          class: "my-divider"
        })

      assert result =~ ~s[id="div-1"]
      assert result =~ "my-divider"
    end

    test "renders text divider with rest attrs" do
      result =
        render_component(&dm_form_divider/1, %{
          text: "or",
          "data-testid": "divider-1"
        })

      assert result =~ ~s[data-testid="divider-1"]
      assert result =~ "or"
    end
  end

  describe "dm_alert style variants (filled, outlined)" do
    test "renders alert with filled style" do
      result =
        render_component(&dm_alert/1, %{
          variant: "info",
          filled: true,
          inner_block: inner_block("Filled alert")
        })

      assert result =~ ~s[variant="filled"]
      assert result =~ "Filled alert"
    end

    test "renders alert with outlined style" do
      result =
        render_component(&dm_alert/1, %{
          variant: "warning",
          outlined: true,
          inner_block: inner_block("Outlined alert")
        })

      assert result =~ ~s[variant="outlined"]
      assert result =~ "Outlined alert"
    end

    test "renders alert without variant attr by default" do
      result =
        render_component(&dm_alert/1, %{
          inner_block: inner_block("Default alert")
        })

      refute result =~ ~s[variant="filled"]
      refute result =~ ~s[variant="outlined"]
    end

    test "renders filled alert with all types" do
      for type <- ~w(info success warning error) do
        result =
          render_component(&dm_alert/1, %{
            variant: type,
            filled: true,
            inner_block: inner_block("msg")
          })

        assert result =~ ~s[type="#{type}"]
        assert result =~ ~s[variant="filled"]
      end
    end

    test "renders outlined alert with title and compact" do
      result =
        render_component(&dm_alert/1, %{
          variant: "error",
          outlined: true,
          title: "Error",
          compact: true,
          inner_block: inner_block("Something failed")
        })

      assert result =~ ~s[variant="outlined"]
      assert result =~ ~s[type="error"]
      assert result =~ ~s[title="Error"]
      assert result =~ "compact"
    end

    test "filled takes precedence over outlined when both set" do
      result =
        render_component(&dm_alert/1, %{
          filled: true,
          outlined: true,
          inner_block: inner_block("msg")
        })

      assert result =~ ~s[variant="filled"]
    end
  end

  describe "dm_form_inline/1" do
    test "renders form inline with form-inline class" do
      result =
        render_component(&dm_form_inline/1, %{
          inner_block: inner_block("inline content")
        })

      assert result =~ "form-inline"
      assert result =~ "inline content"
    end

    test "renders form inline with custom id and class" do
      result =
        render_component(&dm_form_inline/1, %{
          id: "inline-1",
          class: "gap-4",
          inner_block: inner_block("content")
        })

      assert result =~ ~s[id="inline-1"]
      assert result =~ "gap-4"
    end
  end

  describe "dm_form_hint/1" do
    test "renders form hint with form-hint class" do
      result =
        render_component(&dm_form_hint/1, %{
          inner_block: inner_block("Must be 8+ characters")
        })

      assert result =~ "form-hint"
      assert result =~ "Must be 8+ characters"
    end

    test "renders form hint with custom id and class" do
      result =
        render_component(&dm_form_hint/1, %{
          id: "hint-1",
          class: "text-xs",
          inner_block: inner_block("hint")
        })

      assert result =~ ~s[id="hint-1"]
      assert result =~ "text-xs"
    end
  end

  describe "dm_form_counter/1" do
    test "renders counter with current and max" do
      result = render_component(&dm_form_counter/1, %{current: 5, max: 100})

      assert result =~ "form-counter"
      assert result =~ "5/100"
    end

    test "renders counter with error styling" do
      result = render_component(&dm_form_counter/1, %{current: 150, max: 100, error: true})

      assert result =~ "form-counter-error"
      assert result =~ "150/100"
    end

    test "does not render error styling by default" do
      result = render_component(&dm_form_counter/1, %{current: 5, max: 100})

      refute result =~ "form-counter-error"
    end

    test "renders counter with custom id and class" do
      result =
        render_component(&dm_form_counter/1, %{
          current: 10,
          max: 50,
          id: "counter-1",
          class: "mt-1"
        })

      assert result =~ ~s[id="counter-1"]
      assert result =~ "mt-1"
    end
  end
end
