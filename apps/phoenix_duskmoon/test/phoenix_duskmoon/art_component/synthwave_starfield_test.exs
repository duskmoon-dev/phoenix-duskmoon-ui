defmodule PhoenixDuskmoon.ArtComponent.SynthwaveStarfieldTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.ArtComponent.SynthwaveStarfield

  test "renders el-dm-art-synthwave-starfield custom element" do
    result = render_component(&dm_art_synthwave_starfield/1, %{id: "starfield-1"})

    assert result =~ "<el-dm-art-synthwave-starfield"
    assert result =~ ~s[id="starfield-1"]
  end

  test "renders with custom class" do
    result = render_component(&dm_art_synthwave_starfield/1, %{id: "s", class: "w-full"})

    assert result =~ "w-full"
  end

  test "renders with rest attributes" do
    result =
      render_component(&dm_art_synthwave_starfield/1, %{
        id: "s",
        "data-testid": "my-starfield"
      })

    assert result =~ "data-testid=\"my-starfield\""
  end
end
