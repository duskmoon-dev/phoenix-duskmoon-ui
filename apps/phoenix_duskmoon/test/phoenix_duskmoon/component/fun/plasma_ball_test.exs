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

  test "renders plasma ball with CSS variable placeholders for all sizes" do
    # PlasmaBall uses style="..." (not style={...}), so #{@var} renders literally
    for size <- ~w(small medium large) do
      result = render_component(&dm_fun_plasma_ball/1, %{id: "plasma-sz", size: size})
      assert result =~ "--size:"
      assert result =~ "--base-color:"
    end
  end

  test "renders plasma ball style attribute with size and base_color variables" do
    result = render_component(&dm_fun_plasma_ball/1, %{id: "plasma-sv"})
    assert result =~ ~s[style="--size:]
  end

  test "renders plasma ball with 4 ray groups" do
    result = render_component(&dm_fun_plasma_ball/1, %{id: "plasma-rg"})

    # Source has 4 <div class="rays"> groups
    ray_group_count = length(String.split(result, ~s[class="rays"])) - 1
    assert ray_group_count == 4
  end

  test "renders plasma ball with bigwave rays" do
    result = render_component(&dm_fun_plasma_ball/1, %{id: "plasma-rr"})

    # Each rays group has 1 bigwave ray, 4 groups = 4 bigwave rays
    bigwave_count = length(String.split(result, "ray bigwave")) - 1
    assert bigwave_count == 4
  end

  test "renders plasma ball with phx_target on container and checkbox" do
    result =
      render_component(&dm_fun_plasma_ball/1, %{
        id: "plasma-tgt",
        phx_target: "#my-component"
      })

    assert result =~ ~s[phx-target="#my-component"]
  end

  test "renders plasma ball with all attributes combined" do
    result =
      render_component(&dm_fun_plasma_ball/1, %{
        id: "plasma-all",
        size: "large",
        base_color: "#000033",
        show_electrode: false,
        class: "my-plasma",
        "data-testid": "combo"
      })

    assert result =~ ~s[id="plasma-all"]
    assert result =~ "--size:"
    assert result =~ "--base-color:"
    assert result =~ "hide-electrode"
    assert result =~ "my-plasma"
    assert result =~ "data-testid=\"combo\""
  end
end
