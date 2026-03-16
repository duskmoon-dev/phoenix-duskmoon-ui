defmodule PhoenixDuskmoon.ArtComponent.CircularGalleryTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.ArtComponent.CircularGallery

  test "renders el-dm-art-circular-gallery custom element" do
    result = render_component(&dm_art_circular_gallery/1, %{id: "gallery-1"})

    assert result =~ "<el-dm-art-circular-gallery"
    assert result =~ ~s[id="gallery-1"]
  end

  test "renders with custom class" do
    result = render_component(&dm_art_circular_gallery/1, %{id: "g", class: "mx-auto"})

    assert result =~ "mx-auto"
  end

  test "renders with rest attributes" do
    result =
      render_component(&dm_art_circular_gallery/1, %{
        id: "g",
        "data-testid": "my-gallery"
      })

    assert result =~ "data-testid=\"my-gallery\""
  end
end
