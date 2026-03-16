defmodule PhoenixDuskmoon.ArtComponent.AtomTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.ArtComponent.Atom

  test "renders el-dm-art-atom custom element" do
    result = render_component(&dm_art_atom/1, %{id: "atom-1"})

    assert result =~ "<el-dm-art-atom"
    assert result =~ ~s[id="atom-1"]
  end

  test "renders with custom class" do
    result = render_component(&dm_art_atom/1, %{id: "a", class: "mx-auto"})

    assert result =~ "mx-auto"
  end

  test "renders with rest attributes" do
    result =
      render_component(&dm_art_atom/1, %{
        id: "a",
        "data-testid": "my-atom"
      })

    assert result =~ "data-testid=\"my-atom\""
  end
end
