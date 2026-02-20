defmodule PhoenixDuskmoon.Component.DataEntry.TextareaTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataEntry.Textarea

  test "renders basic textarea element" do
    result = render_component(&dm_textarea/1, %{name: "bio", value: nil})

    assert result =~ "<textarea"
    assert result =~ "textarea"
  end

  test "renders textarea with name" do
    result = render_component(&dm_textarea/1, %{name: "description", value: nil})

    assert result =~ ~s[name="description"]
  end

  test "renders textarea with value" do
    result = render_component(&dm_textarea/1, %{name: "bio", value: "Hello world"})

    assert result =~ "Hello world"
  end

  test "renders textarea with placeholder" do
    result =
      render_component(&dm_textarea/1, %{name: "bio", value: nil, placeholder: "Tell us..."})

    assert result =~ ~s[placeholder="Tell us..."]
  end

  test "renders textarea with default rows 3" do
    result = render_component(&dm_textarea/1, %{name: "bio", value: nil})

    assert result =~ ~s[rows="3"]
  end

  test "renders textarea with custom rows" do
    result = render_component(&dm_textarea/1, %{name: "bio", value: nil, rows: 6})

    assert result =~ ~s[rows="6"]
  end

  test "renders textarea with cols" do
    result = render_component(&dm_textarea/1, %{name: "bio", value: nil, cols: 40})

    assert result =~ ~s[cols="40"]
  end

  test "renders textarea with label" do
    result = render_component(&dm_textarea/1, %{name: "bio", value: nil, label: "Biography"})

    assert result =~ "Biography"
    assert result =~ "form-label"
  end

  test "renders textarea without label when not provided" do
    result = render_component(&dm_textarea/1, %{name: "bio", value: nil})

    refute result =~ "form-label"
  end

  test "renders textarea with default color primary" do
    result = render_component(&dm_textarea/1, %{name: "bio", value: nil})

    assert result =~ "textarea-primary"
  end

  test "renders textarea with all color options" do
    for color <- ~w(primary secondary accent info success warning error) do
      result = render_component(&dm_textarea/1, %{name: "bio", value: nil, color: color})
      assert result =~ "textarea-#{color}"
    end
  end

  test "renders textarea with default size md" do
    result = render_component(&dm_textarea/1, %{name: "bio", value: nil})

    assert result =~ "textarea-md"
  end

  test "renders textarea with all size options" do
    for size <- ~w(xs sm md lg) do
      result = render_component(&dm_textarea/1, %{name: "bio", value: nil, size: size})
      assert result =~ "textarea-#{size}"
    end
  end

  test "renders textarea with default resize vertical" do
    result = render_component(&dm_textarea/1, %{name: "bio", value: nil})

    assert result =~ "textarea-resize-vertical"
  end

  test "renders textarea with all resize options" do
    resize_map = %{
      "none" => "textarea-resize-none",
      "vertical" => "textarea-resize-vertical",
      "horizontal" => "resize-x",
      "both" => "resize"
    }

    for {resize, class} <- resize_map do
      result = render_component(&dm_textarea/1, %{name: "bio", value: nil, resize: resize})
      assert result =~ class
    end
  end

  test "renders disabled textarea" do
    result = render_component(&dm_textarea/1, %{name: "bio", value: nil, disabled: true})

    assert result =~ "disabled"
    assert result =~ "opacity-50"
  end

  test "renders readonly textarea" do
    result = render_component(&dm_textarea/1, %{name: "bio", value: nil, readonly: true})

    assert result =~ "readonly"
  end

  test "renders required textarea" do
    result = render_component(&dm_textarea/1, %{name: "bio", value: nil, required: true})

    assert result =~ "required"
  end

  test "renders textarea with maxlength" do
    result = render_component(&dm_textarea/1, %{name: "bio", value: nil, maxlength: 500})

    assert result =~ ~s[maxlength="500"]
  end

  test "renders textarea with custom id" do
    result = render_component(&dm_textarea/1, %{name: "bio", value: nil, id: "my-textarea"})

    assert result =~ ~s[id="my-textarea"]
  end

  test "renders textarea with form-group wrapper" do
    result = render_component(&dm_textarea/1, %{name: "bio", value: nil})

    assert result =~ "form-group"
  end

  test "renders textarea with custom class" do
    result = render_component(&dm_textarea/1, %{name: "bio", value: nil, class: "my-wrapper"})

    assert result =~ "my-wrapper"
  end

  test "renders textarea with textarea_class" do
    result =
      render_component(&dm_textarea/1, %{
        name: "bio",
        value: nil,
        textarea_class: "custom-textarea"
      })

    assert result =~ "custom-textarea"
  end

  test "renders textarea with label_class" do
    result =
      render_component(&dm_textarea/1, %{
        name: "bio",
        value: nil,
        label: "Bio",
        label_class: "custom-label"
      })

    assert result =~ "custom-label"
  end

  test "renders textarea with rest attributes" do
    result =
      render_component(&dm_textarea/1, %{
        name: "bio",
        value: nil,
        "data-testid": "bio-field"
      })

    assert result =~ ~s[data-testid="bio-field"]
  end

  test "renders textarea label for attribute matches textarea id" do
    result =
      render_component(&dm_textarea/1, %{
        name: "bio",
        value: nil,
        id: "bio-id",
        label: "Bio"
      })

    assert result =~ ~s[for="bio-id"]
    assert result =~ ~s[id="bio-id"]
  end

  test "renders textarea with all attributes combined" do
    result =
      render_component(&dm_textarea/1, %{
        name: "notes",
        id: "notes-area",
        value: "Hello",
        label: "Notes",
        label_class: "text-sm",
        textarea_class: "border-2",
        class: "wrapper",
        placeholder: "Enter notes...",
        rows: 8,
        cols: 60,
        size: "lg",
        color: "success",
        resize: "both",
        disabled: true,
        readonly: true,
        required: true,
        maxlength: 1000,
        "data-testid": "notes"
      })

    assert result =~ ~s[id="notes-area"]
    assert result =~ ~s[name="notes"]
    assert result =~ "Hello"
    assert result =~ "Notes"
    assert result =~ "text-sm"
    assert result =~ "border-2"
    assert result =~ "wrapper"
    assert result =~ ~s[placeholder="Enter notes..."]
    assert result =~ ~s[rows="8"]
    assert result =~ ~s[cols="60"]
    assert result =~ "textarea-lg"
    assert result =~ "textarea-success"
    assert result =~ "resize"
    assert result =~ "disabled"
    assert result =~ "readonly"
    assert result =~ "required"
    assert result =~ ~s[maxlength="1000"]
  end

  describe "FormField integration" do
    test "renders textarea with form field using field id and name" do
      field = Phoenix.Component.to_form(%{"bio" => "My bio text"}, as: "user")[:bio]

      result = render_component(&dm_textarea/1, %{field: field})

      assert result =~ ~s[id="user_bio"]
      assert result =~ ~s(name="user[bio]")
      assert result =~ "My bio text"
    end

    test "renders textarea with field value nil" do
      field = Phoenix.Component.to_form(%{"bio" => ""}, as: "user")[:bio]

      result = render_component(&dm_textarea/1, %{field: field})

      assert result =~ ~s[id="user_bio"]
      assert result =~ "<textarea"
    end

    test "renders textarea with custom id overriding field id" do
      field = Phoenix.Component.to_form(%{"bio" => ""}, as: "user")[:bio]

      result = render_component(&dm_textarea/1, %{field: field, id: "custom-area"})

      assert result =~ ~s[id="custom-area"]
    end

    test "renders textarea with field and styling combined" do
      field = Phoenix.Component.to_form(%{"bio" => ""}, as: "user")[:bio]

      result =
        render_component(&dm_textarea/1, %{
          field: field,
          label: "Biography",
          color: "warning",
          size: "lg",
          rows: 10,
          resize: "none"
        })

      assert result =~ "Biography"
      assert result =~ "textarea-warning"
      assert result =~ "textarea-lg"
      assert result =~ ~s[rows="10"]
      assert result =~ "textarea-resize-none"
    end
  end

  test "renders textarea with aria-invalid and error messages when errors present" do
    result =
      render_component(&dm_textarea/1, %{
        name: "bio",
        id: "bio-textarea",
        value: nil,
        errors: ["is too short"]
      })

    assert result =~ ~s[aria-invalid="true"]
    assert result =~ ~s[aria-describedby="bio-textarea-errors"]
    assert result =~ ~s[id="bio-textarea-errors"]
    assert result =~ "is too short"
  end

  test "renders textarea without aria-invalid when no errors" do
    result =
      render_component(&dm_textarea/1, %{
        name: "bio",
        id: "bio-textarea",
        value: nil
      })

    refute result =~ "aria-invalid"
    refute result =~ "aria-describedby"
  end
end
