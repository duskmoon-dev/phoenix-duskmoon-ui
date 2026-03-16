defmodule PhoenixDuskmoon.ArtComponent.CatStargazerTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.ArtComponent.CatStargazer

  test "renders el-dm-art-cat-stargazer custom element" do
    result = render_component(&dm_art_cat_stargazer/1, %{id: "cat-1"})

    assert result =~ "<el-dm-art-cat-stargazer"
    assert result =~ ~s[id="cat-1"]
  end

  test "renders with custom class" do
    result = render_component(&dm_art_cat_stargazer/1, %{id: "c", class: "mx-auto"})

    assert result =~ "mx-auto"
  end

  test "renders with rest attributes" do
    result =
      render_component(&dm_art_cat_stargazer/1, %{
        id: "c",
        "data-testid": "my-cat"
      })

    assert result =~ "data-testid=\"my-cat\""
  end
end
