defmodule PhoenixDuskmoon.ArtComponent.ColorSpinTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.ArtComponent.ColorSpin

  test "renders el-dm-art-color-spin custom element" do
    result = render_component(&dm_art_color_spin/1, %{id: "spin-1"})

    assert result =~ "<el-dm-art-color-spin"
    assert result =~ ~s[id="spin-1"]
  end

  test "renders with custom class" do
    result = render_component(&dm_art_color_spin/1, %{id: "s", class: "mx-auto"})

    assert result =~ "mx-auto"
  end

  test "renders with rest attributes" do
    result =
      render_component(&dm_art_color_spin/1, %{
        id: "s",
        "data-testid": "my-spin"
      })

    assert result =~ "data-testid=\"my-spin\""
  end
end
