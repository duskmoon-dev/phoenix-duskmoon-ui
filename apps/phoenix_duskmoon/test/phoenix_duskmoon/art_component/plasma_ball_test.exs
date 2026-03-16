defmodule PhoenixDuskmoon.ArtComponent.PlasmaBallTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.ArtComponent.PlasmaBall

  test "renders el-dm-art-plasma-ball custom element" do
    result = render_component(&dm_art_plasma_ball/1, %{id: "plasma-1"})

    assert result =~ "<el-dm-art-plasma-ball"
    assert result =~ ~s[id="plasma-1"]
  end

  test "renders with custom class" do
    result = render_component(&dm_art_plasma_ball/1, %{id: "p", class: "mx-auto"})

    assert result =~ "mx-auto"
  end

  test "renders with rest attributes" do
    result =
      render_component(&dm_art_plasma_ball/1, %{
        id: "p",
        "data-testid": "my-plasma"
      })

    assert result =~ "data-testid=\"my-plasma\""
  end
end
