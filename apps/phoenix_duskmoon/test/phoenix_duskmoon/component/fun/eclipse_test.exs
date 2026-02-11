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

  test "renders eclipse with correct size pixel values for each preset" do
    for {size, expected_px} <- [{"small", "400"}, {"medium", "600"}, {"large", "800"}] do
      result = render_component(&dm_fun_eclipse/1, %{id: "e", size: size})
      assert result =~ "--size: #{expected_px}px"
    end
  end

  test "renders eclipse with custom bg_color in CSS variable" do
    result = render_component(&dm_fun_eclipse/1, %{id: "e", bg_color: "#1a1a2e"})
    assert result =~ "--bg-color: #1a1a2e"
  end

  test "renders eclipse with default bg_color" do
    result = render_component(&dm_fun_eclipse/1, %{id: "e"})
    assert result =~ "--bg-color: #09090b"
  end

  test "renders eclipse animation durations proportional to speed 4.0" do
    result = render_component(&dm_fun_eclipse/1, %{id: "e", animation_speed: 4.0})

    assert result =~ "animation-duration: 8s"
    assert result =~ "animation-duration: 5s"
    assert result =~ "animation-duration: 10s"
  end

  test "renders eclipse with all attributes combined" do
    result =
      render_component(&dm_fun_eclipse/1, %{
        id: "e-full",
        size: "large",
        bg_color: "#000000",
        animation_speed: 2.0,
        class: "my-eclipse",
        "data-testid": "eclipse-combo"
      })

    assert result =~ ~s[id="e-full"]
    assert result =~ "--size: 800px"
    assert result =~ "--bg-color: #000000"
    assert result =~ "animation-duration: 15s"
    assert result =~ "my-eclipse"
    assert result =~ "data-testid=\"eclipse-combo\""
  end

  test "renders eclipse with very slow animation speed 0.25" do
    result = render_component(&dm_fun_eclipse/1, %{id: "e", animation_speed: 0.25})

    assert result =~ "animation-duration: 120s"
    assert result =~ "animation-duration: 80s"
    assert result =~ "animation-duration: 160s"
  end

  test "renders eclipse with small size" do
    result = render_component(&dm_fun_eclipse/1, %{id: "e", size: "small"})

    assert result =~ "--size: 400px"
  end

  test "renders eclipse layers each have layer class" do
    result = render_component(&dm_fun_eclipse/1, %{id: "e"})

    for i <- 1..6 do
      assert result =~ ~s[class="layer layer-#{i}"]
    end
  end

  test "renders eclipse with nil class (default)" do
    result = render_component(&dm_fun_eclipse/1, %{id: "e"})

    assert result =~ "dm-fun-eclipse"
  end

  test "renders eclipse with fractional animation speed rounding" do
    # Speed 3.0: 30/3 = 10, 20/3 = 7 (rounded), 40/3 = 13 (rounded)
    result = render_component(&dm_fun_eclipse/1, %{id: "e", animation_speed: 3.0})

    assert result =~ "animation-duration: 10s"
    assert result =~ "animation-duration: 7s"
    assert result =~ "animation-duration: 13s"
  end

  test "renders eclipse medium size by default" do
    result = render_component(&dm_fun_eclipse/1, %{id: "e"})

    assert result =~ "--size: 600px"
  end
end
