defmodule PhoenixDuskmoon.ArtComponent.EclipseTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.ArtComponent.Eclipse

  test "renders el-dm-art-eclipse custom element" do
    result = render_component(&dm_art_eclipse/1, %{id: "eclipse-1"})

    assert result =~ "<el-dm-art-eclipse"
    assert result =~ ~s[id="eclipse-1"]
  end

  test "renders with custom class" do
    result = render_component(&dm_art_eclipse/1, %{id: "e", class: "mx-auto"})

    assert result =~ "mx-auto"
  end

  test "renders with rest attributes" do
    result =
      render_component(&dm_art_eclipse/1, %{
        id: "e",
        "data-testid": "my-eclipse"
      })

    assert result =~ "data-testid=\"my-eclipse\""
  end
end
