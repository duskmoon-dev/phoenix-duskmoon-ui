defmodule PhoenixDuskmoon.ArtComponent.MoonTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.ArtComponent.Moon

  test "renders el-dm-art-moon custom element" do
    result = render_component(&dm_art_moon/1, %{id: "moon-1"})

    assert result =~ "<el-dm-art-moon"
    assert result =~ ~s[id="moon-1"]
  end

  test "renders with custom class" do
    result = render_component(&dm_art_moon/1, %{id: "m", class: "mx-auto"})

    assert result =~ "mx-auto"
  end

  test "renders with rest attributes" do
    result =
      render_component(&dm_art_moon/1, %{
        id: "m",
        "data-testid": "my-moon"
      })

    assert result =~ "data-testid=\"my-moon\""
  end
end
