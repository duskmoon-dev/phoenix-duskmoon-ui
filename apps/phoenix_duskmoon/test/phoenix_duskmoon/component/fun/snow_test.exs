defmodule PhoenixDuskmoon.Component.Fun.SnowTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Fun.Snow

  test "renders snow component with required id" do
    result = render_component(&dm_fun_snow/1, %{id: "snow-1"})

    assert result =~ ~s[id="snow-1"]
  end

  test "renders default 30 snowflakes" do
    result = render_component(&dm_fun_snow/1, %{id: "snow-2"})

    # Count snowflake-size CSS variable occurrences (one per snowflake div)
    count = length(String.split(result, "--snowflake-size")) - 1
    assert count == 30
  end

  test "renders custom number of snowflakes" do
    result = render_component(&dm_fun_snow/1, %{id: "snow-3", count: 10})

    count = length(String.split(result, "--snowflake-size")) - 1
    assert count == 10
  end

  test "renders snow with default white color" do
    result = render_component(&dm_fun_snow/1, %{id: "snow-4"})

    assert result =~ "#FFFFFF"
  end

  test "renders snow with custom color" do
    result = render_component(&dm_fun_snow/1, %{id: "snow-5", color: "#AACCFF"})

    assert result =~ "#AACCFF"
  end

  test "renders snow with unicode class when use_unicode is true" do
    result = render_component(&dm_fun_snow/1, %{id: "snow-6", use_unicode: true})

    assert result =~ "snowflake-unicode"
  end

  test "renders snow without unicode class by default" do
    result = render_component(&dm_fun_snow/1, %{id: "snow-7"})

    refute result =~ "snowflake-unicode"
  end

  test "renders snow with default container class" do
    result = render_component(&dm_fun_snow/1, %{id: "snow-8"})

    assert result =~ "relative w-full h-full"
    assert result =~ "overflow-hidden"
  end

  test "renders snow with custom container class" do
    result =
      render_component(&dm_fun_snow/1, %{
        id: "snow-9",
        container_class: "h-screen relative"
      })

    assert result =~ "h-screen relative"
  end

  test "renders snow with snowfall animation keyframes" do
    result = render_component(&dm_fun_snow/1, %{id: "snow-10"})

    assert result =~ "<style>"
    assert result =~ "@keyframes snowfall"
    assert result =~ "dm-fun-snowflake"
  end

  test "renders snow with custom snowflake class" do
    result =
      render_component(&dm_fun_snow/1, %{
        id: "snow-11",
        snowflake_class: "sparkle"
      })

    assert result =~ "sparkle"
  end

  test "renders snow with rest attributes" do
    result =
      render_component(&dm_fun_snow/1, %{
        id: "snow-12",
        "data-testid": "winter-effect"
      })

    assert result =~ "data-testid=\"winter-effect\""
  end
end
