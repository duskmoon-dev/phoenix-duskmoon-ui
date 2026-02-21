defmodule PhoenixDuskmoon.Component.DataEntry.InputTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataEntry.Input

  describe "select input type" do
    test "renders select element with basic attributes" do
      result =
        render_component(&dm_input/1, %{
          type: "select",
          name: "country",
          id: "country-select",
          options: [{"USA", "us"}, {"Canada", "ca"}, {"Mexico", "mx"}],
          value: "us"
        })

      assert result =~ ~s[<select]
      assert result =~ ~s[id="country-select"]
      assert result =~ ~s[name="country"]
      assert result =~ ~s[class="]
      # Should use select classes, not textarea classes (bug fix verification)
      assert result =~ ~s[select"]
      refute result =~ ~s[textarea]
    end

    test "renders select with color variant" do
      result =
        render_component(&dm_input/1, %{
          type: "select",
          name: "color-select",
          options: [{"Red", "red"}, {"Blue", "blue"}],
          color: "primary",
          value: nil
        })

      assert result =~ ~s[select-primary]
    end

    test "renders select with size" do
      result =
        render_component(&dm_input/1, %{
          type: "select",
          name: "size-select",
          options: [{"Small", "sm"}, {"Large", "lg"}],
          size: "lg",
          value: nil
        })

      assert result =~ ~s[select-lg]
    end

    test "renders select with error state" do
      result =
        render_component(&dm_input/1, %{
          type: "select",
          name: "error-select",
          options: [{"Option 1", "1"}],
          errors: ["is required"],
          value: nil
        })

      assert result =~ ~s[select-error]
      assert result =~ "is required"
    end

    test "renders select with prompt" do
      result =
        render_component(&dm_input/1, %{
          type: "select",
          name: "prompt-select",
          options: [{"Option 1", "1"}],
          prompt: "Choose an option",
          value: nil
        })

      assert result =~ ~s[<option]
      assert result =~ "Choose an option"
    end

    test "renders select with multiple attribute" do
      result =
        render_component(&dm_input/1, %{
          type: "select",
          name: "multi-select",
          options: [{"A", "a"}, {"B", "b"}],
          multiple: true,
          value: nil
        })

      assert result =~ ~s[multiple]
    end

    test "renders select with selected value" do
      result =
        render_component(&dm_input/1, %{
          type: "select",
          name: "selected-select",
          options: [{"USA", "us"}, {"Canada", "ca"}],
          value: "ca"
        })

      assert result =~ ~s[selected]
      assert result =~ ~s[value="ca"]
    end

    test "renders select with label" do
      result =
        render_component(&dm_input/1, %{
          type: "select",
          name: "labeled-select",
          label: "Choose Country",
          options: [{"USA", "us"}],
          value: nil
        })

      assert result =~ "Choose Country"
    end
  end

  describe "textarea input type" do
    test "renders textarea element with basic attributes" do
      result =
        render_component(&dm_input/1, %{
          type: "textarea",
          name: "description",
          id: "desc-textarea",
          value: "Some text content"
        })

      assert result =~ ~s[<textarea]
      assert result =~ ~s[id="desc-textarea"]
      assert result =~ ~s[name="description"]
      # Should use textarea classes, not radio classes (bug fix verification)
      assert result =~ ~s[textarea"]
      refute result =~ ~s[radio]
      assert result =~ "Some text content"
    end

    test "renders textarea with color variant" do
      result =
        render_component(&dm_input/1, %{
          type: "textarea",
          name: "comment",
          color: "success",
          value: nil
        })

      assert result =~ ~s[textarea-success]
    end

    test "renders textarea with size" do
      result =
        render_component(&dm_input/1, %{
          type: "textarea",
          name: "sized-textarea",
          size: "lg",
          value: nil
        })

      assert result =~ ~s[textarea-lg]
    end

    test "renders textarea with error state" do
      result =
        render_component(&dm_input/1, %{
          type: "textarea",
          name: "error-textarea",
          errors: ["cannot be blank", "is too short"],
          value: nil
        })

      assert result =~ ~s[textarea-error]
      assert result =~ "cannot be blank"
      assert result =~ "is too short"
    end

    test "renders textarea with label" do
      result =
        render_component(&dm_input/1, %{
          type: "textarea",
          name: "labeled-textarea",
          label: "Description",
          value: nil
        })

      assert result =~ "Description"
    end

    test "renders textarea with placeholder via rest" do
      result =
        render_component(&dm_input/1, %{
          type: "textarea",
          name: "placeholder-textarea",
          placeholder: "Enter description...",
          value: nil
        })

      assert result =~ ~s[placeholder="Enter description..."]
    end

    test "renders textarea with rows via rest" do
      result =
        render_component(&dm_input/1, %{
          type: "textarea",
          name: "rows-textarea",
          rows: 10,
          value: nil
        })

      assert result =~ ~s[rows="10"]
    end
  end

  describe "radio_group input type" do
    test "renders radio group with basic attributes" do
      result =
        render_component(&dm_input/1, %{
          type: "radio_group",
          name: "gender",
          options: [{"Male", "m"}, {"Female", "f"}, {"Other", "o"}],
          value: nil
        })

      assert result =~ ~s[type="radio"]
      assert result =~ ~s[name="gender"]
      # Should use radio classes, not checkbox classes (bug fix verification)
      assert result =~ ~s[class="]
      refute result =~ ~s[checkbox]
      assert result =~ "Male"
      assert result =~ "Female"
      assert result =~ "Other"
    end

    test "renders radio group with selected value" do
      result =
        render_component(&dm_input/1, %{
          type: "radio_group",
          name: "choice",
          options: [{"A", "a"}, {"B", "b"}],
          value: "b"
        })

      assert result =~ ~s[value="b"]
      assert result =~ ~s[checked]
    end

    test "renders radio group with color variant" do
      result =
        render_component(&dm_input/1, %{
          type: "radio_group",
          name: "colored-radio",
          options: [{"Yes", "y"}, {"No", "n"}],
          color: "primary",
          value: nil
        })

      assert result =~ ~s[radio-primary]
    end

    test "renders radio group with size" do
      result =
        render_component(&dm_input/1, %{
          type: "radio_group",
          name: "sized-radio",
          options: [{"Small", "sm"}],
          size: "lg",
          value: nil
        })

      assert result =~ ~s[radio-lg]
    end

    test "renders radio group with label" do
      result =
        render_component(&dm_input/1, %{
          type: "radio_group",
          name: "labeled-radio",
          label: "Select Option",
          options: [{"Option 1", "1"}],
          value: nil
        })

      assert result =~ "Select Option"
    end

    test "renders radio group with errors" do
      result =
        render_component(&dm_input/1, %{
          type: "radio_group",
          name: "error-radio",
          options: [{"A", "a"}],
          errors: ["must be selected"],
          value: nil
        })

      assert result =~ "must be selected"
    end
  end

  describe "checkbox input type" do
    test "renders checkbox element with basic attributes" do
      result =
        render_component(&dm_input/1, %{
          type: "checkbox",
          name: "agree",
          id: "agree-checkbox",
          label: "I agree to the terms",
          value: nil
        })

      assert result =~ ~s[type="checkbox"]
      assert result =~ ~s[id="agree-checkbox"]
      assert result =~ ~s[name="agree"]
      assert result =~ ~s[class="checkbox"]
      assert result =~ "I agree to the terms"
    end

    test "renders checkbox with checked value" do
      result =
        render_component(&dm_input/1, %{
          type: "checkbox",
          name: "checked-box",
          label: "Checked",
          value: true
        })

      assert result =~ ~s[checked]
    end

    test "renders checkbox with unchecked value" do
      result =
        render_component(&dm_input/1, %{
          type: "checkbox",
          name: "test-box",
          label: "Unchecked",
          value: false
        })

      refute result =~ ~s[checked="checked"]
      refute result =~ ~s[checked>]
    end

    test "renders checkbox with hidden false value" do
      result =
        render_component(&dm_input/1, %{
          type: "checkbox",
          name: "hidden-checkbox",
          label: "Test",
          value: nil
        })

      assert result =~ ~s[type="hidden"]
      assert result =~ ~s[value="false"]
    end

    test "renders checkbox with errors" do
      result =
        render_component(&dm_input/1, %{
          type: "checkbox",
          name: "error-checkbox",
          label: "Accept",
          errors: ["must be accepted"],
          value: nil
        })

      assert result =~ "must be accepted"
    end
  end

  describe "toggle input type" do
    test "renders toggle element with basic attributes" do
      result =
        render_component(&dm_input/1, %{
          type: "toggle",
          name: "notifications",
          id: "notifications-toggle",
          label: "Enable notifications",
          value: nil
        })

      assert result =~ ~s[type="checkbox"]
      assert result =~ ~s[id="notifications-toggle"]
      assert result =~ ~s[name="notifications"]
      assert result =~ "switch"
      assert result =~ "Enable notifications"
    end

    test "renders toggle with checked value" do
      result =
        render_component(&dm_input/1, %{
          type: "toggle",
          name: "enabled-toggle",
          label: "Enabled",
          value: true
        })

      assert result =~ ~s[checked]
      assert result =~ ~s[role="switch"]
      assert result =~ ~s[aria-checked="true"]
    end

    test "renders toggle with unchecked value" do
      result =
        render_component(&dm_input/1, %{
          type: "toggle",
          name: "disabled-toggle",
          label: "Disabled",
          value: false
        })

      refute result =~ ~s[ checked]
      assert result =~ ~s[aria-checked="false"]
    end

    test "renders toggle with color variant" do
      result =
        render_component(&dm_input/1, %{
          type: "toggle",
          name: "color-toggle",
          label: "Color",
          color: "primary",
          value: nil
        })

      assert result =~ ~s[switch-primary]
    end

    test "renders toggle with size" do
      result =
        render_component(&dm_input/1, %{
          type: "toggle",
          name: "size-toggle",
          label: "Size",
          size: "lg",
          value: nil
        })

      assert result =~ ~s[switch-lg]
    end

    test "renders toggle with hidden false value" do
      result =
        render_component(&dm_input/1, %{
          type: "toggle",
          name: "hidden-toggle",
          label: "Test",
          value: nil
        })

      assert result =~ ~s[type="hidden"]
      assert result =~ ~s[value="false"]
    end

    test "renders toggle with errors" do
      result =
        render_component(&dm_input/1, %{
          type: "toggle",
          name: "error-toggle",
          label: "Toggle",
          errors: ["must be enabled"],
          value: nil
        })

      assert result =~ "must be enabled"
    end
  end

  describe "range_slider input type" do
    test "renders range slider with basic attributes" do
      result =
        render_component(&dm_input/1, %{
          type: "range_slider",
          name: "volume",
          id: "volume-slider",
          label: "Volume",
          value: 50
        })

      assert result =~ ~s[type="range"]
      assert result =~ ~s[id="volume-slider"]
      assert result =~ ~s[name="volume"]
      assert result =~ ~s[class="slider"]
      assert result =~ "Volume"
    end

    test "renders range slider with min, max, step" do
      result =
        render_component(&dm_input/1, %{
          type: "range_slider",
          name: "price",
          label: "Price",
          value: 25,
          min: 0,
          max: 100,
          step: 5
        })

      assert result =~ ~s[min="0"]
      assert result =~ ~s[max="100"]
      assert result =~ ~s[step="5"]
    end

    test "renders range slider with default min, max, step" do
      result =
        render_component(&dm_input/1, %{
          type: "range_slider",
          name: "default-range",
          label: "Range",
          value: 50
        })

      assert result =~ ~s[min="0"]
      assert result =~ ~s[max="100"]
      assert result =~ ~s[step="1"]
    end

    test "renders range slider with color variant" do
      result =
        render_component(&dm_input/1, %{
          type: "range_slider",
          name: "color-range",
          label: "Color Range",
          color: "primary",
          value: 50
        })

      assert result =~ ~s[slider-primary]
    end

    test "renders range slider with size" do
      result =
        render_component(&dm_input/1, %{
          type: "range_slider",
          name: "size-range",
          label: "Size Range",
          size: "lg",
          value: 50
        })

      assert result =~ ~s[slider-lg]
    end

    test "renders range slider displaying current value" do
      result =
        render_component(&dm_input/1, %{
          type: "range_slider",
          name: "value-range",
          label: "Value",
          value: 75
        })

      assert result =~ "(75)"
    end

    test "renders range slider with nil value using defaults" do
      result =
        render_component(&dm_input/1, %{
          type: "range_slider",
          name: "nil-range",
          label: "Range",
          value: nil
        })

      # When value is nil, should show the default min value (0)
      assert result =~ "(0)"
      assert result =~ ~s[min="0"]
    end

    test "renders range slider with errors" do
      result =
        render_component(&dm_input/1, %{
          type: "range_slider",
          name: "error-range",
          label: "Range",
          errors: ["value too high"],
          value: 50
        })

      assert result =~ "value too high"
    end

    test "renders range slider with custom non-default min and max" do
      result =
        render_component(&dm_input/1, %{
          type: "range_slider",
          name: "temperature",
          label: "Temperature",
          value: 50,
          min: 10,
          max: 200
        })

      # Custom min=10 and max=200 should render in both the input attrs and display spans
      assert result =~ ~s[min="10"]
      assert result =~ ~s[max="200"]
    end
  end

  describe "file input type" do
    test "renders file input with basic attributes" do
      result =
        render_component(&dm_input/1, %{
          type: "file",
          name: "upload",
          id: "file-upload",
          label: "Upload file",
          value: nil
        })

      assert result =~ ~s[type="file"]
      assert result =~ ~s[id="file-upload"]
      assert result =~ ~s[name="upload"]
      assert result =~ ~s[input file-upload]
      assert result =~ "Upload file"
    end

    test "renders file input with color variant" do
      result =
        render_component(&dm_input/1, %{
          type: "file",
          name: "color-file",
          label: "File",
          color: "primary",
          value: nil
        })

      assert result =~ ~s[input-primary]
    end

    test "renders file input with size" do
      result =
        render_component(&dm_input/1, %{
          type: "file",
          name: "size-file",
          label: "File",
          size: "lg",
          value: nil
        })

      assert result =~ ~s[input-lg]
    end

    test "renders file input with error state" do
      result =
        render_component(&dm_input/1, %{
          type: "file",
          name: "error-file",
          label: "File",
          errors: ["file too large", "invalid format"],
          value: nil
        })

      assert result =~ ~s[input-error]
      assert result =~ "file too large"
      assert result =~ "invalid format"
    end

    test "renders file input with custom class" do
      result =
        render_component(&dm_input/1, %{
          type: "file",
          name: "custom-file",
          label: "File",
          class: "custom-class",
          value: nil
        })

      assert result =~ "custom-class"
    end
  end

  describe "text input type" do
    test "renders text input with basic attributes" do
      result =
        render_component(&dm_input/1, %{
          type: "text",
          name: "username",
          id: "username-input",
          label: "Username",
          value: ""
        })

      assert result =~ ~s[type="text"]
      assert result =~ ~s[id="username-input"]
      assert result =~ ~s[name="username"]
      assert result =~ ~s[input"]
      assert result =~ "Username"
    end

    test "renders text input with value" do
      result =
        render_component(&dm_input/1, %{
          type: "text",
          name: "name",
          label: "Name",
          value: "John Doe"
        })

      assert result =~ ~s[value="John Doe"]
    end

    test "renders text input with color variant" do
      result =
        render_component(&dm_input/1, %{
          type: "text",
          name: "color-text",
          label: "Text",
          color: "primary",
          value: ""
        })

      assert result =~ ~s[input-primary]
    end

    test "renders text input with size" do
      result =
        render_component(&dm_input/1, %{
          type: "text",
          name: "size-text",
          label: "Text",
          size: "lg",
          value: ""
        })

      assert result =~ ~s[input-lg]
    end

    test "renders text input with error state" do
      result =
        render_component(&dm_input/1, %{
          type: "text",
          name: "error-text",
          label: "Text",
          errors: ["is required"],
          value: ""
        })

      assert result =~ ~s[input-error]
      assert result =~ "is required"
    end

    test "renders text input with placeholder via rest" do
      result =
        render_component(&dm_input/1, %{
          type: "text",
          name: "placeholder-text",
          label: "Text",
          placeholder: "Enter text...",
          value: ""
        })

      assert result =~ ~s[placeholder="Enter text..."]
    end
  end

  describe "email input type" do
    test "renders email input with basic attributes" do
      result =
        render_component(&dm_input/1, %{
          type: "email",
          name: "email",
          id: "email-input",
          label: "Email",
          value: ""
        })

      assert result =~ ~s[type="email"]
      assert result =~ ~s[id="email-input"]
      assert result =~ ~s[name="email"]
      assert result =~ ~s[input"]
      assert result =~ "Email"
    end

    test "renders email input with value" do
      result =
        render_component(&dm_input/1, %{
          type: "email",
          name: "user-email",
          label: "Email",
          value: "test@example.com"
        })

      assert result =~ ~s[value="test@example.com"]
    end

    test "renders email input with error state" do
      result =
        render_component(&dm_input/1, %{
          type: "email",
          name: "error-email",
          label: "Email",
          errors: ["is invalid"],
          value: ""
        })

      assert result =~ ~s[input-error]
      assert result =~ "is invalid"
    end
  end

  describe "password input type" do
    test "renders password input with basic attributes" do
      result =
        render_component(&dm_input/1, %{
          type: "password",
          name: "password",
          id: "password-input",
          label: "Password",
          value: ""
        })

      assert result =~ ~s[type="password"]
      assert result =~ ~s[id="password-input"]
      assert result =~ ~s[name="password"]
      assert result =~ ~s[input"]
      assert result =~ "Password"
    end

    test "renders password input with color variant" do
      result =
        render_component(&dm_input/1, %{
          type: "password",
          name: "color-password",
          label: "Password",
          color: "primary",
          value: ""
        })

      assert result =~ ~s[input-primary]
    end

    test "renders password input with error state" do
      result =
        render_component(&dm_input/1, %{
          type: "password",
          name: "error-password",
          label: "Password",
          errors: ["is too weak"],
          value: ""
        })

      assert result =~ ~s[input-error]
      assert result =~ "is too weak"
    end
  end

  describe "number input type" do
    test "renders number input with basic attributes" do
      result =
        render_component(&dm_input/1, %{
          type: "number",
          name: "age",
          id: "age-input",
          label: "Age",
          value: nil
        })

      assert result =~ ~s[type="number"]
      assert result =~ ~s[id="age-input"]
      assert result =~ ~s[name="age"]
      assert result =~ ~s[input"]
      assert result =~ "Age"
    end

    test "renders number input with value" do
      result =
        render_component(&dm_input/1, %{
          type: "number",
          name: "quantity",
          label: "Quantity",
          value: 42
        })

      assert result =~ ~s[value="42"]
    end

    test "renders number input with min, max, step via rest" do
      result =
        render_component(&dm_input/1, %{
          type: "number",
          name: "count",
          label: "Count",
          value: nil,
          min: 0,
          max: 100,
          step: 5
        })

      assert result =~ ~s[min="0"]
      assert result =~ ~s[max="100"]
      assert result =~ ~s[step="5"]
    end

    test "renders number input with error state" do
      result =
        render_component(&dm_input/1, %{
          type: "number",
          name: "error-number",
          label: "Number",
          errors: ["must be positive"],
          value: nil
        })

      assert result =~ ~s[input-error]
      assert result =~ "must be positive"
    end
  end

  describe "url input type" do
    test "renders url input with basic attributes" do
      result =
        render_component(&dm_input/1, %{
          type: "url",
          name: "website",
          id: "website-input",
          label: "Website",
          value: ""
        })

      assert result =~ ~s[type="url"]
      assert result =~ ~s[id="website-input"]
      assert result =~ ~s[name="website"]
      assert result =~ ~s[input"]
      assert result =~ "Website"
    end

    test "renders url input with value" do
      result =
        render_component(&dm_input/1, %{
          type: "url",
          name: "homepage",
          label: "Homepage",
          value: "https://example.com"
        })

      assert result =~ ~s[value="https://example.com"]
    end

    test "renders url input with error state" do
      result =
        render_component(&dm_input/1, %{
          type: "url",
          name: "error-url",
          label: "URL",
          errors: ["is invalid"],
          value: ""
        })

      assert result =~ ~s[input-error]
      assert result =~ "is invalid"
    end
  end

  describe "tel input type" do
    test "renders tel input with basic attributes" do
      result =
        render_component(&dm_input/1, %{
          type: "tel",
          name: "phone",
          id: "phone-input",
          label: "Phone",
          value: ""
        })

      assert result =~ ~s[type="tel"]
      assert result =~ ~s[id="phone-input"]
      assert result =~ ~s[name="phone"]
      assert result =~ ~s[input"]
      assert result =~ "Phone"
    end

    test "renders tel input with value" do
      result =
        render_component(&dm_input/1, %{
          type: "tel",
          name: "mobile",
          label: "Mobile",
          value: "+1-555-123-4567"
        })

      assert result =~ ~s[value="+1-555-123-4567"]
    end

    test "renders tel input with error state" do
      result =
        render_component(&dm_input/1, %{
          type: "tel",
          name: "error-tel",
          label: "Phone",
          errors: ["is invalid format"],
          value: ""
        })

      assert result =~ ~s[input-error]
      assert result =~ "is invalid format"
    end
  end

  describe "checkbox_group input type" do
    test "renders checkbox group with basic attributes" do
      result =
        render_component(&dm_input/1, %{
          type: "checkbox_group",
          name: "colors",
          options: [{"Red", "red"}, {"Blue", "blue"}, {"Green", "green"}],
          value: nil
        })

      assert result =~ ~s[type="checkbox"]
      assert result =~ "name=\"colors[]\""
      assert result =~ "Red"
      assert result =~ "Blue"
      assert result =~ "Green"
    end

    test "renders checkbox group with checked values" do
      result =
        render_component(&dm_input/1, %{
          type: "checkbox_group",
          name: "colors",
          options: [{"Red", "red"}, {"Blue", "blue"}],
          value: ["red"]
        })

      assert result =~ ~s[value="red"]
      assert result =~ ~s[checked]
    end

    test "renders checkbox group with color variant" do
      result =
        render_component(&dm_input/1, %{
          type: "checkbox_group",
          name: "items",
          options: [{"A", "a"}],
          color: "primary",
          value: nil
        })

      assert result =~ ~s[checkbox-primary]
    end

    test "renders checkbox group with size" do
      result =
        render_component(&dm_input/1, %{
          type: "checkbox_group",
          name: "items",
          options: [{"A", "a"}],
          size: "lg",
          value: nil
        })

      assert result =~ ~s[checkbox-lg]
    end

    test "renders checkbox group with label" do
      result =
        render_component(&dm_input/1, %{
          type: "checkbox_group",
          name: "items",
          label: "Select Items",
          options: [{"A", "a"}],
          value: nil
        })

      assert result =~ "Select Items"
    end

    test "renders checkbox group with errors" do
      result =
        render_component(&dm_input/1, %{
          type: "checkbox_group",
          name: "items",
          options: [{"A", "a"}],
          errors: ["select at least one"],
          value: nil
        })

      assert result =~ "select at least one"
    end
  end

  describe "datepicker input type" do
    test "renders datepicker with basic attributes" do
      result =
        render_component(&dm_input/1, %{
          type: "datepicker",
          name: "birthday",
          id: "birthday-picker",
          label: "Birthday",
          value: "2000-01-01"
        })

      assert result =~ ~s[type="date"]
      assert result =~ ~s[id="birthday-picker"]
      assert result =~ ~s[name="birthday"]
      assert result =~ ~s[value="2000-01-01"]
      assert result =~ "Birthday"
    end

    test "renders datepicker with color variant" do
      result =
        render_component(&dm_input/1, %{
          type: "datepicker",
          name: "date",
          label: "Date",
          color: "primary",
          value: nil
        })

      assert result =~ ~s[input-primary]
    end

    test "renders datepicker with size" do
      result =
        render_component(&dm_input/1, %{
          type: "datepicker",
          name: "date",
          label: "Date",
          size: "lg",
          value: nil
        })

      assert result =~ ~s[input-lg]
    end

    test "renders datepicker with calendar icon" do
      result =
        render_component(&dm_input/1, %{
          type: "datepicker",
          name: "date",
          label: "Date",
          value: nil
        })

      # Calendar icon renders as SVG
      assert result =~ "<svg"
    end

    test "renders datepicker with error state" do
      result =
        render_component(&dm_input/1, %{
          type: "datepicker",
          name: "date",
          label: "Date",
          errors: ["is required"],
          value: nil
        })

      assert result =~ ~s[input-error]
      assert result =~ "is required"
    end
  end

  describe "timepicker input type" do
    test "renders timepicker with basic attributes" do
      time_val = "09:00"

      result =
        render_component(&dm_input/1, %{
          type: "timepicker",
          name: "start_time",
          id: "start-time",
          label: "Start Time",
          value: time_val
        })

      assert result =~ ~s[type="time"]
      assert result =~ ~s[id="start-time"]
      assert result =~ ~s[name="start_time"]
      assert result =~ time_val
      assert result =~ "Start Time"
    end

    test "renders timepicker with color variant" do
      result =
        render_component(&dm_input/1, %{
          type: "timepicker",
          name: "time",
          label: "Time",
          color: "primary",
          value: nil
        })

      assert result =~ ~s[input-primary]
    end

    test "renders timepicker with error state" do
      result =
        render_component(&dm_input/1, %{
          type: "timepicker",
          name: "time",
          label: "Time",
          errors: ["invalid time"],
          value: nil
        })

      assert result =~ ~s[input-error]
      assert result =~ "invalid time"
    end
  end

  describe "color_picker input type" do
    test "renders color picker with basic attributes" do
      result =
        render_component(&dm_input/1, %{
          type: "color_picker",
          name: "theme_color",
          id: "color-pick",
          label: "Theme Color",
          value: "#ff0000"
        })

      assert result =~ ~s[type="color"]
      assert result =~ ~s[id="color-pick"]
      assert result =~ ~s[name="theme_color"]
      assert result =~ ~s[value="#ff0000"]
      assert result =~ "Theme Color"
    end

    test "renders color picker with default value when nil" do
      result =
        render_component(&dm_input/1, %{
          type: "color_picker",
          name: "color",
          label: "Color",
          value: nil
        })

      assert result =~ ~s[value="#000000"]
    end

    test "renders color picker with text input showing hex value" do
      result =
        render_component(&dm_input/1, %{
          type: "color_picker",
          name: "color",
          label: "Color",
          value: "#abcdef"
        })

      # Should have a readonly text input showing the hex value
      assert result =~ ~s[readonly]
      assert result =~ "#abcdef"
    end

    test "renders color picker with error state" do
      result =
        render_component(&dm_input/1, %{
          type: "color_picker",
          name: "color",
          label: "Color",
          errors: ["invalid color"],
          value: nil
        })

      assert result =~ ~s[input-error]
      assert result =~ "invalid color"
    end

    test "renders color picker without swatches by default" do
      result =
        render_component(&dm_input/1, %{
          type: "color_picker",
          name: "color",
          label: "Color",
          value: nil
        })

      # Swatches section not rendered when swatches is nil
      refute result =~ "Select color"
    end

    test "renders color picker with swatches buttons" do
      result =
        render_component(&dm_input/1, %{
          type: "color_picker",
          name: "color",
          id: "swatch-pick",
          label: "Color",
          value: "#ff0000",
          swatches: ["#ff0000", "#00ff00", "#0000ff"]
        })

      assert result =~ ~s[aria-label="Select color #ff0000"]
      assert result =~ ~s[aria-label="Select color #00ff00"]
      assert result =~ ~s[aria-label="Select color #0000ff"]
      assert result =~ ~s[background-color: #ff0000]
      assert result =~ ~s[background-color: #00ff00]
    end

    test "renders color picker with size sm" do
      result =
        render_component(&dm_input/1, %{
          type: "color_picker",
          name: "color",
          label: "Color",
          value: nil,
          size: "sm"
        })

      assert result =~ "w-8 h-8"
    end

    test "renders color picker with size lg" do
      result =
        render_component(&dm_input/1, %{
          type: "color_picker",
          name: "color",
          label: "Color",
          value: nil,
          size: "lg"
        })

      assert result =~ "w-16 h-16"
    end
  end

  describe "switch input type" do
    test "renders switch with basic attributes" do
      result =
        render_component(&dm_input/1, %{
          type: "switch",
          name: "dark_mode",
          id: "dark-mode-switch",
          label: "Dark Mode",
          value: nil
        })

      assert result =~ ~s[type="checkbox"]
      assert result =~ ~s[id="dark-mode-switch"]
      assert result =~ ~s[name="dark_mode"]
      assert result =~ ~s[role="switch"]
      assert result =~ "switch"
      assert result =~ "Dark Mode"
    end

    test "renders switch with aria-checked matching checked state" do
      result =
        render_component(&dm_input/1, %{
          type: "switch",
          name: "toggle",
          label: "Toggle",
          value: true
        })

      assert result =~ ~s[role="switch"]
      assert result =~ ~s[aria-checked="true"]
    end

    test "renders switch with aria-checked false when unchecked" do
      result =
        render_component(&dm_input/1, %{
          type: "switch",
          name: "toggle",
          label: "Toggle",
          value: false
        })

      assert result =~ ~s[aria-checked="false"]
    end

    test "renders switch with checked value" do
      result =
        render_component(&dm_input/1, %{
          type: "switch",
          name: "enabled",
          label: "Enabled",
          value: true
        })

      assert result =~ ~s[checked]
    end

    test "renders switch with unchecked value" do
      result =
        render_component(&dm_input/1, %{
          type: "switch",
          name: "disabled",
          label: "Disabled",
          value: false
        })

      refute result =~ ~s[checked="checked"]
    end

    test "renders switch with color variant" do
      result =
        render_component(&dm_input/1, %{
          type: "switch",
          name: "switch",
          label: "Switch",
          color: "primary",
          value: nil
        })

      assert result =~ ~s[switch-primary]
    end

    test "renders switch with hidden false value" do
      result =
        render_component(&dm_input/1, %{
          type: "switch",
          name: "test-switch",
          label: "Test",
          value: nil
        })

      assert result =~ ~s[type="hidden"]
      assert result =~ ~s[value="false"]
    end

    test "renders switch with errors" do
      result =
        render_component(&dm_input/1, %{
          type: "switch",
          name: "switch",
          label: "Switch",
          errors: ["must be enabled"],
          value: nil
        })

      assert result =~ "must be enabled"
    end
  end

  describe "search_with_suggestions input type" do
    test "renders search input with basic attributes" do
      result =
        render_component(&dm_input/1, %{
          type: "search_with_suggestions",
          name: "search",
          id: "search-input",
          label: "Search",
          value: ""
        })

      assert result =~ ~s[type="text"]
      assert result =~ ~s[id="search-input"]
      assert result =~ ~s[name="search"]
      assert result =~ "Search"
    end

    test "renders search with magnify icon" do
      result =
        render_component(&dm_input/1, %{
          type: "search_with_suggestions",
          name: "search",
          label: "Search",
          value: ""
        })

      # Magnify icon renders as SVG
      assert result =~ "<svg"
    end

    test "renders search with color variant" do
      result =
        render_component(&dm_input/1, %{
          type: "search_with_suggestions",
          name: "search",
          label: "Search",
          color: "primary",
          value: ""
        })

      assert result =~ ~s[input-primary]
    end

    test "renders search with error state" do
      result =
        render_component(&dm_input/1, %{
          type: "search_with_suggestions",
          name: "search",
          label: "Search",
          errors: ["no results"],
          value: ""
        })

      assert result =~ ~s[input-error]
      assert result =~ "no results"
    end

    test "renders search with populated suggestions dropdown" do
      result =
        render_component(&dm_input/1, %{
          type: "search_with_suggestions",
          name: "search",
          id: "search-field",
          label: "Search",
          value: "el",
          suggestions: ["elixir", "elm", "electron"]
        })

      assert result =~ "dropdown dropdown-open"
      assert result =~ "elixir"
      assert result =~ "elm"
      assert result =~ "electron"
    end

    test "renders search without dropdown when suggestions empty" do
      result =
        render_component(&dm_input/1, %{
          type: "search_with_suggestions",
          name: "search",
          id: "search-field",
          label: "Search",
          value: "",
          suggestions: []
        })

      refute result =~ "dropdown-open"
    end
  end

  describe "file_upload input type" do
    test "renders file upload with basic attributes" do
      result =
        render_component(&dm_input/1, %{
          type: "file_upload",
          name: "document",
          id: "doc-upload",
          label: "Upload Document",
          value: nil
        })

      assert result =~ ~s[type="file"]
      assert result =~ ~s[id="doc-upload"]
      assert result =~ ~s[name="document"]
      assert result =~ "Upload Document"
      assert result =~ "Drop files here or click to browse"
      assert result =~ "Choose Files"
    end

    test "renders file upload with color variant on button" do
      result =
        render_component(&dm_input/1, %{
          type: "file_upload",
          name: "upload",
          label: "Upload",
          color: "primary",
          value: nil
        })

      assert result =~ "file-upload-button"
    end

    test "renders file upload with existing value" do
      result =
        render_component(&dm_input/1, %{
          type: "file_upload",
          name: "upload",
          label: "Upload",
          value: "document.pdf"
        })

      assert result =~ "document.pdf"
    end

    test "renders file upload with errors" do
      result =
        render_component(&dm_input/1, %{
          type: "file_upload",
          name: "upload",
          label: "Upload",
          errors: ["file too large"],
          value: nil
        })

      assert result =~ "file too large"
    end

    test "renders file upload with accept attribute" do
      result =
        render_component(&dm_input/1, %{
          type: "file_upload",
          name: "upload",
          id: "img-upload",
          label: "Upload Image",
          value: nil,
          accept: "image/*"
        })

      assert result =~ ~s[accept="image/*"]
    end

    test "renders file upload with multiple attribute" do
      result =
        render_component(&dm_input/1, %{
          type: "file_upload",
          name: "uploads",
          id: "multi-upload",
          label: "Upload Files",
          value: nil,
          multiple: true
        })

      assert result =~ "multiple"
    end

    test "renders file upload with custom drop_text" do
      result =
        render_component(&dm_input/1, %{
          type: "file_upload",
          name: "upload",
          label: "Upload",
          value: nil,
          drop_text: "Drag your files here"
        })

      assert result =~ "Drag your files here"
      refute result =~ "Drop files here or click to browse"
    end

    test "renders file upload with custom choose_files_text" do
      result =
        render_component(&dm_input/1, %{
          type: "file_upload",
          name: "upload",
          label: "Upload",
          value: nil,
          choose_files_text: "Browse..."
        })

      assert result =~ "Browse..."
      refute result =~ "Choose Files"
    end
  end

  describe "rich_text input type" do
    test "renders rich text editor with basic attributes" do
      result =
        render_component(&dm_input/1, %{
          type: "rich_text",
          name: "content",
          id: "content-editor",
          label: "Content",
          value: nil
        })

      assert result =~ ~s[contenteditable="true"]
      assert result =~ ~s[id="content-editor"]
      assert result =~ ~s[data-name="content"]
      assert result =~ "Content"
    end

    test "renders rich text with toolbar buttons" do
      result =
        render_component(&dm_input/1, %{
          type: "rich_text",
          name: "content",
          label: "Content",
          value: nil
        })

      assert result =~ "toolbar"
      # Toolbar has formatting buttons (rendered as SVG icons)
      assert result =~ "btn btn-ghost btn-xs"
    end

    test "renders rich text with existing value" do
      result =
        render_component(&dm_input/1, %{
          type: "rich_text",
          name: "content",
          label: "Content",
          value: "<p>Hello World</p>"
        })

      assert result =~ "<p>Hello World</p>"
    end

    test "renders rich text with hidden input for form submission" do
      result =
        render_component(&dm_input/1, %{
          type: "rich_text",
          name: "content",
          id: "editor",
          label: "Content",
          value: "test"
        })

      assert result =~ ~s[type="hidden"]
      assert result =~ ~s[name="content"]
      assert result =~ ~s[id="editor_hidden"]
    end

    test "renders rich text with error state" do
      result =
        render_component(&dm_input/1, %{
          type: "rich_text",
          name: "content",
          label: "Content",
          errors: ["cannot be blank"],
          value: nil
        })

      assert result =~ "border-error"
      assert result =~ "cannot be blank"
    end
  end

  describe "tags input type" do
    test "renders tags input with basic attributes" do
      result =
        render_component(&dm_input/1, %{
          type: "tags",
          name: "tags",
          id: "tags-input",
          label: "Tags",
          value: nil
        })

      assert result =~ ~s[type="text"]
      assert result =~ "Add tag..."
      assert result =~ "Tags"
    end

    test "renders tags with existing values" do
      result =
        render_component(&dm_input/1, %{
          type: "tags",
          name: "tags",
          label: "Tags",
          value: ["elixir", "phoenix"]
        })

      assert result =~ "elixir"
      assert result =~ "phoenix"
      assert result =~ "badge"
    end

    test "renders tags with color variant" do
      result =
        render_component(&dm_input/1, %{
          type: "tags",
          name: "tags",
          label: "Tags",
          color: "primary",
          value: ["test"]
        })

      assert result =~ ~s[badge-primary]
    end

    test "renders tags with errors" do
      result =
        render_component(&dm_input/1, %{
          type: "tags",
          name: "tags",
          label: "Tags",
          errors: ["too many tags"],
          value: nil
        })

      assert result =~ "too many tags"
    end

    test "renders tags with custom add_tag_placeholder" do
      result =
        render_component(&dm_input/1, %{
          type: "tags",
          name: "tags",
          label: "Tags",
          value: nil,
          add_tag_placeholder: "Type a tag..."
        })

      assert result =~ ~s[placeholder="Type a tag..."]
      refute result =~ "Add tag..."
    end
  end

  describe "rating input type" do
    test "renders rating with basic attributes" do
      result =
        render_component(&dm_input/1, %{
          type: "rating",
          name: "rating",
          id: "product-rating",
          label: "Rating",
          value: 3
        })

      assert result =~ ~s[name="rating"]
      assert result =~ ~s[id="product-rating"]
      assert result =~ "Rating"
      assert result =~ "(3/5)"
    end

    test "renders rating with default max of 5" do
      result =
        render_component(&dm_input/1, %{
          type: "rating",
          name: "rating",
          label: "Score",
          value: 3
        })

      # Default max is 5
      assert result =~ "(3/5)"
    end

    test "renders rating with nil value showing 0" do
      result =
        render_component(&dm_input/1, %{
          type: "rating",
          name: "rating",
          label: "Rating",
          value: nil
        })

      assert result =~ "(0/5)"
    end

    test "renders rating stars as SVG icons" do
      result =
        render_component(&dm_input/1, %{
          type: "rating",
          name: "rating",
          label: "Rating",
          value: 2
        })

      # Stars render as SVG icons (mdi star) in rating-item buttons
      assert result =~ "<svg"
      assert result =~ "rating-item"
    end

    test "renders rating with errors" do
      result =
        render_component(&dm_input/1, %{
          type: "rating",
          name: "rating",
          label: "Rating",
          errors: ["must rate"],
          value: nil
        })

      assert result =~ "must rate"
    end
  end

  describe "password_strength input type" do
    test "renders password strength with basic attributes" do
      result =
        render_component(&dm_input/1, %{
          type: "password_strength",
          name: "password",
          id: "pw-input",
          label: "Password",
          value: ""
        })

      assert result =~ ~s[type="password"]
      assert result =~ ~s[id="pw-input"]
      assert result =~ ~s[name="password"]
      assert result =~ "Password"
    end

    test "renders weak strength for short password" do
      result =
        render_component(&dm_input/1, %{
          type: "password_strength",
          name: "password",
          label: "Password",
          value: "abc"
        })

      assert result =~ "Weak"
      assert result =~ "progress-error"
    end

    test "renders medium strength for moderate password" do
      result =
        render_component(&dm_input/1, %{
          type: "password_strength",
          name: "password",
          label: "Password",
          value: "Password1"
        })

      assert result =~ "Medium"
      assert result =~ "progress-warning"
    end

    test "renders strong strength for complex password" do
      result =
        render_component(&dm_input/1, %{
          type: "password_strength",
          name: "password",
          label: "Password",
          value: "MyStr0ng!Pass#"
        })

      assert result =~ "Strong"
      assert result =~ "progress-success"
    end

    test "renders eye toggle button" do
      result =
        render_component(&dm_input/1, %{
          type: "password_strength",
          name: "password",
          label: "Password",
          value: ""
        })

      # Eye icon for show/hide password
      assert result =~ "<svg"
    end

    test "renders password strength with error state" do
      result =
        render_component(&dm_input/1, %{
          type: "password_strength",
          name: "password",
          label: "Password",
          errors: ["is too common"],
          value: ""
        })

      assert result =~ ~s[input-error]
      assert result =~ "is too common"
    end

    test "renders password strength with color variant" do
      result =
        render_component(&dm_input/1, %{
          type: "password_strength",
          name: "password",
          label: "Password",
          color: "primary",
          value: ""
        })

      assert result =~ ~s[input-primary]
    end

    test "renders empty password as weak" do
      result =
        render_component(&dm_input/1, %{
          type: "password_strength",
          name: "password",
          label: "Password",
          value: ""
        })

      assert result =~ "Weak"
    end

    test "renders exactly 8 uppercase-only password as medium" do
      result =
        render_component(&dm_input/1, %{
          type: "password_strength",
          name: "password",
          label: "Password",
          value: "ABCDEFGH"
        })

      # 8 chars meets length threshold, has uppercase => medium
      assert result =~ "Medium"
    end

    test "renders 7-char password as weak regardless of complexity" do
      result =
        render_component(&dm_input/1, %{
          type: "password_strength",
          name: "password",
          label: "Password",
          value: "Aa1!Bb2"
        })

      # 7 chars < 8 threshold => weak
      assert result =~ "Weak"
    end

    test "renders 12+ char password with all char types as strong" do
      result =
        render_component(&dm_input/1, %{
          type: "password_strength",
          name: "password",
          label: "Password",
          value: "AbcDef123!@#"
        })

      assert result =~ "Strong"
    end

    test "renders password with custom weak hint" do
      result =
        render_component(&dm_input/1, %{
          type: "password_strength",
          name: "password",
          label: "Password",
          value: "abc",
          password_hint_weak: "Too simple!"
        })

      assert result =~ "Too simple!"
    end

    test "renders password with custom medium hint" do
      result =
        render_component(&dm_input/1, %{
          type: "password_strength",
          name: "password",
          label: "Password",
          value: "Password1",
          password_hint_medium: "Almost there"
        })

      assert result =~ "Almost there"
    end

    test "renders password with custom strong hint" do
      result =
        render_component(&dm_input/1, %{
          type: "password_strength",
          name: "password",
          label: "Password",
          value: "AbcDef123!@#",
          password_hint_strong: "Excellent!"
        })

      assert result =~ "Excellent!"
    end
  end

  describe "slider_range input type" do
    test "renders slider range with basic attributes" do
      result =
        render_component(&dm_input/1, %{
          type: "slider_range",
          name: "price_range",
          id: "price-range",
          label: "Price Range",
          value: [20, 80]
        })

      assert result =~ ~s[type="range"]
      assert result =~ "Price Range"
      assert result =~ "(20 - 80)"
    end

    test "renders slider range with default values when nil" do
      result =
        render_component(&dm_input/1, %{
          type: "slider_range",
          name: "range",
          label: "Range",
          value: nil
        })

      assert result =~ "(0 - 100)"
    end

    test "renders slider range with default min/max/step" do
      result =
        render_component(&dm_input/1, %{
          type: "slider_range",
          name: "range",
          label: "Range",
          value: [10, 50]
        })

      # Default min=0, max=100, step=1
      assert result =~ ~s[min="0"]
      assert result =~ ~s[max="100"]
      assert result =~ ~s[step="1"]
    end

    test "renders slider range with color variant" do
      result =
        render_component(&dm_input/1, %{
          type: "slider_range",
          name: "range",
          label: "Range",
          color: "primary",
          value: nil
        })

      assert result =~ ~s[slider-primary]
    end

    test "renders slider range with hidden input for form" do
      result =
        render_component(&dm_input/1, %{
          type: "slider_range",
          name: "range",
          label: "Range",
          value: [25, 75]
        })

      assert result =~ ~s[type="hidden"]
      assert result =~ ~s[name="range"]
    end

    test "renders slider range with errors" do
      result =
        render_component(&dm_input/1, %{
          type: "slider_range",
          name: "range",
          label: "Range",
          errors: ["invalid range"],
          value: nil
        })

      assert result =~ "invalid range"
    end

    test "renders unique IDs for min and max range inputs" do
      result =
        render_component(&dm_input/1, %{
          type: "slider_range",
          name: "price",
          id: "price",
          label: "Price",
          value: [10, 90]
        })

      assert result =~ ~s[id="price_min"]
      assert result =~ ~s[id="price_max"]
      # Exactly 2 range inputs (min + max), no duplicates
      range_count = length(String.split(result, ~s[type="range"])) - 1
      assert range_count == 2
    end
  end

  describe "aria-invalid on error state" do
    test "renders aria-invalid on text input with errors" do
      result =
        render_component(&dm_input/1, %{
          type: "text",
          name: "email",
          label: "Email",
          errors: ["is required"],
          value: nil
        })

      assert result =~ ~s[aria-invalid="true"]
    end

    test "does not render aria-invalid on text input without errors" do
      result =
        render_component(&dm_input/1, %{
          type: "text",
          name: "email",
          label: "Email",
          errors: [],
          value: nil
        })

      refute result =~ "aria-invalid"
    end

    test "renders aria-invalid on select input with errors" do
      result =
        render_component(&dm_input/1, %{
          type: "select",
          name: "country",
          label: "Country",
          options: [{"USA", "us"}],
          errors: ["must be selected"],
          value: nil
        })

      assert result =~ ~s[aria-invalid="true"]
    end

    test "renders aria-invalid on textarea input with errors" do
      result =
        render_component(&dm_input/1, %{
          type: "textarea",
          name: "notes",
          label: "Notes",
          errors: ["too short"],
          value: nil
        })

      assert result =~ ~s[aria-invalid="true"]
    end

    test "renders aria-invalid on checkbox input with errors" do
      result =
        render_component(&dm_input/1, %{
          type: "checkbox",
          name: "agree",
          label: "I agree",
          errors: ["must accept"],
          value: nil
        })

      assert result =~ ~s[aria-invalid="true"]
    end

    test "renders aria-invalid on file input with errors" do
      result =
        render_component(&dm_input/1, %{
          type: "file",
          name: "avatar",
          label: "Avatar",
          errors: ["file too large"],
          value: nil
        })

      assert result =~ ~s[aria-invalid="true"]
    end
  end

  describe "aria-describedby for error messages" do
    test "default text input has aria-describedby linking to error container" do
      result =
        render_component(&dm_input/1, %{
          name: "email",
          id: "email-field",
          label: "Email",
          errors: ["is required"],
          value: nil
        })

      assert result =~ ~s[aria-describedby="email-field-errors"]
      assert result =~ ~s[id="email-field-errors"]
      assert result =~ "is required"
    end

    test "default text input omits aria-describedby when no errors" do
      result =
        render_component(&dm_input/1, %{
          name: "email",
          id: "email-field",
          label: "Email",
          errors: [],
          value: nil
        })

      refute result =~ "aria-describedby"
      refute result =~ "email-field-errors"
    end

    test "select input has aria-describedby when errors present" do
      result =
        render_component(&dm_input/1, %{
          type: "select",
          name: "country",
          id: "country-select",
          options: [{"USA", "us"}],
          errors: ["must be selected"],
          value: nil
        })

      assert result =~ ~s[aria-describedby="country-select-errors"]
      assert result =~ ~s[id="country-select-errors"]
    end

    test "textarea has aria-describedby when errors present" do
      result =
        render_component(&dm_input/1, %{
          type: "textarea",
          name: "bio",
          id: "bio-field",
          errors: ["too short"],
          value: nil
        })

      assert result =~ ~s[aria-describedby="bio-field-errors"]
      assert result =~ ~s[id="bio-field-errors"]
    end

    test "checkbox has aria-describedby when errors present" do
      result =
        render_component(&dm_input/1, %{
          type: "checkbox",
          name: "agree",
          id: "agree-cb",
          errors: ["must accept"],
          value: nil
        })

      assert result =~ ~s[aria-describedby="agree-cb-errors"]
      assert result =~ ~s[id="agree-cb-errors"]
    end

    test "file input has aria-describedby when errors present" do
      result =
        render_component(&dm_input/1, %{
          type: "file",
          name: "avatar",
          id: "avatar-upload",
          label: "Avatar",
          errors: ["file too large"],
          value: nil
        })

      assert result =~ ~s[aria-describedby="avatar-upload-errors"]
      assert result =~ ~s[id="avatar-upload-errors"]
    end

    test "switch input has aria-describedby when errors present" do
      result =
        render_component(&dm_input/1, %{
          type: "switch",
          name: "notifications",
          id: "notif-switch",
          label: "Notifications",
          errors: ["must be enabled"],
          value: nil
        })

      assert result =~ ~s[aria-describedby="notif-switch-errors"]
      assert result =~ ~s[id="notif-switch-errors"]
    end

    test "error container is not rendered when errors list is empty" do
      result =
        render_component(&dm_input/1, %{
          type: "select",
          name: "country",
          id: "country-select",
          options: [{"USA", "us"}],
          errors: [],
          value: nil
        })

      refute result =~ "country-select-errors"
      refute result =~ "aria-describedby"
    end

    test "password_strength has aria-describedby when errors present" do
      result =
        render_component(&dm_input/1, %{
          type: "password_strength",
          name: "pass",
          id: "pass-field",
          label: "Password",
          errors: ["too weak"],
          value: nil
        })

      assert result =~ ~s[aria-describedby="pass-field-errors"]
      assert result =~ ~s[id="pass-field-errors"]
    end
  end

  describe "icon-only button aria-labels" do
    test "rating stars have aria-label with rating value" do
      result =
        render_component(&dm_input/1, %{
          type: "rating",
          name: "rating",
          id: "rating-field",
          label: "Rating",
          value: nil
        })

      assert result =~ ~s[aria-label="Rate 1 out of 5"]
      assert result =~ ~s[aria-label="Rate 5 out of 5"]
    end

    test "file upload remove button has aria-label" do
      result =
        render_component(&dm_input/1, %{
          type: "file_upload",
          name: "avatar",
          id: "avatar",
          label: "Avatar",
          value: "photo.jpg"
        })

      assert result =~ ~s[aria-label="Remove file"]
    end

    test "rich text toolbar buttons have aria-labels" do
      result =
        render_component(&dm_input/1, %{
          type: "rich_text",
          name: "content",
          id: "content",
          label: "Content",
          value: nil
        })

      assert result =~ ~s[aria-label="Bold"]
      assert result =~ ~s[aria-label="Italic"]
      assert result =~ ~s[aria-label="Underline"]
      assert result =~ ~s[aria-label="Bulleted list"]
      assert result =~ ~s[aria-label="Numbered list"]
      assert result =~ ~s[aria-label="Insert link"]
    end

    test "rich text toolbar has role toolbar" do
      result =
        render_component(&dm_input/1, %{
          type: "rich_text",
          name: "content",
          id: "content",
          label: "Content",
          value: nil
        })

      assert result =~ ~s[role="toolbar"]
      assert result =~ ~s[aria-label="Text formatting"]
    end

    test "tags remove button has aria-label with tag name" do
      result =
        render_component(&dm_input/1, %{
          type: "tags",
          name: "tags",
          id: "tags",
          label: "Tags",
          value: ["elixir", "phoenix"]
        })

      assert result =~ ~s[aria-label="Remove tag elixir"]
      assert result =~ ~s[aria-label="Remove tag phoenix"]
    end

    test "password strength toggle has aria-label" do
      result =
        render_component(&dm_input/1, %{
          type: "password_strength",
          name: "pass",
          id: "pass",
          label: "Password",
          value: nil
        })

      assert result =~ ~s[aria-label="Toggle password visibility"]
    end
  end

  describe "FormField path" do
    test "renders input from FormField extracting id and name" do
      field = Phoenix.Component.to_form(%{"email" => "test@example.com"}, as: "user")[:email]

      result =
        render_component(&dm_input/1, %{
          field: field,
          type: "text",
          label: "Email"
        })

      assert result =~ ~s(name="user[email]")
      assert result =~ ~s(id="user_email")
      assert result =~ "test@example.com"
    end

    test "renders input from FormField with multiple appending brackets" do
      field = Phoenix.Component.to_form(%{"tags" => []}, as: "post")[:tags]

      result =
        render_component(&dm_input/1, %{
          field: field,
          type: "text",
          label: "Tags",
          multiple: true
        })

      assert result =~ ~s(name="post[tags][]")
    end
  end

  describe "rating edge cases" do
    test "renders rating buttons with aria-labels for each star" do
      result =
        render_component(&dm_input/1, %{
          type: "rating",
          name: "stars",
          id: "stars",
          label: "Rating",
          value: 3,
          max: 5
        })

      assert result =~ ~s[aria-label="Rate 1 out of 5"]
      assert result =~ ~s[aria-label="Rate 5 out of 5"]
    end

    test "renders rating color applied only to filled stars" do
      result =
        render_component(&dm_input/1, %{
          type: "rating",
          name: "stars",
          id: "stars",
          label: "Rating",
          value: 2,
          color: "warning",
          max: 3
        })

      # Should have rating-warning on the container for color variant
      assert result =~ "rating-warning"
      # The hidden input should have value 2
      assert result =~ ~s[value="2"]
    end

    test "renders rating with nil value shows 0/max" do
      result =
        render_component(&dm_input/1, %{
          type: "rating",
          name: "stars",
          id: "stars",
          label: "Rating",
          value: nil
        })

      assert result =~ "(0/5)"
    end
  end

  describe "checkbox_group edge cases" do
    test "renders checkbox_group with nil value has no checked boxes" do
      result =
        render_component(&dm_input/1, %{
          type: "checkbox_group",
          name: "colors",
          id: "colors",
          label: "Colors",
          options: [{"Red", "red"}, {"Blue", "blue"}],
          value: nil
        })

      # nil value => [] => no checkboxes checked
      refute result =~ "checked"
    end
  end

  describe "a11y improvements" do
    test "rating star buttons wrapped in role=group" do
      result =
        render_component(&dm_input/1, %{
          type: "rating",
          name: "rating",
          id: "rating-field",
          label: "Quality",
          value: 3
        })

      assert result =~ ~s[role="group"]
      assert result =~ ~s[aria-label="Quality rating"]
    end

    test "rich_text contenteditable has role=textbox and aria-multiline" do
      result =
        render_component(&dm_input/1, %{
          type: "rich_text",
          name: "content",
          id: "rich-text-field",
          label: "Description",
          value: "Hello"
        })

      assert result =~ ~s[role="textbox"]
      assert result =~ ~s[aria-multiline="true"]
      assert result =~ ~s[aria-label="Description"]
    end

    test "tags container has role=group" do
      result =
        render_component(&dm_input/1, %{
          type: "tags",
          name: "tags",
          id: "tags-field",
          label: "Keywords",
          value: ["elixir", "phoenix"]
        })

      assert result =~ ~s[role="group"]
      assert result =~ ~s[aria-label="Keywords tags"]
    end

    test "checkbox_group container has role=group and aria-labelledby" do
      result =
        render_component(&dm_input/1, %{
          type: "checkbox_group",
          name: "colors",
          id: "colors-group",
          label: "Favorite Colors",
          options: [{"Red", "red"}, {"Blue", "blue"}],
          value: []
        })

      assert result =~ ~s[role="group"]
      assert result =~ ~s[aria-labelledby="colors-group-label"]
      assert result =~ ~s[id="colors-group-label"]
    end

    test "radio_group container has role=group and aria-labelledby" do
      result =
        render_component(&dm_input/1, %{
          type: "radio_group",
          name: "size",
          id: "size-group",
          label: "Size",
          options: [{"Small", "sm"}, {"Large", "lg"}],
          value: nil
        })

      assert result =~ ~s[role="group"]
      assert result =~ ~s[aria-labelledby="size-group-label"]
      assert result =~ ~s[id="size-group-label"]
    end
  end

  describe "aria-invalid across input types" do
    test "toggle type has aria-invalid when errors present" do
      result =
        render_component(&dm_input/1, %{
          type: "toggle",
          name: "notify",
          id: "notify-toggle",
          value: "false",
          errors: ["is required"]
        })

      assert result =~ ~s[aria-invalid="true"]
      assert result =~ ~s[aria-describedby="notify-toggle-errors"]
    end

    test "toggle type has no aria-invalid without errors" do
      result =
        render_component(&dm_input/1, %{
          type: "toggle",
          name: "notify",
          id: "notify-toggle",
          value: "false"
        })

      refute result =~ "aria-invalid"
    end

    test "checkbox_group has aria-invalid on individual checkboxes when errors" do
      result =
        render_component(&dm_input/1, %{
          type: "checkbox_group",
          name: "colors",
          id: "colors-group",
          options: [{"Red", "r"}, {"Blue", "b"}],
          value: [],
          errors: ["select at least one"]
        })

      assert result =~ ~s[aria-invalid="true"]
      assert result =~ "select at least one"
    end

    test "radio_group has aria-invalid on individual radios when errors" do
      result =
        render_component(&dm_input/1, %{
          type: "radio_group",
          name: "size",
          id: "size-group",
          options: [{"Small", "sm"}, {"Large", "lg"}],
          value: nil,
          errors: ["must choose a size"]
        })

      assert result =~ ~s[aria-invalid="true"]
      assert result =~ "must choose a size"
    end

    test "range_slider has aria-invalid when errors present" do
      result =
        render_component(&dm_input/1, %{
          type: "range_slider",
          name: "volume",
          id: "volume-slider",
          value: 50,
          errors: ["out of range"]
        })

      assert result =~ ~s[aria-invalid="true"]
      assert result =~ ~s[aria-describedby="volume-slider-errors"]
      assert result =~ "out of range"
    end

    test "rating has aria-invalid on group when errors present" do
      result =
        render_component(&dm_input/1, %{
          type: "rating",
          name: "stars",
          id: "stars-rating",
          value: 0,
          label: "Rating",
          errors: ["please rate"]
        })

      assert result =~ ~s[aria-invalid="true"]
      assert result =~ ~s[aria-describedby="stars-rating-errors"]
      assert result =~ "please rate"
    end

    test "datepicker has aria-invalid when errors present" do
      result =
        render_component(&dm_input/1, %{
          type: "datepicker",
          name: "birthday",
          id: "birthday-picker",
          value: nil,
          errors: ["is required"]
        })

      assert result =~ ~s[aria-invalid="true"]
      assert result =~ ~s[aria-describedby="birthday-picker-errors"]
    end

    test "timepicker has aria-invalid when errors present" do
      result =
        render_component(&dm_input/1, %{
          type: "timepicker",
          name: "alarm",
          id: "alarm-picker",
          value: nil,
          errors: ["is required"]
        })

      assert result =~ ~s[aria-invalid="true"]
      assert result =~ ~s[aria-describedby="alarm-picker-errors"]
    end

    test "color_picker has aria-invalid when errors present" do
      result =
        render_component(&dm_input/1, %{
          type: "color_picker",
          name: "theme_color",
          id: "color-pick",
          value: "#ff0000",
          errors: ["invalid color"]
        })

      assert result =~ ~s[aria-invalid="true"]
      assert result =~ ~s[aria-describedby="color-pick-errors"]
    end

    test "switch has aria-invalid when errors present" do
      result =
        render_component(&dm_input/1, %{
          type: "switch",
          name: "agree",
          id: "agree-switch",
          value: "false",
          errors: ["must agree"]
        })

      assert result =~ ~s[aria-invalid="true"]
      assert result =~ ~s[aria-describedby="agree-switch-errors"]
    end

    test "search_with_suggestions has aria-invalid when errors present" do
      result =
        render_component(&dm_input/1, %{
          type: "search_with_suggestions",
          name: "query",
          id: "search-field",
          value: "",
          errors: ["too short"]
        })

      assert result =~ ~s[aria-invalid="true"]
      assert result =~ ~s[aria-describedby="search-field-errors"]
    end

    test "file_upload has aria-invalid when errors present" do
      result =
        render_component(&dm_input/1, %{
          type: "file_upload",
          name: "avatar",
          id: "avatar-upload",
          value: nil,
          errors: ["file required"]
        })

      assert result =~ ~s[aria-invalid="true"]
      assert result =~ ~s[aria-describedby="avatar-upload-errors"]
    end

    test "rich_text has aria-invalid when errors present" do
      result =
        render_component(&dm_input/1, %{
          type: "rich_text",
          name: "content",
          id: "content-editor",
          value: "",
          label: "Content",
          errors: ["cannot be blank"]
        })

      assert result =~ ~s[aria-invalid="true"]
      assert result =~ ~s[aria-describedby="content-editor-errors"]
    end

    test "tags has aria-invalid on group when errors present" do
      result =
        render_component(&dm_input/1, %{
          type: "tags",
          name: "keywords",
          id: "keywords-field",
          label: "Keywords",
          value: [],
          errors: ["add at least one tag"]
        })

      assert result =~ ~s[aria-invalid="true"]
      assert result =~ ~s[aria-describedby="keywords-field-errors"]
      assert result =~ "add at least one tag"
    end

    test "slider_range has aria-invalid when errors present" do
      result =
        render_component(&dm_input/1, %{
          type: "slider_range",
          name: "price",
          id: "price-range",
          value: [10, 90],
          label: "Price",
          errors: ["invalid range"]
        })

      assert result =~ ~s[aria-invalid="true"]
      assert result =~ ~s[aria-describedby="price-range-errors"]
      assert result =~ "invalid range"
    end

    test "password_strength has aria-invalid when errors present" do
      result =
        render_component(&dm_input/1, %{
          type: "password_strength",
          name: "password",
          id: "pw-field",
          value: "weak",
          label: "Password",
          errors: ["too weak"]
        })

      assert result =~ ~s[aria-invalid="true"]
      assert result =~ ~s[aria-describedby="pw-field-errors"]
      assert result =~ "too weak"
    end

    test "no aria-invalid on any type when no errors" do
      types_and_attrs = [
        {"toggle", %{value: "false"}},
        {"checkbox_group", %{options: [{"A", "a"}], value: []}},
        {"radio_group", %{options: [{"A", "a"}], value: nil}},
        {"range_slider", %{value: 50}},
        {"rating", %{value: 3, label: "Rate"}},
        {"datepicker", %{value: nil}},
        {"timepicker", %{value: nil}},
        {"color_picker", %{value: "#000000"}},
        {"switch", %{value: "false"}},
        {"search_with_suggestions", %{value: ""}},
        {"file_upload", %{value: nil}},
        {"rich_text", %{value: "", label: "Body"}},
        {"tags", %{value: [], label: "Tags"}},
        {"slider_range", %{value: [0, 100], label: "Range"}},
        {"password_strength", %{value: "", label: "PW"}}
      ]

      for {type, extra} <- types_and_attrs do
        base = %{type: type, name: "test", id: "test-id"}
        result = render_component(&dm_input/1, Map.merge(base, extra))
        refute result =~ "aria-invalid", "#{type} should NOT have aria-invalid without errors"
      end
    end

    test "checkbox_group has aria-describedby pointing to errors container" do
      result =
        render_component(&dm_input/1, %{
          type: "checkbox_group",
          name: "colors",
          id: "colors-grp",
          label: "Colors",
          options: [{"Red", "red"}, {"Blue", "blue"}],
          value: [],
          errors: ["must select at least one"]
        })

      assert result =~ ~s[aria-describedby="colors-grp-errors"]
      assert result =~ ~s[id="colors-grp-errors"]
      assert result =~ "must select at least one"
    end

    test "checkbox_group without errors has no aria-describedby" do
      result =
        render_component(&dm_input/1, %{
          type: "checkbox_group",
          name: "colors",
          id: "colors-grp",
          label: "Colors",
          options: [{"Red", "red"}, {"Blue", "blue"}],
          value: []
        })

      refute result =~ "aria-describedby"
    end

    test "radio_group has aria-describedby pointing to errors container" do
      result =
        render_component(&dm_input/1, %{
          type: "radio_group",
          name: "size",
          id: "size-grp",
          label: "Size",
          options: [{"Small", "sm"}, {"Large", "lg"}],
          value: nil,
          errors: ["is required"]
        })

      assert result =~ ~s[aria-describedby="size-grp-errors"]
      assert result =~ ~s[id="size-grp-errors"]
      assert result =~ "is required"
    end

    test "radio_group without errors has no aria-describedby" do
      result =
        render_component(&dm_input/1, %{
          type: "radio_group",
          name: "size",
          id: "size-grp",
          label: "Size",
          options: [{"Small", "sm"}, {"Large", "lg"}],
          value: nil
        })

      refute result =~ "aria-describedby"
    end
  end

  describe "configurable rich_text and file_upload labels" do
    test "file upload renders custom remove_file_label" do
      result =
        render_component(&dm_input/1, %{
          type: "file_upload",
          name: "avatar",
          id: "avatar",
          label: "Avatar",
          value: "photo.jpg",
          remove_file_label: "Supprimer le fichier"
        })

      assert result =~ ~s[aria-label="Supprimer le fichier"]
    end

    test "rich text renders custom toolbar_label" do
      result =
        render_component(&dm_input/1, %{
          type: "rich_text",
          name: "body",
          id: "body",
          label: "Body",
          value: nil,
          toolbar_label: "Mise en forme du texte"
        })

      assert result =~ ~s[aria-label="Mise en forme du texte"]
    end

    test "rich text renders custom bold/italic/underline labels" do
      result =
        render_component(&dm_input/1, %{
          type: "rich_text",
          name: "body",
          id: "body",
          label: "Body",
          value: nil,
          bold_label: "Gras",
          italic_label: "Italique",
          underline_label: "Souligner"
        })

      assert result =~ ~s[aria-label="Gras"]
      assert result =~ ~s[aria-label="Italique"]
      assert result =~ ~s[aria-label="Souligner"]
    end

    test "rich text renders custom list and link labels" do
      result =
        render_component(&dm_input/1, %{
          type: "rich_text",
          name: "body",
          id: "body",
          label: "Body",
          value: nil,
          bulleted_list_label: "Liste à puces",
          numbered_list_label: "Liste numérotée",
          insert_link_label: "Insérer un lien"
        })

      assert result =~ ~s[aria-label="Liste à puces"]
      assert result =~ ~s[aria-label="Liste numérotée"]
      assert result =~ ~s[aria-label="Insérer un lien"]
    end
  end

  describe "configurable password_strength labels" do
    test "password_strength renders custom toggle_password_label" do
      result =
        render_component(&dm_input/1, %{
          type: "password_strength",
          name: "password",
          id: "pw-toggle",
          label: "Password",
          value: "",
          toggle_password_label: "Mostrar contrasena"
        })

      assert result =~ ~s[aria-label="Mostrar contrasena"]
    end
  end

  describe "field_class attribute" do
    test "default text input renders field_class on wrapper" do
      result =
        render_component(&dm_input/1, %{
          type: "text",
          name: "user",
          id: "user-field",
          label: "User",
          value: "",
          field_class: "w-full max-w-md"
        })

      assert result =~ "form-group"
      assert result =~ "w-full max-w-md"
    end

    test "select input renders field_class on wrapper" do
      result =
        render_component(&dm_input/1, %{
          type: "select",
          name: "country",
          id: "country-sel",
          options: [{"US", "us"}],
          value: nil,
          field_class: "col-span-2"
        })

      assert result =~ "col-span-2"
    end

    test "textarea renders field_class on wrapper" do
      result =
        render_component(&dm_input/1, %{
          type: "textarea",
          name: "bio",
          id: "bio-field",
          value: nil,
          field_class: "mt-4"
        })

      assert result =~ "mt-4"
    end

    test "checkbox renders field_class on wrapper" do
      result =
        render_component(&dm_input/1, %{
          type: "checkbox",
          name: "agree",
          id: "agree-cb",
          label: "Agree",
          value: "true",
          field_class: "border-b"
        })

      assert result =~ "border-b"
    end

    test "range_slider renders field_class on wrapper" do
      result =
        render_component(&dm_input/1, %{
          type: "range_slider",
          name: "volume",
          id: "vol-slider",
          label: "Volume",
          value: "50",
          field_class: "px-4"
        })

      assert result =~ "px-4"
    end

    test "field_class nil does not add extra class" do
      result =
        render_component(&dm_input/1, %{
          type: "text",
          name: "name",
          id: "name-field",
          label: "Name",
          value: ""
        })

      assert result =~ "form-group"
    end
  end

  describe "classic mode" do
    test "classic text input omits input class" do
      result =
        render_component(&dm_input/1, %{
          type: "text",
          name: "user",
          id: "user-classic",
          label: "User",
          value: "",
          classic: true
        })

      # Extract input element to verify no input class on it
      refute Regex.match?(~r/<input[^>]*class="[^"]*input/, result)
    end

    test "non-classic text input includes input class" do
      result =
        render_component(&dm_input/1, %{
          type: "text",
          name: "user",
          id: "user-styled",
          label: "User",
          value: ""
        })

      assert result =~ "input"
    end

    test "classic select omits select class" do
      result =
        render_component(&dm_input/1, %{
          type: "select",
          name: "country",
          id: "country-classic",
          options: [{"US", "us"}],
          value: nil,
          classic: true
        })

      refute Regex.match?(~r/<select[^>]*class="[^"]*select/, result)
    end

    test "classic textarea omits textarea class" do
      result =
        render_component(&dm_input/1, %{
          type: "textarea",
          name: "bio",
          id: "bio-classic",
          value: nil,
          classic: true
        })

      refute Regex.match?(~r/<textarea[^>]*class="[^"]*textarea/, result)
    end

    test "classic checkbox omits checkbox class" do
      result =
        render_component(&dm_input/1, %{
          type: "checkbox",
          name: "agree",
          id: "agree-classic",
          label: "Agree",
          value: "true",
          classic: true
        })

      refute Regex.match?(~r/<input[^>]*class="[^"]*checkbox/, result)
    end

    test "classic radio_group omits radio class" do
      result =
        render_component(&dm_input/1, %{
          type: "radio_group",
          name: "color",
          id: "color-classic",
          label: "Color",
          options: [{"Red", "red"}, {"Blue", "blue"}],
          value: "red",
          classic: true
        })

      refute Regex.match?(~r/<input[^>]*class="[^"]*radio/, result)
    end

    test "classic range_slider omits slider class" do
      result =
        render_component(&dm_input/1, %{
          type: "range_slider",
          name: "vol",
          id: "vol-classic",
          label: "Volume",
          value: "50",
          classic: true
        })

      refute Regex.match?(~r/<input[^>]*class="[^"]*slider/, result)
    end

    test "classic file input omits input class" do
      result =
        render_component(&dm_input/1, %{
          type: "file",
          name: "doc",
          id: "doc-classic",
          label: "Document",
          value: nil,
          classic: true
        })

      refute Regex.match?(~r/<input[^>]*class="[^"]*input/, result)
    end

    test "classic datepicker omits input class" do
      result =
        render_component(&dm_input/1, %{
          type: "datepicker",
          name: "bday",
          id: "bday-classic",
          label: "Birthday",
          value: "",
          classic: true
        })

      refute Regex.match?(~r/<input[^>]*class="[^"]*input/, result)
    end

    test "classic password_strength omits input class" do
      result =
        render_component(&dm_input/1, %{
          type: "password_strength",
          name: "pwd",
          id: "pwd-classic",
          label: "Password",
          value: "",
          classic: true
        })

      refute Regex.match?(~r/<input[^>]*class="[^"]*input/, result)
    end

    test "classic search_with_suggestions omits input class" do
      result =
        render_component(&dm_input/1, %{
          type: "search_with_suggestions",
          name: "search",
          id: "search-classic",
          label: "Search",
          value: "",
          classic: true
        })

      refute Regex.match?(~r/<input[^>]*class="[^"]*input/, result)
    end

    test "classic timepicker omits input class" do
      result =
        render_component(&dm_input/1, %{
          type: "timepicker",
          name: "alarm",
          id: "alarm-classic",
          label: "Alarm",
          value: "",
          classic: true
        })

      refute Regex.match?(~r/<input[^>]*class="[^"]*input/, result)
    end

    test "classic mode preserves color and size variant classes" do
      result =
        render_component(&dm_input/1, %{
          type: "text",
          name: "styled",
          id: "styled-classic",
          label: "Input",
          value: "",
          classic: true,
          color: "primary",
          size: "lg"
        })

      # Color and size classes still apply even in classic mode
      assert result =~ "input-primary"
      assert result =~ "input-lg"
    end

    test "11-char password with all char types is medium (under 12 threshold)" do
      result =
        render_component(&dm_input/1, %{
          type: "password_strength",
          name: "password",
          label: "Password",
          value: "AbcDef12!@#"
        })

      # 11 chars < 12, so even with all 4 char types => medium
      assert result =~ "Medium"
    end

    test "12-char password with only 3 char types is medium (missing special)" do
      result =
        render_component(&dm_input/1, %{
          type: "password_strength",
          name: "password",
          label: "Password",
          value: "AbcDef123456"
        })

      # 12 chars but only uppercase + lowercase + digits, no special => medium
      assert result =~ "Medium"
    end

    test "12-char password with only lowercase and digits is medium" do
      result =
        render_component(&dm_input/1, %{
          type: "password_strength",
          name: "password",
          label: "Password",
          value: "abcdef123456"
        })

      # 12 chars but only lowercase + digits, no uppercase or special => medium
      assert result =~ "Medium"
    end

    test "classic mode with field_class applies both" do
      result =
        render_component(&dm_input/1, %{
          type: "text",
          name: "combo",
          id: "combo-field",
          label: "Combo",
          value: "",
          classic: true,
          field_class: "my-wrapper"
        })

      assert result =~ "my-wrapper"
      refute Regex.match?(~r/<input[^>]*class="[^"]*input[^-]/, result)
    end
  end

  describe "input style variants (ghost, filled, bordered)" do
    test "renders text input with ghost variant" do
      result =
        render_component(&dm_input/1, %{
          type: "text",
          name: "ghost-text",
          label: "Ghost",
          variant: "ghost",
          value: ""
        })

      assert result =~ "input-ghost"
      assert result =~ "class=\"input "
    end

    test "renders text input with filled variant" do
      result =
        render_component(&dm_input/1, %{
          type: "text",
          name: "filled-text",
          label: "Filled",
          variant: "filled",
          value: ""
        })

      assert result =~ "input-filled"
    end

    test "renders text input with bordered variant" do
      result =
        render_component(&dm_input/1, %{
          type: "text",
          name: "bordered-text",
          label: "Bordered",
          variant: "bordered",
          value: ""
        })

      assert result =~ "input-bordered"
    end

    test "renders text input without variant class by default" do
      result =
        render_component(&dm_input/1, %{
          type: "text",
          name: "default-text",
          label: "Default",
          value: ""
        })

      refute result =~ "input-ghost"
      refute result =~ "input-filled"
      refute result =~ "input-bordered"
    end

    test "renders ghost variant with color" do
      result =
        render_component(&dm_input/1, %{
          type: "text",
          name: "ghost-color",
          label: "Ghost Primary",
          variant: "ghost",
          color: "primary",
          value: ""
        })

      assert result =~ "input-ghost"
      assert result =~ "input-primary"
    end

    test "renders filled variant with size" do
      result =
        render_component(&dm_input/1, %{
          type: "text",
          name: "filled-size",
          label: "Filled LG",
          variant: "filled",
          size: "lg",
          value: ""
        })

      assert result =~ "input-filled"
      assert result =~ "input-lg"
    end

    test "renders ghost variant on email input type" do
      result =
        render_component(&dm_input/1, %{
          type: "email",
          name: "ghost-email",
          label: "Email",
          variant: "ghost",
          value: ""
        })

      assert result =~ "input-ghost"
      assert result =~ ~s[type="email"]
    end

    test "renders filled variant on password input type" do
      result =
        render_component(&dm_input/1, %{
          type: "password",
          name: "filled-pass",
          label: "Password",
          variant: "filled",
          value: ""
        })

      assert result =~ "input-filled"
      assert result =~ ~s[type="password"]
    end

    test "renders ghost variant on search input type" do
      result =
        render_component(&dm_input/1, %{
          type: "search",
          name: "ghost-search",
          label: "Search",
          variant: "ghost",
          value: ""
        })

      assert result =~ "input-ghost"
      assert result =~ ~s[type="search"]
    end

    test "renders filled variant on datepicker type" do
      result =
        render_component(&dm_input/1, %{
          type: "datepicker",
          name: "filled-date",
          label: "Date",
          variant: "filled",
          value: ""
        })

      assert result =~ "input-filled"
    end

    test "renders ghost variant on timepicker type" do
      result =
        render_component(&dm_input/1, %{
          type: "timepicker",
          name: "ghost-time",
          label: "Time",
          variant: "ghost",
          value: ""
        })

      assert result =~ "input-ghost"
    end

    test "renders filled variant on password_strength type" do
      result =
        render_component(&dm_input/1, %{
          type: "password_strength",
          name: "filled-pw",
          label: "Password",
          variant: "filled",
          value: ""
        })

      assert result =~ "input-filled"
    end

    test "renders ghost variant with error state" do
      result =
        render_component(&dm_input/1, %{
          type: "text",
          name: "ghost-error",
          label: "Input",
          variant: "ghost",
          errors: ["is invalid"],
          value: ""
        })

      assert result =~ "input-ghost"
      assert result =~ "input-error"
      assert result =~ "is invalid"
    end

    test "renders filled variant with all options combined" do
      result =
        render_component(&dm_input/1, %{
          type: "text",
          name: "filled-all",
          id: "filled-all",
          label: "Full",
          variant: "filled",
          color: "success",
          size: "lg",
          value: "test"
        })

      assert result =~ "input-filled"
      assert result =~ "input-success"
      assert result =~ "input-lg"
      assert result =~ ~s[value="test"]
    end
  end

  describe "label_class" do
    test "renders label with custom label_class" do
      result =
        render_component(&dm_input/1, %{
          name: "user",
          label: "Username",
          label_class: "text-lg font-bold",
          value: nil
        })

      assert result =~ "text-lg font-bold"
      assert result =~ "Username"
    end

    test "renders label with label_class and error class combined" do
      result =
        render_component(&dm_input/1, %{
          name: "user",
          label: "Username",
          label_class: "text-sm",
          errors: ["is required"],
          value: nil
        })

      assert result =~ "text-sm"
      assert result =~ "form-group-error"
    end

    test "renders select label with label_class" do
      result =
        render_component(&dm_input/1, %{
          type: "select",
          name: "country",
          label: "Country",
          label_class: "font-semibold",
          options: [{"us", "USA"}],
          value: nil
        })

      assert result =~ "font-semibold"
      assert result =~ "Country"
    end

    test "renders textarea label with label_class" do
      result =
        render_component(&dm_input/1, %{
          type: "textarea",
          name: "bio",
          label: "Bio",
          label_class: "italic",
          value: nil
        })

      assert result =~ "italic"
      assert result =~ "Bio"
    end
  end

  describe "horizontal layout" do
    test "renders text input with form-group-horizontal" do
      result =
        render_component(&dm_input/1, %{
          name: "email",
          label: "Email",
          value: nil,
          horizontal: true
        })

      assert result =~ "form-group-horizontal"
    end

    test "does not render form-group-horizontal by default" do
      result =
        render_component(&dm_input/1, %{name: "email", label: "Email", value: nil})

      refute result =~ "form-group-horizontal"
    end

    test "renders select input with form-group-horizontal" do
      result =
        render_component(&dm_input/1, %{
          name: "country",
          type: "select",
          value: nil,
          horizontal: true,
          options: [{"us", "USA"}]
        })

      assert result =~ "form-group-horizontal"
    end

    test "renders textarea input with form-group-horizontal" do
      result =
        render_component(&dm_input/1, %{
          name: "bio",
          type: "textarea",
          value: nil,
          horizontal: true
        })

      assert result =~ "form-group-horizontal"
    end
  end

  describe "validation state" do
    test "renders input with form-group-success" do
      result =
        render_component(&dm_input/1, %{
          name: "email",
          value: "ok@test.com",
          state: "success"
        })

      assert result =~ "form-group-success"
    end

    test "renders input with form-group-warning" do
      result =
        render_component(&dm_input/1, %{name: "email", value: "hmm", state: "warning"})

      assert result =~ "form-group-warning"
    end

    test "does not render state class by default" do
      result = render_component(&dm_input/1, %{name: "email", value: nil})

      refute result =~ "form-group-success"
      refute result =~ "form-group-warning"
    end

    test "renders checkbox with form-group-success" do
      result =
        render_component(&dm_input/1, %{
          name: "agree",
          type: "checkbox",
          value: "true",
          state: "success"
        })

      assert result =~ "form-group-success"
    end
  end
end
