defmodule PhoenixDuskmoon.ArtComponent.SunTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.ArtComponent.Sun

  test "renders el-dm-art-sun custom element" do
    result = render_component(&dm_art_sun/1, %{id: "sun-1"})

    assert result =~ "<el-dm-art-sun"
    assert result =~ ~s[id="sun-1"]
  end

  test "renders with custom class" do
    result = render_component(&dm_art_sun/1, %{id: "s", class: "mx-auto"})

    assert result =~ "mx-auto"
  end

  test "renders with rest attributes" do
    result =
      render_component(&dm_art_sun/1, %{
        id: "s",
        "data-testid": "my-sun"
      })

    assert result =~ "data-testid=\"my-sun\""
  end
end
