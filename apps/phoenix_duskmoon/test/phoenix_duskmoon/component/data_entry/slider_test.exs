defmodule PhoenixDuskmoon.Component.DataEntry.SliderTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataEntry.Slider

  test "renders basic slider" do
    result = render_component(&dm_slider/1, %{name: "vol", value: nil})

    assert result =~ ~s[type="range"]
    assert result =~ "dm-range"
  end

  test "renders slider with min, max, step" do
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

  test "renders slider with color" do
    result = render_component(&dm_slider/1, %{name: "vol", value: nil, color: "success"})

    assert result =~ "dm-range--success"
  end

  test "renders slider with label" do
    result = render_component(&dm_slider/1, %{name: "vol", value: nil, label: "Volume"})

    assert result =~ "Volume"
  end

  test "renders disabled slider" do
    result = render_component(&dm_slider/1, %{name: "vol", value: nil, disabled: true})

    assert result =~ "disabled"
  end
end
