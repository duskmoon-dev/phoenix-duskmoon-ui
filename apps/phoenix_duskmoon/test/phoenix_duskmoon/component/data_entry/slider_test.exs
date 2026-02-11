defmodule PhoenixDuskmoon.Component.DataEntry.SliderTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataEntry.Slider

  test "renders basic slider as range input" do
    result = render_component(&dm_slider/1, %{name: "vol", value: nil})

    assert result =~ ~s[type="range"]
    assert result =~ "dm-range"
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
    assert result =~ "dm-label__text"
  end

  test "renders slider without label when not provided" do
    result = render_component(&dm_slider/1, %{name: "vol", value: nil})

    refute result =~ "dm-label__text"
  end

  test "renders slider with default color primary" do
    result = render_component(&dm_slider/1, %{name: "vol", value: nil})

    assert result =~ "dm-range--primary"
  end

  test "renders slider with all color options" do
    for color <- ~w(primary secondary accent info success warning error) do
      result = render_component(&dm_slider/1, %{name: "vol", value: nil, color: color})
      assert result =~ "dm-range--#{color}"
    end
  end

  test "renders slider with default size md" do
    result = render_component(&dm_slider/1, %{name: "vol", value: nil})

    assert result =~ "dm-range--md"
  end

  test "renders slider with all size options" do
    for size <- ~w(xs sm md lg) do
      result = render_component(&dm_slider/1, %{name: "vol", value: nil, size: size})
      assert result =~ "dm-range--#{size}"
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

  test "renders slider with dm-form-group wrapper" do
    result = render_component(&dm_slider/1, %{name: "vol", value: nil})

    assert result =~ "dm-form-group"
  end

  test "renders slider with slider_class" do
    result =
      render_component(&dm_slider/1, %{name: "vol", value: nil, slider_class: "custom-range"})

    assert result =~ "custom-range"
  end
end
