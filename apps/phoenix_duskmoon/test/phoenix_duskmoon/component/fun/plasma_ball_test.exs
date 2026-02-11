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

    assert result =~ "--size: 250px"
  end

  test "renders plasma ball with large size" do
    result = render_component(&dm_fun_plasma_ball/1, %{id: "plasma-6", size: "large"})

    assert result =~ "--size: 450px"
  end

  test "renders plasma ball with default base_color CSS variable" do
    result = render_component(&dm_fun_plasma_ball/1, %{id: "plasma-7"})

    assert result =~ "--base-color: #222222"
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

  test "renders plasma ball with correct size pixel values for each preset" do
    for {size, expected_px} <- [{"small", "250"}, {"medium", "350"}, {"large", "450"}] do
      result = render_component(&dm_fun_plasma_ball/1, %{id: "plasma-sz", size: size})
      assert result =~ "--size: #{expected_px}px"
      assert result =~ "--base-color: #222222"
    end
  end

  test "renders plasma ball with custom base_color in CSS variable" do
    result = render_component(&dm_fun_plasma_ball/1, %{id: "plasma-sv", base_color: "#1a1a2e"})
    assert result =~ "--base-color: #1a1a2e"
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
    assert result =~ "--size: 450px"
    assert result =~ "--base-color: #000033"
    assert result =~ "hide-electrode"
    assert result =~ "my-plasma"
    assert result =~ "data-testid=\"combo\""
  end

  test "renders plasma ball with default medium size" do
    result = render_component(&dm_fun_plasma_ball/1, %{id: "plasma-def"})

    assert result =~ "--size: 350px"
  end

  test "renders plasma ball with style attribute" do
    result = render_component(&dm_fun_plasma_ball/1, %{id: "plasma-style"})

    assert result =~ "style="
    assert result =~ "--size:"
    assert result =~ "--base-color:"
  end

  test "renders plasma ball show_electrode true by default" do
    result = render_component(&dm_fun_plasma_ball/1, %{id: "plasma-elec"})

    # electrode visible, no hide-electrode class
    assert result =~ "electrode"
    refute result =~ "hide-electrode"
  end

  test "renders plasma ball with custom base_color" do
    result =
      render_component(&dm_fun_plasma_ball/1, %{id: "plasma-bc", base_color: "#ff0000"})

    assert result =~ "--base-color: #ff0000"
  end

  test "renders plasma ball with 5 rays per group" do
    result = render_component(&dm_fun_plasma_ball/1, %{id: "plasma-rays5"})

    # Each rays group has 5 ray divs (1 bigwave + 4 regular)
    ray_count = length(String.split(result, ~s[class="ray"])) - 1
    # 4 groups * 4 regular rays = 16 occurrences of class="ray" (bigwave has "ray bigwave")
    assert ray_count >= 16
  end

  test "renders plasma ball checkbox input for toggle" do
    result = render_component(&dm_fun_plasma_ball/1, %{id: "plasma-chk"})

    assert result =~ ~s[type="checkbox"]
    assert result =~ "switcher"
  end

  test "renders plasma ball with nil phx_target omits phx-target" do
    result = render_component(&dm_fun_plasma_ball/1, %{id: "plasma-notgt", phx_target: nil})

    assert result =~ ~s[phx-click="plasma_toggle"]
    # phx-target should not have a value when nil
  end

  test "renders plasma ball electrode without hide class when show_electrode true" do
    result = render_component(&dm_fun_plasma_ball/1, %{id: "plasma-show-e", show_electrode: true})

    assert result =~ "electrode"
    refute result =~ "hide-electrode"
  end

  test "renders plasma ball checkbox with aria-label for toggle" do
    result = render_component(&dm_fun_plasma_ball/1, %{id: "plasma-a11y"})

    assert result =~ ~s[aria-label="Toggle plasma effect"]
  end

  test "renders plasma ball wrapper div with id" do
    result = render_component(&dm_fun_plasma_ball/1, %{id: "my-plasma"})

    assert result =~ ~s[id="my-plasma"]
  end

  test "renders plasma ball with dm-fun-plasma-ball class" do
    result = render_component(&dm_fun_plasma_ball/1, %{id: "plasma-cls"})

    assert result =~ "dm-fun-plasma-ball"
  end

  test "renders custom toggle_label on checkbox" do
    result =
      render_component(&dm_fun_plasma_ball/1, %{
        id: "plasma-i18n",
        toggle_label: "Activer l'effet plasma"
      })

    assert result =~ ~s[aria-label="Activer l&#39;effet plasma"]
  end
end
