defmodule PhoenixDuskmoon.Component.Form.InputTypesTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Form.Input

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
      assert result =~ ~s[select select-bordered]
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
      assert result =~ ~s[textarea textarea-bordered]
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
      assert result =~ ~s[class="toggle"]
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
    end

    test "renders toggle with unchecked value" do
      result =
        render_component(&dm_input/1, %{
          type: "toggle",
          name: "disabled-toggle",
          label: "Disabled",
          value: false
        })

      refute result =~ ~s[checked]
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

      assert result =~ ~s[toggle-primary]
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

      assert result =~ ~s[toggle-lg]
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
      assert result =~ ~s[class="range"]
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

      assert result =~ ~s[range-primary]
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

      assert result =~ ~s[range-lg]
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
      assert result =~ ~s[file-input file-input-bordered]
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

      assert result =~ ~s[file-input-primary]
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

      assert result =~ ~s[file-input-lg]
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

      assert result =~ ~s[file-input-error]
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
      assert result =~ ~s[input input-bordered]
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
      assert result =~ ~s[input input-bordered]
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
      assert result =~ ~s[input input-bordered]
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
      assert result =~ ~s[input input-bordered]
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
      assert result =~ ~s[input input-bordered]
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
      assert result =~ ~s[input input-bordered]
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
end
