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

  test "renders eclipse with dm-fun-eclipse class for all sizes" do
    for size <- ~w(small medium large) do
      result = render_component(&dm_fun_eclipse/1, %{id: "e", size: size})
      assert result =~ "dm-fun-eclipse"
    end
  end

  test "renders eclipse with style attribute containing CSS variables" do
    result = render_component(&dm_fun_eclipse/1, %{id: "e"})

    # CSS #{} interpolation doesn't work in render_component, but the style attr is present
    assert result =~ "style="
    assert result =~ "--size:"
    assert result =~ "--bg-color:"
  end

  test "renders eclipse with default animation speed durations" do
    result = render_component(&dm_fun_eclipse/1, %{id: "e"})

    # Default speed 1.0: layer 1 = 30s, layer 2/3 = 20s, layer 4/5 = 40s
    assert result =~ "animation-duration: 30s"
    assert result =~ "animation-duration: 20s"
    assert result =~ "animation-duration: 40s"
  end

  test "renders eclipse with faster animation speed" do
    result = render_component(&dm_fun_eclipse/1, %{id: "e", animation_speed: 2.0})

    # Speed 2.0: layer 1 = 15s, layer 2/3 = 10s, layer 4/5 = 20s
    assert result =~ "animation-duration: 15s"
    assert result =~ "animation-duration: 10s"
    assert result =~ "animation-duration: 20s"
  end

  test "renders eclipse with slower animation speed" do
    result = render_component(&dm_fun_eclipse/1, %{id: "e", animation_speed: 0.5})

    # Speed 0.5: layer 1 = 60s, layer 2/3 = 40s, layer 4/5 = 80s
    assert result =~ "animation-duration: 60s"
    assert result =~ "animation-duration: 40s"
    assert result =~ "animation-duration: 80s"
  end

  test "renders eclipse layer-6 as static layer without inline animation-duration" do
    result = render_component(&dm_fun_eclipse/1, %{id: "e"})

    # layer-6 is the static layer — rendered as a plain div without inline style
    assert result =~ ~s[class="layer layer-6"]
  end

  test "renders eclipse with custom class" do
    result = render_component(&dm_fun_eclipse/1, %{id: "e", class: "mx-auto"})

    assert result =~ "mx-auto"
    assert result =~ "dm-fun-eclipse"
  end

  test "renders eclipse with rest attributes" do
    result =
      render_component(&dm_fun_eclipse/1, %{
        id: "e",
        "data-testid": "my-eclipse",
        "aria-hidden": "true"
      })

    assert result =~ "data-testid=\"my-eclipse\""
    assert result =~ "aria-hidden=\"true\""
  end

  test "renders all 5 animated layers with animation-duration" do
    result = render_component(&dm_fun_eclipse/1, %{id: "e"})

    # Count layers with animation-duration (5 animated layers, layer-6 is static)
    count = length(String.split(result, "animation-duration:")) - 1
    assert count == 5
  end

  test "renders eclipse layer HTML comments" do
    result = render_component(&dm_fun_eclipse/1, %{id: "e"})

    assert result =~ "Fast rotating layer"
    assert result =~ "Static background layer"
  end
end
