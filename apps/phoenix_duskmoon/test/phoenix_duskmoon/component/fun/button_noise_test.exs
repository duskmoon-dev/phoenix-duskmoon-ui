defmodule PhoenixDuskmoon.Component.Fun.ButtonNoiseTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Fun.ButtonNoise

  test "renders button noise" do
    result =
      render_component(&dm_fun_button_noise/1, %{
        id: "noise-1",
        content: "Click me"
      })

    assert result =~ "btn-noise"
    assert result =~ ~s[data-content="Click me"]
  end

  test "renders button noise with custom font size" do
    result =
      render_component(&dm_fun_button_noise/1, %{
        id: "noise-2",
        content: "Big",
        font_size: "48px"
      })

    assert result =~ "48px"
  end

  test "renders button noise with color scheme" do
    result =
      render_component(&dm_fun_button_noise/1, %{
        id: "noise-3",
        content: "Electric",
        color_scheme: "electric"
      })

    assert result =~ "btn-noise"
  end

  test "renders button noise with custom class" do
    result =
      render_component(&dm_fun_button_noise/1, %{
        id: "noise-4",
        content: "Custom",
        class: "my-noise"
      })

    assert result =~ "my-noise"
  end
end
