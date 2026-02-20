defmodule PhoenixDuskmoon.Component.DataEntry.RadioTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataEntry.Radio

  test "renders basic radio button" do
    result = render_component(&dm_radio/1, %{name: "choice", value: "a"})

    assert result =~ ~s[type="radio"]
    assert result =~ "radio"
  end

  test "renders radio with name and value" do
    result = render_component(&dm_radio/1, %{name: "theme", value: "dark"})

    assert result =~ ~s[name="theme"]
    assert result =~ ~s[value="dark"]
  end

  test "renders radio with label" do
    result = render_component(&dm_radio/1, %{name: "choice", value: "a", label: "Option A"})

    assert result =~ "Option A"
  end

  test "renders radio without label span when no label" do
    result = render_component(&dm_radio/1, %{name: "choice", value: "a"})

    refute result =~ "<span"
  end

  test "renders radio with custom id" do
    result = render_component(&dm_radio/1, %{name: "choice", value: "a", id: "radio-1"})

    assert result =~ ~s[id="radio-1"]
  end

  test "renders radio with default size md" do
    result = render_component(&dm_radio/1, %{name: "choice", value: "a"})

    assert result =~ "radio-md"
  end

  test "renders radio with all size options" do
    for size <- ~w(xs sm md lg xl) do
      result = render_component(&dm_radio/1, %{name: "choice", value: "a", size: size})
      assert result =~ "radio-#{size}"
    end
  end

  test "renders radio with default color primary" do
    result = render_component(&dm_radio/1, %{name: "choice", value: "a"})

    assert result =~ "radio-primary"
  end

  test "renders radio with all color options" do
    for color <- ~w(primary secondary accent info success warning error) do
      result = render_component(&dm_radio/1, %{name: "choice", value: "a", color: color})
      css_class = if color == "accent", do: "tertiary", else: color
      assert result =~ "radio-#{css_class}"
    end
  end

  test "renders checked radio" do
    result = render_component(&dm_radio/1, %{name: "choice", value: "a", checked: true})

    assert result =~ "checked"
  end

  test "renders disabled radio" do
    result = render_component(&dm_radio/1, %{name: "choice", value: "a", disabled: true})

    assert result =~ "disabled"
    assert result =~ "opacity-50"
  end

  test "renders radio with form-group wrapper" do
    result = render_component(&dm_radio/1, %{name: "choice", value: "a"})

    assert result =~ "form-group"
  end

  test "renders radio with custom class" do
    result = render_component(&dm_radio/1, %{name: "choice", value: "a", class: "my-radio"})

    assert result =~ "my-radio"
  end

  test "renders radio with label_class" do
    result =
      render_component(&dm_radio/1, %{
        name: "choice",
        value: "a",
        label: "Option",
        label_class: "text-lg"
      })

    assert result =~ "text-lg"
  end

  test "renders radio with radio_class" do
    result =
      render_component(&dm_radio/1, %{
        name: "choice",
        value: "a",
        radio_class: "custom-radio"
      })

    assert result =~ "custom-radio"
  end

  test "renders radio without disabled styles when not disabled" do
    result = render_component(&dm_radio/1, %{name: "choice", value: "a"})

    refute result =~ "opacity-50"
    refute result =~ "cursor-not-allowed"
  end

  test "renders radio with rest attributes" do
    result =
      render_component(&dm_radio/1, %{
        name: "choice",
        value: "a",
        "data-testid": "radio-option",
        "aria-describedby": "help"
      })

    assert result =~ "data-testid=\"radio-option\""
    assert result =~ "aria-describedby=\"help\""
  end

  test "renders radio with label wrapping input in flex layout" do
    result = render_component(&dm_radio/1, %{name: "choice", value: "a", label: "Pick"})

    assert result =~ "<label"
    assert result =~ "flex items-center gap-2"
    assert result =~ "cursor-pointer"
  end

  test "renders radio with unchecked state by default" do
    result = render_component(&dm_radio/1, %{name: "choice", value: "a"})

    refute result =~ "checked"
  end

  test "renders radio with combined label_class and radio_class" do
    result =
      render_component(&dm_radio/1, %{
        name: "choice",
        value: "a",
        label: "Styled",
        label_class: "font-bold",
        radio_class: "border-2"
      })

    assert result =~ "font-bold"
    assert result =~ "border-2"
  end

  test "renders radio with all attributes combined" do
    result =
      render_component(&dm_radio/1, %{
        name: "theme",
        id: "radio-dark",
        value: "dark",
        label: "Dark Mode",
        label_class: "text-lg",
        radio_class: "border-accent",
        class: "my-wrapper",
        size: "lg",
        color: "accent",
        checked: true,
        "data-testid": "theme-radio"
      })

    assert result =~ ~s[name="theme"]
    assert result =~ ~s[id="radio-dark"]
    assert result =~ ~s[value="dark"]
    assert result =~ "Dark Mode"
    assert result =~ "text-lg"
    assert result =~ "border-accent"
    assert result =~ "my-wrapper"
    assert result =~ "radio-lg"
    assert result =~ "radio-tertiary"
    assert result =~ "checked"
    assert result =~ "data-testid=\"theme-radio\""
  end

  test "renders radio with disabled state and cursor-not-allowed" do
    result =
      render_component(&dm_radio/1, %{
        name: "opt",
        value: "a",
        disabled: true
      })

    assert result =~ "disabled"
    assert result =~ "cursor-not-allowed"
  end

  test "renders radio without label when not provided" do
    result =
      render_component(&dm_radio/1, %{
        name: "opt",
        value: "a"
      })

    refute result =~ "<span"
  end

  test "renders radio without id when not provided" do
    result =
      render_component(&dm_radio/1, %{
        name: "opt",
        value: "a"
      })

    refute result =~ ~s[id="]
  end

  describe "FormField integration" do
    test "renders radio with form field using field id" do
      field = Phoenix.Component.to_form(%{"theme" => "dark"}, as: "user")[:theme]

      result = render_component(&dm_radio/1, %{field: field, value: "dark"})

      assert result =~ ~s[id="user_theme"]
      assert result =~ ~s(name="user[theme]")
      assert result =~ ~s[value="dark"]
    end

    test "renders radio with field value passed through" do
      field = Phoenix.Component.to_form(%{"theme" => "dark"}, as: "user")[:theme]

      result = render_component(&dm_radio/1, %{field: field, value: "dark"})

      assert result =~ ~s[value="dark"]
      assert result =~ ~s(name="user[theme]")
    end

    test "renders radio with custom id overriding field id" do
      field = Phoenix.Component.to_form(%{"theme" => "light"}, as: "user")[:theme]

      result = render_component(&dm_radio/1, %{field: field, value: "dark", id: "custom-id"})

      assert result =~ ~s[id="custom-id"]
    end

    test "renders radio with field and label combined" do
      field = Phoenix.Component.to_form(%{"theme" => ""}, as: "user")[:theme]

      result =
        render_component(&dm_radio/1, %{
          field: field,
          value: "dark",
          label: "Dark Mode",
          color: "accent",
          size: "lg"
        })

      assert result =~ "Dark Mode"
      assert result =~ "radio-tertiary"
      assert result =~ "radio-lg"
    end
  end

  test "renders radio with aria-invalid and error messages when errors present" do
    result =
      render_component(&dm_radio/1, %{
        name: "choice",
        id: "choice-a",
        value: "a",
        errors: ["must select one"]
      })

    assert result =~ ~s[aria-invalid="true"]
    assert result =~ ~s[aria-describedby="choice-a-errors"]
    assert result =~ ~s[id="choice-a-errors"]
    assert result =~ "must select one"
  end

  test "renders radio without aria-invalid when no errors" do
    result =
      render_component(&dm_radio/1, %{
        name: "choice",
        id: "choice-a",
        value: "a"
      })

    refute result =~ "aria-invalid"
    refute result =~ "aria-describedby"
  end

  test "renders disabled radio label without cursor-pointer" do
    result =
      render_component(&dm_radio/1, %{
        name: "choice",
        value: "a",
        disabled: true,
        label: "Disabled Option"
      })

    assert result =~ "cursor-not-allowed"
    refute result =~ "cursor-pointer"
  end

  describe "aria-describedby helper linking" do
    test "aria-describedby references helper id when helper present" do
      result =
        render_component(&dm_radio/1, %{
          name: "theme",
          id: "theme-dark",
          value: "dark",
          helper: "Choose your preferred theme"
        })

      assert result =~ ~s[aria-describedby="theme-dark-helper"]
      assert result =~ ~s[id="theme-dark-helper"]
    end

    test "aria-describedby references errors instead of helper when errors present" do
      result =
        render_component(&dm_radio/1, %{
          name: "theme",
          id: "theme-dark",
          value: "dark",
          helper: "Choose your preferred theme",
          errors: ["must select one"]
        })

      assert result =~ ~s[aria-describedby="theme-dark-errors"]
      refute result =~ "theme-dark-helper"
    end

    test "no aria-describedby when neither helper nor errors present" do
      result =
        render_component(&dm_radio/1, %{
          name: "theme",
          id: "theme-dark",
          value: "dark"
        })

      refute result =~ "aria-describedby"
    end
  end

  describe "helper text" do
    test "renders helper text when provided" do
      result =
        render_component(&dm_radio/1, %{
          name: "theme",
          value: "dark",
          helper: "Choose your preferred theme"
        })

      assert result =~ "helper-text"
      assert result =~ "Choose your preferred theme"
    end

    test "does not render helper text when not provided" do
      result = render_component(&dm_radio/1, %{name: "theme", value: "dark"})

      refute result =~ "helper-text"
    end

    test "hides helper text when errors are present" do
      result =
        render_component(&dm_radio/1, %{
          name: "theme",
          value: "dark",
          helper: "Choose your preferred theme",
          errors: ["must select one"]
        })

      refute result =~ "Choose your preferred theme"
      assert result =~ "must select one"
    end
  end
end
