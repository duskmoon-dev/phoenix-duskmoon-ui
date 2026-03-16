defmodule PhoenixDuskmoon.ArtComponent.MountainTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.ArtComponent.Mountain

  test "renders el-dm-art-mountain custom element" do
    result = render_component(&dm_art_mountain/1, %{id: "mountain-1"})

    assert result =~ "<el-dm-art-mountain"
    assert result =~ ~s[id="mountain-1"]
  end

  test "renders with custom class" do
    result = render_component(&dm_art_mountain/1, %{id: "m", class: "w-full"})

    assert result =~ "w-full"
  end

  test "renders with rest attributes" do
    result =
      render_component(&dm_art_mountain/1, %{
        id: "m",
        "data-testid": "my-mountain"
      })

    assert result =~ "data-testid=\"my-mountain\""
  end
end
