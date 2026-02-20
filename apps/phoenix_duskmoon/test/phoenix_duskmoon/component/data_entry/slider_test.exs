defmodule PhoenixDuskmoon.Component.DataEntry.SliderTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataEntry.Slider

  test "renders basic slider as range input" do
    result = render_component(&dm_slider/1, %{name: "vol", value: nil})

    assert result =~ ~s[type="range"]
    assert result =~ "slider"
  end

  test "renders slider with name" do
    result = render_component(&dm_slider/1, %{name: "volume", value: nil})

    assert result =~ ~s[name="volume"]
  end

  test "renders slider with default min 0 and max 100" do
    result = render_component(&dm_slider/1, %{name: "vol", value: nil})

    assert result =~ ~s[min="0"]
    assert result =~ ~s[max="100"]
  end

  test "renders slider with custom min, max, step" do
    result =
      render_component(&dm_slider/1, %{name: "vol", value: nil, min: 10, max: 200, step: 5})

    assert result =~ ~s[min="10"]
    assert result =~ ~s[max="200"]
    assert result =~ ~s[step="5"]
  end

  test "renders slider with value" do
    result = render_component(&dm_slider/1, %{name: "vol", value: 50})

    assert result =~ ~s[value="50"]
  end

  test "renders slider with custom id" do
    result = render_component(&dm_slider/1, %{name: "vol", value: nil, id: "my-slider"})

    assert result =~ ~s[id="my-slider"]
  end

  test "renders slider with label" do
    result = render_component(&dm_slider/1, %{name: "vol", value: nil, label: "Volume"})

    assert result =~ "Volume"
    assert result =~ "form-label"
  end

  test "renders slider without label when not provided" do
    result = render_component(&dm_slider/1, %{name: "vol", value: nil})

    refute result =~ "form-label"
  end

  test "renders slider with default color primary" do
    result = render_component(&dm_slider/1, %{name: "vol", value: nil})

    assert result =~ "slider-primary"
  end

  test "renders slider with all color options" do
    for color <- ~w(primary secondary accent info success warning error) do
      result = render_component(&dm_slider/1, %{name: "vol", value: nil, color: color})
      css_class = if color == "accent", do: "tertiary", else: color
      assert result =~ "slider-#{css_class}"
    end
  end

  test "renders slider with default size md" do
    result = render_component(&dm_slider/1, %{name: "vol", value: nil})

    assert result =~ "slider-md"
  end

  test "renders slider with all size options" do
    for size <- ~w(xs sm md lg) do
      result = render_component(&dm_slider/1, %{name: "vol", value: nil, size: size})
      assert result =~ "slider-#{size}"
    end
  end

  test "renders disabled slider" do
    result = render_component(&dm_slider/1, %{name: "vol", value: nil, disabled: true})

    assert result =~ "disabled"
    assert result =~ "opacity-50"
  end

  test "renders slider with show_value enabled by default" do
    result = render_component(&dm_slider/1, %{name: "vol", value: 75, label: "Volume"})

    # show_value is true by default — shows value display and min/max labels
    assert result =~ "75"
  end

  test "renders slider with form-group wrapper" do
    result = render_component(&dm_slider/1, %{name: "vol", value: nil})

    assert result =~ "form-group"
  end

  test "renders slider with slider_class" do
    result =
      render_component(&dm_slider/1, %{name: "vol", value: nil, slider_class: "custom-range"})

    assert result =~ "custom-range"
  end

  test "renders slider with show_value false hides value display" do
    result =
      render_component(&dm_slider/1, %{
        name: "vol",
        value: 75,
        label: "Volume",
        show_value: false
      })

    # Label still renders
    assert result =~ "Volume"
    # Min/max labels should not render
    refute result =~ "flex justify-between text-xs"
  end

  test "renders slider with custom wrapper class" do
    result =
      render_component(&dm_slider/1, %{name: "vol", value: nil, class: "my-wrapper"})

    assert result =~ "my-wrapper"
    assert result =~ "form-group"
  end

  test "renders slider with label_class" do
    result =
      render_component(&dm_slider/1, %{
        name: "vol",
        value: nil,
        label: "Volume",
        label_class: "text-lg"
      })

    assert result =~ "text-lg"
  end

  test "renders slider with rest attributes" do
    result =
      render_component(&dm_slider/1, %{
        name: "vol",
        value: nil,
        "data-testid": "volume-slider",
        "aria-label": "Volume control"
      })

    assert result =~ "data-testid=\"volume-slider\""
    assert result =~ "aria-label=\"Volume control\""
  end

  test "renders min and max labels when show_value is true" do
    result =
      render_component(&dm_slider/1, %{name: "vol", value: 50, min: 10, max: 200})

    # Min and max labels should show the range endpoints
    assert result =~ ">10</span>"
    assert result =~ ">200</span>"
  end

  test "renders value display next to label when show_value is true" do
    result =
      render_component(&dm_slider/1, %{name: "vol", value: 42, label: "Volume"})

    assert result =~ "Volume"
    assert result =~ "42"
  end

  test "renders slider with default step 1" do
    result = render_component(&dm_slider/1, %{name: "vol", value: nil})

    assert result =~ ~s[step="1"]
  end

  test "renders slider with boundary value 0" do
    result = render_component(&dm_slider/1, %{name: "vol", value: 0})

    assert result =~ ~s[value="0"]
  end

  test "renders slider with value at max boundary" do
    result = render_component(&dm_slider/1, %{name: "vol", value: 100, max: 100})

    assert result =~ ~s[value="100"]
    assert result =~ ~s[max="100"]
  end

  test "renders label with for attribute when id provided" do
    result =
      render_component(&dm_slider/1, %{
        name: "vol",
        value: nil,
        id: "vol-slider",
        label: "Volume"
      })

    assert result =~ ~s[for="vol-slider"]
  end

  test "renders slider with aria-invalid and error messages when errors present" do
    result =
      render_component(&dm_slider/1, %{
        name: "volume",
        id: "vol-slider",
        value: 50,
        errors: ["is out of range"]
      })

    assert result =~ ~s[aria-invalid="true"]
    assert result =~ ~s[aria-describedby="vol-slider-errors"]
    assert result =~ ~s[id="vol-slider-errors"]
    assert result =~ "is out of range"
  end

  test "renders slider without aria-invalid when no errors" do
    result =
      render_component(&dm_slider/1, %{
        name: "volume",
        id: "vol-slider",
        value: 50
      })

    refute result =~ "aria-invalid"
    refute result =~ "aria-describedby"
  end

  test "renders slider with range input type" do
    result =
      render_component(&dm_slider/1, %{
        name: "volume",
        value: 50
      })

    assert result =~ ~s[type="range"]
  end

  test "renders slider with slider class on input" do
    result =
      render_component(&dm_slider/1, %{
        name: "range",
        value: 0
      })

    assert result =~ "slider"
  end

  describe "FormField integration" do
    test "renders slider with form field using field id and name" do
      field = Phoenix.Component.to_form(%{"volume" => "50"}, as: "settings")[:volume]

      result = render_component(&dm_slider/1, %{field: field})

      assert result =~ ~s[id="settings_volume"]
      assert result =~ ~s(name="settings[volume]")
    end

    test "renders slider with field value" do
      field = Phoenix.Component.to_form(%{"volume" => "75"}, as: "settings")[:volume]

      result = render_component(&dm_slider/1, %{field: field})

      assert result =~ ~s[value="75"]
    end

    test "renders slider with field value falling back to min when nil" do
      field = Phoenix.Component.to_form(%{"volume" => nil}, as: "settings")[:volume]

      result = render_component(&dm_slider/1, %{field: field, min: 10})

      assert result =~ ~s[value="10"]
    end

    test "renders slider with field value of zero without falling back to min" do
      field = Phoenix.Component.to_form(%{"volume" => 0}, as: "settings")[:volume]

      result = render_component(&dm_slider/1, %{field: field, min: 10})

      assert result =~ ~s[value="0"]
      refute result =~ ~s[value="10"]
    end

    test "renders slider with custom id overriding field id" do
      field = Phoenix.Component.to_form(%{"volume" => ""}, as: "settings")[:volume]

      result = render_component(&dm_slider/1, %{field: field, id: "custom-slider"})

      assert result =~ ~s[id="custom-slider"]
    end

    test "renders slider with field and styling combined" do
      field = Phoenix.Component.to_form(%{"brightness" => "80"}, as: "display")[:brightness]

      result =
        render_component(&dm_slider/1, %{
          field: field,
          label: "Brightness",
          color: "warning",
          size: "lg",
          min: 0,
          max: 100,
          step: 5
        })

      assert result =~ "Brightness"
      assert result =~ "slider-warning"
      assert result =~ "slider-lg"
      assert result =~ ~s[step="5"]
    end
  end

  test "renders slider with all options combined" do
    result =
      render_component(&dm_slider/1, %{
        name: "vol",
        id: "vol-slider",
        value: 60,
        label: "Volume",
        label_class: "text-lg",
        slider_class: "border-2",
        class: "wrapper",
        min: 10,
        max: 200,
        step: 5,
        size: "lg",
        color: "error",
        show_value: true,
        disabled: true,
        errors: ["out of range"],
        "data-testid": "slider"
      })

    assert result =~ ~s[id="vol-slider"]
    assert result =~ ~s[name="vol"]
    assert result =~ ~s[value="60"]
    assert result =~ "Volume"
    assert result =~ "text-lg"
    assert result =~ "border-2"
    assert result =~ "wrapper"
    assert result =~ ~s[min="10"]
    assert result =~ ~s[max="200"]
    assert result =~ ~s[step="5"]
    assert result =~ "slider-lg"
    assert result =~ "slider-error"
    assert result =~ "disabled"
    assert result =~ "out of range"
    assert result =~ ~s[aria-invalid="true"]
    assert result =~ ~s[data-testid="slider"]
  end

  test "renders slider with multiple errors" do
    result =
      render_component(&dm_slider/1, %{
        name: "vol",
        id: "vol",
        value: 50,
        errors: ["is too low", "must be a multiple of 5"]
      })

    assert result =~ "is too low"
    assert result =~ "must be a multiple of 5"
  end

  test "renders vertical slider" do
    result =
      render_component(&dm_slider/1, %{
        name: "vol",
        value: 50,
        vertical: true
      })

    assert result =~ "slider-vertical"
  end

  test "renders horizontal slider by default (no vertical class)" do
    result =
      render_component(&dm_slider/1, %{
        name: "vol",
        value: 50
      })

    refute result =~ "slider-vertical"
  end

  test "renders vertical slider with color and size" do
    result =
      render_component(&dm_slider/1, %{
        name: "vol",
        value: 30,
        vertical: true,
        color: "success",
        size: "lg"
      })

    assert result =~ "slider-vertical"
    assert result =~ "slider-success"
    assert result =~ "slider-lg"
  end
end
