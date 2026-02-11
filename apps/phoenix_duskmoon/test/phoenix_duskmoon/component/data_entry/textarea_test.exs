defmodule PhoenixDuskmoon.Component.DataEntry.TextareaTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataEntry.Textarea

  test "renders basic textarea element" do
    result = render_component(&dm_textarea/1, %{name: "bio", value: nil})

    assert result =~ "<textarea"
    assert result =~ "dm-textarea"
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
    assert result =~ "dm-label__text"
    assert result =~ "dm-label"
  end

  test "renders textarea without label when not provided" do
    result = render_component(&dm_textarea/1, %{name: "bio", value: nil})

    refute result =~ "dm-label__text"
  end

  test "renders textarea with default color primary" do
    result = render_component(&dm_textarea/1, %{name: "bio", value: nil})

    assert result =~ "dm-textarea--primary"
  end

  test "renders textarea with all color options" do
    for color <- ~w(primary secondary accent info success warning error) do
      result = render_component(&dm_textarea/1, %{name: "bio", value: nil, color: color})
      assert result =~ "dm-textarea--#{color}"
    end
  end

  test "renders textarea with default size md" do
    result = render_component(&dm_textarea/1, %{name: "bio", value: nil})

    assert result =~ "dm-textarea--md"
  end

  test "renders textarea with all size options" do
    for size <- ~w(xs sm md lg) do
      result = render_component(&dm_textarea/1, %{name: "bio", value: nil, size: size})
      assert result =~ "dm-textarea--#{size}"
    end
  end

  test "renders textarea with default resize vertical" do
    result = render_component(&dm_textarea/1, %{name: "bio", value: nil})

    assert result =~ "dm-textarea--resize-y"
  end

  test "renders textarea with all resize options" do
    resize_map = %{
      "none" => "dm-textarea--resize-none",
      "vertical" => "dm-textarea--resize-y",
      "horizontal" => "dm-textarea--resize-x",
      "both" => "dm-textarea--resize-both"
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

  test "renders textarea with dm-form-group wrapper" do
    result = render_component(&dm_textarea/1, %{name: "bio", value: nil})

    assert result =~ "dm-form-group"
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

    assert result =~ "data-testid=\"bio-field\""
  end
end
