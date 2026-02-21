defmodule PhoenixDuskmoon.Component.DataEntry.CompactInputTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataEntry.CompactInput

  test "renders basic compact input" do
    result =
      render_component(&dm_compact_input/1, %{name: "user", label: "Username", value: nil})

    assert result =~ "form-group"
    assert result =~ "Username"
  end

  test "renders compact input with label" do
    result =
      render_component(&dm_compact_input/1, %{name: "email", label: "Email", value: nil})

    assert result =~ "form-label"
    assert result =~ "Email"
  end

  test "renders compact input with default type text" do
    result =
      render_component(&dm_compact_input/1, %{name: "user", label: "User", value: nil})

    assert result =~ ~s[type="text"]
  end

  test "renders compact input with email type" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "email",
        label: "Email",
        type: "email",
        value: nil
      })

    assert result =~ ~s[type="email"]
  end

  test "renders compact input with password type" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "pass",
        label: "Password",
        type: "password",
        value: nil
      })

    assert result =~ ~s[type="password"]
  end

  test "renders compact input with value" do
    result =
      render_component(&dm_compact_input/1, %{name: "user", label: "User", value: "john"})

    assert result =~ ~s[value="john"]
  end

  test "renders compact input with custom id" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "user",
        label: "User",
        value: nil,
        id: "my-input"
      })

    assert result =~ ~s[id="my-input"]
  end

  test "renders compact input with input class" do
    result =
      render_component(&dm_compact_input/1, %{name: "user", label: "User", value: nil})

    assert result =~ "input"
  end

  test "renders compact input with phx-feedback-for" do
    result =
      render_component(&dm_compact_input/1, %{name: "user", label: "User", value: nil})

    assert result =~ ~s[phx-feedback-for="user"]
  end

  test "renders compact select input" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "country",
        label: "Country",
        type: "select",
        value: nil,
        options: [{"us", "USA"}, {"ca", "Canada"}]
      })

    assert result =~ "<select"
    assert result =~ "select"
    assert result =~ "USA"
    assert result =~ "Canada"
  end

  test "renders compact select with prompt" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "country",
        label: "Country",
        type: "select",
        value: nil,
        prompt: "Choose...",
        options: [{"us", "USA"}]
      })

    assert result =~ "Choose..."
  end

  test "renders compact input with errors" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "user",
        label: "User",
        value: nil,
        errors: ["is required"]
      })

    assert result =~ "is required"
    assert result =~ "form-group-error"
  end

  test "renders compact input with custom class" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "user",
        label: "User",
        value: nil,
        class: "my-compact"
      })

    assert result =~ "my-compact"
  end

  test "renders compact input with number type" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "age",
        label: "Age",
        type: "number",
        value: nil
      })

    assert result =~ ~s[type="number"]
  end

  test "renders compact input with date type" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "birthday",
        label: "Birthday",
        type: "date",
        value: nil
      })

    assert result =~ ~s[type="date"]
  end

  test "renders compact input with url type" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "website",
        label: "Website",
        type: "url",
        value: nil
      })

    assert result =~ ~s[type="url"]
  end

  test "renders compact input with tel type" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "phone",
        label: "Phone",
        type: "tel",
        value: nil
      })

    assert result =~ ~s[type="tel"]
  end

  test "renders compact input with multiple errors" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "user",
        label: "User",
        value: nil,
        errors: ["is required", "must be at least 3 characters"]
      })

    assert result =~ "is required"
    assert result =~ "must be at least 3 characters"
    assert result =~ "form-group-error"
  end

  test "renders compact input with disabled attribute" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "user",
        label: "User",
        value: nil,
        disabled: true
      })

    assert result =~ "disabled"
  end

  test "renders compact input with readonly attribute" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "user",
        label: "User",
        value: nil,
        readonly: true
      })

    assert result =~ "readonly"
  end

  test "renders compact input with placeholder attribute" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "user",
        label: "User",
        value: nil,
        placeholder: "Enter username"
      })

    assert result =~ ~s[placeholder="Enter username"]
  end

  test "renders compact input with required attribute" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "user",
        label: "User",
        value: nil,
        required: true
      })

    assert result =~ "required"
  end

  test "renders compact select with multiple flag" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "colors",
        label: "Colors",
        type: "select",
        value: nil,
        multiple: true,
        options: [{"red", "Red"}, {"blue", "Blue"}]
      })

    assert result =~ "multiple"
  end

  test "renders compact input without label" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "user",
        value: nil
      })

    assert result =~ "form-label"
    assert result =~ "input"
  end

  test "renders compact select with error state" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "country",
        label: "Country",
        type: "select",
        value: nil,
        options: [{"us", "USA"}],
        errors: ["is required"]
      })

    assert result =~ "form-group-error"
    assert result =~ "is required"
  end

  test "renders compact input with field_class" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "user",
        label: "User",
        value: nil,
        field_class: "w-full"
      })

    assert result =~ "form-group"
  end

  test "renders aria-invalid when errors present" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "email",
        label: "Email",
        value: nil,
        errors: ["is required"]
      })

    assert result =~ ~s[aria-invalid="true"]
  end

  test "does not render aria-invalid when no errors" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "email",
        label: "Email",
        value: nil,
        errors: []
      })

    refute result =~ "aria-invalid"
  end

  test "renders aria-invalid on select type with errors" do
    result =
      render_component(&dm_compact_input/1, %{
        type: "select",
        name: "country",
        label: "Country",
        value: nil,
        options: [{"USA", "us"}],
        errors: ["must be selected"]
      })

    assert result =~ ~s[aria-invalid="true"]
  end

  test "renders aria-describedby linking to error container when errors present" do
    result =
      render_component(&dm_compact_input/1, %{
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

  test "omits aria-describedby when no errors" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "email",
        id: "email-field",
        label: "Email",
        errors: [],
        value: nil
      })

    refute result =~ "aria-describedby"
    refute result =~ "email-field-errors"
  end

  test "compact select renders aria-describedby when errors present" do
    result =
      render_component(&dm_compact_input/1, %{
        type: "select",
        name: "country",
        id: "country-select",
        label: "Country",
        value: nil,
        options: [{"USA", "us"}],
        errors: ["must be selected"]
      })

    assert result =~ ~s[aria-describedby="country-select-errors"]
    assert result =~ ~s[id="country-select-errors"]
  end

  describe "FormField integration" do
    test "renders compact input with form field using field id and name" do
      field = Phoenix.Component.to_form(%{"email" => "test@example.com"}, as: "user")[:email]

      result = render_component(&dm_compact_input/1, %{field: field, label: "Email"})

      assert result =~ ~s[id="user_email"]
      assert result =~ ~s(name="user[email]")
      assert result =~ ~s[value="test@example.com"]
    end

    test "renders compact input with field value nil" do
      field = Phoenix.Component.to_form(%{"name" => nil}, as: "user")[:name]

      result = render_component(&dm_compact_input/1, %{field: field, label: "Name"})

      assert result =~ ~s[id="user_name"]
      assert result =~ "<input"
    end

    test "renders compact input with custom id overriding field id" do
      field = Phoenix.Component.to_form(%{"email" => ""}, as: "user")[:email]

      result =
        render_component(&dm_compact_input/1, %{
          field: field,
          id: "custom-email",
          label: "Email"
        })

      assert result =~ ~s[id="custom-email"]
    end

    test "renders compact select with form field" do
      field = Phoenix.Component.to_form(%{"country" => "us"}, as: "user")[:country]

      result =
        render_component(&dm_compact_input/1, %{
          field: field,
          type: "select",
          label: "Country",
          options: [{"us", "USA"}, {"ca", "Canada"}]
        })

      assert result =~ ~s[id="user_country"]
      assert result =~ ~s(name="user[country]")
      assert result =~ "<select"
    end

    test "renders compact select with multiple field appending [] to name" do
      field = Phoenix.Component.to_form(%{"tags" => ""}, as: "post")[:tags]

      result =
        render_component(&dm_compact_input/1, %{
          field: field,
          type: "select",
          label: "Tags",
          multiple: true,
          options: [{"elixir", "Elixir"}, {"phoenix", "Phoenix"}]
        })

      assert result =~ ~s(name="post[tags][]")
      assert result =~ "multiple"
    end

    test "renders compact input with field and type combined" do
      field = Phoenix.Component.to_form(%{"age" => "25"}, as: "user")[:age]

      result =
        render_component(&dm_compact_input/1, %{
          field: field,
          type: "number",
          label: "Age"
        })

      assert result =~ ~s[type="number"]
      assert result =~ ~s[id="user_age"]
      assert result =~ "Age"
    end
  end

  test "renders compact input with all text options combined" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "email",
        id: "email-field",
        value: "test@test.com",
        label: "Email",
        type: "email",
        class: "my-wrapper",
        errors: ["is invalid"],
        placeholder: "Enter email",
        required: true
      })

    assert result =~ ~s[id="email-field"]
    assert result =~ ~s[name="email"]
    assert result =~ ~s[type="email"]
    assert result =~ ~s[value="test@test.com"]
    assert result =~ "Email"
    assert result =~ "my-wrapper"
    assert result =~ "form-group-error"
    assert result =~ "is invalid"
    assert result =~ ~s[placeholder="Enter email"]
    assert result =~ "required"
    assert result =~ ~s[aria-invalid="true"]
    assert result =~ ~s[aria-describedby="email-field-errors"]
  end

  test "renders compact select with all options combined" do
    result =
      render_component(&dm_compact_input/1, %{
        name: "country",
        id: "country-field",
        value: nil,
        label: "Country",
        type: "select",
        class: "select-wrapper",
        prompt: "Choose...",
        options: [{"us", "USA"}, {"ca", "Canada"}],
        errors: ["is required"]
      })

    assert result =~ ~s[id="country-field"]
    assert result =~ "Country"
    assert result =~ "select-wrapper"
    assert result =~ "Choose..."
    assert result =~ "USA"
    assert result =~ "Canada"
    assert result =~ "form-group-error"
    assert result =~ "is required"
    assert result =~ ~s[aria-invalid="true"]
  end

  describe "color variants" do
    test "renders compact input with default color primary" do
      result =
        render_component(&dm_compact_input/1, %{name: "user", label: "User", value: nil})

      assert result =~ "input-primary"
    end

    test "renders compact input with all color options" do
      for color <- ~w(primary secondary accent info success warning error) do
        result =
          render_component(&dm_compact_input/1, %{
            name: "user",
            label: "User",
            value: nil,
            color: color
          })

        css_class = if color == "accent", do: "tertiary", else: color
        assert result =~ "input-#{css_class}"
      end
    end

    test "renders compact select with color" do
      result =
        render_component(&dm_compact_input/1, %{
          name: "opt",
          label: "Opt",
          type: "select",
          value: nil,
          color: "warning",
          options: [{"1", "One"}]
        })

      assert result =~ "select-warning"
    end

    test "renders compact select with accent color mapped to tertiary" do
      result =
        render_component(&dm_compact_input/1, %{
          name: "opt",
          label: "Opt",
          type: "select",
          value: nil,
          color: "accent",
          options: [{"1", "One"}]
        })

      assert result =~ "select-tertiary"
    end
  end

  describe "size variants" do
    test "renders compact input with default size md" do
      result =
        render_component(&dm_compact_input/1, %{name: "user", label: "User", value: nil})

      assert result =~ "input-md"
    end

    test "renders compact input with all size options" do
      for size <- ~w(xs sm md lg) do
        result =
          render_component(&dm_compact_input/1, %{
            name: "user",
            label: "User",
            value: nil,
            size: size
          })

        assert result =~ "input-#{size}"
      end
    end

    test "renders compact select with size" do
      result =
        render_component(&dm_compact_input/1, %{
          name: "opt",
          label: "Opt",
          type: "select",
          value: nil,
          size: "lg",
          options: [{"1", "One"}]
        })

      assert result =~ "select-lg"
    end

    test "renders compact select with all size options" do
      for size <- ~w(xs sm md lg) do
        result =
          render_component(&dm_compact_input/1, %{
            name: "opt",
            label: "Opt",
            type: "select",
            value: nil,
            size: size,
            options: [{"1", "One"}]
          })

        assert result =~ "select-#{size}"
      end
    end
  end

  describe "style variants (ghost, filled, bordered)" do
    test "renders compact input with ghost variant" do
      result =
        render_component(&dm_compact_input/1, %{
          name: "user",
          label: "User",
          value: nil,
          variant: "ghost"
        })

      assert result =~ "input-ghost"
    end

    test "renders compact input with filled variant" do
      result =
        render_component(&dm_compact_input/1, %{
          name: "user",
          label: "User",
          value: nil,
          variant: "filled"
        })

      assert result =~ "input-filled"
    end

    test "renders compact input with bordered variant" do
      result =
        render_component(&dm_compact_input/1, %{
          name: "user",
          label: "User",
          value: nil,
          variant: "bordered"
        })

      assert result =~ "input-bordered"
    end

    test "renders compact input without variant class by default" do
      result =
        render_component(&dm_compact_input/1, %{name: "user", label: "User", value: nil})

      refute result =~ "input-ghost"
      refute result =~ "input-filled"
      refute result =~ "input-bordered"
    end

    test "renders compact select with ghost variant" do
      result =
        render_component(&dm_compact_input/1, %{
          name: "opt",
          label: "Opt",
          type: "select",
          value: nil,
          variant: "ghost",
          options: [{"1", "One"}]
        })

      assert result =~ "select-ghost"
    end

    test "renders compact select with filled variant" do
      result =
        render_component(&dm_compact_input/1, %{
          name: "opt",
          label: "Opt",
          type: "select",
          value: nil,
          variant: "filled",
          options: [{"1", "One"}]
        })

      assert result =~ "select-filled"
    end

    test "renders compact select without variant class by default" do
      result =
        render_component(&dm_compact_input/1, %{
          name: "opt",
          label: "Opt",
          type: "select",
          value: nil,
          options: [{"1", "One"}]
        })

      refute result =~ "select-ghost"
      refute result =~ "select-filled"
      refute result =~ "select-bordered"
    end

    test "renders compact input with variant and color combined" do
      result =
        render_component(&dm_compact_input/1, %{
          name: "user",
          label: "User",
          value: nil,
          variant: "filled",
          color: "success"
        })

      assert result =~ "input-filled"
      assert result =~ "input-success"
    end
  end

  describe "aria-describedby helper linking" do
    test "aria-describedby references helper id when helper present" do
      result =
        render_component(&dm_compact_input/1, %{
          name: "email",
          id: "email-field",
          label: "Email",
          value: nil,
          helper: "We will never share your email"
        })

      assert result =~ ~s[aria-describedby="email-field-helper"]
      assert result =~ ~s[id="email-field-helper"]
    end

    test "aria-describedby references errors instead of helper when errors present" do
      result =
        render_component(&dm_compact_input/1, %{
          name: "email",
          id: "email-field",
          label: "Email",
          value: nil,
          helper: "We will never share your email",
          errors: ["is invalid"]
        })

      assert result =~ ~s[aria-describedby="email-field-errors"]
      refute result =~ "email-field-helper"
    end

    test "no aria-describedby when neither helper nor errors present" do
      result =
        render_component(&dm_compact_input/1, %{
          name: "email",
          id: "email-field",
          label: "Email",
          value: nil
        })

      refute result =~ "aria-describedby"
    end

    test "compact select aria-describedby references helper id" do
      result =
        render_component(&dm_compact_input/1, %{
          name: "country",
          id: "country-field",
          label: "Country",
          type: "select",
          value: nil,
          helper: "Select your country",
          options: [{"us", "USA"}]
        })

      assert result =~ ~s[aria-describedby="country-field-helper"]
      assert result =~ ~s[id="country-field-helper"]
    end

    test "compact select aria-describedby references errors instead of helper" do
      result =
        render_component(&dm_compact_input/1, %{
          name: "country",
          id: "country-field",
          label: "Country",
          type: "select",
          value: nil,
          helper: "Select your country",
          errors: ["is required"],
          options: [{"us", "USA"}]
        })

      assert result =~ ~s[aria-describedby="country-field-errors"]
      refute result =~ "country-field-helper"
    end
  end

  describe "helper text" do
    test "renders helper text when provided" do
      result =
        render_component(&dm_compact_input/1, %{
          name: "email",
          label: "Email",
          value: nil,
          helper: "We will never share your email"
        })

      assert result =~ "helper-text"
      assert result =~ "We will never share your email"
    end

    test "does not render helper text when not provided" do
      result =
        render_component(&dm_compact_input/1, %{name: "email", label: "Email", value: nil})

      refute result =~ "helper-text"
    end

    test "hides helper text when errors are present" do
      result =
        render_component(&dm_compact_input/1, %{
          name: "email",
          label: "Email",
          value: nil,
          helper: "We will never share your email",
          errors: ["is invalid"]
        })

      refute result =~ "We will never share your email"
      assert result =~ "is invalid"
    end

    test "renders helper text on compact select" do
      result =
        render_component(&dm_compact_input/1, %{
          name: "country",
          label: "Country",
          type: "select",
          value: nil,
          helper: "Select your country of residence",
          options: [{"us", "USA"}]
        })

      assert result =~ "helper-text"
      assert result =~ "Select your country of residence"
    end

    test "hides helper text on compact select when errors present" do
      result =
        render_component(&dm_compact_input/1, %{
          name: "country",
          label: "Country",
          type: "select",
          value: nil,
          helper: "Select your country of residence",
          errors: ["is required"],
          options: [{"us", "USA"}]
        })

      refute result =~ "Select your country of residence"
      assert result =~ "is required"
    end
  end

  describe "horizontal layout" do
    test "renders compact input with form-group-horizontal" do
      result =
        render_component(&dm_compact_input/1, %{
          name: "email",
          label: "Email",
          value: nil,
          horizontal: true
        })

      assert result =~ "form-group-horizontal"
    end

    test "does not render form-group-horizontal by default" do
      result =
        render_component(&dm_compact_input/1, %{name: "email", label: "Email", value: nil})

      refute result =~ "form-group-horizontal"
    end

    test "renders compact select with form-group-horizontal" do
      result =
        render_component(&dm_compact_input/1, %{
          name: "country",
          label: "Country",
          type: "select",
          value: nil,
          horizontal: true,
          options: [{"us", "USA"}]
        })

      assert result =~ "form-group-horizontal"
    end
  end

  describe "validation state" do
    test "renders compact input with form-group-success" do
      result =
        render_component(&dm_compact_input/1, %{
          name: "email",
          label: "Email",
          value: "ok@test.com",
          state: "success"
        })

      assert result =~ "form-group-success"
    end

    test "renders compact input with form-group-warning" do
      result =
        render_component(&dm_compact_input/1, %{
          name: "email",
          label: "Email",
          value: "hmm",
          state: "warning"
        })

      assert result =~ "form-group-warning"
    end

    test "does not render state class by default" do
      result =
        render_component(&dm_compact_input/1, %{name: "email", label: "Email", value: nil})

      refute result =~ "form-group-success"
      refute result =~ "form-group-warning"
    end

    test "renders compact select with form-group-success" do
      result =
        render_component(&dm_compact_input/1, %{
          name: "country",
          label: "Country",
          type: "select",
          value: "us",
          state: "success",
          options: [{"us", "USA"}]
        })

      assert result =~ "form-group-success"
    end
  end
end
