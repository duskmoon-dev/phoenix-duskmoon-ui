defmodule PhoenixDuskmoon.ArtComponent.FlowerAnimationTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.ArtComponent.FlowerAnimation

  test "renders el-dm-art-flower-animation custom element" do
    result = render_component(&dm_art_flower_animation/1, %{id: "flower-1"})

    assert result =~ "<el-dm-art-flower-animation"
    assert result =~ ~s[id="flower-1"]
  end

  test "renders with custom class" do
    result = render_component(&dm_art_flower_animation/1, %{id: "f", class: "mx-auto"})

    assert result =~ "mx-auto"
  end

  test "renders with rest attributes" do
    result =
      render_component(&dm_art_flower_animation/1, %{
        id: "f",
        "data-testid": "my-flower"
      })

    assert result =~ "data-testid=\"my-flower\""
  end
end
