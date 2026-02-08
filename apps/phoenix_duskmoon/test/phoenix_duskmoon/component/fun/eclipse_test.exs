defmodule PhoenixDuskmoon.Component.Fun.EclipseTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Fun.Eclipse

  test "renders eclipse component" do
    result =
      render_component(&dm_fun_eclipse/1, %{
        id: "eclipse-1"
      })

    assert result =~ "dm-fun-eclipse"
    assert result =~ ~s[id="eclipse-1"]
  end

  test "renders eclipse with size" do
    result =
      render_component(&dm_fun_eclipse/1, %{
        id: "eclipse-2",
        size: "large"
      })

    assert result =~ "dm-fun-eclipse"
  end

  test "renders eclipse with custom bg color" do
    result =
      render_component(&dm_fun_eclipse/1, %{
        id: "eclipse-3",
        bg_color: "#000000"
      })

    assert result =~ "dm-fun-eclipse"
  end

  test "renders eclipse with animation speed" do
    result =
      render_component(&dm_fun_eclipse/1, %{
        id: "eclipse-4",
        animation_speed: 2.0
      })

    assert result =~ "dm-fun-eclipse"
  end
end
