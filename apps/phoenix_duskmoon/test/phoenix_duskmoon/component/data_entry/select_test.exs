defmodule PhoenixDuskmoon.Component.DataEntry.SelectTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataEntry.Select

  test "renders basic select with options" do
    result =
      render_component(&dm_select/1, %{
        name: "country",
        value: nil,
        options: [{"us", "USA"}, {"ca", "Canada"}]
      })

    assert result =~ "<select"
    assert result =~ "select"
    assert result =~ "USA"
    assert result =~ "Canada"
  end

  test "renders select option values" do
    result =
      render_component(&dm_select/1, %{
        name: "country",
        value: nil,
        options: [{"us", "USA"}, {"ca", "Canada"}]
      })

    assert result =~ ~s[value="us"]
    assert result =~ ~s[value="ca"]
  end

  test "renders select with prompt" do
    result =
      render_component(&dm_select/1, %{
        name: "country",
        value: nil,
        prompt: "Select a country",
        options: [{"us", "USA"}]
      })

    assert result =~ "Select a country"
    assert result =~ ~s[value=""]
  end

  test "renders select with label" do
    result =
      render_component(&dm_select/1, %{
        name: "country",
        value: nil,
        label: "Country",
        options: [{"us", "USA"}]
      })

    assert result =~ "Country"
    assert result =~ "form-label"
  end

  test "renders select with custom id" do
    result =
      render_component(&dm_select/1, %{
        name: "country",
        id: "country-select",
        value: nil,
        options: [{"us", "USA"}]
      })

    assert result =~ ~s[id="country-select"]
  end

  test "renders select with default size md" do
    result =
      render_component(&dm_select/1, %{
        name: "opt",
        value: nil,
        options: [{"1", "One"}]
      })

    assert result =~ "select-md"
  end

  test "renders select with all size options" do
    for size <- ~w(xs sm md lg) do
      result =
        render_component(&dm_select/1, %{
          name: "opt",
          value: nil,
          size: size,
          options: [{"1", "One"}]
        })

      assert result =~ "select-#{size}"
    end
  end

  test "renders select with default color primary" do
    result =
      render_component(&dm_select/1, %{
        name: "opt",
        value: nil,
        options: [{"1", "One"}]
      })

    assert result =~ "select-primary"
  end

  test "renders select with all color options" do
    for color <- ~w(primary secondary accent info success warning error) do
      result =
        render_component(&dm_select/1, %{
          name: "opt",
          value: nil,
          color: color,
          options: [{"1", "One"}]
        })

      assert result =~ "select-#{color}"
    end
  end

  test "renders disabled select" do
    result =
      render_component(&dm_select/1, %{
        name: "opt",
        value: nil,
        disabled: true,
        options: [{"1", "One"}]
      })

    assert result =~ "disabled"
    assert result =~ "opacity-50"
  end

  test "renders select with form-group wrapper" do
    result =
      render_component(&dm_select/1, %{
        name: "opt",
        value: nil,
        options: [{"1", "One"}]
      })

    assert result =~ "form-group"
  end

  test "renders select with custom class" do
    result =
      render_component(&dm_select/1, %{
        name: "opt",
        value: nil,
        class: "my-select-wrapper",
        options: [{"1", "One"}]
      })

    assert result =~ "my-select-wrapper"
  end

  test "renders select with select_class" do
    result =
      render_component(&dm_select/1, %{
        name: "opt",
        value: nil,
        select_class: "custom-select",
        options: [{"1", "One"}]
      })

    assert result =~ "custom-select"
  end

  test "renders select with selected option" do
    result =
      render_component(&dm_select/1, %{
        name: "opt",
        value: "b",
        options: [{"a", "Alpha"}, {"b", "Beta"}]
      })

    assert result =~ "selected"
  end

  test "renders select with multiple attribute" do
    result =
      render_component(&dm_select/1, %{
        name: "colors",
        value: nil,
        multiple: true,
        options: [{"r", "Red"}, {"g", "Green"}, {"b", "Blue"}]
      })

    assert result =~ "multiple"
    assert result =~ "Red"
    assert result =~ "Green"
    assert result =~ "Blue"
  end

  test "renders select with label_class" do
    result =
      render_component(&dm_select/1, %{
        name: "opt",
        value: nil,
        label: "Pick one",
        label_class: "text-lg font-semibold",
        options: [{"1", "One"}]
      })

    assert result =~ "text-lg font-semibold"
    assert result =~ "form-label"
  end

  test "renders select without label by default" do
    result =
      render_component(&dm_select/1, %{
        name: "opt",
        value: nil,
        options: [{"1", "One"}]
      })

    refute result =~ "form-label"
    refute result =~ "<label"
  end

  test "renders select with inner_block instead of options" do
    result =
      render_component(&dm_select/1, %{
        name: "opt",
        value: nil,
        inner_block: [%{inner_block: fn _, _ -> "Custom option content" end}]
      })

    assert result =~ "Custom option content"
    assert result =~ "<select"
  end

  test "renders select with prompt and inner_block" do
    result =
      render_component(&dm_select/1, %{
        name: "opt",
        value: nil,
        prompt: "Choose...",
        inner_block: [%{inner_block: fn _, _ -> "Option A" end}]
      })

    assert result =~ "Choose..."
    assert result =~ "Option A"
  end

  test "renders select with rest attributes" do
    result =
      render_component(&dm_select/1, %{
        name: "opt",
        value: nil,
        "data-testid": "my-select",
        "aria-label": "Select option",
        options: [{"1", "One"}]
      })

    assert result =~ "data-testid=\"my-select\""
    assert result =~ "aria-label=\"Select option\""
  end

  test "renders select with non-disabled default" do
    result =
      render_component(&dm_select/1, %{
        name: "opt",
        value: nil,
        options: [{"1", "One"}]
      })

    refute result =~ "opacity-50"
    refute result =~ "cursor-not-allowed"
  end

  test "renders select label with for attribute matching id" do
    result =
      render_component(&dm_select/1, %{
        name: "opt",
        id: "my-id",
        value: nil,
        label: "My Label",
        options: [{"1", "One"}]
      })

    assert result =~ ~s[for="my-id"]
    assert result =~ ~s[id="my-id"]
  end

  test "renders select with all attributes combined" do
    result =
      render_component(&dm_select/1, %{
        name: "full",
        id: "full-select",
        value: "b",
        label: "Full Select",
        label_class: "text-sm",
        select_class: "border-2",
        class: "wrapper-class",
        size: "lg",
        color: "error",
        prompt: "Pick one",
        options: [{"a", "Alpha"}, {"b", "Beta"}],
        "data-testid": "combo-select"
      })

    assert result =~ ~s[id="full-select"]
    assert result =~ "Full Select"
    assert result =~ "text-sm"
    assert result =~ "border-2"
    assert result =~ "wrapper-class"
    assert result =~ "select-lg"
    assert result =~ "select-error"
    assert result =~ "Pick one"
    assert result =~ "selected"
    assert result =~ "data-testid=\"combo-select\""
  end

  describe "FormField integration" do
    test "renders select with form field using field id and name" do
      field = Phoenix.Component.to_form(%{"country" => "us"}, as: "user")[:country]

      result =
        render_component(&dm_select/1, %{
          field: field,
          options: [{"us", "USA"}, {"ca", "Canada"}]
        })

      assert result =~ ~s[id="user_country"]
      assert result =~ ~s(name="user[country]")
    end

    test "renders select with field value selecting correct option" do
      field = Phoenix.Component.to_form(%{"country" => "ca"}, as: "user")[:country]

      result =
        render_component(&dm_select/1, %{
          field: field,
          options: [{"us", "USA"}, {"ca", "Canada"}]
        })

      assert result =~ "selected"
    end

    test "renders select with multiple field appending [] to name" do
      field = Phoenix.Component.to_form(%{"colors" => ""}, as: "user")[:colors]

      result =
        render_component(&dm_select/1, %{
          field: field,
          multiple: true,
          options: [{"r", "Red"}, {"g", "Green"}]
        })

      assert result =~ ~s(name="user[colors][]")
      assert result =~ "multiple"
    end

    test "renders select with custom id overriding field id" do
      field = Phoenix.Component.to_form(%{"country" => ""}, as: "user")[:country]

      result =
        render_component(&dm_select/1, %{
          field: field,
          id: "custom-select",
          options: [{"us", "USA"}]
        })

      assert result =~ ~s[id="custom-select"]
    end

    test "renders select with field and styling combined" do
      field = Phoenix.Component.to_form(%{"priority" => ""}, as: "user")[:priority]

      result =
        render_component(&dm_select/1, %{
          field: field,
          label: "Priority",
          color: "warning",
          size: "lg",
          prompt: "Select priority",
          options: [{"low", "Low"}, {"high", "High"}]
        })

      assert result =~ "Priority"
      assert result =~ "select-warning"
      assert result =~ "select-lg"
      assert result =~ "Select priority"
    end
  end

  test "renders select with aria-invalid and error messages when errors present" do
    result =
      render_component(&dm_select/1, %{
        name: "country",
        id: "country-select",
        value: nil,
        options: [{"us", "USA"}],
        errors: ["is required"]
      })

    assert result =~ ~s[aria-invalid="true"]
    assert result =~ ~s[aria-describedby="country-select-errors"]
    assert result =~ ~s[id="country-select-errors"]
    assert result =~ "is required"
  end

  test "renders select without aria-invalid when no errors" do
    result =
      render_component(&dm_select/1, %{
        name: "country",
        id: "country-select",
        value: nil,
        options: [{"us", "USA"}]
      })

    refute result =~ "aria-invalid"
    refute result =~ "aria-describedby"
  end
end
