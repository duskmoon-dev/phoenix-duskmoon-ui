defmodule PhoenixDuskmoon.ArtComponent.SnowTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.ArtComponent.Snow

  test "renders el-dm-art-snow custom element" do
    result = render_component(&dm_art_snow/1, %{id: "snow-1"})

    assert result =~ "<el-dm-art-snow"
    assert result =~ ~s[id="snow-1"]
  end

  test "renders with custom class" do
    result = render_component(&dm_art_snow/1, %{id: "s", class: "h-screen"})

    assert result =~ "h-screen"
  end

  test "renders with rest attributes" do
    result =
      render_component(&dm_art_snow/1, %{
        id: "s",
        "data-testid": "my-snow"
      })

    assert result =~ "data-testid=\"my-snow\""
  end
end
