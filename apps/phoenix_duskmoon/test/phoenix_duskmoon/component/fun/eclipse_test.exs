defmodule PhoenixDuskmoon.Component.Fun.EclipseTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Fun.Eclipse

  test "renders eclipse with required id" do
    result = render_component(&dm_fun_eclipse/1, %{id: "eclipse-1"})

    assert result =~ "dm-fun-eclipse"
    assert result =~ ~s[id="eclipse-1"]
  end

  test "renders eclipse with 6 animation layers" do
    result = render_component(&dm_fun_eclipse/1, %{id: "eclipse-2"})

    assert result =~ "layer-1"
    assert result =~ "layer-2"
    assert result =~ "layer-3"
    assert result =~ "layer-4"
    assert result =~ "layer-5"
    assert result =~ "layer-6"
  end

  test "renders eclipse with small size" do
    result = render_component(&dm_fun_eclipse/1, %{id: "eclipse-3", size: "small"})

    assert result =~ "dm-fun-eclipse"
  end

  test "renders eclipse with large size" do
    result = render_component(&dm_fun_eclipse/1, %{id: "eclipse-4", size: "large"})

    assert result =~ "dm-fun-eclipse"
  end

  test "renders eclipse with custom bg_color" do
    result = render_component(&dm_fun_eclipse/1, %{id: "eclipse-5", bg_color: "#000000"})

    assert result =~ "dm-fun-eclipse"
  end

  test "renders eclipse with default animation speed durations" do
    result = render_component(&dm_fun_eclipse/1, %{id: "eclipse-6"})

    # Default speed 1.0: layer 1 = 30s, layer 2/3 = 20s, layer 4/5 = 40s
    assert result =~ "animation-duration: 30s"
    assert result =~ "animation-duration: 20s"
    assert result =~ "animation-duration: 40s"
  end

  test "renders eclipse with faster animation speed" do
    result = render_component(&dm_fun_eclipse/1, %{id: "eclipse-7", animation_speed: 2.0})

    # Speed 2.0: layer 1 = 15s, layer 2/3 = 10s, layer 4/5 = 20s
    assert result =~ "animation-duration: 15s"
    assert result =~ "animation-duration: 10s"
    assert result =~ "animation-duration: 20s"
  end

  test "renders eclipse with custom class" do
    result = render_component(&dm_fun_eclipse/1, %{id: "eclipse-8", class: "mx-auto"})

    assert result =~ "mx-auto"
    assert result =~ "dm-fun-eclipse"
  end

  test "renders eclipse with rest attributes" do
    result =
      render_component(&dm_fun_eclipse/1, %{
        id: "eclipse-9",
        "data-testid": "my-eclipse",
        "aria-hidden": "true"
      })

    assert result =~ "data-testid=\"my-eclipse\""
    assert result =~ "aria-hidden=\"true\""
  end

  test "renders eclipse layer-6 as static layer" do
    result = render_component(&dm_fun_eclipse/1, %{id: "eclipse-10"})

    # layer-6 is the static background layer
    assert result =~ "layer layer-6"
  end
end
