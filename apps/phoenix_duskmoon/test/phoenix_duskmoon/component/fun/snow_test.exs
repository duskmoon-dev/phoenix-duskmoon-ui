defmodule PhoenixDuskmoon.Component.Fun.SnowTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Fun.Snow

  test "renders snow component" do
    result = render_component(&dm_fun_snow/1, %{id: "snow-1"})

    assert result =~ ~s[id="snow-1"]
  end

  test "renders snow with custom count" do
    result = render_component(&dm_fun_snow/1, %{id: "snow-2", count: 10})

    # With 10 snowflakes, there should be multiple snowflake elements
    assert result =~ ~s[id="snow-2"]
  end

  test "renders snow with custom color" do
    result = render_component(&dm_fun_snow/1, %{id: "snow-3", color: "#AACCFF"})

    assert result =~ "#AACCFF"
  end

  test "renders snow with unicode snowflakes" do
    result = render_component(&dm_fun_snow/1, %{id: "snow-4", use_unicode: true})

    assert result =~ ~s[id="snow-4"]
  end

  test "renders snow with custom container class" do
    result =
      render_component(&dm_fun_snow/1, %{
        id: "snow-5",
        container_class: "my-snow-container"
      })

    assert result =~ "my-snow-container"
  end
end
