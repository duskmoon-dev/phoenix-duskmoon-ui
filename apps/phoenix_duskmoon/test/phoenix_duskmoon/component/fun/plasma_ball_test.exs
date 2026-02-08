defmodule PhoenixDuskmoon.Component.Fun.PlasmaBallTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Fun.PlasmaBall

  test "renders plasma ball" do
    result = render_component(&dm_fun_plasma_ball/1, %{id: "plasma-1"})

    assert result =~ "dm-fun-plasma-ball"
    assert result =~ ~s[id="plasma-1"]
  end

  test "renders plasma ball with size" do
    result = render_component(&dm_fun_plasma_ball/1, %{id: "plasma-2", size: "large"})

    assert result =~ "dm-fun-plasma-ball"
  end

  test "renders plasma ball with base color" do
    result =
      render_component(&dm_fun_plasma_ball/1, %{id: "plasma-3", base_color: "#333333"})

    assert result =~ "dm-fun-plasma-ball"
  end

  test "renders plasma ball without electrode" do
    result =
      render_component(&dm_fun_plasma_ball/1, %{id: "plasma-4", show_electrode: false})

    assert result =~ "dm-fun-plasma-ball"
  end
end
