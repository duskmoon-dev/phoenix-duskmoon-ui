defmodule PhoenixDuskmoon.Component.Fun.PlasmaBallTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Fun.PlasmaBall

  test "renders plasma ball with required id" do
    result = render_component(&dm_fun_plasma_ball/1, %{id: "plasma-1"})

    assert result =~ "dm-fun-plasma-ball"
    assert result =~ ~s[id="plasma-1"]
  end

  test "renders plasma ball with glass ball structure" do
    result = render_component(&dm_fun_plasma_ball/1, %{id: "plasma-2"})

    assert result =~ "glassball"
    assert result =~ "electrode"
    assert result =~ "rays"
  end

  test "renders plasma ball with base structure" do
    result = render_component(&dm_fun_plasma_ball/1, %{id: "plasma-3"})

    assert result =~ ~s[class="base"]
  end

  test "renders plasma ball with switch toggle" do
    result = render_component(&dm_fun_plasma_ball/1, %{id: "plasma-4"})

    assert result =~ ~s[class="switcher"]
    assert result =~ ~s[type="checkbox"]
    assert result =~ ~s[class="switch"]
  end

  test "renders plasma ball with small size" do
    result = render_component(&dm_fun_plasma_ball/1, %{id: "plasma-5", size: "small"})

    assert result =~ "dm-fun-plasma-ball"
  end

  test "renders plasma ball with large size" do
    result = render_component(&dm_fun_plasma_ball/1, %{id: "plasma-6", size: "large"})

    assert result =~ "dm-fun-plasma-ball"
  end

  test "renders plasma ball with custom base_color" do
    result = render_component(&dm_fun_plasma_ball/1, %{id: "plasma-7", base_color: "#1a1a2e"})

    assert result =~ "dm-fun-plasma-ball"
  end

  test "renders plasma ball with electrode visible by default" do
    result = render_component(&dm_fun_plasma_ball/1, %{id: "plasma-8"})

    assert result =~ "electrode"
    refute result =~ "hide-electrode"
  end

  test "renders plasma ball without electrode when show_electrode is false" do
    result = render_component(&dm_fun_plasma_ball/1, %{id: "plasma-9", show_electrode: false})

    assert result =~ "hide-electrode"
  end

  test "renders plasma ball with phx-click event" do
    result = render_component(&dm_fun_plasma_ball/1, %{id: "plasma-10"})

    assert result =~ ~s[phx-click="plasma_toggle"]
  end

  test "renders plasma ball with custom class" do
    result = render_component(&dm_fun_plasma_ball/1, %{id: "plasma-11", class: "my-plasma"})

    assert result =~ "my-plasma"
    assert result =~ "dm-fun-plasma-ball"
  end

  test "renders plasma ball with multiple ray groups" do
    result = render_component(&dm_fun_plasma_ball/1, %{id: "plasma-12"})

    assert result =~ "bigwave"
  end

  test "renders plasma ball with rest attributes" do
    result =
      render_component(&dm_fun_plasma_ball/1, %{
        id: "plasma-13",
        "data-testid": "my-plasma",
        "aria-label": "Plasma ball effect"
      })

    assert result =~ "data-testid=\"my-plasma\""
    assert result =~ "aria-label=\"Plasma ball effect\""
  end
end
