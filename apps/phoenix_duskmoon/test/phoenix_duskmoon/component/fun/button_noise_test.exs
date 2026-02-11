defmodule PhoenixDuskmoon.Component.Fun.ButtonNoiseTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Fun.ButtonNoise

  test "renders button noise with required attrs" do
    result =
      render_component(&dm_fun_button_noise/1, %{
        id: "noise-1",
        content: "Click me"
      })

    assert result =~ "btn-noise"
    assert result =~ ~s[data-content="Click me"]
    assert result =~ ~s[id="noise-1"]
  end

  test "renders as a button element with type button" do
    result =
      render_component(&dm_fun_button_noise/1, %{
        id: "noise-2",
        content: "Test"
      })

    assert result =~ "<button"
    assert result =~ ~s[type="button"]
  end

  test "renders 72 animated light bars" do
    result =
      render_component(&dm_fun_button_noise/1, %{
        id: "noise-3",
        content: "Test"
      })

    # Each bar is an <i></i> element
    assert length(String.split(result, "<i>")) > 72
  end

  test "renders with default font size 24px" do
    result =
      render_component(&dm_fun_button_noise/1, %{
        id: "noise-4",
        content: "Test"
      })

    assert result =~ "font-size: 24px"
  end

  test "renders with custom font size" do
    result =
      render_component(&dm_fun_button_noise/1, %{
        id: "noise-5",
        content: "Big",
        font_size: "48px"
      })

    assert result =~ "font-size: 48px"
  end

  test "renders with default font family" do
    result =
      render_component(&dm_fun_button_noise/1, %{
        id: "noise-6",
        content: "Test"
      })

    assert result =~ "Josefin Sans"
  end

  test "renders with custom font family" do
    result =
      render_component(&dm_fun_button_noise/1, %{
        id: "noise-7",
        content: "Test",
        font_family: "Arial, sans-serif"
      })

    assert result =~ "font-family: Arial, sans-serif"
  end

  test "renders with electric color scheme" do
    result =
      render_component(&dm_fun_button_noise/1, %{
        id: "noise-8",
        content: "Electric",
        color_scheme: "electric"
      })

    assert result =~ "--primary-hue: 180"
    assert result =~ "--secondary-hue: 280"
  end

  test "renders with neon color scheme" do
    result =
      render_component(&dm_fun_button_noise/1, %{
        id: "noise-9",
        content: "Neon",
        color_scheme: "neon"
      })

    assert result =~ "--primary-hue: 300"
    assert result =~ "--secondary-hue: 60"
  end

  test "renders with default color scheme (no extra variables)" do
    result =
      render_component(&dm_fun_button_noise/1, %{
        id: "noise-10",
        content: "Default"
      })

    refute result =~ "--primary-hue"
  end

  test "renders with custom class" do
    result =
      render_component(&dm_fun_button_noise/1, %{
        id: "noise-11",
        content: "Custom",
        class: "my-noise-btn"
      })

    assert result =~ "my-noise-btn"
    assert result =~ "btn-noise"
  end

  test "renders with rest attributes" do
    result =
      render_component(&dm_fun_button_noise/1, %{
        id: "noise-12",
        content: "Test",
        "data-testid": "noise-button",
        "aria-label": "Noise effect"
      })

    assert result =~ "data-testid=\"noise-button\""
    assert result =~ "aria-label=\"Noise effect\""
  end

  test "renders exactly 72 light bars" do
    result =
      render_component(&dm_fun_button_noise/1, %{id: "noise-exact", content: "Test"})

    count = length(String.split(result, "<i></i>")) - 1
    assert count == 72
  end

  test "renders with phx_target attribute" do
    result =
      render_component(&dm_fun_button_noise/1, %{
        id: "noise-target",
        content: "Target",
        phx_target: "#component"
      })

    assert result =~ "phx-target"
  end

  test "renders with all style customizations combined" do
    result =
      render_component(&dm_fun_button_noise/1, %{
        id: "noise-combined",
        content: "Styled",
        font_size: "36px",
        font_family: "Arial, sans-serif",
        color_scheme: "electric"
      })

    assert result =~ "font-size: 36px"
    assert result =~ "font-family: Arial, sans-serif"
    assert result =~ "--primary-hue: 180"
    assert result =~ "--secondary-hue: 280"
  end

  test "renders all three color schemes correctly" do
    for {scheme, has_vars} <-
          [{"default", false}, {"electric", true}, {"neon", true}] do
      result =
        render_component(&dm_fun_button_noise/1, %{
          id: "noise-#{scheme}",
          content: "Test",
          color_scheme: scheme
        })

      if has_vars do
        assert result =~ "--primary-hue"
      else
        refute result =~ "--primary-hue"
      end
    end
  end

  test "renders data-content with special characters" do
    result =
      render_component(&dm_fun_button_noise/1, %{
        id: "noise-special",
        content: "Submit →"
      })

    assert result =~ "Submit →"
  end

  test "renders button with content text visible" do
    result =
      render_component(&dm_fun_button_noise/1, %{
        id: "noise-visible",
        content: "Visible Text"
      })

    assert result =~ "Visible Text"
  end

  test "renders button without hue variables by default" do
    result =
      render_component(&dm_fun_button_noise/1, %{
        id: "noise-no-hue",
        content: "Test"
      })

    refute result =~ "--secondary-hue"
  end

  test "renders button with both id and data-content" do
    result =
      render_component(&dm_fun_button_noise/1, %{
        id: "noise-both",
        content: "Both"
      })

    assert result =~ ~s[id="noise-both"]
    assert result =~ ~s[data-content="Both"]
  end

  test "renders button with nil class (no extra class)" do
    result =
      render_component(&dm_fun_button_noise/1, %{
        id: "noise-nil-class",
        content: "Test"
      })

    assert result =~ "btn-noise"
  end

  test "renders neon scheme with correct hue values" do
    result =
      render_component(&dm_fun_button_noise/1, %{
        id: "noise-neon-check",
        content: "Neon",
        color_scheme: "neon"
      })

    assert result =~ "--primary-hue: 300"
    assert result =~ "--secondary-hue: 60"
  end
end
