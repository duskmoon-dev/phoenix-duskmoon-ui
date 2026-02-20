defmodule PhoenixDuskmoon.Component.DataEntry.CheckboxTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataEntry.Checkbox

  test "renders basic checkbox" do
    result = render_component(&dm_checkbox/1, %{name: "agree"})

    assert result =~ ~s[type="checkbox"]
    assert result =~ "checkbox"
  end

  test "renders checkbox with name" do
    result = render_component(&dm_checkbox/1, %{name: "subscribe"})

    assert result =~ ~s[name="subscribe"]
  end

  test "renders checkbox with label" do
    result = render_component(&dm_checkbox/1, %{name: "agree", label: "I agree to terms"})

    assert result =~ "I agree to terms"
  end

  test "renders checkbox without label span when no label" do
    result = render_component(&dm_checkbox/1, %{name: "agree"})

    refute result =~ "<span"
  end

  test "renders checkbox with custom id" do
    result = render_component(&dm_checkbox/1, %{name: "agree", id: "my-checkbox"})

    assert result =~ ~s[id="my-checkbox"]
  end

  test "renders checkbox with default size md" do
    result = render_component(&dm_checkbox/1, %{name: "opt"})

    assert result =~ "checkbox-md"
  end

  test "renders checkbox with all size options" do
    for size <- ~w(xs sm md lg xl) do
      result = render_component(&dm_checkbox/1, %{name: "opt", size: size})
      assert result =~ "checkbox-#{size}"
    end
  end

  test "renders checkbox with default color primary" do
    result = render_component(&dm_checkbox/1, %{name: "opt"})

    assert result =~ "checkbox-primary"
  end

  test "renders checkbox with all color options" do
    for color <- ~w(primary secondary accent info success warning error) do
      result = render_component(&dm_checkbox/1, %{name: "opt", color: color})
      css_class = if color == "accent", do: "tertiary", else: color
      assert result =~ "checkbox-#{css_class}"
    end
  end

  test "renders checked checkbox" do
    result = render_component(&dm_checkbox/1, %{name: "opt", checked: true})

    assert result =~ "checked"
  end

  test "renders disabled checkbox" do
    result = render_component(&dm_checkbox/1, %{name: "opt", disabled: true})

    assert result =~ "disabled"
    assert result =~ "opacity-50"
  end

  test "renders checkbox with indeterminate state" do
    result = render_component(&dm_checkbox/1, %{name: "opt", indeterminate: true})

    assert result =~ "phx-indeterminate"
  end

  test "renders checkbox with form-group wrapper" do
    result = render_component(&dm_checkbox/1, %{name: "opt"})

    assert result =~ "form-group"
  end

  test "renders checkbox with custom class" do
    result = render_component(&dm_checkbox/1, %{name: "opt", class: "my-checkbox"})

    assert result =~ "my-checkbox"
  end

  test "renders checkbox with checkbox_class" do
    result = render_component(&dm_checkbox/1, %{name: "opt", checkbox_class: "custom-input"})

    assert result =~ "custom-input"
  end

  test "renders checkbox with value true" do
    result = render_component(&dm_checkbox/1, %{name: "opt"})

    assert result =~ ~s[value="true"]
  end

  test "renders checkbox with label_class" do
    result =
      render_component(&dm_checkbox/1, %{
        name: "opt",
        label: "Accept terms",
        label_class: "text-sm"
      })

    assert result =~ "text-sm"
  end

  test "renders checkbox with rest attributes" do
    result =
      render_component(&dm_checkbox/1, %{
        name: "opt",
        "data-testid": "terms-checkbox",
        "aria-label": "Accept terms"
      })

    assert result =~ "data-testid=\"terms-checkbox\""
    assert result =~ "aria-label=\"Accept terms\""
  end

  test "renders unchecked checkbox by default" do
    result = render_component(&dm_checkbox/1, %{name: "opt"})

    refute result =~ "checked=\"checked\""
  end

  test "renders checkbox with checked and disabled" do
    result =
      render_component(&dm_checkbox/1, %{name: "opt", checked: true, disabled: true})

    assert result =~ "checked"
    assert result =~ "disabled"
    assert result =~ "opacity-50"
  end

  test "renders checkbox with indeterminate and checked" do
    result =
      render_component(&dm_checkbox/1, %{
        name: "opt",
        checked: true,
        indeterminate: true
      })

    assert result =~ "checked"
    assert result =~ "phx-indeterminate"
  end

  test "renders checkbox with cursor-pointer label" do
    result = render_component(&dm_checkbox/1, %{name: "opt"})

    assert result =~ "cursor-pointer"
  end

  test "renders checkbox label with flex layout" do
    result = render_component(&dm_checkbox/1, %{name: "opt"})

    assert result =~ "flex items-center gap-2"
  end

  test "renders non-indeterminate checkbox by default" do
    result = render_component(&dm_checkbox/1, %{name: "opt"})

    refute result =~ "phx-indeterminate"
  end

  test "renders enabled checkbox by default" do
    result = render_component(&dm_checkbox/1, %{name: "opt"})

    refute result =~ "cursor-not-allowed"
  end

  describe "FormField integration" do
    test "renders checkbox with form field using field id and name" do
      field = Phoenix.Component.to_form(%{"agree" => "true"}, as: "user")[:agree]

      result = render_component(&dm_checkbox/1, %{field: field})

      assert result =~ ~s[id="user_agree"]
      assert result =~ ~s(name="user[agree]")
    end

    test "renders checkbox with field value" do
      field = Phoenix.Component.to_form(%{"agree" => "true"}, as: "user")[:agree]

      result = render_component(&dm_checkbox/1, %{field: field})

      assert result =~ ~s[value="true"]
      assert result =~ ~s(name="user[agree]")
    end

    test "renders checkbox with multiple appending [] to name" do
      field = Phoenix.Component.to_form(%{"tags" => ""}, as: "user")[:tags]

      result = render_component(&dm_checkbox/1, %{field: field, multiple: true})

      assert result =~ ~s(name="user[tags][]")
    end

    test "renders checkbox with custom id overriding field id" do
      field = Phoenix.Component.to_form(%{"agree" => ""}, as: "user")[:agree]

      result = render_component(&dm_checkbox/1, %{field: field, id: "custom-cb"})

      assert result =~ ~s[id="custom-cb"]
    end

    test "renders checkbox with field and styling combined" do
      field = Phoenix.Component.to_form(%{"agree" => ""}, as: "user")[:agree]

      result =
        render_component(&dm_checkbox/1, %{
          field: field,
          label: "I agree",
          color: "success",
          size: "lg"
        })

      assert result =~ "I agree"
      assert result =~ "checkbox-success"
      assert result =~ "checkbox-lg"
    end
  end

  test "renders checkbox with aria-invalid and error messages when errors present" do
    result =
      render_component(&dm_checkbox/1, %{
        name: "agree",
        id: "agree-cb",
        errors: ["must be accepted"]
      })

    assert result =~ ~s[aria-invalid="true"]
    assert result =~ ~s[aria-describedby="agree-cb-errors"]
    assert result =~ ~s[id="agree-cb-errors"]
    assert result =~ "must be accepted"
  end

  test "renders checkbox without aria-invalid when no errors" do
    result =
      render_component(&dm_checkbox/1, %{
        name: "agree",
        id: "agree-cb"
      })

    refute result =~ "aria-invalid"
    refute result =~ "aria-describedby"
  end

  test "renders disabled checkbox label without cursor-pointer" do
    result =
      render_component(&dm_checkbox/1, %{
        name: "agree",
        disabled: true,
        label: "Disabled option"
      })

    assert result =~ "cursor-not-allowed"
    refute result =~ "cursor-pointer"
  end

  test "renders hidden false input for form submission" do
    result = render_component(&dm_checkbox/1, %{name: "agree"})

    assert result =~ ~s(type="hidden")
    assert result =~ ~s(value="false")
  end

  test "hidden false input uses same name as checkbox" do
    result = render_component(&dm_checkbox/1, %{name: "terms"})

    assert result =~ ~s(<input type="hidden" name="terms" value="false")
  end

  describe "aria-describedby helper linking" do
    test "aria-describedby references helper id when helper present" do
      result =
        render_component(&dm_checkbox/1, %{
          name: "agree",
          id: "agree-cb",
          helper: "You must accept to continue"
        })

      assert result =~ ~s[aria-describedby="agree-cb-helper"]
      assert result =~ ~s[id="agree-cb-helper"]
    end

    test "aria-describedby references errors instead of helper when errors present" do
      result =
        render_component(&dm_checkbox/1, %{
          name: "agree",
          id: "agree-cb",
          helper: "You must accept to continue",
          errors: ["must be accepted"]
        })

      assert result =~ ~s[aria-describedby="agree-cb-errors"]
      refute result =~ "agree-cb-helper"
    end

    test "no aria-describedby when neither helper nor errors present" do
      result =
        render_component(&dm_checkbox/1, %{
          name: "agree",
          id: "agree-cb"
        })

      refute result =~ "aria-describedby"
    end
  end

  describe "helper text" do
    test "renders helper text when provided" do
      result =
        render_component(&dm_checkbox/1, %{
          name: "agree",
          helper: "You must accept to continue"
        })

      assert result =~ "helper-text"
      assert result =~ "You must accept to continue"
    end

    test "does not render helper text when not provided" do
      result = render_component(&dm_checkbox/1, %{name: "agree"})

      refute result =~ "helper-text"
    end

    test "hides helper text when errors are present" do
      result =
        render_component(&dm_checkbox/1, %{
          name: "agree",
          helper: "You must accept to continue",
          errors: ["must be accepted"]
        })

      refute result =~ "You must accept to continue"
      assert result =~ "must be accepted"
    end
  end
end
